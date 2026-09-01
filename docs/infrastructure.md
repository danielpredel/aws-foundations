# Infrastructure

## Overview

Terraform is used to define the project's AWS infrastructure as reproducible configuration.

The Terraform configuration is organized into two environments:

* `floci` — local infrastructure used for development and testing.
* `aws` — infrastructure deployed to real AWS.

Both environments use the same reusable Terraform modules while providing environment-specific configuration.

## Directory Structure

```text
terraform/
├── environments/
│   ├── aws/
│   │   ├── locals.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── user-data.sh
│   │   └── variables.tf
│   │
│   └── floci/
│       ├── locals.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── user-data.sh
│       └── variables.tf
│
└── modules/
    ├── ec2/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    ├── iam/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    ├── network/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    │
    └── s3/
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```

## Environments

### Floci

The `terraform/environments/floci` configuration is used to provision the infrastructure against the local Floci environment.

It uses the same AWS resource model as the AWS environment while targeting Floci through its Terraform provider configuration.

The environment provisions the resources required to run the application locally:

```text
VPC
├── Subnet
├── Internet Gateway
├── Route Table
└── Security Group

IAM
└── EC2 Role / Instance Profile

S3
└── Application Bucket

EC2
└── FastAPI Application
```

### AWS

The `terraform/environments/aws` configuration provisions the equivalent infrastructure in real AWS.

The environment-specific configuration allows the same modules to be reused without duplicating the resource definitions.

## Modules

The project uses small, focused Terraform modules to separate infrastructure concerns.

### Network

The `network` module manages the networking foundation required by the application.

It contains the resources required for:

* VPC
* Subnet
* Internet Gateway
* Route table
* Security Group

The module exposes its required resource identifiers through outputs so that other modules can reference them.

### IAM

The `iam` module defines the IAM resources required by the EC2 instance.

The EC2 instance receives an IAM role through an instance profile, allowing the application to access the required S3 resources without embedding AWS credentials in the application.

The permissions are intentionally limited to the operations required by the application.

### S3

The `s3` module creates the S3 bucket used by the application for file storage.

The bucket is referenced by the application and by the EC2 IAM permissions.

### EC2

The `ec2` module provisions the EC2 instance that hosts the FastAPI application.

The module receives networking and IAM information from the environment configuration and uses the provided user-data script to initialize the instance.

## Module Composition

The environment configurations compose the individual modules into the complete infrastructure.

Conceptually:

```text
                    Environment
                         │
          ┌──────────────┼──────────────┐
          │              │              │
       Network          IAM            S3
          │              │              │
          └──────────────┼──────────────┘
                         │
                        EC2
                         │
                         ▼
                  FastAPI Application
```

This keeps reusable infrastructure definitions inside `modules/` while environment-specific configuration remains inside `environments/`.

## User Data

Each environment contains its own `user-data.sh`.

The script is passed to the EC2 instance during creation and is responsible for the instance initialization required to run the application.

This keeps EC2 provisioning and application initialization connected while keeping the initialization logic outside the Terraform resource definition.

## Terraform Workflow

Terraform is used through the standard workflow:

```bash
terraform init
terraform plan
terraform apply
```

After validating the infrastructure, resources can be removed with:

```bash
terraform destroy
```

The same workflow is used for both environments, with the Terraform provider configuration determining whether the resources are created in Floci or real AWS.

## Local-to-AWS Workflow

The infrastructure follows the project's local-first approach:

```text
Terraform Configuration
        │
        ▼
   Floci Environment
        │
        ▼
 Local Validation
        │
        ▼
   AWS Environment
        │
        ▼
    Real AWS
```

The goal is to validate the infrastructure locally before applying the equivalent configuration to AWS.

## State

Terraform state is maintained separately for each environment.

```text
terraform/environments/
├── floci/
│   └── terraform.tfstate
│
└── aws/
    └── terraform.tfstate
```

Keeping the environments separate prevents local Floci resources and real AWS resources from being managed by the same Terraform state.

## Infrastructure Resources

The resulting infrastructure consists of:

| Resource         | Terraform Module | Purpose                          |
| ---------------- | ---------------- | -------------------------------- |
| VPC              | `network`        | Networking foundation            |
| Subnet           | `network`        | Hosts the EC2 instance           |
| Internet Gateway | `network`        | Internet connectivity            |
| Route Table      | `network`        | Network routing                  |
| Security Group   | `network`        | Controls EC2 network access      |
| IAM Role         | `iam`            | Grants EC2 AWS permissions       |
| Instance Profile | `iam`            | Associates the IAM role with EC2 |
| S3 Bucket        | `s3`             | Application file storage         |
| EC2 Instance     | `ec2`            | Runs the FastAPI application     |

## Infrastructure as Code

Terraform is the declarative infrastructure layer of the project.

Instead of manually creating resources through the AWS CLI, the infrastructure is described as code and can be recreated consistently.

The CLI implementation is documented separately in [`cli.md`](cli.md).

The overall infrastructure architecture is documented in [`architecture.md`](architecture.md).
