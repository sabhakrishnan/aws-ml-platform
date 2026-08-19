# Project Instructions

## Purpose

This repository contains a small end-to-end AWS ML platform for an interview assessment.

The intended flow is:

Public Dataset
    ↓
S3 Raw Data
    ↓
AWS Glue ETL
    ↓
S3 Curated Parquet
    ↓
Glue Data Catalog
    ↓
Athena
    ↓
SageMaker Training
    ↓
S3 Model Artifact
    ↓
SageMaker Endpoint

## Core Rules

- All AWS infrastructure must be created using Terraform.
- Do not create AWS resources manually through the AWS Console.
- Do not hardcode AWS credentials.
- Use IAM roles and least-privilege permissions.
- Keep the architecture small and cost-conscious.
- Avoid unnecessary AWS services and infrastructure.
- Do not introduce EKS, MWAA, Airflow, NAT Gateway, Feature Store, EventBridge, Lambda, or complex VPC infrastructure unless explicitly required.
- Raw and curated data must be separated.
- Curated data must be stored as Parquet.
- Athena must query the curated dataset.
- SageMaker training must consume the curated output produced by the data pipeline.
- Do not create a separate copy of the dataset for ML training.
- Code must be simple enough to explain during an interview.
- Prefer explicit, readable implementation over clever abstractions.

## Agent Behavior

Before making significant changes:

1. Explain what will be changed.
2. Explain why the change is required.
3. Identify AWS resources involved.
4. Identify security and cost implications.
5. Then implement the change.

After implementation:

1. Run formatting tools where applicable.
2. Run validation/tests where applicable.
3. Report what was verified.
4. Do not claim that an AWS resource exists unless it has actually been created and verified.

Do not implement future tasks unless explicitly requested.