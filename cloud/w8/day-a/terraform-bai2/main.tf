terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_s3_bucket" "first" {
  bucket_prefix = "viet-terraform-bai2-"
  force_destroy = true

  tags = {
    Project = "terraform-series"
    Bai     = "02"
    Owner   = "LeHoangViet"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.first.id
}

output "bucket_arn" {
  value = aws_s3_bucket.first.arn
}
