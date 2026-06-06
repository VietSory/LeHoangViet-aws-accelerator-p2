output "web_security_group_id" {
  description = "Security group ID for EC2 web server"
  value       = aws_security_group.web.id
}

output "db_security_group_id" {
  description = "Security group ID for RDS database"
  value       = aws_security_group.db.id
}
