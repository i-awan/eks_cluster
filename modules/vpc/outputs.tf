# modules/vpc/outputs.tf

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "route_table_ids" {
  description = "Route table IDs for private subnets"
  value       = aws_route_table.private[*].id
}


