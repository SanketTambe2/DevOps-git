# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"
  tags = { Name = "My-Vpc" }
}

# Public Subnet (Only 1 public subnet)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = { Name = "Public-Subnet-1" }
}

# Private Subnet (Only 1 private subnet)
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "Private-Subnet-1" }
}

# Security Groups
resource "aws_security_group" "public_sg_vpc" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "Public-SG" }
}

resource "aws_security_group" "private_sg_vpc" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "Private-SG" }
}

# Internet Gateway
resource "aws_internet_gateway" "my-IGW" {
  vpc_id    = aws_vpc.main.id
  tags      = { Name = "My-IGW" }
}

# Route-Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id      = aws_vpc.main.id
  tags        = { Name = "Public-RT" }
}

# Edit-Routes for Public Route Table
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"  # Default route for internet traffic
  gateway_id             = aws_internet_gateway.my-IGW.id
}

# Subnet Association for Public Subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Allocate an Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = { Name = "NAT-EIP" }
}

# Create the NAT Gateway in the Public Subnet
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  tags          = { Name = "NAT-Gateway" }
  depends_on    = [aws_internet_gateway.my-IGW]
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "Private-RT" }
}

# Edit-Routes for Private Route Table (via NAT Gateway)
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"  # Default route for internet traffic
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

# Subnet Association for Private Subnet
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

