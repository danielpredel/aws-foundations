variable "common" {
  type = object({
    project     = string
    environment = string
    region      = string
    prefix_name = string
    tags        = map(string)
  })
}

variable "s3" {
  type = object({
    bucket_name = string
  })
}
