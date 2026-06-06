# W8 Day C — Terraform Final Project: Deploy a Web App on AWS

## 1. Overview

This project is part of Phase 2 — W8 Cloud/DevOps practice. The goal is to deploy a small AWS web application infrastructure using Terraform.

The project demonstrates:

- Infrastructure as Code with Terraform
- Terraform workflow: `init`, `plan`, `apply`, `destroy`
- Remote state with S3 backend
- DynamoDB state locking
- Module-based Terraform structure
- AWS networking with public and private subnets
- Security Group design with least-required traffic
- EC2 web server deployment
- Private RDS MySQL deployment
- Private S3 static asset bucket

The infrastructure was deployed in the Singapore region using AWS profile `hviet`.

---

## 2. Architecture

```text
Internet
   |
   | HTTP :80
   v
EC2 Web Server
Public Subnet - ap-southeast-1a
   |
   | MySQL :3306
   | Allowed only from Web Security Group
   v
RDS MySQL
Private DB Subnet Group
- ap-southeast-1a
- ap-southeast-1b

S3 Bucket
- Private static assets storage

Terraform Remote State
- S3 backend
- DynamoDB locking
```

The EC2 instance is deployed in a public subnet because users need to access the web server through HTTP.

The RDS MySQL database is deployed in private subnet infrastructure because the database should not be directly accessible from the Internet.

The S3 bucket is used for static asset storage. It is private, encrypted, versioned, and blocks public access.

---

## 3. AWS Configuration

| Item                     | Value             |
| ------------------------ | ----------------- |
| AWS Profile              | `hviet`           |
| AWS Region               | `ap-southeast-1`  |
| Region Name              | Singapore         |
| Project Name             | `hviet-w8-webapp` |
| VPC CIDR                 | `10.20.0.0/16`    |
| Public Subnet CIDR       | `10.20.1.0/24`    |
| Private DB Subnet A CIDR | `10.20.11.0/24`   |
| Private DB Subnet B CIDR | `10.20.12.0/24`   |
| Primary AZ               | `ap-southeast-1a` |
| Secondary AZ             | `ap-southeast-1b` |

---

## 4. Terraform Backend

Terraform state is stored remotely in S3 instead of only being stored locally.

Terraform state is important because it maps Terraform resources in code to real AWS resources. If state is lost, Terraform may not know which AWS resources it manages.

| Component      | Value                                          |
| -------------- | ---------------------------------------------- |
| Backend Type   | S3                                             |
| State Bucket   | `hviet-w8-tf-state-20260606085917365100000001` |
| State Key      | `w8/day-c/webapp/terraform.tfstate`            |
| Lock Table     | `hviet-w8-terraform-locks`                     |
| Backend Region | `ap-southeast-1`                               |

The backend was created first in a separate `bootstrap-backend` step because Terraform cannot use an S3 backend before the S3 bucket exists.

Terraform may show this warning:

```text
The parameter "dynamodb_table" is deprecated. Use parameter "use_lockfile" instead.
```

For this assignment, DynamoDB locking is kept because the slide/project requirement asks for S3 backend with DynamoDB locking.

---

## 5. Project Structure

```text
webapp-infra/
├── backend.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars
├── main.tf
├── outputs.tf
├── README.md
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── security_groups/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── rds/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── s3/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

The project is split into modules to keep the Terraform code easier to read, reuse, and maintain.

---

## 6. Module Details

### 6.1 VPC Module

The VPC module creates the network foundation.

Resources created:

- VPC
- Internet Gateway
- Public subnet
- Private DB subnet A
- Private DB subnet B
- Public route table
- Private route table
- Route table associations

| Resource            | Purpose                                |
| ------------------- | -------------------------------------- |
| VPC                 | Isolated AWS network for the project   |
| Public Subnet       | Hosts the EC2 web server               |
| Private DB Subnet A | Used by the RDS subnet group           |
| Private DB Subnet B | Used by the RDS subnet group           |
| Internet Gateway    | Allows public subnet Internet access   |
| Public Route Table  | Routes `0.0.0.0/0` to Internet Gateway |
| Private Route Table | Has no Internet Gateway route          |

The public subnet is connected to the Internet Gateway. The private DB subnets are not connected to the Internet Gateway.

### 6.2 Security Groups Module

This module creates two Security Groups.

#### Web Security Group

Attached to the EC2 web server.

Allowed inbound traffic:

```text
TCP 80 from 0.0.0.0/0
```

SSH port 22 is not opened because direct SSH access is not required for this lab.

#### Database Security Group

Attached to the RDS MySQL instance.

Allowed inbound traffic:

```text
TCP 3306 from Web Security Group only
```

This means the database can only be reached by the EC2 web server, not by the public Internet.

### 6.3 EC2 Module

The EC2 module creates an Amazon Linux 2023 instance in the public subnet.

The instance installs Apache HTTP Server using `user_data` and serves a simple HTML page.

| Item        | Value                 |
| ----------- | --------------------- |
| Instance ID | `i-063c880f49beb4d22` |
| Public IP   | `13.212.48.93`        |
| Website URL | `http://13.212.48.93` |

