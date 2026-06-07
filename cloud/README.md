# LeHoangViet AWS Accelerator Phase 2 Portfolio

## Overview

This repository contains my personal portfolio for **AWS Accelerator Phase 2 — Cloud/DevOps Track**.

Phase 2 focuses on hands-on Cloud/DevOps engineering practices, including:

* Infrastructure as Code with Terraform
* Kubernetes fundamentals and local orchestration
* AWS networking and compute services
* GitOps and deployment workflows
* Observability and monitoring
* Canary deployment concepts
* Security and cloud operation best practices
* Capstone preparation and cross-team collaboration

Compared with Phase 1, Phase 2 emphasizes more self-study, hands-on labs, daily commits, evidence-based checkpoints, and mentor review through show-and-tell sessions.

## Information

| Field        | Value                                         |
| ------------ | --------------------------------------------- |
| Name         | Lê Hoàng Việt                                 |
| Track        | Cloud/DevOps                                  |
| Phase        | Phase 2                                       |
| Repository   | LeHoangViet AWS Accelerator Phase 2 Portfolio |

## Phase 2 Timeline

Phase 2 runs from **Monday 01/06/2026** to **Friday 03/07/2026**.

It is divided into two main stages:

| Stage   | Time        | Focus                                                                                                |
| ------- | ----------- | ---------------------------------------------------------------------------------------------------- |
| W8–W10  | 01/06–19/06 | Deep dive into Cloud/DevOps foundations: IaC, Kubernetes, GitOps, Observability, Canary and Security |
| W11–W12 | 22/06–03/07 | Capstone cross-team pod and final pitching                                                           |

## Weekly Workflow

The weekly workflow follows this pattern:

| Days             | Activity                                                              |
| ---------------- | --------------------------------------------------------------------- |
| Monday–Wednesday | Online self-study, reading materials, exercises, individual commits   |
| Thursday–Friday  | Onsite labs in Da Nang, mentor review, show-and-tell, technical tests |

The goal is not only to complete labs, but also to build a clear portfolio showing technical understanding, implementation evidence, troubleshooting ability, and reflection.

## Repository Structure

```text
.
├── README.md
├── cloud/
│   ├── w8/
│   │   ├── day-a/
│   │   ├── day-b/
│   │   ├── day-c/
│   │   ├── lab/
│   │   └── reflection.md
│   │
│   ├── w9/
│   └── w10/
│
└── capstone/
    ├── w11/
    └── w12/
```

## Folder Description

| Path                     | Purpose                                                         |
| ------------------------ | --------------------------------------------------------------- |
| `cloud/w8/day-a/`        | Terraform foundation: IaC overview, HCL syntax, workflow basics |
| `cloud/w8/day-b/`        | Kubernetes container/orchestration fundamentals                 |
| `cloud/w8/day-c/`        | Kubernetes scaling, networking and cloud integration            |
| `cloud/w8/lab/`          | Hands-on labs and mini platform implementations                 |
| `cloud/w8/reflection.md` | Weekly reflection and learning notes                            |
| `cloud/w9/`              | Future Cloud/DevOps topics and labs                             |
| `cloud/w10/`             | Future Cloud/DevOps topics and labs                             |
| `capstone/w11/`          | Capstone preparation and cross-team pod work                    |
| `capstone/w12/`          | Final capstone delivery and pitching materials                  |

## W8 — Foundation: Infrastructure as Code and Kubernetes

W8 focuses on the foundation of Cloud/DevOps through Terraform and Kubernetes.

### Main Topics

| Area       | Topics                                                                               |
| ---------- | ------------------------------------------------------------------------------------ |
| Terraform  | IaC overview, HCL syntax, init, plan, apply, destroy, state, modules, best practices |
| Kubernetes | Pod, Deployment, Service, ConfigMap, Secret, probes, scaling, networking             |
| Tools      | Docker Desktop, Docker Engine, kubectl, minikube                                     |
| AWS        | EC2, VPC, Subnet, Security Group, IAM, ALB, Target Group, SSM                        |

