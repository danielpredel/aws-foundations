variable "project" {
  type    = string
  default = "aws-foundations"
}

variable "environment" {
  type    = string
  default = "prod"
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
  type        = string
  default     = "amazon"
}

variable "ami_name_pattern" {
  type        = string
  default     = "al2023-ami-*"
}

variable "ami_architecture" {
  type        = string
  default     = "x86_64"
}
