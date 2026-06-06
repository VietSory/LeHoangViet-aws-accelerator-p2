output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_web_subnet_id" {
  description = "Public subnet used for EC2 web server"
  value       = module.vpc.public_web_subnet_id
}

output "private_db_subnet_ids" {
  description = "Private subnets used for RDS DB subnet group"
  value       = module.vpc.private_db_subnet_ids
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = module.vpc.private_route_table_id
}

output "web_security_group_id" {
  description = "Security group ID for EC2 web server"
  value       = module.security_groups.web_security_group_id
}

output "db_security_group_id" {
  description = "Security group ID for RDS database"
  value       = module.security_groups.db_security_group_id
}

output "web_instance_id" {
  description = "EC2 web server instance ID"
  value       = module.ec2.instance_id
}

output "web_public_ip" {
  description = "Public IP address of EC2 web server"
  value       = module.ec2.public_ip
}

output "website_url" {
  description = "URL of the deployed EC2 web server"
  value       = "http://${module.ec2.public_ip}"
}

output "rds_instance_id" {
  description = "RDS MySQL instance ID"
  value       = module.rds.db_instance_id
}

output "rds_endpoint" {
  description = "Private RDS MySQL endpoint"
  value       = module.rds.db_endpoint
}

output "rds_subnet_group_name" {
  description = "RDS DB subnet group name"
  value       = module.rds.db_subnet_group_name
}

output "rds_secret_arn" {
  description = "Secrets Manager ARN containing RDS master credentials"
  value       = module.rds.db_secret_arn
  sensitive   = true
}
