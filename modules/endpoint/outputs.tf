output "interface_dns" {
  value = aws_vpc_endpoint.this.dns_entry[0].dns_name
}
