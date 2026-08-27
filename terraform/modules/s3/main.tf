resource "aws_s3_bucket" "app" {
  bucket = var.s3.bucket_name
  region = var.common.region

  tags = merge(
    var.common.tags,
    {
      Name = var.s3.bucket_name
    }
  )
}
