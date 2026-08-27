locals {
  prefix_name = "${var.project}-${var.environment}-${var.region_abbreviation}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
  }

  bucket_name   = "${local.prefix_name}-s3-app"
  instance_name = "${local.prefix_name}-ec2-app"
}
