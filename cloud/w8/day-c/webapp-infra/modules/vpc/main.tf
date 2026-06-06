resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public_web" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-web-a"
    Tier = "public"
  }
}

resource "aws_subnet" "private_db_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_db_subnet_a_cidr
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-db-a"
    Tier = "private"
  }
}

resource "aws_subnet" "private_db_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_db_subnet_b_cidr
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-db-b"
    Tier = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public_web" {
  subnet_id      = aws_subnet.public_web.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-private-db-rt"
  }
}

resource "aws_route_table_association" "private_db_a" {
  subnet_id      = aws_subnet.private_db_a.id
  route_table_id = aws_route_table.private_db.id
}

resource "aws_route_table_association" "private_db_b" {
  subnet_id      = aws_subnet.private_db_b.id
  route_table_id = aws_route_table.private_db.id
}
