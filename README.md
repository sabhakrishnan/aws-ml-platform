# AWS ML Platform

An end-to-end AWS machine learning platform for processing hourly data, building curated datasets, training a machine learning model, containerizing inference, and provisioning the cloud infrastructure using Terraform.

The project demonstrates an MLOps-oriented architecture using **Amazon S3, AWS Glue, Amazon Athena, Amazon ECR, Amazon SageMaker, IAM, Docker, and Terraform**.

---

## Architecture

```text
                    ┌──────────────────────┐
                    │   Hourly Source Data │
                    │      hour.csv        │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │      Amazon S3       │
                    │    Raw Data Layer    │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │      AWS Glue        │
                    │    ETL Processing    │
                    └──────────┬───────────┘
                               │
                               ▼
                    ┌──────────────────────┐
                    │      Amazon S3       │
                    │ Curated Parquet Data │
                    └──────────┬───────────┘
                               │
                 ┌─────────────┴─────────────┐
                 │                           │
                 ▼                           ▼
        ┌─────────────────┐         ┌─────────────────┐
        │ Amazon Athena   │         │ Amazon SageMaker│
        │ Data Querying   │         │    Training     │
        └─────────────────┘         └────────┬────────┘
                                             │
                                             ▼
                                   ┌────────────────────┐
                                   │   Model Artifact   │
                                   │ RandomForestRegressor│
                                   └─────────┬──────────┘
                                             │
                                             ▼
                                   ┌────────────────────┐
                                   │     Amazon ECR     │
                                   │ Inference Container │
                                   └─────────┬──────────┘
                                             │
                                             ▼
                                   ┌────────────────────┐
                                   │ Amazon SageMaker   │
                                   │ Inference Endpoint │
                                   └────────────────────┘
```

---

## Project Objectives

The platform was designed to demonstrate the following capabilities:

* Build an AWS-based data and ML pipeline.
* Store raw and curated datasets in Amazon S3.
* Transform raw hourly data using AWS Glue.
* Store curated data in Parquet format.
* Query the curated dataset using Amazon Athena.
* Train a machine learning model using SageMaker.
* Package inference code into a Docker container.
* Store the inference container in Amazon ECR.
* Provision infrastructure using Terraform modules.
* Implement IAM roles and policies following least-privilege principles.
* Validate the inference container locally before deployment.
* Separate infrastructure, data processing, training, and inference components.

---

## Technology Stack

| Component              | Technology            |
| ---------------------- | --------------------- |
| Cloud                  | AWS                   |
| Infrastructure as Code | Terraform             |
| Object Storage         | Amazon S3             |
| ETL                    | AWS Glue              |
| Query Engine           | Amazon Athena         |
| ML Training            | Amazon SageMaker      |
| Container Registry     | Amazon ECR            |
| Containerization       | Docker                |
| ML Framework           | Scikit-learn          |
| Model                  | RandomForestRegressor |
| Programming            | Python                |
| Data Format            | CSV / Parquet         |
| Version Control        | Git / GitHub          |

---

## Repository Structure

```text
aws-ml-platform/
│
├── .github/
│   └── copilot-instructions.md
│
├── docs/
│   └── architecture.md
│
├── data_pipeline/
│   └── hour.csv
│
├── glue/
│   └── scripts/
│       └── hour_etl.py
│
├── metrics/
│   └── metrics.json
│
├── docker-metrics/
│   └── metrics.json
│
├── sagemaker/
│   ├── training/
│   │   ├── Dockerfile
│   │   ├── requirements.txt
│   │   └── train.py
│   │
│   └── inference/
│       ├── Dockerfile
│       ├── inference.py
│       ├── requirements.txt
│       └── model/
│           └── model.joblib
│
└── terraform/
    ├── main.tf
    ├── providers.tf
    ├── variables.tf
    ├── outputs.tf
    ├── athena-policy.json
    │
    └── modules/
        ├── s3/
        ├── iam/
        ├── glue/
        ├── glue_job/
        └── sagemaker/
```

> The trained `model.joblib` artifact is intentionally excluded from Git because it is approximately 229 MB. The model artifact is used locally for container validation and is not stored in the Git repository.

---

# Data Pipeline

## 1. Raw Data

