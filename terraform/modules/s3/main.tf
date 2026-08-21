resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "ml_platform" {
  bucket = format("%s-%s", var.bucket_name_prefix, random_id.bucket_suffix.hex)

  tags = {
    Name        = var.bucket_name_prefix
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

// Versioning as separate resource
resource "aws_s3_bucket_versioning" "ml_platform" {
  bucket = aws_s3_bucket.ml_platform.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ml_platform" {
  bucket = aws_s3_bucket.ml_platform.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ml_platform" {
  bucket = aws_s3_bucket.ml_platform.id

  rule {
    id     = "raw-expire"
    status = "Enabled"

    filter {
      prefix = "raw/"
    }

    expiration {
      days = 365
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "noncurrent-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.ml_platform.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
