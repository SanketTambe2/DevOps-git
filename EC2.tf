# Variables
variable "sg_ports" {
  type        = list(number)
  description = "List of ingress ports"
  default     = [80, 22]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}


# AMI
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

# Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "mykey-new"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHytR9/71L3jn/5Qj9QW6ue2nShgSu3kLUYOVzAJLuZ8 Sanket@LAPTOP-QUR2N0FG"
}

# Security Group for Public Instances
resource "aws_security_group" "public_sg" {
  name        = "Public-EC2-SG"
  vpc_id      = aws_vpc.main.id
  description = "Allow public traffic"

  dynamic "ingress" {
    for_each = var.sg_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for Private Instances
resource "aws_security_group" "private_sg" {
  name        = "Private-EC2-SG"
  vpc_id      = aws_vpc.main.id
  description = "Private instance access within VPC"

  dynamic "ingress" {
    for_each = var.sg_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# User Data Script (Install Apache and MariaDB)
locals {
  user_data = <<-EOT
    #!/bin/bash
    yum update -y
    yum install nginx -y
    systemctl start nginx
    systemctl enable nginx
  EOT
}

# Public EC2 Instance 1
resource "aws_instance" "public_instance_1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  user_data              = local.user_data

  tags = {
    Name = "Public-Instance-1"
  }
}

# Private EC2 Instance 1
resource "aws_instance" "private_instance_1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  user_data              = local.user_data

  tags = {
    Name = "Private-Instance-1"
  }
}

