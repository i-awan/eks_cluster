variable "aws_region" {
  type        = string
  description = "AWS region to deploy the EKS cluster"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "eks_role_name" {
  type        = string
  description = "IAM role name for the EKS cluster"
}
