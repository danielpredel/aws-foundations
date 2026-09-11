variable "common" {
  type = object({
    project     = string
    environment = string
    region      = string
    prefix_name = string
    tags        = map(string)
  })
}

variable "cloudwatch" {
  type = object({
    log_group_name = string
  })
}
