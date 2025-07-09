output "iam_role_arn" {
  description = "ARN of the IAM role associated with the order-processor service account"
  value       = aws_iam_role.order_processor_role.arn
}
