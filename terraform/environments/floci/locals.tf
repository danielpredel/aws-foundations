locals {
  common = {
    project     = var.project
    environment = var.environment
    region      = var.region
    prefix_name = "${var.project}-${var.environment}-${var.region_abbreviation}"
    tags = {
      Project     = var.project
      Environment = var.environment
    }
  }

  network = {
    my_ip_cidr = "192.168.1.21/32"
  }

  s3 = {
    bucket_name = "${local.common.prefix_name}-s3-app"
  }

  ec2 = {
    key_pair_name = var.key_pair_name
    instance_name = "${local.common.prefix_name}-ec2-app"
  }
}
