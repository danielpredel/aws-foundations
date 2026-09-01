# AWS CLI

This document contains the AWS CLI commands used to manually create and configure
the infrastructure for this project.

The commands use placeholders such as `<VPC-ID>` and `<Bucket-Name>` that must be
replaced with the values generated during the setup.

## IAM

The EC2 instance requires an IAM role that allows it to access the project's S3
bucket.

### Create the trust policy

Create a JSON file containing a trust policy that allows EC2 to assume the role:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
}
```

### Create the IAM role

```bash
aws iam create-role \
    --role-name <RoleName> \
    --assume-role-policy-document file://<TrustPolicyFilename>
```

### Create the custom S3 policy

Create a JSON file containing the permissions required by the application:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "<CustomPolicySID>",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::<BucketName>/*"
            ]
        }
    ]
}
```

### Create the policy

```bash
aws iam create-policy \
    --policy-name <PolicyName> \
    --policy-document file://<PolicyFilename>
```

### Attach the policy to the role

```bash
aws iam attach-role-policy \
    --role-name <RoleName> \
    --policy-arn arn:aws:iam::<AccountID>:policy/<PolicyName>
```

### Create the instance profile

```bash
aws iam create-instance-profile \
    --instance-profile-name <InstanceProfileName>
```

### Add the role to the instance profile

```bash
aws iam add-role-to-instance-profile \
    --instance-profile-name <InstanceProfileName> \
    --role-name <RoleName>
```

The instance profile is later associated with the EC2 instance.

---

## Networking

### Create the VPC

```bash
aws ec2 create-vpc \
  --cidr-block <VPC-CIDR> \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=<VPC-Name>}]'
```

Creating the VPC automatically creates a route table with a local route.

### Create the subnet

```bash
aws ec2 create-subnet \
  --vpc-id <VPC-ID> \
  --cidr-block <Subnet-CIDR> \
  --availability-zone <AZ-Name> \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=<Subnet-Name>}]'
```

### Enable automatic public IPv4 assignment

```bash
aws ec2 modify-subnet-attribute \
  --subnet-id <Subnet-ID> \
  --map-public-ip-on-launch
```

### Create the Internet Gateway

```bash
aws ec2 create-internet-gateway \
  --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=<IGW-Name>}]'
```

### Attach the Internet Gateway to the VPC

```bash
aws ec2 attach-internet-gateway \
  --internet-gateway-id <IGW-ID> \
  --vpc-id <VPC-ID>
```

### Add a route to the Internet Gateway

To make the subnet public, a route to the Internet Gateway is required.

```bash
aws ec2 create-route \
  --route-table-id <Route-Table-ID> \
  --destination-cidr-block <Route-CIDR> \
  --gateway-id <IGW-ID>
```

### Route table association

The subnet uses the VPC's default route table through an implicit association.

A separate route table association is only required when the subnet needs to use
a different route table.

### Get the VPC ID

```bash
aws ec2 describe-vpcs | grep "VpcId"
```

### Create the Security Group

```bash
aws ec2 create-security-group \
  --group-name <SG-Name> \
  --description "EC2 security group" \
  --vpc-id <VPC-ID>
```

### Get the Security Group ID

```bash
aws ec2 describe-security-groups | grep "GroupId"
```

### Allow SSH

```bash
aws ec2 authorize-security-group-ingress \
  --group-id <SG-ID> \
  --protocol tcp \
  --port 22 \
  --cidr <MyIP>/32
```

### Allow application traffic

For a custom application port:

```bash
aws ec2 authorize-security-group-ingress \
  --group-id <SG-ID> \
  --protocol <Custom-Protocol> \
  --port <Custom-Port> \
  --cidr <Custom-CIDR>
```

---

## S3

### Create the bucket

```bash
aws s3api create-bucket \
  --bucket <Bucket-Name> \
  --region <Region>
```

The bucket is used by the backend application for file storage. The EC2 instance accesses it through the IAM role configured previously.

---

## EC2

### Create an SSH key — Floci only

Floci requires a locally generated key pair:

```bash
ssh-keygen -t rsa -b 2048 -f ~/.ssh/<KeyFilename>
```

### Import the key — Floci only

```bash
aws ec2 import-key-pair \
    --key-name <KeyPairName> \
    --public-key-material fileb://$HOME/.ssh/<PublicKeyFilename>
```

### Create a key pair — Real AWS only

Real AWS can generate the key pair and return the private key:

```bash
aws ec2 create-key-pair \
    --key-name <KeyPairName> \
    --query 'KeyMaterial' \
    --output text > ~/.ssh/<KeyFilename>

chmod 400 ~/.ssh/<KeyFilename>
```

### Find an Amazon Linux AMI

```bash
aws ec2 describe-images \
  --owners amazon \
  --filters \
    "Name=name,Values=al2023-ami-*" \
    "Name=architecture,Values=x86_64" \
  --query 'Images | sort_by(@, &CreationDate)[-1].ImageId'
```

### Find the subnet ID

```bash
aws ec2 describe-subnets | grep "SubnetId"
```

### Launch the EC2 instance

```bash
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

The user-data script is used to configure the instance during startup.

### Get the public IP

```bash
aws ec2 describe-instances \
    --query 'Reservations[].Instances[].PublicIpAddress'
```

### Get the instance ID

```bash
aws ec2 describe-instances | grep "InstanceId"
```

### Check the assigned port — Floci only

Floci runs simulated EC2 instances using containers. The assigned port can be found with:

```bash
docker ps | grep "<InstanceId>"
```

### SSH into the instance

In Floci, `ec2-user` does not exist and the simulated instance uses `root`.
The public IP is `127.0.0.1`, so the assigned port must also be specified:

```bash
ssh -i ~/.ssh/<KeyFilename> root@<PublicIP> -p <EC2Port>
```

For real AWS:

```bash
ssh -i ~/.ssh/<KeyFilename> ec2-user@<PublicIP>
```

### Remove an old SSH host configuration — Floci only

Because new Floci instances share `127.0.0.1`, SSH may report a host key conflict
when connecting to a different instance.

```bash
ssh-keygen -f ~/.ssh/known_hosts -R '[<PublicIP>]:<EC2Port>'
```

### Terminate the instance

```bash
aws ec2 terminate-instances --instance-ids <InstanceId>
```

---

## Floci-specific EC2 Limitations

Floci uses containers to simulate EC2 instances. As a result, the environment
does not provide some components of a real EC2 workflow, including packages such
as `systemd` and `cloud-init`.

Additionally:

* `ec2-user` does not exist.
* SSH connections are made directly as `root`.
* The simulated public IP is `127.0.0.1`.
* Access to the instance requires the port assigned by Floci.

These differences should be considered when moving the deployment from Floci to
real AWS.
