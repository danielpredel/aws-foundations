variable "common" {
  type = object({
    project     = string
    environment = string
    region      = string
    prefix_name = string
    tags        = map(string)
  })
}

variable "ec2" {
  type = object({
    key_pair_name = string
    instance_name = string
  })
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "user_data" {
  type = string
}
