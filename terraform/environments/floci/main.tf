module "network" {
  source = "../../modules/network"

  common  = local.common
  network = local.network
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  common = local.common
}

module "iam" {
  source = "../../modules/iam"

  common = local.common
  s3     = local.s3

  aws_cloudwatch_log_group_arn = module.cloudwatch.aws_cloudwatch_log_group_arn
}

module "s3" {
  source = "../../modules/s3"

  common = local.common
  s3     = local.s3
}

module "ec2" {
  source = "../../modules/ec2"

  ami_owner        = var.ami_owner
  ami_name_pattern = var.ami_name_pattern
  ami_architecture = var.ami_architecture

  common = local.common
  ec2    = local.ec2

  subnet_id             = module.network.subnet_id
  security_group_id     = module.network.security_group_id
  instance_profile_name = module.iam.instance_profile_name

  user_data = templatefile("${path.module}/user-data.sh", {
    bucket_name                       = local.s3.bucket_name
    aws_endpoint_url                  = local.floci.aws_endpoint_url
    aws_ec2_metadata_service_endpoint = local.floci.aws_ec2_metadata_service_endpoint
    region                            = var.region
  })
}
