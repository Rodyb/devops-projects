provider "aws" {
  region = "eu-central-1"
}

variable "environment" {
  description = "some desc"
  type        = string
}

module "vpc" {
  source = "./modules/vpc"
}

module "security" {
  source      = "./modules/security"
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

module "ec2_instance" {
  source                = "./modules/ec2"
  subnet_id             = module.vpc.subnet_id
  vpc_security_group_id = module.security.sg_id
  key_name              = "ssh-aws-test"
}

output "public_ip" {
  value = module.ec2_instance.public_ip
}

output "ssh_command" {
  value = module.ec2_instance.ssh_command
}
