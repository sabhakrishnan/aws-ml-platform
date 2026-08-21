
variable "database_name" {
  description = "Glue Data Catalog database name"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket containing the raw data"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket containing the raw data"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "project_name" {
  description = "Project name used for Glue resources"
  type        = string
}
