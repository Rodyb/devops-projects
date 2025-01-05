
---
# Kubernetes CI/CD Pipeline

This project automates the CI/CD process for deploying a Python application integrated with a PostgreSQL database to a Kubernetes cluster. The pipeline handles the entire lifecycle, including version updates, Docker image building, and Kubernetes deployment.

## Tools Used

- **Jenkins**: Orchestrates the CI/CD pipeline.
- **Docker**: Builds and pushes application images.
- **Kubernetes**: Manages the application deployment.
- **Helm**: Simplifies Kubernetes application deployment.
- **PostgreSQL**: Backend database for the application.

---

## Pipeline Overview

### Parameters
- **`RELEASE_BUILD`**: Indicates whether the pipeline is for a release build. Default is `false`.

### Pipeline Stages

#### 1. Docker Login
Authenticates with Docker Hub to push/pull application images.

```bash
echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
```

#### 2. Update Version for Release (Conditional)
If `RELEASE_BUILD` is `true`, the `CURRENT_MAJOR_RELEASE_VERSION` in `app.py` is incremented and updated for a new release.

```bash
# Increment version in app.py
sed -i "s/^CURRENT_MAJOR_RELEASE_VERSION = \".*\"/CURRENT_MAJOR_RELEASE_VERSION = \"$new_version\"/" app.py
```

#### 3. Commit and Push Changes (Conditional)
For release builds, commits the version changes to the main branch in the repository.

```bash
git config user.name "$GIT_USERNAME"
git config user.email "$GIT_USERNAME"
git add app.py
git commit -m "Updated CURRENT_MAJOR_RELEASE_VERSION and APP_VERSION for release"
git push https://${encoded_username}:${GIT_PASSWORD}@github.com/Rodyb/k8s-test.git HEAD:main
```

#### 4. Build and Push Docker Images
Builds a Docker image of the application and pushes it to Docker Hub.

```bash
# Build Docker image
docker build -t rodybothe2/python-app:${DOCKER_TAG} .

# Push Docker image
docker push rodybothe2/python-app:${DOCKER_TAG}
```

#### 5. Deploy to Kubernetes
Deploys the application and its secrets using Helm.

```bash
# Create Kubernetes secret (if not exists)
kubectl create secret generic postgres-and-python-secret \
  --from-literal=DB_NAME=<DB_NAME> \
  --from-literal=DB_USER=<DB_USER> \
  --from-literal=DB_PASSWORD=<DB_PASSWORD>

# Deploy with Helm
helm upgrade --install python-postgres-chart ./k8s/python-postgres-chart -n ms --create-namespace \
  --set pythonApp.image.repository=rodybothe2/python-app \
  --set pythonApp.image.tag=${DOCKER_TAG} \
  --set env.RELEASE_BUILD=${RELEASE_BUILD}
```

---

## Key Features

- **Conditional Versioning**: Automatically increments the version for release builds.
- **Docker Integration**: Builds and pushes application images.
- **Helm Charts**: Manages Kubernetes deployments.
- **Secrets Management**: Ensures secure handling of PostgreSQL credentials.

---

## Project Structure

```plaintext
.
├── k8s/
│   └── python-postgres-chart/ # Helm chart for application deployment
├── app.py                     # Application source code
├── templates                  # HTML files
├── Dockerfile                 # Dockerfile for building the application image
├── docker-compose.yml         # To run the setup locally
├── requirements.txt           # Packages install file
├── Jenkinsfile                # CI/CD pipeline definition
└── README.md                  # Project documentation
```

---