## W8 Learning Summary

During W8, I studied and practiced both Terraform and Kubernetes fundamentals.

For Terraform, I focused on:

* Understanding Infrastructure as Code
* Writing HCL configuration
* Running Terraform workflow commands
* Understanding Terraform state
* Structuring Terraform files clearly
* Using variables, outputs and providers
* Creating AWS resources through Terraform instead of using AWS Console manually

For Kubernetes, I focused on:

* Understanding container orchestration
* Creating Deployments and Pods
* Exposing applications using Services
* Using NodePort for local and cloud access
* Adding readiness and liveness probes
* Using ConfigMap to inject application content
* Debugging with `kubectl get`, `kubectl describe`, `kubectl logs`
* Running Kubernetes locally with minikube

## Highlight Project — Challenge 08: Kubernetes on AWS with Terraform

One of the main W8 deliverables is **Challenge 08 — K8s on AWS with Terraform One-Click Automation**.

The goal was to provision a small Kubernetes application on AWS using Terraform.

### Challenge Requirements

The challenge required:

* One EC2 instance running minikube or kind
* A small application running inside Kubernetes
* Public access through an Application Load Balancer
* One-click provisioning with Terraform
* At least two Terraform providers
* Clear README, architecture explanation and cleanup process

### Implemented Architecture

```text
Internet / Browser
        |
        | HTTP :80
        v
Application Load Balancer
- Internet-facing
- Deployed across two public subnets in two Availability Zones
        |
        | Target Group: HTTP :30080
        v
EC2 Ubuntu Instance
- c7i-flex.large
- Managed through AWS Systems Manager Session Manager
- No public SSH inbound rule
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

### Main AWS Resources

| Resource                  | Purpose                                         |
| ------------------------- | ----------------------------------------------- |
| VPC                       | Network boundary for the challenge              |
| Public Subnets            | Host ALB and EC2 networking                     |
| Internet Gateway          | Public Internet connectivity                    |
| Route Table               | Route public subnet traffic to Internet Gateway |
| Security Groups           | Restrict access between Internet, ALB and EC2   |
| IAM Role                  | Allow EC2 to be managed by SSM                  |
| EC2 Instance              | Host Docker and minikube                        |
| Application Load Balancer | Public entry point for the app                  |
| Target Group              | Forward traffic to EC2 port `30080`             |
| Listener                  | Receive HTTP traffic on port `80`               |

### Main Kubernetes Resources

| Resource   | Purpose                                    |
| ---------- | ------------------------------------------ |
| ConfigMap  | Store custom HTML page                     |
| Deployment | Run two nginx Pods                         |
| Service    | Expose nginx Pods through NodePort `30080` |

### Terraform Providers Used

| Provider              | Purpose                                                                            |
| --------------------- | ---------------------------------------------------------------------------------- |
| `hashicorp/aws`       | Provision AWS resources such as VPC, EC2, IAM, ALB and Security Groups             |
| `hashicorp/cloudinit` | Render EC2 bootstrap user data to install minikube and deploy Kubernetes manifests |

I chose the `cloudinit` provider as the second provider because it has a real role in the architecture. It prepares the bootstrap script and Kubernetes manifests as EC2 user data. Then cloud-init inside the EC2 instance runs the script during boot.

## Important Design Decisions

### Why minikube with Docker driver?

I used minikube with the Docker driver because it is easier to bootstrap reliably on EC2 compared with running Kubernetes directly on the host using the `none` driver.

The minikube node runs inside Docker, and the NodePort is published to the EC2 host:

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
ALB -> EC2:30080 -> Minikube NodePort -> Kubernetes Service -> Nginx Pods
```

### Why use NodePort?

The ALB needs a stable port on the EC2 instance. Kubernetes Pods have dynamic IPs and can be recreated at any time, so the ALB should not connect directly to Pods.

The Service provides a stable entry point:

```text
EC2:30080 -> Service web-service -> nginx Pods
```

