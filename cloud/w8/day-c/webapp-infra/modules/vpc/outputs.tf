output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.this.id
}

output "public_web_subnet_id" {
  description = "Public subnet ID for EC2 web server"
  value       = aws_subnet.public_web.id
}

output "private_db_subnet_ids" {
  description = "Private subnet IDs for RDS DB subnet group"
  value = [
    aws_subnet.private_db_a.id,
    aws_subnet.private_db_b.id
  ]
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = aws_route_table.private_db.id
}
