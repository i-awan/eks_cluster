variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "nlb_arn" {
  type = string
}

variable "acceptance_required" {
  type    = bool
  default = false
}

variable "security_group_ids" {
  type = list(string)
}

variable "zone_id" {
  type = string
}

variable "dns_name" {
  type = string
}

variable "private_dns_enabled" {
  type    = bool
  default = false
}
