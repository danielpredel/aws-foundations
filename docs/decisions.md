# Architecture Decisions

## Floci for Local Development

Floci was selected to reproduce AWS infrastructure locally before deploying to
real AWS.

This allows the AWS concepts and Terraform configuration to be validated
without depending entirely on a live AWS environment.

## AWS CLI and Terraform

The infrastructure is practiced through two approaches:

- AWS CLI for imperative resource management.
- Terraform for declarative Infrastructure as Code.

Using both provides practical experience with AWS resource management and IaC.

## EC2 for Application Hosting

EC2 was selected to keep the project focused on the fundamentals of AWS
compute, networking, IAM, and deployment.

Managed compute services such as ECS or Lambda are outside the scope of this
project.

## S3 for File Storage

S3 was selected as the application's external storage layer to demonstrate
interaction between an EC2 workload and an AWS managed service through IAM.

## Terraform Modules

The Terraform configuration is divided into reusable modules for networking,
IAM, S3, and EC2.

This keeps infrastructure concerns separated and allows the same modules to be
used by both the Floci and AWS environments.
