# Challenge 08 — Kubernetes on AWS with Terraform One-Click Automation

## Objective

Provision a lightweight Kubernetes application on AWS using Terraform:

* One EC2 instance running **minikube**
* A small web application running **inside Kubernetes**
* Public access through an **Application Load Balancer**
* Automated provisioning through Terraform and cloud-init
* Two Terraform providers: `aws` and `cloudinit`

## Architecture

```text
Internet / Browser
        |
        | HTTP :80
        v
Application Load Balancer
- Internet-facing
- Deployed across 2 public subnets in 2 Availability Zones
        |
        | Target Group: HTTP :30080
        | Health check: /
        v
EC2 Ubuntu Instance
- c7i-flex.large
- No public SSH inbound rule
- Managed through AWS Systems Manager Session Manager
        |
        | Docker published port :30080
        v
Minikube Cluster
- Docker driver
- Port publishing: EC2:30080 -> minikube:30080
        |
        v
Kubernetes Service
- Type: NodePort
- Port mapping: 80 -> 30080
        |
        +-------------------+
        |                   |
        v                   v
Nginx Pod #1            Nginx Pod #2
- Custom HTML           - Custom HTML
- Readiness probe       - Readiness probe
- Liveness probe        - Liveness probe
- Resource limits       - Resource limits
```

## Design Decisions

### Why minikube with Docker driver?

The challenge requires Kubernetes to run inside one EC2 instance. Minikube is started with the Docker driver because it is easier to bootstrap reliably than installing Kubernetes components directly on the EC2 host.

The minikube node runs inside Docker, so the Kubernetes NodePort is published to the EC2 host:

```bash
minikube start \
  --driver=docker \
  --cpus=2 \
  --memory=2600mb \
  --ports=30080:30080 \
  --listen-address=0.0.0.0
```

This creates the traffic path:

```text
ALB -> EC2:30080 -> Minikube NodePort -> Nginx Pods
```

### Why two public subnets?

The internet-facing Application Load Balancer requires subnets in two different Availability Zones. This provides availability for the load balancer layer.

The backend remains one EC2 instance because the challenge scope explicitly requires one EC2 host running minikube. Therefore, this is not a fully highly available production architecture.

### Why EC2 is in a public subnet?

The EC2 instance must download Ubuntu packages, Docker, kubectl, minikube images and the nginx container image during first boot.

For this small challenge environment, placing the EC2 instance in a public subnet avoids adding a NAT Gateway and keeps the architecture simple and cost-conscious.

Security is restricted as follows:

* No public SSH inbound rule
* EC2 NodePort `30080` only accepts traffic from the ALB security group
* Administration is performed through AWS Systems Manager Session Manager

### Why `cloudinit` as the second Terraform provider?

Two Terraform providers are used:

| Provider              | Purpose                                                                                   |
| --------------------- | ----------------------------------------------------------------------------------------- |
| `hashicorp/aws`       | Provision VPC, subnets, security groups, IAM, EC2, ALB, target group and listener         |
| `hashicorp/cloudinit` | Render EC2 bootstrap user data that installs minikube and deploys the Kubernetes workload |

The `kubernetes` provider was considered, but the Kubernetes API does not exist until the EC2 instance has finished bootstrapping minikube. Using `cloudinit` avoids exposing the Kubernetes API externally and avoids bootstrap dependency problems during the first Terraform apply.

## AWS Resources Created

| Resource                       | Purpose                                                  |
| ------------------------------ | -------------------------------------------------------- |
| Custom VPC `10.80.0.0/16`      | Network boundary for the challenge                       |
| Public Subnet A `10.80.1.0/24` | EC2 instance and ALB availability zone A                 |
| Public Subnet B `10.80.2.0/24` | ALB availability zone B                                  |
| Internet Gateway               | Internet connectivity                                    |
| Public Route Table             | Routes public subnets to the Internet Gateway            |
| ALB Security Group             | Allows HTTP `80` from the Internet                       |
| EC2 Security Group             | Allows NodePort `30080` only from the ALB security group |
| IAM Role and Instance Profile  | Allows EC2 management through SSM                        |
| EC2 Ubuntu Instance            | Hosts Docker and minikube                                |
| Application Load Balancer      | Public HTTP entry point                                  |
| Target Group                   | Routes traffic to EC2 port `30080`                       |
| Listener                       | Receives HTTP traffic on port `80`                       |

## Kubernetes Resources Deployed

| Resource                | Purpose                                |
| ----------------------- | -------------------------------------- |
| ConfigMap `web-content` | Provides custom `index.html` content   |
| Deployment `web`        | Runs two nginx replicas                |
| Service `web-service`   | Exposes nginx through NodePort `30080` |

The Deployment also includes:

* `readinessProbe`
* `livenessProbe`
* CPU and memory requests/limits
* RollingUpdate deployment strategy

## Prerequisites

* Terraform installed
* AWS CLI configured with credentials that can create the required resources
* Region: `ap-southeast-1`

Verify AWS authentication:

```bash
aws sts get-caller-identity
```

## Deploy

Initialize Terraform:

```bash
terraform init
```

Validate the configuration:

```bash
terraform fmt -recursive
terraform validate
```

Create the full infrastructure and application:

```bash
terraform apply -auto-approve
```

After deployment, Terraform outputs the application URL:

```bash
terraform output -raw application_url
```

Open the returned URL in a browser or test it using:

```bash
curl -i "$(terraform output -raw application_url)"
```

Expected response content:

```text
Kubernetes Challenge 08
Application is running successfully.
Student: Le Hoang Viet
ALB -> EC2 -> Minikube NodePort -> Nginx Pods
```

## Verification

### Verify the public application endpoint

```bash
curl -i "$(terraform output -raw application_url)"
```

Expected HTTP status:

```text
HTTP/1.1 200 OK
```

### Connect to EC2 using SSM

```bash
aws ssm start-session \
  --target "$(terraform output -raw minikube_instance_id)" \
  --region ap-southeast-1
```

Inside the EC2 session:

```bash
sudo -u ubuntu -H minikube status
sudo -u ubuntu -H kubectl get nodes -o wide
sudo -u ubuntu -H kubectl get deployment,pods,svc -o wide
curl -i http://127.0.0.1:30080/
```

Expected Kubernetes state:

```text
Node: Ready
Deployment web: 2/2 Available
Pods: 2 Running
Service web-service: NodePort 80:30080/TCP
```

### Verify ALB target health

```bash
TG_ARN=$(aws elbv2 describe-target-groups \
  --region ap-southeast-1 \
  --names viet-k8s-challenge08-tg \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

aws elbv2 describe-target-health \
  --region ap-southeast-1 \
  --target-group-arn "$TG_ARN" \
  --query 'TargetHealthDescriptions[*].[Target.Id,Target.Port,TargetHealth.State]' \
  --output table
```

Expected state:

```text
healthy
```

## Cleanup

Destroy all infrastructure after verification to avoid unnecessary cost:

```bash
terraform destroy -auto-approve
```

Confirm that no managed AWS resources remain in Terraform state:

```bash
terraform state list
```

## Evidence

* Browser screenshot showing the public ALB URL and successful application page: `evidence/Screenshot 2026-06-04 172354.png`

