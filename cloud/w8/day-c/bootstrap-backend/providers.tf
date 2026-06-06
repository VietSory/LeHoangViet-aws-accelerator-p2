terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project   = "hviet-w8-webapp"
      Phase     = "phase-2"
      Week      = "w8"
      Day       = "day-c"
      ManagedBy = "terraform"
    }
  }
}
