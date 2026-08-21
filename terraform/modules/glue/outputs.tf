output "database_name" {
  description = "Name of the Glue Data Catalog database"
  value       = aws_glue_catalog_database.ml_platform.name
}

output "crawler_name" {
  description = "Glue crawler name"
  value       = aws_glue_crawler.ml_platform.name
}

output "crawler_role_arn" {
  description = "IAM role ARN used by the Glue crawler"
  value       = aws_iam_role.crawler.arn
}

output "curated_crawler_name" {
  description = "Name of the curated data crawler"
  value       = aws_glue_crawler.curated.name
}