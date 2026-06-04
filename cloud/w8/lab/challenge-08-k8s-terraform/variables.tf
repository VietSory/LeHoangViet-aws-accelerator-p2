variable "aws_region" {
  description = "AWS region used for Challenge 08."
  type        = string
  default     = "ap-southeast-1"
}
variable "project_name" {
  description = "Name prefix used for all challenge resources."
  type        = string
  default     = "viet-k8s-challenge08"
}

variable "vpc_cidr" {
  description = "CIDR block for the custom VPC."
  type        = string
  default     = "10.80.0.0/16"
}

variable "public_subnet_a_cidr" {
  description = "CIDR block for public subnet A."
  type        = string
  default     = "10.80.1.0/24"
}

variable "public_subnet_b_cidr" {
  description = "CIDR block for public subnet B."
  type        = string
  default     = "10.80.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes."
  type        = string
  default     = "c7i-flex.large"
}

variable "node_port" {
  description = "NodePort exposed by Kubernetes and published from minikube to EC2."
  type        = number
  default     = 30080

  validation {
    condition     = var.node_port >= 30000 && var.node_port <= 32767
    error_message = "NodePort must be between 30000 and 32767."
  }
}