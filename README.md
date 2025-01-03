# DevOps Projects Overview

This repository contains a collection of streamlined DevOps pipelines and automation tools for provisioning, deploying, and managing applications across various platforms.

---

## Projects

### 1. **Jenkins Agents**
- **Purpose**: Automates the provisioning and configuration of Jenkins agents.
- **Key Tools**: Terraform, Ansible, Docker, DigitalOcean.
- **Features**:
    - Dynamically provisions servers on DigitalOcean.
    - Configures Jenkins agents with Docker.
    - Enables seamless integration with the Jenkins controller.
- **Folder**: [`jenkins-agents`](./jenkins-agents)

### 2. **Kubernetes Helm Python**
- **Purpose**: Automates the deployment of a Python application with a PostgreSQL database on Kubernetes using Helm.
- **Key Tools**: Kubernetes, Helm, Docker, PostgreSQL.
- **Features**:
    - CI/CD pipeline with Jenkins.
    - Simplified Helm-based Kubernetes deployments.
    - Integrated database and application secrets management.
- **Folder**: [`kubernetes-helm-python`](./kubernetes-helm-python)

### 3. **TerraFlow CI/CD**
- **Purpose**: A complete CI/CD pipeline for Java applications with Terraform and Playwright testing.
- **Key Tools**: Terraform, Ansible, Gradle, Docker, Playwright, Nexus.
- **Features**:
    - Provisions infrastructure with Terraform.
    - Builds and deploys Java applications using Gradle and Docker.
    - Runs end-to-end Playwright tests.
    - Stores artifacts in Nexus.
- **Folder**: [`terraflow-ci-cd`](./terraflow-ci-cd)

---

## Usage

Each project has its own dedicated directory with an **in-depth README** containing detailed setup instructions and pipeline steps. Navigate to the respective folder for specifics.

---

### Example Directory Structure

```plaintext
devops-projects/
├── jenkins-agents/          # Jenkins agent provisioning and setup
├── kubernetes-helm-python/  # Kubernetes Python app deployment
└── terraflow-ci-cd/         # Full CI/CD pipeline for Java apps
```

Explore each folder for more details and how to get started!