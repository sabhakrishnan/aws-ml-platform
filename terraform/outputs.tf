output "aws_region" {
  description = "Configured AWS region"
  value       = var.aws_region
}

output "s3_bucket_name" {
  description = "The name (ID) of the S3 bucket created for the ML platform (from modules/s3)"
  value       = module.s3.bucket_name
}

output "glue_role_name" {
  description = "Name of the AWS Glue execution role"
  value       = module.iam.glue_role_name
}

output "glue_role_arn" {
  description = "ARN of the IAM role to be assumed by AWS Glue for ETL jobs"
  value       = module.iam.glue_role_arn
}

output "glue_database_name" {
  description = "Glue Data Catalog database name"
  value       = module.glue.database_name
}

output "glue_crawler_name" {
  description = "Glue crawler name"
  value       = module.glue.crawler_name
}

output "glue_crawler_role_arn" {
  description = "IAM role ARN used by the Glue crawler"
  value       = module.glue.crawler_role_arn
}

output "sagemaker_role_arn" {
  description = "ARN of the SageMaker execution role"
  value       = module.sagemaker.sagemaker_role_arn
}

output "sagemaker_role_name" {
  description = "Name of the SageMaker execution role"
  value       = module.sagemaker.sagemaker_role_name
}
