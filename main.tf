resource "aws_iam_role" "app" {
  name = "${join(var.separator, compact(list(var.customer, var.project, var.app, var.environment)))}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "app" {
  name = "${join(var.separator, compact(list(var.customer, var.project, var.app, var.environment)))}"
  role = "${aws_iam_role.app.name}"
}

resource "aws_security_group" "app" {
  name        = "${join(var.separator, compact(list(var.customer, var.project, var.environment, var.app)))}"
  description = "Load Balancer Security Group"
  vpc_id      = "${var.vpc_id}"

  tags {
    "Name"        = "${join(var.separator, compact(list(var.customer, var.project, var.environment, var.app)))}"
    "Terraform"   = "true"
    "Customer"    = "${length(var.customer) > 0 ? var.customer : "N/A"}"
    "Project"     = "${length(var.project) > 0 ? var.project : "N/A"}"
    "Environment" = "${var.environment}"
  }
}

resource "aws_security_group_rule" "app_ingress_tcp_80_cidr" {
  security_group_id = "${aws_security_group.app.id}"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = "${var.http_cidr_ingress}"
  type              = "ingress"
}

resource "aws_security_group_rule" "app_egress_tcp_80" {
  security_group_id = "${aws_security_group.app.id}"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = "${var.http_cidr_egress}"
  type              = "egress"
}

resource "aws_elastic_beanstalk_environment" "app" {
  name                = "${join(var.separator, compact(list(var.customer, var.project, var.app, var.environment)))}"
  application         = "${var.ebs_app}"
  solution_stack_name = "${var.app_solution_stack}"
  tier                = "${var.app_tier}"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpc_id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${join(",", var.vpc_ec2_subnets)}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${join(",", var.vpc_elb_subnets)}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "${var.vpc_elb_scheme}"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "${var.rolling_update_enabled}"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "${var.rolling_update_type}"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "CrossZone"
    value     = "true"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SecurityGroups"
    value     = "${aws_security_group.app.id}"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = "${aws_security_group.app.id}"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "LoadBalancerHTTPSPort"
    value     = "443"
  }

  setting {
    namespace = "aws:elb:loadbalancer"
    name      = "SSLCertificateId"
    value     = "${var.elb_ssl_cert}"
  }

  setting {
    namespace = "aws:elb:policies"
    name      = "ConnectionDrainingEnabled"
    value     = "${var.elb_connection_draining_enabled}"
  }

  setting {
    namespace = "aws:elb:policies"
    name      = "ConnectionDrainingTimeout"
    value     = "${var.elb_connection_draining_timeout}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "${var.ec2_key_name}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SSHSourceRestriction"
    value     = "tcp,22,22,${var.ssh_source_restriction}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.ec2_instance_type}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.app.name}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "${var.asg_min_size}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "${var.asg_max_size}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerThreshold"
    value     = "${var.asg_trigger_lower_threshold}"
  }

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperThreshold"
    value     = "${var.asg_trigger_upper_threshold}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = "${var.healthcheck_url}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Endpoint"
    value     = "${var.notification_endpoint}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "${var.logs_stream}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = "${var.logs_delete_on_terminate}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "${var.logs_retention}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:container:nodejs"
    name      = "NodeVersion"
    value     = "${var.node_version}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:container:nodejs"
    name      = "NodeCommand"
    value     = "${var.node_command}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "NODE_ENV"
    value     = "${var.node_env}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DB_URI"
    value     = "${var.db_uri}"
  }

  tags {
    "Terraform"   = "true"
    "Customer"    = "${length(var.customer) > 0 ? var.customer : "N/A"}"
    "Environment" = "${var.environment}"
    "Project"     = "${length(var.project) > 0 ? var.project : "N/A"}"
  }
}
