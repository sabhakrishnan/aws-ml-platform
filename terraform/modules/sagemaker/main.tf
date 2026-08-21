// IAM execution role for Amazon SageMaker training jobs.
// SageMaker can assume this role to pull the training image,
// read curated training data, write model artifacts,
// and publish training logs.

data "aws_iam_policy_document" "sagemaker_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "sagemaker" {
  name               = "aws-ml-platform-sagemaker-role"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume_role.json

  description = "Execution role for AWS ML Platform SageMaker training jobs"

  tags = {
    Name        = "aws-ml-platform-sagemaker-role"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "sagemaker_policy" {

  # ---------------------------------------------------------
  # S3 - Read curated training data
  # ---------------------------------------------------------

  statement {
    sid    = "S3ListTrainingBucket"
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

      values = [
        "curated/hour",
        "curated/hour/*",
        "sagemaker/output",
        "sagemaker/output/*"
      ]
    }
  }

  statement {
    sid    = "S3ReadTrainingData"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${var.bucket_arn}/curated/hour/*"
    ]
  }

  # ---------------------------------------------------------
  # S3 - Write SageMaker model artifacts
  # ---------------------------------------------------------

  statement {
    sid    = "S3WriteModelArtifacts"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:AbortMultipartUpload"
    ]

    resources = [
      "${var.bucket_arn}/sagemaker/output/*"
    ]
  }

  # ---------------------------------------------------------
  # ECR - Pull training image
  # ---------------------------------------------------------

  statement {
    sid    = "ECRPullTrainingImage"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer"
    ]

    resources = [
      var.ecr_repository_arn
    ]
  }

  statement {
    sid    = "ECRAuthorization"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = [
      "*"
    ]
  }

  # ---------------------------------------------------------
  # CloudWatch Logs
  # ---------------------------------------------------------

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
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/sagemaker/*"
    ]
  }
}

resource "aws_iam_role_policy" "sagemaker_policy_attach" {
  name   = "aws-ml-platform-sagemaker-policy"
  role   = aws_iam_role.sagemaker.id
  policy = data.aws_iam_policy_document.sagemaker_policy.json
}
