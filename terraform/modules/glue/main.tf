resource "aws_glue_catalog_database" "ml_platform" {
  name        = var.database_name
  description = "AWS ML Platform Glue Data Catalog database"

  create_table_default_permission {
    permissions = ["ALL"]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "crawler_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "crawler" {
  name               = "aws-ml-platform-crawler-role"
  assume_role_policy = data.aws_iam_policy_document.crawler_assume_role.json
  description        = "Execution role for AWS Glue crawler"
}

data "aws_iam_policy_document" "crawler_policy" {

  statement {
    sid    = "S3ReadCurated"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}"
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "curated/",
        "curated/*"
      ]
    }
  }

  statement {
    sid    = "S3ReadCuratedObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}/curated/hour/*"
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
      "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/crawlers",
      "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/crawlers:*"
    ]
  }
  statement {
    sid    = "S3ReadRaw"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      var.bucket_arn,
      "${var.bucket_arn}/raw/*"
    ]
  }

  statement {
    sid    = "GlueCatalogAccess"
    effect = "Allow"

    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:GetTable",
      "glue:GetTables",
      "glue:CreatePartition",
      "glue:BatchCreatePartition"
    ]

    resources = [
      "arn:aws:glue:${var.aws_region}:${var.account_id}:catalog",
      "arn:aws:glue:${var.aws_region}:${var.account_id}:database/${var.database_name}",
      "arn:aws:glue:${var.aws_region}:${var.account_id}:table/${var.database_name}/*"
    ]
  }
}

resource "aws_iam_role_policy" "crawler_policy" {
  name   = "aws-ml-platform-crawler-policy"
  role   = aws_iam_role.crawler.id
  policy = data.aws_iam_policy_document.crawler_policy.json
}

resource "aws_glue_crawler" "ml_platform" {
  name          = "aws-ml-platform-crawler"
  role          = aws_iam_role.crawler.arn
  database_name = aws_glue_catalog_database.ml_platform.name

  s3_target {
    path = "s3://${var.bucket_name}/raw/"
  }
}