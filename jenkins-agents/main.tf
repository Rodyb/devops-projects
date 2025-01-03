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

# Variables
variable "digitalocean_token" {
  description = "DigitalOcean API token"
  type        = string
}

variable "controller_name" {
  description = "The name of the Jenkins controller droplet"
  type        = string
}

variable "region" {
  description = "Region to create the resources in"
  type        = string
  default     = "ams3"
}

variable "size" {
  description = "Size of the droplets"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "image" {
  description = "Base image for the droplets (Docker pre-installed)"
  type        = string
  default     = "docker-20-04"
}

# Data Sources
data "digitalocean_ssh_key" "macbook" {
  name = "Macbook"
}

data "digitalocean_droplet" "jenkins_controller" {
  name = var.controller_name
}

# Create Droplets for Jenkins Agents
resource "digitalocean_droplet" "jenkins_agent" {
  count       = 2
  name        = "jenkins-agent-${count.index + 1}"
  region      = var.region
  size        = var.size
  image       = var.image
  ssh_keys    = [data.digitalocean_ssh_key.macbook.id]
  tags        = ["jenkins", "agent"]
}

# Create a New Firewall
resource "digitalocean_firewall" "jenkins_new_firewall" {
  name = "jenkins-new-firewall"

  # Inbound Rules
  inbound_rule {
    protocol         = "tcp"
    port_range       = "all"
    source_addresses = digitalocean_droplet.jenkins_agent[*].ipv4_address
  }

  # Outbound Rules
  outbound_rule {
    protocol             = "tcp"
    port_range           = "all"
    destination_addresses = ["0.0.0.0/0"]
  }

  # Associate the Firewall with Jenkins Controller and Agents
  droplet_ids = concat(
    [data.digitalocean_droplet.jenkins_controller.id],
    digitalocean_droplet.jenkins_agent[*].id
  )
}

# Outputs
output "jenkins_agent_ips" {
  description = "Public IP addresses of the Jenkins agent Droplets"
  value       = digitalocean_droplet.jenkins_agent[*].ipv4_address
  sensitive   = false
}

output "new_firewall_details" {
  description = "Details of the newly created Jenkins firewall"
  value = {
    id             = digitalocean_firewall.jenkins_new_firewall.id
    name           = digitalocean_firewall.jenkins_new_firewall.name
    inbound_rules  = digitalocean_firewall.jenkins_new_firewall.inbound_rule
    outbound_rules = digitalocean_firewall.jenkins_new_firewall.outbound_rule
  }
  sensitive = false
}
