module "network" {
  source = "../../modules/network"

  common  = local.common
  network = local.network
}

module "iam" {
  source = "../../modules/iam"

  common = local.common
  s3     = local.s3
}

module "s3" {
  source = "../../modules/s3"

  common = local.common
  s3     = local.s3
}

module "ec2" {
  source = "../../modules/ec2"

  common = local.common
  ec2    = local.ec2

  subnet_id             = module.network.subnet_id
  security_group_id     = module.network.security_group_id
  instance_profile_name = module.iam.instance_profile_name

  user_data = templatefile("${path.module}/user-data.sh", {
    bucket_name = local.s3.bucket_name
  })
}
