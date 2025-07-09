variable "name" {
  description = "Name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to launch the bastion in"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the bastion instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the bastion host"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID for EKS IAM policy scoping"
  type        = string
}
