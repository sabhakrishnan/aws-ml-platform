variable "bucket_name_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
}

variable "project_name" {
  description = "Project name used for tags"
  type        = string
}

variable "environment" {
  description = "Environment tag value"
  type        = string
}
