variable "bucket_arn" {
  description = "ARN of the S3 bucket used by the ML platform"
  type        = string
}

variable "aws_region" {
  description = "AWS region where the platform is deployed"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}