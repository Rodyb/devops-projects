# Kubernetes CI/CD Pipeline

This project automates the CI/CD process for deploying a Python application with a PostgreSQL database to a Kubernetes cluster. The pipeline handles everything from building Docker images to deploying and testing on Kubernetes.

## Tools Used

- **Jenkins**: Orchestrates the CI/CD pipeline.
- **Docker**: Builds and pushes Docker images.
- **Kubernetes**: Deploys and manages the application.
- **Helm**: Simplifies Kubernetes application deployment.
- **PostgreSQL**: Database for the application.
- **cURL**: Runs post-deployment health checks.

## Pipeline Steps

### 1. Docker Login
The pipeline logs into Docker Hub to allow pushing and pulling Docker images.
```bash
# Executes the following command internally
echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
```

### 2. Build and Push Docker Images
The pipeline builds and pushes a Docker image of the Python application.
```bash
# Build Docker image
docker build -t $DOCKER_USERNAME/python-app:${BUILD_NUMBER} .

# Push image to Docker Hub
docker push $DOCKER_USERNAME/python-app:${BUILD_NUMBER}
```

### 3. Deploy to Kubernetes
The application and its secrets are deployed to a Kubernetes cluster using Helm.
```bash
# Load Kubernetes configuration
export KUBECONFIG=<path-to-kubeconfig>

# Create Kubernetes secrets
kubectl create secret generic postgres-and-python-secret \
  --from-literal=DB_NAME=<DB_NAME> \
  --from-literal=DB_USER=<DB_USER> \
  --from-literal=DB_PASSWORD=<DB_PASSWORD>

# Deploy with Helm
helm upgrade --install python-postgres-chart ./python-postgres-chart -n ms --create-namespace \
  --set image.repository=$DOCKER_USERNAME/python-app \
  --set image.tag=${BUILD_NUMBER}
```

### 4. Post-Deployment Tests
The pipeline verifies the deployment by running a health check using cURL.
```bash
curl -f http://kubernetes-service-url/python-app/health
```

### 5. Cleanup
Cleans up the workspace in Jenkins after the pipeline run.
```bash
# Executes internally in Jenkins
cleanWs()
```

## Directory Structure
```plaintext
.
├── python-postgres-chart/  # Helm chart for Kubernetes deployment
├── Dockerfile              # Dockerfile for building the application image
├── Jenkinsfile             # CI/CD pipeline definition
└── README.md               # Project documentation
```



