variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public web subnet"
  type        = string
}

variable "private_db_subnet_a_cidr" {
  description = "CIDR block for private DB subnet A"
  type        = string
}

variable "private_db_subnet_b_cidr" {
  description = "CIDR block for private DB subnet B"
  type        = string
}

variable "availability_zone_a" {
  description = "Primary Availability Zone"
  type        = string
}

variable "availability_zone_b" {
  description = "Secondary Availability Zone"
  type        = string
}
