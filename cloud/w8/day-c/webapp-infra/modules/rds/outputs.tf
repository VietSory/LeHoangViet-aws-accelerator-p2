output "db_instance_id" {
  description = "RDS DB instance ID"
  value       = aws_db_instance.mysql.id
}

output "db_endpoint" {
  description = "RDS MySQL private endpoint"
  value       = aws_db_instance.mysql.endpoint
}

output "db_address" {
  description = "RDS MySQL private address"
  value       = aws_db_instance.mysql.address
}

output "db_port" {
  description = "RDS MySQL port"
  value       = aws_db_instance.mysql.port
}

output "db_subnet_group_name" {
  description = "RDS DB subnet group name"
  value       = aws_db_subnet_group.this.name
}

output "db_secret_arn" {
  description = "Secrets Manager ARN for RDS master credentials"
  value       = aws_db_instance.mysql.master_user_secret[0].secret_arn
  sensitive   = true
}