The project uses hourly bike-sharing data as the source dataset.

The raw dataset is stored in Amazon S3 under:

```text
s3://<bucket>/raw/hour.csv
```

The pipeline keeps raw data separate from processed data to maintain a clear data-lake structure.

---

## 2. AWS Glue ETL

The Glue ETL job is implemented in:

```text
glue/scripts/hour_etl.py
```

The ETL process:

1. Reads the raw hourly dataset.
2. Performs data transformation and preparation.
3. Produces curated data.
4. Writes the result as Parquet.
5. Stores the curated dataset under:

```text
s3://<bucket>/curated/hour/
```

The curated dataset was successfully generated as multiple Parquet objects.

Example:

```text
curated/hour/
├── part-00000-....snappy.parquet
├── part-00001-....snappy.parquet
├── part-00002-....snappy.parquet
└── part-00003-....snappy.parquet
```

---

# Amazon Athena

Athena is used to query the curated dataset stored in S3.

The project provisions the required IAM permissions and Glue catalog resources to support querying.

Athena query results are written to:

```text
s3://<bucket>/athena-results/
```

This provides a serverless SQL interface over the curated data without requiring a dedicated database.

---

# Machine Learning

## Model

The project uses:

```text
RandomForestRegressor
```

from Scikit-learn.

The trained model expects **12 input features**.

The model artifact is stored locally as:

```text
sagemaker/inference/model/model.joblib
```

The artifact is intentionally ignored by Git because of its size.

---

# SageMaker Training

Training code:

```text
sagemaker/training/train.py
```

Training dependencies:

```text
sagemaker/training/requirements.txt
```

Training container:

```text
sagemaker/training/Dockerfile
```

The intended training flow is:

```text
S3 curated Parquet
        ↓
SageMaker Training Job
        ↓
Training Container
        ↓
RandomForestRegressor
        ↓
Model Artifact
        ↓
S3 Model Output
```

The training configuration uses the curated S3 prefix:

```text
s3://<bucket>/curated/hour/
```

and writes model outputs to:

```text
s3://<bucket>/sagemaker/output/
```

---

# SageMaker Inference

Inference implementation:

```text
sagemaker/inference/inference.py
```

The inference service exposes:

```text
GET /ping
POST /invocations
```

## Health Check

The container exposes a health endpoint:

```bash
curl http://localhost:8080/ping
```

Expected response:

```json
{
  "status": "healthy"
}
```

## Prediction

Example request:

```bash
curl -X POST http://localhost:8080/invocations \
  -H "Content-Type: application/json" \
  -d '{
    "season": 1,
    "yr": 1,
    "mnth": 6,
    "hr": 17,
    "holiday": 0,
    "weekday": 2,
    "workingday": 1,
    "weathersit": 1,
    "temp": 0.7,
    "atemp": 0.65,
    "hum": 0.5,
    "windspeed": 0.2
  }'
```

Example response:

```json
{
  "predictions": [
    801.245
  ]
}
```

---

# Docker Inference Container

The inference container is defined in:

```text
sagemaker/inference/Dockerfile
```

The container packages:

* Python 3.11
* Pandas
* Scikit-learn
* Joblib
* Inference application
* Trained model artifact

The container was successfully built using:

```bash
docker build \
  -t aws-ml-platform-inference \
  sagemaker/inference
```

It was also validated locally using:

```bash
docker run --rm \
  -p 8080:8080 \
  aws-ml-platform-inference
```

The `/ping` and `/invocations` endpoints were successfully tested.

---

# Amazon ECR

The inference container is published to Amazon ECR:

```text
aws-ml-platform-inference:latest
```

The ECR repository was successfully verified using:

```bash
aws ecr describe-images \
  --repository-name aws-ml-platform-inference \
  --image-ids imageTag=latest \
  --region us-east-1
```

The image digest was successfully returned by ECR, confirming that the inference image was uploaded.

---

# Infrastructure as Code

Terraform is used to provision the AWS infrastructure.

The root Terraform configuration is:

```text
terraform/main.tf
```

Reusable modules are organized under:

```text
terraform/modules/
```

### S3 Module

Responsible for the project data bucket and related configuration.

### IAM Module

Creates IAM roles and policies required by:

* Glue
* SageMaker
* Other project services

