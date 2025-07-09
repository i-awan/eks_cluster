variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "eks_role_name" {
  type = string
}

variable "endpoint_public_access" {
  type    = bool
  default = false
}

variable "endpoint_private_access" {
  type    = bool
  default = true
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}
