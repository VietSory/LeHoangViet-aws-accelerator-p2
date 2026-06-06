output "state_bucket_name" {
  description = "Generated S3 bucket name used for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "lock_table_name" {
  description = "DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "backend_config_for_next_step" {
  description = "Copy these values into webapp-infra/backend.tf"
  value = {
    bucket         = aws_s3_bucket.terraform_state.bucket
    key            = "w8/day-c/webapp/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
    profile        = var.aws_profile
  }
}
