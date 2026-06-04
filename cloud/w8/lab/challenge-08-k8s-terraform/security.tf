resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-"
  description = "Security group for the public Application Load Balancer."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-alb-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_from_internet" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow public HTTP traffic to the ALB."
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_security_group" "ec2" {
  name_prefix = "${var.project_name}-ec2-"
  description = "Security group for the EC2 instance hosting minikube."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_nodeport_from_alb" {
  security_group_id            = aws_security_group.ec2.id
  description                  = "Allow only the ALB to reach the Kubernetes NodePort."
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.node_port
  to_port                      = var.node_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ec2_nodeport" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Allow ALB traffic and health checks to EC2 NodePort."
  referenced_security_group_id = aws_security_group.ec2.id
  from_port                    = var.node_port
  to_port                      = var.node_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ec2_outbound" {
  security_group_id = aws_security_group.ec2.id
  description       = "Allow EC2 to install packages, pull images, and reach SSM."
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
