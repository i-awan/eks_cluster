variable "name" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = list(string)
}
variable "listener_port" {
  type = number
}
variable "target_port" {
  type = number
}
variable "target_ips" {
  type = list(string)
}
variable "target_az_map" {
  type = map(string)
}