### Glue Module

Creates Glue-related resources including the data catalog/crawler configuration.

### Glue Job Module

Defines the Glue ETL job.

### SageMaker Module

Defines SageMaker-related resources and configuration.

---

# Terraform Workflow

Initialize Terraform:

```bash
cd terraform

terraform init
```

Validate configuration:

```bash
terraform validate
```

Format configuration:

```bash
terraform fmt -recursive
```

Review changes:

```bash
terraform plan
```

Apply infrastructure:

```bash
terraform apply
```

---

# Security

The project follows several security practices:

* IAM roles are used instead of embedding credentials in application code.
* AWS access keys are not stored in the repository.
* Terraform state files are excluded from Git.
* Terraform variable files containing environment-specific values are excluded.
* Python virtual environments are excluded.
* Large model artifacts are excluded.
* `.terraform` provider binaries are excluded.
* IAM permissions are scoped to project-specific resources where practical.

No AWS access keys or secret credentials are committed to the repository.

---

# Infrastructure Validation

The deployed S3 data pipeline was verified using AWS CLI.

Example:

```bash
aws s3 ls s3://<bucket>/ --recursive
```

The resulting structure included:

```text
raw/
curated/hour/
athena-results/
```

The curated Parquet dataset was successfully generated and stored in S3.

---

# SageMaker Quota Limitation

The final managed SageMaker training/inference deployment was affected by AWS account-level service quotas.

The account initially reported:

```text
ml.m5.large for training job usage = 0 instances
```

A quota increase was requested through AWS Service Quotas.

An alternative instance type was also tested, but the selected `ml.t3.medium` resource was not available for SageMaker training in the selected region.

Therefore, the project includes and validates the complete training and inference implementation, while the final managed SageMaker compute allocation remained dependent on AWS quota availability.

The inference container itself was successfully validated locally.

---

# Project Validation Summary

| Component                       | Status                            |
| ------------------------------- | --------------------------------- |
| S3 raw data                     | ✅                                 |
| S3 curated data                 | ✅                                 |
| Glue ETL                        | ✅                                 |
| Curated Parquet output          | ✅                                 |
| Athena                          | ✅                                 |
| Terraform infrastructure        | ✅                                 |
| IAM configuration               | ✅                                 |
| Training code                   | ✅                                 |
| Training Dockerfile             | ✅                                 |
| Inference code                  | ✅                                 |
| Inference Docker image          | ✅                                 |
| Local `/ping` health check      | ✅                                 |
| Local `/invocations` prediction | ✅                                 |
| ECR inference image             | ✅                                 |
| SageMaker managed training      | ⚠️ AWS quota limitation           |
| SageMaker managed endpoint      | ⚠️ AWS compute allocation pending |

---

# Key Design Decisions

### Modular Terraform

Infrastructure is separated into reusable modules to improve maintainability and allow individual components to evolve independently.

### S3 Data Lake Structure

Raw and curated datasets are separated:

```text
raw/
    ↓
Glue ETL
    ↓
curated/
```

This preserves the original source data while providing an optimized dataset for analytics and ML.

### Containerized Inference

Inference is packaged as a Docker image instead of relying exclusively on a framework-specific deployment mechanism. This provides greater control over:

* Runtime dependencies
* Python version
* Model loading
* API behavior
* Deployment portability

### Local Validation Before Cloud Deployment

The inference container was tested locally before attempting managed deployment:

```text
Docker
  ↓
/ping
  ↓
/invocations
  ↓
Model prediction
```

This isolates application/container issues from AWS infrastructure issues.

---

# Future Improvements

Potential production enhancements include:

* SageMaker Model Registry integration
* Automated model versioning
* CI/CD pipeline using GitHub Actions
* Automated Docker image build and ECR push
* SageMaker Endpoint deployment through Terraform
* Model monitoring
* Data drift detection
* Model performance monitoring
* CloudWatch dashboards and alarms
* Automated retraining
* Feature Store integration
* Blue/green model deployments
* Infrastructure deployment across multiple AWS accounts/environments

---

# Repository

GitHub:

```text
https://github.com/sabhakrishnan/aws-ml-platform
```

The repository contains the infrastructure, ETL, training, inference, Docker, and configuration required to reproduce the project architecture.

