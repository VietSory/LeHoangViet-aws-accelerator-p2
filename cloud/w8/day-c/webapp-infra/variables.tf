variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_profile" {
  description = "AWS CLI profile used by Terraform"
  type        = string
  default     = "hviet"
}

variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
  default     = "hviet-w8-webapp"
}

variable "vpc_cidr" {
  description = "CIDR block for the project VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public web subnet"
  type        = string
  default     = "10.20.1.0/24"
}

variable "private_db_subnet_a_cidr" {
  description = "CIDR block for private DB subnet A"
  type        = string
  default     = "10.20.11.0/24"
}

variable "private_db_subnet_b_cidr" {
  description = "CIDR block for private DB subnet B"
  type        = string
  default     = "10.20.12.0/24"
}

variable "availability_zone_a" {
  description = "Primary Availability Zone"
  type        = string
  default     = "ap-southeast-1a"
}

variable "availability_zone_b" {
  description = "Secondary Availability Zone required for RDS subnet group"
  type        = string
  default     = "ap-southeast-1b"
}

variable "ec2_instance_type" {
  description = "EC2 instance type for the web server"
  type        = string
  default     = "t3.micro"
}

variable "rds_instance_class" {
  description = "RDS instance class for MySQL database"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_multi_az" {
  description = "Whether RDS should run in Multi-AZ mode"
  type        = bool
  default     = false
}
