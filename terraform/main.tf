// Root module: compose infrastructure modules.

module "s3" {
  source             = "./modules/s3"
  bucket_name_prefix = var.bucket_name_prefix
  project_name       = var.project_name
  environment        = var.environment
}

module "iam" {
  source = "./modules/iam"

  bucket_arn   = module.s3.bucket_arn
  aws_region   = var.aws_region
  account_id   = var.account_id
  project_name = var.project_name
  environment  = var.environment
}

module "glue" {

  source       = "./modules/glue"
  project_name = var.project_name

  database_name = var.glue_database_name

  bucket_name = module.s3.bucket_name
  bucket_arn  = module.s3.bucket_arn

  aws_region = var.aws_region
  account_id = var.aws_account_id
}

module "glue_job" {
  source = "./modules/glue_job"

  job_name = "aws-ml-platform-hour-etl"

  role_arn = module.iam.glue_role_arn

  script_location = "s3://${module.s3.bucket_name}/scripts/hour_etl.py"
}

module "sagemaker" {
  source = "./modules/sagemaker"

  project_name = var.project_name
  environment  = var.environment

  bucket_arn = module.s3.bucket_arn

  ecr_repository_arn = "arn:aws:ecr:${var.aws_region}:${var.account_id}:repository/aws-ml-platform-training"

  aws_region = var.aws_region
  account_id = var.account_id
}

// Tell Terraform that the existing S3 resources were moved into the S3 module.

moved {
  from = random_id.bucket_suffix
  to   = module.s3.random_id.bucket_suffix
}

moved {
  from = aws_s3_bucket.ml_platform
  to   = module.s3.aws_s3_bucket.ml_platform
}

moved {
  from = aws_s3_bucket_versioning.ml_platform
  to   = module.s3.aws_s3_bucket_versioning.ml_platform
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.ml_platform
  to   = module.s3.aws_s3_bucket_server_side_encryption_configuration.ml_platform
}

moved {
  from = aws_s3_bucket_public_access_block.block
  to   = module.s3.aws_s3_bucket_public_access_block.block
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.ml_platform
  to   = module.s3.aws_s3_bucket_lifecycle_configuration.ml_platform
}

// Tell Terraform that the existing IAM resources were moved into the IAM module.

moved {
  from = aws_iam_role.glue
  to   = module.iam.aws_iam_role.glue
}

moved {
  from = aws_iam_role_policy.glue_policy_attach
  to   = module.iam.aws_iam_role_policy.glue_policy_attach
}