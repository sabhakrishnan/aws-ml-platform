resource "aws_glue_crawler" "curated" {
  name          = "${var.project_name}-curated-crawler"
  role          = aws_iam_role.crawler.arn
  database_name = aws_glue_catalog_database.ml_platform.name

  s3_target {
    path = "s3://${var.bucket_name}/curated/hour/"
  }
}

data "aws_iam_policy_document" "curated_crawler_policy" {
  statement {
    sid    = "S3ReadCurated"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::aws-ml-platform-bucket-c40fb655"
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "curated/*",
        "curated/"
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
      "arn:aws:s3:::aws-ml-platform-bucket-c40fb655/curated/hour/*"
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
      "glue:BatchCreatePartition"
    ]

    resources = [
      "arn:aws:glue:us-east-1:940104439577:catalog",
      "arn:aws:glue:us-east-1:940104439577:database/aws_ml_platform",
      "arn:aws:glue:us-east-1:940104439577:table/aws_ml_platform/*"
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
      "arn:aws:logs:us-east-1:940104439577:log-group:/aws-glue/crawlers",
      "arn:aws:logs:us-east-1:940104439577:log-group:/aws-glue/crawlers:*"
    ]
  }
}