output "sagemaker_role_arn" {
  description = "IAM role ARN used by SageMaker training jobs"
  value       = aws_iam_role.sagemaker.arn
}

output "sagemaker_role_name" {
  description = "IAM role name used by SageMaker training jobs"
  value       = aws_iam_role.sagemaker.name
}
