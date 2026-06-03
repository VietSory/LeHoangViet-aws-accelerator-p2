terraform {
  backend "s3" {
    bucket         = "viet-w8-terraform-state-474013238625"
    key            = "w8/day-a/webapp/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true

    dynamodb_table = "viet-w8-terraform-locks"
    use_lockfile   = true
  }
}
