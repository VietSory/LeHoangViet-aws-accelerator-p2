variable "aws_region" {
  description = "AWS region used for this Terraform project"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile used by Terraform"
  type        = string
  default     = "hviet"
}

variable "state_bucket_prefix" {
  description = "Prefix for globally unique S3 bucket storing Terraform state"
  type        = string
  default     = "hviet-w8-tf-state-"
}

variable "lock_table_name" {
  description = "DynamoDB table name used for Terraform state locking"
  type        = string
  default     = "hviet-w8-terraform-locks"
}
