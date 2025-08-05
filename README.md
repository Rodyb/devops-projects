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

### 4. **Monitoring Flask App**
- **Purpose**: Sets up a complete monitoring stack for a Flask application, using Prometheus, Grafana, and Alertmanager.
- **Key Tools**: Prometheus, Grafana, Alertmanager, Docker Compose.
- **Features**:
  - Tracks metrics like request count and latency for the Flask app.
  - Visualizes metrics with Grafana dashboards.
  - Sends alerts for high request volume and service outages.
  - Runs load tests with K6 to simulate traffic.
- **Folder**: [`monitoring-flask-app`](./monitoring-flask-app)

### 5. **Serverless Lambda API**
- **Purpose**: Deploys a serverless REST API using AWS Lambda, DynamoDB, and API Gateway with CI/CD integration
- **Key Tools**: Terraform, AWS Lambda, DynamoDB, API Gateway, Jenkins, Docker, Jest.
- **Features**:
  - Provisions infrastructure with Terraform including Lambda functions, IAM roles, API Gateway routes, and DynamoDB.
  - Defines three endpoints: POST /users, GET /users/{id}, and GET /users for CRUD operations.
  - Runs integration tests using Jest inside a Docker container from a Jenkins pipeline.
  - Automatically destroys infrastructure with a conditional teardown stage.
- **Folder**: [`aws-lambda`](./aws-lambda)

---

## Usage

Each project has its own dedicated directory with an **in-depth README** containing detailed setup instructions and pipeline steps. Navigate to the respective folder for specifics.

---

### Example Directory Structure

```plaintext
devops-projects/
├── jenkins-agents/          # Jenkins agent provisioning and setup
├── kubernetes-helm-python/  # Kubernetes Python app deployment
├── terraflow-ci-cd/         # Full CI/CD pipeline for Java apps
├── aws-lambda/              # Serverless REST API with full CI/CD 
└── monitoring/              # Monitoring stack for Flask app
```
