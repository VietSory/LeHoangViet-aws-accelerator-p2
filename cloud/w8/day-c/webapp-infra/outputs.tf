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