### Why use SSM instead of SSH?

I used AWS Systems Manager Session Manager to debug the EC2 instance without opening public SSH port `22`.

This makes the security design cleaner:

```text
Internet -> ALB:80
ALB -> EC2:30080
No public SSH access
```

SSM was used to verify:

* Bootstrap logs
* Minikube status
* Kubernetes nodes
* Deployments, Pods and Services
* Local curl to `127.0.0.1:30080`

### Why use two public subnets?

An internet-facing Application Load Balancer requires subnets in at least two Availability Zones. Therefore, the architecture uses two public subnets even though the backend only has one EC2 instance.

The backend is still single-node because the challenge scope requires one EC2 instance running minikube.

## Verification Evidence

Before cleanup, the system was verified using:

```bash
terraform output -raw application_url
curl -i "$(terraform output -raw application_url)"
```

Inside the EC2 instance, the following checks were performed:

```bash
sudo -u ubuntu -H minikube status
sudo -u ubuntu -H kubectl get nodes -o wide
sudo -u ubuntu -H kubectl get deployment,pods,svc -o wide
curl -i http://127.0.0.1:30080/
```

The successful Kubernetes state included:

```text
minikube: Running
node: Ready
deployment/web: 2/2 Available
pods: 2 Running
service/web-service: NodePort 80:30080/TCP
```

The bootstrap log confirmed:

```text
=== Challenge 08 bootstrap completed successfully ===
```

The public ALB URL also returned the custom web page:

```text
Kubernetes Challenge 08
Application is running successfully.
Student: Le Hoang Viet
ALB -> EC2 -> Minikube NodePort -> Nginx Pods
```

## Cleanup

After verification, all AWS resources were destroyed using Terraform to avoid unnecessary cost:

```bash
terraform destroy
```

The cleanup step is important because the project creates paid resources such as EC2 and ALB.

## Useful Commands

### Terraform

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
terraform destroy
```

### AWS CLI

```bash
aws sts get-caller-identity
aws ssm start-session --target <instance-id> --region ap-southeast-1
```

### Kubernetes

```bash
kubectl get nodes -o wide
kubectl get deployment,pods,svc -o wide
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Minikube

```bash
minikube status
minikube service list
```

## Learning Outcomes

Through this phase and W8 work, I practiced how Cloud/DevOps tools connect together in a real workflow.

Key takeaways:

* Terraform is used to make infrastructure reproducible.
* Kubernetes Service is needed because Pods are dynamic.
* ALB provides a public entry point to the application.
* Security Group rules should be limited to the actual traffic path.
* SSM is useful for debugging EC2 without exposing SSH.
* Cloud-init helps automate EC2 bootstrap.
* Evidence and cleanup are important parts of a cloud lab.
* A good DevOps workflow should be testable, explainable and repeatable.

## Commit Convention

Daily commits should follow the Phase 2 convention:

```text
[W8-D1] <short topic>
[W8-D2] <short topic>
[W8-D3] <short topic>
```

Examples:

```text
[W8-D1] learn terraform workflow basics
[W8-D2] deploy nginx on minikube
[W8-D3] add terraform challenge 08 infrastructure
```

## References

### Terraform

* HashiCorp Terraform Tutorials
* Terraform Documentation
* Terraform Registry
* Terraform Best Practices
* Terraform from Basics to Production series

### Docker and Containers

* Docker Documentation
* Docker Curriculum
* Docker Deep Dive
* OCI Image Specification

### Kubernetes

* Kubernetes Documentation
* Kubernetes Basics
* minikube Documentation
* kubectl Cheat Sheet
* Kubernetes in Action
* Kubernetes Patterns

### AWS

* AWS Documentation
* AWS Skill Builder
* AWS Workshops
* AWS Well-Architected Framework

## Status

Current status:

```text
W8 foundation work: Completed
Challenge 08: Completed and verified
AWS resources: Destroyed after testing
Repository: Ready for review and future Phase 2 updates
```
