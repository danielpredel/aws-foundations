terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.61.0"
    }
  }
}

# Default provider configuration
provider "aws" {
  region = var.region
}
