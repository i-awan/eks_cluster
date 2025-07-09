variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "routable_cidr" {
  description = "CIDR block for the routable VPC"
  type        = string
}

variable "non_routable_cidr" {
  description = "CIDR block for the non-routable VPC"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to spread resources across"
  type        = list(string)
}

variable "zone_name" {
  description = "Private Route 53 zone domain name"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
  type        = string
}

variable "account_id" {
  description = "AWS account ID used for IAM policies"
  type        = string
}
