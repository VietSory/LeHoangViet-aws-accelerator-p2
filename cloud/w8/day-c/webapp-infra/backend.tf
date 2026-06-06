terraform {
  backend "s3" {
    bucket         = "hviet-w8-tf-state-20260606085917365100000001"
    key            = "w8/day-c/webapp/terraform.tfstate"
    region         = "ap-southeast-1"
    profile        = "hviet"
    encrypt        = true
    dynamodb_table = "hviet-w8-terraform-locks"
  }
}