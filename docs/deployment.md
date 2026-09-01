# Deployment

## Overview

The project follows a local-first deployment workflow.

The infrastructure and application are first deployed and validated locally using Floci. Once the local deployment is working, the same Terraform configuration is used to deploy the infrastructure to real AWS.

```text
Local Development
       │
       ▼
     Floci
       │
       ├── AWS CLI
       │
       └── Terraform
       │
       ▼
Local Validation
       │
       ▼
    Real AWS
       │
       └── Terraform
```

## Prerequisites

The following tools are required:

* AWS CLI
* Terraform
* Floci
* Git
* SSH client

The application also requires Python and its project dependencies.

---

## Local Deployment

### 1. Start Floci

Start the local AWS environment before provisioning the infrastructure.

Verify that Floci is running and that the required AWS-compatible endpoints are available.

### 2. Configure the Floci Environment

Configure the AWS CLI to use the local Floci environment.

The AWS CLI is used for resource management while Floci provides the local AWS-compatible infrastructure.

### 3. Initialize Terraform

Change to the Floci environment:

```bash
cd terraform/environments/floci
```

Initialize Terraform:

```bash
terraform init
```

### 4. Review the Infrastructure

Create a Terraform execution plan:

```bash
terraform plan
```

Review the resources Terraform intends to create before applying the configuration.

### 5. Deploy the Infrastructure

Apply the configuration:

```bash
terraform apply
```

Terraform provisions the required infrastructure, including:

* VPC
* Subnet
* Internet Gateway
* Route table
* Security Group
* IAM role and instance profile
* S3 bucket
* EC2 instance

### 6. Verify the EC2 Instance

After the infrastructure is created, retrieve the instance information from Terraform outputs or the AWS CLI.

For Floci, determine the port assigned to the simulated EC2 instance:

```bash
docker ps | grep "<InstanceId>"
```

### 7. Connect to the Instance

Floci EC2 instances use `root` rather than `ec2-user` and expose the simulated instance through a local port.

```bash
ssh -i ~/.ssh/<KeyFilename> root@127.0.0.1 -p <EC2Port>
```

### 8. Verify the Application

The EC2 user-data script initializes the instance and deploys the application.

Verify that the application is running and that the health endpoint responds successfully:

```text
GET /health
```

The application should return:

```json
{
  "status": "ok"
}
```

### 9. Validate S3 Integration

Verify the application's S3 operations using:

```text
GET /files/{key}
PUT /files/{key}
```

A successful upload followed by a retrieval confirms that the application can communicate with S3 using the EC2 IAM role.

---

## AWS Deployment

After validating the local deployment, deploy the infrastructure to real AWS.

### 1. Configure AWS Credentials

Configure the AWS CLI with credentials that have sufficient permissions to provision the project's resources.

Verify the configured identity:

```bash
aws sts get-caller-identity
```

### 2. Select the AWS Environment

Change to the AWS Terraform environment:

```bash
cd terraform/environments/aws
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Deployment

```bash
terraform plan
```

Review the resources before applying them.

### 5. Deploy the Infrastructure

```bash
terraform apply
```

Terraform creates the AWS infrastructure using the AWS environment configuration.

Correct. Then simply:

### 6. Verify the EC2 Instance

The EC2 instance information, including its public IP, is displayed automatically as part of the Terraform `apply` output.

### 7. Connect to EC2

Unlike Floci, a real Amazon Linux EC2 instance uses `ec2-user`:

```bash
ssh -i ~/.ssh/<KeyFilename> ec2-user@<PublicIP>
```

### 8. Verify the Application

Confirm that the application is running and test:

```text
GET /health
```

Then verify the S3 file operations:

```text
GET /files/{key}
PUT /files/{key}
```

---

## Deployment Validation

A deployment is considered successful when:

* Terraform completes without errors.
* The EC2 instance is running.
* The application is available.
* `/health` returns a successful response.
* The application can upload files to S3.
* The application can retrieve files from S3.
* The EC2 instance accesses S3 through its IAM role rather than hard-coded credentials.

---

## Teardown

### Floci

From the Floci Terraform environment:

```bash
cd terraform/environments/floci
terraform destroy
```

### AWS

From the AWS Terraform environment:

```bash
cd terraform/environments/aws
terraform destroy
```

Review the resources Terraform plans to remove before confirming the operation.

---

## Floci and AWS Differences

The deployment process is intentionally similar between the two environments, but Floci has several EC2-specific differences.

### EC2 access

Floci:

```text
127.0.0.1:<EC2Port>
```

Real AWS:

```text
<PublicIP>:22
```

### SSH user

Floci:

```text
root
```

Real AWS:

```text
ec2-user
```

### EC2 implementation

Floci simulates EC2 instances using containers, so the local environment does not reproduce every behavior of a real EC2 instance.

These differences should be considered when validating the application locally before deploying it to AWS.
