output "glue_role_arn" {
  description = "ARN of the AWS Glue execution role"
  value       = aws_iam_role.glue.arn
}

output "glue_role_name" {
  description = "Name of the AWS Glue execution role"
  value       = aws_iam_role.glue.name
}
