variable "project" {
  type    = string
  default = "aws-foundations"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "region_abbreviation" {
  type    = string
  default = "use1"
}

variable "ami_owner" {
  type    = string
  default = "099720109477"
}

variable "ami_name_pattern" {
  type    = string
  default = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
}

variable "ami_architecture" {
  type    = string
  default = "x86_64"
}

variable "floci_ip" {
  type    = string
  default = "172.17.0.2"
}