The website page contains:

```text
Web App deployed on AWS with Terraform
```

### 6.4 RDS Module

The RDS module creates a private MySQL database.

| Item                | Value               |
| ------------------- | ------------------- |
| Engine              | MySQL               |
| Instance Class      | `db.t3.micro`       |
| Storage             | 20 GB               |
| Storage Type        | gp3                 |
| Storage Encryption  | Enabled             |
| Publicly Accessible | `false`             |
| Multi-AZ            | `false`             |
| DB Name             | `webappdb`          |
| Username            | `adminuser`         |
| Password Management | AWS Secrets Manager |

Current endpoint:

```text
hviet-w8-webapp-mysql.crgue8smyanh.ap-southeast-1.rds.amazonaws.com:3306
```

#### Why Single-AZ?

The RDS database is configured as Single-AZ because this is a lab environment and the goal is to reduce cost.

This is controlled by:

```hcl
multi_az = false
```

#### Why are there two private DB subnets?

Even though the database is Single-AZ, the DB subnet group contains two private subnets in two Availability Zones:

```text
ap-southeast-1a
ap-southeast-1b
```

This is needed for a valid RDS DB subnet group. It does not mean the database is Multi-AZ. The database remains Single-AZ because `multi_az = false`.

### 6.5 S3 Module

The S3 module creates a private bucket for static assets.

| Item          | Value                                               |
| ------------- | --------------------------------------------------- |
| Bucket        | `hviet-w8-static-assets-20260606103422346400000001` |
| Sample Object | `assets/project-info.txt`                           |
| Versioning    | Enabled                                             |
| Encryption    | Enabled                                             |
| Public Access | Blocked                                             |

The bucket is not used as a public static website. It is used as private static asset storage to satisfy the project requirement.

---

## 7. Current Terraform Outputs

```text
db_security_group_id = "sg-011307016611fb4d9"

private_db_subnet_ids = [
  "subnet-0510197682de66e40",
  "subnet-050fa3dfb60ee8388",
]

private_route_table_id = "rtb-0780a13608a8cc69c"
public_route_table_id = "rtb-07438b885e07f4c41"
public_web_subnet_id = "subnet-094cfd7fdd35d0e75"

rds_endpoint = "hviet-w8-webapp-mysql.crgue8smyanh.ap-southeast-1.rds.amazonaws.com:3306"
rds_instance_id = "db-C3P7PHMT2IFC5ZAM6AUCGNPPDE"
rds_subnet_group_name = "hviet-w8-webapp-db-subnet-group"

static_asset_object = "assets/project-info.txt"
static_assets_bucket = "hviet-w8-static-assets-20260606103422346400000001"

vpc_id = "vpc-06f967975f79ec4d0"

web_instance_id = "i-063c880f49beb4d22"
web_public_ip = "13.212.48.93"
web_security_group_id = "sg-074bb4c914b2324b0"
website_url = "http://13.212.48.93"
```

---

## 8. How to Run

Go to the project directory:

```bash
cd /mnt/d/LeHoangViet-aws-accelerator-p2/cloud/w8/day-c/webapp-infra
```

Login to AWS:

```bash
aws sso login --profile hviet
aws sts get-caller-identity --profile hviet
```

Initialize Terraform:

```bash
terraform init
```

Format Terraform files:

```bash
terraform fmt -recursive
```

Validate configuration:

```bash
terraform validate
```

Review changes:

```bash
terraform plan
```

Apply infrastructure:

```bash
terraform apply
```

Approve when Terraform asks:

```text
yes
```

---

## 9. Verification

### 9.1 Verify Website

```bash
curl "$(terraform output -raw website_url)"
```

Expected output contains:

```text
Web App deployed on AWS with Terraform
```

This verifies:

- EC2 is running
- Apache is installed
- EC2 user data executed successfully
- HTTP port 80 is reachable
- Public subnet routing works

### 9.2 Verify Terraform State

```bash
terraform state list
```

Expected resources include:

```text
module.ec2.data.aws_ami.amazon_linux_2023
module.ec2.aws_instance.web
module.rds.aws_db_instance.mysql
module.rds.aws_db_subnet_group.this
module.s3.aws_s3_bucket.static_assets
module.s3.aws_s3_bucket_public_access_block.static_assets
module.s3.aws_s3_bucket_server_side_encryption_configuration.static_assets
module.s3.aws_s3_bucket_versioning.static_assets
module.s3.aws_s3_object.project_info
module.security_groups.aws_security_group.db
module.security_groups.aws_security_group.web
module.vpc.aws_internet_gateway.this
module.vpc.aws_route.public_internet_access
module.vpc.aws_route_table.private_db
module.vpc.aws_route_table.public
module.vpc.aws_route_table_association.private_db_a
module.vpc.aws_route_table_association.private_db_b
module.vpc.aws_route_table_association.public_web
module.vpc.aws_subnet.private_db_a
module.vpc.aws_subnet.private_db_b
module.vpc.aws_subnet.public_web
module.vpc.aws_vpc.this
```

