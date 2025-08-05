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
  description = "IP address of the CI/CD pipeline (e.g. 12.12.12.12)"
  type        = string
}

variable "my_ip" {
  description = "Your own public IP (e.g. 34.56.78.90)"
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

# VPC and networking
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

# App Security Group (open to pipeline + your IP)
resource "aws_security_group" "app_sg" {
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
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [ "${var.pipeline_ip}/32", "${var.my_ip}/32" ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${var.my_ip}/32" ]
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

# Infra Security Group (only open to your IP)
resource "aws_security_group" "infra_sg" {
  name        = "infra-${var.environment}"
  description = "Infra SG: only your IP + app SG"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = [ "${var.my_ip}/32" ]
  }

  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = [ "${var.my_ip}/32" ]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [ "${var.my_ip}/32" ]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = [ "${var.my_ip}/32" ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "${var.my_ip}/32" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name        = "sg-infra-${var.environment}"
    Environment = var.environment
  }
}

# Allow App EC2 to access Infra EC2
resource "aws_security_group_rule" "allow_app_to_infra" {
  type                     = "ingress"
  from_port                = 9090
  to_port                  = 9090
  protocol                 = "tcp"
  security_group_id        = aws_security_group.infra_sg.id
  source_security_group_id = aws_security_group.app_sg.id
}

resource "aws_security_group_rule" "allow_app_to_alertmanager" {
  type                     = "ingress"
  from_port                = 9093
  to_port                  = 9093
  protocol                 = "tcp"
  security_group_id        = aws_security_group.infra_sg.id
  source_security_group_id = aws_security_group.app_sg.id
}

resource "aws_security_group_rule" "allow_app_to_grafana" {
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.infra_sg.id
  source_security_group_id = aws_security_group.app_sg.id
}

resource "aws_security_group_rule" "allow_app_to_nexus" {
  type                     = "ingress"
  from_port                = 8081
  to_port                  = 8081
  protocol                 = "tcp"
  security_group_id        = aws_security_group.infra_sg.id
  source_security_group_id = aws_security_group.app_sg.id
}

# EC2 Instances
resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.vpc_subnet.id
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true
  key_name                    = "ssh-aws-test"

  tags = {
    Name = "app-${var.environment}"
  }
}

resource "aws_instance" "infra" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.vpc_subnet.id
  vpc_security_group_ids      = [aws_security_group.infra_sg.id]
  associate_public_ip_address = true
  key_name                    = "ssh-aws-test"

  tags = {
    Name = "infra-${var.environment}"
  }
}

# Outputs
output "app_public_ip" {
  value = aws_instance.app.public_ip
}

output "infra_public_ip" {
  value = aws_instance.infra.public_ip
}

output "app_ssh" {
  description = "SSH command for App EC2"
  value       = "ssh -i ~/.ssh/ssh-aws-test.pem ubuntu@${aws_instance.app.public_ip}"
}

output "infra_ssh" {
  description = "SSH command for Infra EC2"
  value       = "ssh -i ~/.ssh/ssh-aws-test.pem ubuntu@${aws_instance.infra.public_ip}"
}
