# Network resources
resource "aws_vpc" "main" {
  cidr_block = "172.32.0.0/16"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix_name}-vpc"
    }
  )
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.32.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix_name}-subnet"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix_name}-igw"
    }
  )
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_security_group" "allow_ssh_app" {
  name        = "${local.prefix_name}-allow-ssh-app"
  description = "Allow SSH and 8000 (app) inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix_name}-allow-ssh-app"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh_app.id
  cidr_ipv4         = "192.168.1.21/32"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_app" {
  security_group_id = aws_security_group.allow_ssh_app.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8000
  to_port           = 8000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.allow_ssh_app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# IAM Resources
data "aws_iam_policy_document" "ec2_app_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_app" {
  name               = "${local.prefix_name}-ec2-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_app_assume_role_policy.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix_name}-ec2-app-role"
    }
  )
}

data "aws_iam_policy_document" "ec2_app_s3_policy" {
  statement {
    sid = "${local.prefix_name}-ec2-app-rw-s3"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]
  }
}

resource "aws_iam_policy" "ec2_app_s3" {
  name   = "${local.prefix_name}-ec2-s3-app-policy"
  policy = data.aws_iam_policy_document.ec2_app_s3_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_app_s3" {
  role       = aws_iam_role.ec2_app.name
  policy_arn = aws_iam_policy.ec2_app_s3.arn
}

resource "aws_iam_instance_profile" "ec2_app" {
  name = "${local.prefix_name}-ec2-app-instance-profile"
  role = aws_iam_role.ec2_app.name
}


# S3 resources
resource "aws_s3_bucket" "app" {
  bucket = local.bucket_name
  region = var.region

  tags = merge(
    local.common_tags,
    {
      Name = local.bucket_name
    }
  )
}


# EC2 resources
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_app.id]
  subnet_id              = aws_subnet.public.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_app.name

  user_data = templatefile("${path.module}/user-data.sh", {
    bucket_name = local.bucket_name
  })

  tags = merge(
    local.common_tags,
    {
      Name = local.instance_name
    }
  )
}
