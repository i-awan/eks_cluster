variable "name" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "attach_to_tgw" {
  type    = bool
  default = false
}

variable "tgw_id" {
  type    = string
  default = ""
}
