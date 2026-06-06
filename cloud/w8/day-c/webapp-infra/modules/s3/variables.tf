variable "project_name" {
  description = "Project name used as resource prefix"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for globally unique S3 bucket storing static assets"
  type        = string
}
