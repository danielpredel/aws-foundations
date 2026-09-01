# AWS Foundations

A hands-on AWS foundations project focused on building, managing, and automating cloud infrastructure using AWS services, AWS CLI, Terraform, and a local AWS environment with Floci.

The project follows a **local-first approach**: infrastructure and application components are developed and tested locally before being deployed to real AWS.

## Project Goals

* Learn and practice core AWS infrastructure concepts.
* Manage AWS resources through AWS CLI, and Infrastructure as Code.
* Use Terraform to create reproducible infrastructure.
* Deploy and run a backend application on EC2.
* Integrate Amazon S3 for application file storage.
* Apply IAM roles and Security Groups following the principle of least privilege.
* Understand the differences between local AWS emulation and real AWS infrastructure.

## Architecture

### Application Architecture

![Architecture Diagram](images/architecture/diagram.png)

More details about the Architecture are available in:

* [`docs/architecture.md`](docs/architecture.md)

### Infrastructure

The project uses the following AWS components:

| Service         | Purpose                                     |
| --------------- | ------------------------------------------- |
| EC2             | Hosts the backend application               |
| S3              | Stores application files                    |
| IAM             | Manages identities, roles, and permissions  |
| VPC             | Provides the networking foundation          |
| Security Groups | Controls network access to the EC2 instance |


## Technology Stack

### Cloud

* AWS
* Floci — local AWS environment

### Infrastructure & DevOps

* AWS CLI
* Terraform
* Bash
* Git

### Application

* Python
* FastAPI
* Boto3

### Infrastructure Components

* Amazon EC2
* Amazon S3
* AWS IAM
* Amazon VPC
* Security Groups

## Local Development

The infrastructure is initially developed and tested locally using Floci.

```text
Developer
   │
   ├── AWS CLI
   └── Terraform
          │
          ▼
       Floci
          │
          ├── EC2
          ├── S3
          ├── IAM
          └── VPC
```

### Floci

Floci provides a local AWS-compatible environment that allows AWS APIs, SDKs, and CLI workflows to be practiced without immediately deploying resources to AWS.

![Floci Resources (Floci UI)](images/floci/overview.png)

## AWS

The infrastructure was also deployed (with terraform) and validated in real AWS.

![EC2 Instance](images/aws/ec2-instance.png)

![S3 Bucket](images/aws/s3-bucket.png)

## Infrastructure Provisioning

The project demonstrates two different approaches to managing AWS infrastructure.

### 1. AWS CLI

AWS resources can be created, inspected, and managed through the AWS CLI.

Example:

```bash
# Command to launch an EC2 instance
aws ec2 run-instances \
  --image-id <AMIID> \
  --instance-type <InstanceType> \
  --key-name <KeyName> \
  --security-group-ids <SGID> \
  --subnet-id <SubnetID> \
  --iam-instance-profile Name=<InstanceProfileName> \
  --user-data file://<UserDataScript> \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=<Instance-Name>}]' \
  --count 1
```
> See [docs/cli.md]() for the complete command history.
More details about the complete command history are available in:

* [`docs/cli.md`](docs/cli.md)

### 2. Infrastructure as Code

Terraform is used to define the infrastructure as reproducible configuration.

```text
terraform/
├── environments/
└── modules/
```

`terraform plan`

![terraform plan](images/terraform/terraform-plan.png)

`terraform apply`

![terraform apply](images/terraform/terraform-apply.png)

More details about the Terraform implementation are available in:

* [`docs/infrastructure.md`](docs/infrastructure.md)

## Application

The project includes a small backend application running on EC2 and interacting with Amazon S3.

### API

The application provides endpoints for:

| Method | Endpoint       | Purpose                  |
| ------ | -------------- | ------------------------ |
| GET    | `/health`      | Application health check |
| GET    | `/files/{key}` | Retrieve a file from S3  |
| PUT    | `/files/{key}` | Upload a file to S3      |

![Endpoints](images/application/endpoints.png)

## Deployment

The project follows this progression:

```text
Local Development
       │
       ▼
     Floci
       │
       ├── AWS CLI
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

Detailed deployment instructions are available in:

* [`docs/deployment.md`](docs/deployment.md)

## Security

The project applies basic AWS security practices including:

* IAM roles instead of hard-coded AWS credentials where possible.
* Least-privilege IAM permissions.
* Security Groups to restrict network access.
* Separation between infrastructure configuration and application code.
* No AWS credentials or secrets committed to the repository.

<!-- Add specific security decisions from the actual implementation. -->

Detailed security considerations:

* [`docs/security.md`](docs/security.md)

## Infrastructure Documentation

Additional documentation:

* [`Architecture`](docs/architecture.md)
* [`Infrastructure`](docs/infrastructure.md)
* [`AWS CLI`](docs/cli.md)
* [`Deployment`](docs/deployment.md)
* [`Security`](docs/security.md)
* [`Architecture Decisions`](docs/decisions.md)

## Project Structure

```text
aws-foundations/
│
├── app/
│   └── Backend application
│
├── terraform/
│   ├── environments/
│   └── modules/
│
├── docs/
│   ├── architecture.md
│   ├── deployment.md
│   ├── cli.md
│   ├── infrastructure.md
│   ├── security.md
│   └── decisions.md
│
├── images/
│   ├── floci/
│   ├── aws/
│   ├── cli/
│   ├── terraform/
│   └── application/
│
└── README.md
```

## What This Project Demonstrates

This project demonstrates practical experience with:

* AWS infrastructure fundamentals
* Amazon EC2
* Amazon S3
* AWS IAM
* Amazon VPC
* Security Groups
* AWS CLI
* Terraform
* Bash automation
* Linux-based application deployment
* Python/FastAPI
* Boto3
* Infrastructure as Code
* Local AWS development with Floci

## Local vs AWS

One of the objectives of this project is to understand the transition from local AWS-compatible infrastructure to real AWS infrastructure.

The same infrastructure concepts are practiced locally first and then validated against real AWS.

This provides a controlled development environment while maintaining familiarity with the actual AWS tooling and workflows.

## Lessons Learned

* Differences between local AWS emulation and real AWS.
* Managing AWS infrastructure through multiple interfaces.
* Terraform state and reproducible infrastructure.
* IAM roles and permissions.
* EC2 instance setup and application deployment.
* S3 integration.
* AWS networking fundamentals.

## Future Improvements

Potential future improvements include:

* Automated CI/CD pipeline.
* Containerized application deployment.
* Application testing.
* Monitoring and alerting.
* Automated infrastructure deployment.
* Integration with additional AWS services.

These improvements are intentionally kept outside the initial scope of the foundations project and may be introduced in later projects.

## Author

**Daniel Preciado Delgadillo**

Software Engineer focused on AWS, Cloud Infrastructure, and DevOps.
