data "aws_ami" "instance" {
  most_recent = true

  owners = [var.ami_owner]

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }

  filter {
    name   = "architecture"
    values = [var.ami_architecture]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.instance.id
  instance_type          = "t3.micro"
  key_name               = var.ec2.key_pair_name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.subnet_id
  iam_instance_profile   = var.instance_profile_name

  user_data = var.user_data

  tags = merge(
    var.common.tags,
    {
      Name = var.ec2.instance_name
    }
  )
}
