variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, test, prod)"
  type        = string
}

variable "pipeline_ip" {
  description = "Pipeline ip"
  type        = string
}

variable "my_ip" {
  description = "My own ip"
  type        = string
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "vpc_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.vpc_subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "app_nexus" {
  name        = "app-${var.environment}"
  description = "App SG: pipeline + your IP"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [ "${var.pipeline_ip}/32", "${var.my_ip}/32" ]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [ "${var.pipeline_ip}/32", "${var.my_ip}/32" ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${var.pipeline_ip}/32", "${var.my_ip}/32" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name        = "sg-app-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.small"
  subnet_id                   = aws_subnet.vpc_subnet.id
  vpc_security_group_ids      = [aws_security_group.app_nexus.id]
  associate_public_ip_address = true
  key_name                    = "ssh-aws-test"

  tags = {
    Name = "app-${var.environment}"
  }
}

output "app_public_ip" {
  value = aws_instance.app.public_ip
}

output "app_ssh" {
  description = "SSH command for Application stack"
  value       = "ssh -i ~/.ssh/ssh-aws-test.pem ubuntu@${aws_instance.app.public_ip}"
}
