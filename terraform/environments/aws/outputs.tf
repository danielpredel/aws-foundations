output "s3_bucket_name" {
  value = module.s3.s3_bucket_name
}

output "ec2_instance_id" {
  value = module.ec2.ec2_instance_id
}

output "ec2_public_ip" {
  value = module.ec2.ec2_public_ip
}
