output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_a_id" {
  description = "ID of the created public subnet A."
  value       = aws_subnet.public_a.id
}

output "public_subnet_b_id" {
  description = "ID of the created public subnet B."
  value       = aws_subnet.public_b.id
}

output "availability_zones" {
  description = "Availability Zones selected for the two public subnets."
  value = [
    aws_subnet.public_a.availability_zone,
    aws_subnet.public_b.availability_zone
  ]
}
output "ubuntu_ami_id" {
  description = "Official Ubuntu AMI selected for the minikube EC2 instance."
  value       = data.aws_ami.ubuntu.id
}

output "minikube_instance_id" {
  description = "ID of the EC2 instance hosting minikube."
  value       = aws_instance.minikube.id
}

output "minikube_instance_public_ip" {
  description = "Public IP of the EC2 instance for visibility only; application access must go through ALB."
  value       = aws_instance.minikube.public_ip
}

output "ssm_start_session_command" {
  description = "Command used to connect to the EC2 host without opening SSH."
  value       = "aws ssm start-session --target ${aws_instance.minikube.id} --region ${var.aws_region}"
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer."
  value       = aws_lb.web.dns_name
}

output "application_url" {
  description = "Public URL used to access the Kubernetes application through ALB."
  value       = "http://${aws_lb.web.dns_name}"
}

output "verify_application_command" {
  description = "Command used to verify the application through the ALB."
  value       = "curl -i http://${aws_lb.web.dns_name}"
}
