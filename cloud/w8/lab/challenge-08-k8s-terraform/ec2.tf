data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "cloudinit_config" "bootstrap" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "challenge-bootstrap.sh"
    content_type = "text/x-shellscript"

    content = templatefile("${path.module}/bootstrap/bootstrap.sh.tftpl", {
      node_port      = var.node_port
      configmap_b64  = base64encode(file("${path.module}/k8s/configmap.yaml"))
      deployment_b64 = base64encode(file("${path.module}/k8s/deployment.yaml"))
      service_b64 = base64encode(templatefile("${path.module}/k8s/service.yaml.tftpl", {
        node_port = var.node_port
      }))
    })
  }
}

resource "aws_instance" "minikube" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name

  user_data_base64            = data.cloudinit_config.bootstrap.rendered
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 25
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-minikube-ec2"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ec2_ssm_core
  ]
}
