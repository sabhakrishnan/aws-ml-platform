// IAM role for Glue ETL jobs with least-privilege permissions.
// The Glue service is trusted to assume this role.
// Permissions are restricted to the ML platform S3 bucket,
// Glue Data Catalog, and CloudWatch Logs.

data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "glue" {
  name               = "aws-ml-platform-glue-role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json
  description        = "Execution role for AWS Glue ETL jobs (least-privilege)"

  tags = {
    Name        = "aws-ml-platform-glue-role"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "glue_policy" {

  statement {
    sid    = "S3ListCuratedBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      var.bucket_arn
    ]
  }

  statement {
    sid    = "S3ReadJobScript"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${var.bucket_arn}/scripts/*"
    ]
  }

  statement {
    sid    = "S3ReadRaw"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${var.bucket_arn}/raw/*"
    ]
  }

  statement {
    sid    = "S3ListRawBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      var.bucket_arn
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["raw/*", "raw/"]
    }
  }

  statement {
    sid    = "S3WriteCurated"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload"
    ]

    resources = [
      "${var.bucket_arn}/curated/*",
      "${var.bucket_arn}/curated_$folder$"
    ]
  }

  statement {
    sid    = "GlueCatalogAccess"
    effect = "Allow"

    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:CreatePartition",
      "glue:BatchCreatePartition",
      "glue:GetPartitions",
    ]

    resources = [
      "arn:aws:glue:${var.aws_region}:${var.account_id}:catalog",
      "arn:aws:glue:${var.aws_region}:${var.account_id}:database/*",
      "arn:aws:glue:${var.aws_region}:${var.account_id}:table/*/*"
    ]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = [
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws-glue/*"
    ]
  }
}

resource "aws_iam_role_policy" "glue_policy_attach" {
  name   = "aws-ml-platform-glue-policy"
  role   = aws_iam_role.glue.id
  policy = data.aws_iam_policy_document.glue_policy.json
}
