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

  cloudwatch = {
    log_group_name = "/aws/ec2/${local.common.project}"
  }

  s3 = {
    bucket_name = "${local.common.prefix_name}-s3-app"
  }

  ec2 = {
    key_pair_name = "${var.project}-${var.environment}-ec2"
    instance_name = "${local.common.prefix_name}-ec2-app"
  }

  floci = {
    aws_endpoint_url                  = "http://${var.floci_ip}:4566"
    aws_ec2_metadata_service_endpoint = "http://${var.floci_ip}:9169"
  }
}
