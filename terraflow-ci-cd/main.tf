terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

variable "digitalocean_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "jenkins_public_ip" {
  description = "Public outbound IPv4 address of the Jenkins agent"
  type        = string
}

variable "droplet_name" {
  description = "Name of the DigitalOcean droplet"
  type        = string
  default     = "docker-node-app"
}

variable "region" {
  description = "Region to create the droplet in"
  type        = string
  default     = "ams3"
}

variable "size" {
  description = "Size of the droplet"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "image" {
  description = "Base image for the droplet"
  type        = string
  default     = "docker-20-04"
}

data "digitalocean_ssh_key" "macbook" {
  name = "Macbook"
}

resource "digitalocean_droplet" "app_droplet" {
  name   = var.droplet_name
  region = var.region
  size   = var.size
  image  = var.image

  ssh_keys = [data.digitalocean_ssh_key.macbook.id]

  tags = ["docker-node"]
}

resource "digitalocean_firewall" "app_firewall" {
  name = "app-firewall"

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["${var.jenkins_public_ip}/32"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "7071"
    source_addresses = ["${var.jenkins_public_ip}/32"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  droplet_ids = [digitalocean_droplet.app_droplet.id]
}

output "droplet_ip" {
  description = "The public IP address of the droplet"
  value       = digitalocean_droplet.app_droplet.ipv4_address
}
