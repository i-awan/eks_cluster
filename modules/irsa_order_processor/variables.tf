variable "name" {
  description = "Name prefix"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "oidc_url" {
  description = "OIDC issuer URL (without https://)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "service_account_name" {
  description = "Name of the service account"
  type        = string
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
}
