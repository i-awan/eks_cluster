output "dns_name" {
  description = "DNS name of the NLB"
  value       = aws_lb.this.dns_name
}

output "arn" {
  description = "ARN of the NLB"
  value       = aws_lb.this.arn
}
