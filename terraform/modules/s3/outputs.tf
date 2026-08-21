output "bucket_name" {
  description = "S3 bucket name (id)"
  value       = aws_s3_bucket.ml_platform.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.ml_platform.arn
}
