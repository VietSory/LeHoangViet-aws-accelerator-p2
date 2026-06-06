variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID where EC2 web server is deployed"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID attached to EC2 web server"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}