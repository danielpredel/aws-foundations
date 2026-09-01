# Security

## IAM

The EC2 instance uses an IAM role through an instance profile instead of storing AWS credentials on the instance.

The role is granted only the S3 permissions required by the application:

- `s3:GetObject`
- `s3:PutObject`

## Network Security

The EC2 instance is protected by a Security Group.

SSH access is restricted to the administrator's IP address rather than being
open to the entire internet.

Application traffic is allowed only through the required port.

## S3

The application accesses S3 through the EC2 IAM role. No AWS access keys are
embedded in the application code or deployment scripts.

## Credentials

AWS credentials are provided through the AWS CLI/Terraform environment and are
not committed to the repository.

> This project demonstrates basic AWS security practices and is not intended to
> represent a complete production security architecture.
