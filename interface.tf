variable "project" {
  description = "Project name."
  default     = ""
}

variable "customer" {
  description = "Customer name."
  default     = ""
}

variable "environment" {
  description = "Environment name."
}

variable "app" {
  description = "App name."
}

variable "ebs_app" {
  description = "EBS App name."
}

variable "app_solution_stack" {
  description = "Solution stack to be used."
}

variable "app_tier" {
  description = "Webserver or Worker."
  default     = "WebServer"
}

variable "separator" {
  description = "Separator to be used in naming."
  default     = "-"
}

variable "vpc_id" {
  description = "VPC id."
}

variable "vpc_ec2_subnets" {
  type        = "list"
  description = "Subnets for autoscaling group."
}

variable "vpc_elb_subnets" {
  type        = "list"
  description = "Subnets for loadbalancer."
}

variable "vpc_elb_scheme" {
  description = "internal or external."
  default     = ""
}

variable "rolling_update_enabled" {
  description = "Should we update in rolling manner."
  default     = "true"
}

variable "rolling_update_type" {
  default     = "Time"
  description = "Rolling update type."
}

variable "http_cidr_ingress" {
  description = "CIDR whitelist for 80 port."
  default     = ["0.0.0.0/0"]
}

variable "http_cidr_egress" {
  description = "CIDR whitelist outbound ELB connectivity."
  default     = ["0.0.0.0/0"]
}

variable "elb_connection_draining_enabled" {
  default     = "true"
  description = "Should connection draining be enabled."
}

variable "elb_connection_draining_timeout" {
  default     = 180
  description = "Connection draining timeout in seconds."
}

variable "elb_ssl_cert" {
  description = "ARN of ceriticate."
}

variable "ec2_key_name" {
  default     = ""
  description = "SSH Key Name to insert."
}

variable "ec2_instance_type" {
  description = "EC2 instance type."
}

variable "asg_min_size" {
  default     = 1
  description = "Minimum size of ASG group."
}

variable "asg_max_size" {
  default     = 1
  description = "Maximum size of ASG group."
}

variable "healthcheck_url" {
  default     = "TCP:80"
  description = "Application healthcheck URL."
}

variable "notification_endpoint" {
  default     = ""
  description = "Notification endpoint."
}

variable "ssh_source_restriction" {
  default     = "0.0.0.0/0"
  description = "CIDR SSH access whitelist."
}

variable "logs_stream" {
  default     = "false"
  description = "Should logs be published in CloudWatch."
}

variable "logs_delete_on_terminate" {
  default     = "false"
  description = "Should logs be removed from CloudWatch when environment is terminated."
}

variable "logs_retention" {
  default     = 7
  description = "CloudWatch logs retention in days."
}

variable "node_version" {
  description = "Node.js version to use."
}

variable "node_command" {
  default     = ""
  description = "Command used to starte the Node.js application."
}

variable "node_env" {
  default     = ""
  description = "NODE_ENV environment variable."
}

variable "db_uri" {
  default     = ""
  description = "DB_URI environment variable."
}

variable "asg_trigger_breach_duration" {
  description = "Amount of time, in minutes, a metric can be beyond its defined limit before the trigger fires."
  default     = 5
}

variable "asg_trigger_lower_breach_scale_increment" {
  description = "How many Amazon EC2 instances to remove when performing a scaling activity."
  default     = -1
}

variable "asg_trigger_lower_threshold" {
  default     = "2000000"
  description = "If the measurement falls below this number for the breach duration, a trigger is fired."
}

variable "asg_trigger_measure_name" {
  default     = "NetworkOut"
  description = "Metric used for your Auto Scaling trigger."
}

variable "asg_trigger_period" {
  default     = 5
  description = "Specifies how frequently Amazon CloudWatch measures the metrics for your trigger."
}

variable "asg_trigger_statistic" {
  default     = "Average"
  description = "Statistic the trigger should use, such as Average."
}

variable "asg_trigger_unit" {
  default     = "Bytes"
  description = "Unit for the trigger measurement, such as Bytes."
}

variable "asg_trigger_upper_breach_scale_increment" {
  description = "How many Amazon EC2 instances to add when performing a scaling activity."
  default     = 1
}

variable "asg_trigger_upper_threshold" {
  default     = "6000000"
  description = "If the measurement is higher than this number for the breach duration, a trigger is fired."
}

output "role-name" {
  description = "IAM role name."
  value       = "${aws_iam_role.app.name}"
}

output "app-fqdn" {
  value       = "${lower(aws_elastic_beanstalk_environment.app.cname)}"
  description = "Application FQDN."
}