### 9.3 Verify RDS

```bash
aws rds describe-db-instances   --db-instance-identifier hviet-w8-webapp-mysql   --region ap-southeast-1   --profile hviet   --query "DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus,Engine,DBInstanceClass,PubliclyAccessible,MultiAZ,Endpoint.Address]"   --output table
```

Actual result:

```text
+-----------------------+-----------+--------+--------------+--------+--------+------------------------------------------------------------------------+
| hviet-w8-webapp-mysql | available | mysql  | db.t3.micro | False  | False  | hviet-w8-webapp-mysql.crgue8smyanh.ap-southeast-1.rds.amazonaws.com   |
+-----------------------+-----------+--------+--------------+--------+--------+------------------------------------------------------------------------+
```

This proves that RDS is available, private, and Single-AZ.

### 9.4 Verify RDS Subnet Group

```bash
aws rds describe-db-subnet-groups   --db-subnet-group-name hviet-w8-webapp-db-subnet-group   --region ap-southeast-1   --profile hviet   --query "DBSubnetGroups[*].Subnets[*].[SubnetIdentifier,SubnetAvailabilityZone.Name]"   --output table
```

Actual result:

```text
+---------------------------+-------------------+
| subnet-050fa3dfb60ee8388  | ap-southeast-1b   |
| subnet-0510197682de66e40  | ap-southeast-1a   |
+---------------------------+-------------------+
```

### 9.5 Verify S3 Static Assets

```bash
BUCKET_NAME=$(terraform output -raw static_assets_bucket)

aws s3 ls s3://$BUCKET_NAME/assets/   --region ap-southeast-1   --profile hviet
```

Expected object:

```text
assets/project-info.txt
```

Check versioning:

```bash
aws s3api get-bucket-versioning   --bucket $BUCKET_NAME   --region ap-southeast-1   --profile hviet
```

Expected result:

```json
{
  "Status": "Enabled"
}
```

Check public access block:

```bash
aws s3api get-public-access-block   --bucket $BUCKET_NAME   --region ap-southeast-1   --profile hviet
```

Expected result:

```json
{
  "PublicAccessBlockConfiguration": {
    "BlockPublicAcls": true,
    "IgnorePublicAcls": true,
    "BlockPublicPolicy": true,
    "RestrictPublicBuckets": true
  }
}
```

### 9.6 Verify Security Groups

```bash
aws ec2 describe-security-groups   --group-ids sg-074bb4c914b2324b0 sg-011307016611fb4d9   --region ap-southeast-1   --profile hviet   --query "SecurityGroups[*].[GroupName,GroupId,IpPermissions]"   --output json
```

Expected design:

```text
Web Security Group:
- Inbound TCP 80 from 0.0.0.0/0

Database Security Group:
- Inbound TCP 3306 from Web Security Group only
```

---

## 10. Evidence Checklist

Evidence to collect:

- Terraform backend S3 bucket exists
- DynamoDB lock table exists
- `terraform init` successful
- `terraform validate` successful
- `terraform apply` successful
- `terraform output` shows website URL, RDS endpoint, and S3 bucket
- `terraform state list` shows all managed resources
- Website is accessible with `curl`
- EC2 instance is running with public IP
- RDS instance status is `available`
- RDS `PubliclyAccessible` is `False`
- RDS `MultiAZ` is `False`
- RDS DB subnet group includes `ap-southeast-1a` and `ap-southeast-1b`
- S3 static asset object exists
- S3 versioning is enabled
- S3 public access is blocked
- EC2 Security Group allows HTTP only
- RDS Security Group allows MySQL only from EC2 Security Group

---

## 11. Cleanup

This project creates AWS resources that may generate cost, especially EC2 and RDS.

After collecting evidence, destroy the infrastructure:

```bash
terraform destroy
```

Approve when Terraform asks:

```text
yes
```

The backend resources in `bootstrap-backend` should only be destroyed after all evidence and review are complete.

---

## 12. Lessons Learned

From this project, I learned how to:

- Use Terraform to provision AWS infrastructure
- Organize Terraform code into reusable modules
- Use Terraform outputs to expose important resource information
- Use remote state with S3
- Use DynamoDB locking for state safety
- Deploy an EC2 web server using user data
- Place a database in private subnet infrastructure
- Restrict access using Security Groups
- Use S3 as private static asset storage
- Verify infrastructure using Terraform outputs and AWS CLI

The most important learning point was understanding that Terraform state is critical. It is not just a generated file; it is the source Terraform uses to understand what it manages.

Another important point was understanding the difference between RDS Single-AZ and an RDS DB subnet group. The database can be Single-AZ while the subnet group still contains subnets in multiple Availability Zones.
