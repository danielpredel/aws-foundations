resource "aws_vpc" "main" {
  cidr_block = "172.32.0.0/16"

  tags = merge(
    var.common.tags,
    {
      Name = "${var.common.prefix_name}-vpc"
    }
  )
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.32.0.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = merge(
    var.common.tags,
    {
      Name = "${var.common.prefix_name}-subnet"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common.tags,
    {
      Name = "${var.common.prefix_name}-igw"
    }
  )
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_security_group" "allow_ssh_app" {
  name        = "${var.common.prefix_name}-allow-ssh-app"
  description = "Allow SSH and 8000 (app) inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = merge(
    var.common.tags,
    {
      Name = "${var.common.prefix_name}-allow-ssh-app"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh_app.id
  cidr_ipv4         = "${var.network.my_ip_cidr}"
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
