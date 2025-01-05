# Jenkins Agents Deployment Guide

This project sets up and configures Jenkins agents on DigitalOcean, automating server provisioning, Docker installation, and agent registration with a Jenkins controller.

## Tools Used

- **Terraform**: Provisions Jenkins agent servers on DigitalOcean.
- **Ansible**: Installs Docker and deploys Jenkins agents on the provisioned servers.
- **Jenkins**: Acts as the CI/CD orchestrator.
- **Docker**: Runs Jenkins agents in containerized environments.
- **DigitalOcean**: Cloud hosting provider.

## Pipeline Steps

### 1. Provision Jenkins Agent Servers
Terraform provisions the DigitalOcean droplets to act as Jenkins agents.

```bash
cd terraform/
terraform init
terraform apply -var="digitalocean_token=YOUR_DIGITALOCEAN_TOKEN" -auto-approve
```

This step creates two Jenkins agent droplets and outputs their public IPs.

### 2. Configure Jenkins Agents
Use Ansible to install Docker and deploy Jenkins agents on the provisioned servers.

```bash
# Generate the Ansible inventory
./scripts/generate_inventory.sh <agent-secret-1> <agent-secret-2>

# Run the Ansible playbook
ansible-playbook ./ansible/deploy-jenkins-agents.yml -i ./ansible/inventory.ini
```

The playbook:
- Installs Docker on the droplets.
- Runs the Jenkins agent Docker container.

### 3. Register Agents with Jenkins Controller
The agents automatically register with the Jenkins controller using the provided secrets. Ensure the controller is accessible via its public IP.

```plaintext
Jenkins Controller URL: http://<CONTROLLER_IP>:8080
```

### 4. Validate Agent Registration
Log in to the Jenkins dashboard and confirm the agents are online:
```plaintext
Manage Jenkins -> Nodes and Clouds -> Agents
```

### 5. Cleanup
To destroy the Jenkins agent servers, use Terraform:

```bash
cd terraform/
terraform destroy -var="digitalocean_token=YOUR_DIGITALOCEAN_TOKEN" -auto-approve
```

This step removes the provisioned DigitalOcean droplets.

---

## Directory Structure

```plaintext
.
├── ansible/                   # Ansible playbooks for Docker and agent setup
├── Dockerfile                 # Dockerfile for building the application image
├── Jenkinsfile                # CI/CD pipeline definition
├── main.tf                    # Terraform provisioning file
├── generate_inventory.sh      # Script to create Ansible inventory 
└── README.md                  # Project documentation
```

