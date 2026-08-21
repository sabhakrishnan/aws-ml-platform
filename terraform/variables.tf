variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used for tags"
  type        = string
  default     = "aws-ml-platform"
}

variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "aws-ml-platform-bucket"
}

variable "account_id" {
  description = "AWS account ID used to construct IAM resource ARNs"
  type        = string
}

variable "glue_database_name" {
  description = "Name of the Glue Data Catalog database"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}
