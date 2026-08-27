terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.61.0"
    }

    http = {
      source = "hashicorp/http"
    }
  }
}

# Default provider configuration
provider "aws" {
  region  = var.region
  profile = "aws-project1"
}
