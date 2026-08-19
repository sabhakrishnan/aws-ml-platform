# AWS ML Platform Architecture

## Objective

Build a small end-to-end AWS ML platform using Terraform.

## Data Flow

Public Dataset
→ S3 Raw
→ AWS Glue ETL
→ S3 Curated Parquet
→ Glue Data Catalog
→ Athena
→ SageMaker Training
→ S3 Model Artifact
→ SageMaker Endpoint

## AWS Services

- Amazon S3
- AWS Glue
- AWS Glue Data Catalog
- Amazon Athena
- Amazon SageMaker
- IAM
- CloudWatch
- Terraform

## Dataset

UCI Bike Sharing Dataset.

The dataset provides timestamp information, categorical attributes, numerical features, and a bike rental count that can be used as the prediction target.

## Design Principles

- All AWS infrastructure is managed by Terraform.
- Raw and curated data are separated.
- Curated data is stored as Parquet.
- Athena queries the curated dataset.
- SageMaker training consumes the curated dataset produced by Task 2.
- No separate copy of the dataset is maintained for ML training.
- Infrastructure should remain small and cost-conscious.
- IAM should follow least privilege.