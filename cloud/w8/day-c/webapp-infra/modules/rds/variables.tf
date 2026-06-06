variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the RDS DB subnet group"
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security group ID attached to RDS"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "multi_az" {
  description = "Whether RDS runs in Multi-AZ mode"
  type        = bool
  default     = false
}
