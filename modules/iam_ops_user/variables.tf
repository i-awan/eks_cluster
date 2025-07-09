variable "name" {
  description = "Name prefix"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "service_account_name" {
  description = "Service account name"
  type        = string
}

variable "eks_oidc_provider" {
  description = "OIDC provider URL from EKS"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}
