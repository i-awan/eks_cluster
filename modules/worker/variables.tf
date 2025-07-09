variable "name" {
  type        = string
  description = "Name prefix for resources"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name to attach worker nodes to"
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type for worker nodes"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to associate"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for ASG placement"
}

variable "desired_capacity" {
  type        = number
  default     = 1
}

variable "min_size" {
  type        = number
  default     = 1
}

variable "max_size" {
  type        = number
  default     = 3
}
