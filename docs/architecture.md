# Architecture

## Overview

The project consists of a small backend application deployed on Amazon EC2
and integrated with Amazon S3 for file storage.

The infrastructure is designed to be developed and validated locally using
Floci before being deployed to real AWS.

## Architecture

![Architecture Diagram](../images/architecture/diagram.png)

The architecture consists of the following AWS components:

| Component | Purpose |
|---|---|
| VPC | Provides the networking foundation |
| Internet Gateway | Provides internet connectivity |
| Route Table | Controls traffic routing within the VPC |
| Subnet | Provides the network segment for the EC2 instance |
| Security Group | Controls network access to the EC2 instance |
| EC2 | Hosts and runs the backend application |
| S3 | Stores application files |
| IAM | Provides the EC2 instance with the required permissions |

## Application Architecture

The backend application runs on an EC2 instance and exposes a small REST API.

```text
                    ┌──────────────────┐
                    │      Client      │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │   EC2 Instance   │
                    │                  │
                    │ FastAPI Backend  │
                    └────────┬─────────┘
                             │
                        Boto3 / AWS API
                             │
                             ▼
                    ┌──────────────────┐
                    │   Amazon S3      │
                    │                  │
                    │ Application Files│
                    └──────────────────┘
```

The application is responsible for handling HTTP requests and interacting with S3 through Boto3.

## AWS Infrastructure

The infrastructure consists of the following AWS components:

| Component      | Purpose                                                 |
| -------------- | ------------------------------------------------------- |
| EC2            | Hosts and runs the backend application                  |
| S3             | Stores application files                                |
| IAM            | Provides the EC2 instance with the required permissions |
| VPC            | Provides the networking foundation                      |
| Security Group | Controls network access to the EC2 instance             |

The EC2 instance uses an IAM role rather than hard-coded AWS credentials to access AWS resources.

## Networking

The EC2 instance is deployed within a VPC.

The Security Group controls the inbound and outbound network access associated with the instance.

The application is accessed through the EC2 instance, while S3 is accessed through AWS APIs from the backend.

The project focuses on the fundamental AWS networking concepts required to deploy the application rather than implementing a highly available or production-scale network architecture.

## Application and S3 Interaction

The application uses Boto3 to interact with the S3 bucket.

```text
HTTP Request
     │
     ▼
FastAPI
     │
     ▼
Boto3
     │
     ▼
Amazon S3
```

The API supports:

| Method | Endpoint       | Description                           |
| ------ | -------------- | ------------------------------------- |
| GET    | `/health`      | Returns the application health status |
| GET    | `/files/{key}` | Retrieves a file from S3              |
| PUT    | `/files/{key}` | Uploads a file to S3                  |

## Local Architecture

During development, the AWS infrastructure is emulated locally using Floci.

```text
Developer
    │
    ├── AWS CLI
    │
    └── Terraform
            │
            ▼
         Floci
            │
     ┌──────┼──────┐
     │      │      │
    EC2     S3    IAM
     │
     ▼
FastAPI Application
```

This allows the AWS infrastructure and application integration to be tested locally before deployment to real AWS.

## AWS Architecture

The same infrastructure concepts are then deployed to real AWS using Terraform.

```text
                    ┌──────────────────┐
                    │      Client      │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │   EC2 Instance   │
                    │                  │
                    │ FastAPI Backend  │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │   Amazon S3      │
                    │                  │
                    │ Application Files│
                    └──────────────────┘

                            VPC
                             │
                      Security Group
                             │
                            EC2

                         IAM Role
                             │
                             ▼
                         EC2 → S3
```

## Infrastructure Provisioning

The infrastructure can be managed through two approaches:

1. **AWS CLI** — resources can be created, inspected, and managed using AWS-compatible CLI commands.
2. **Terraform** — infrastructure is defined as code and can be recreated consistently.

The same infrastructure concepts are therefore practiced both imperatively through the CLI and declaratively through Terraform.

More details about the implementation are available in [`docs/infrastructure.md`](infrastructure.md).
