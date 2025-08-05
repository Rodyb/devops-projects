# TerraFlow CI/CD Suite

TerraFlow CI/CD Suite is a streamlined DevOps pipeline that automates application deployment from server provisioning to artifact storage.

## Tools Used
- **Terraform**: Provisions servers.
- **Ansible**: Installs Docker on servers.
- **Gradle**: Builds the application.
- **Docker**: Builds, pushes, and runs the application on Docker Hub.
- **Playwright**: Validates the application with isolated tests.
- **Nexus**: Stores the final Docker image.
- **DIGITAL OCEAN** Cloud hosting
## Pipeline Steps

### 1. Provision Servers
Terraform sets up a dynamic test environment.
```bash
cd terraform/
terraform init
terraform apply -var="digitalocean_token=YOUR_DIGITALOCEAN_TOKEN" -auto-approve
```

### 2. Install Docker
Use Ansible to install Docker on the provisioned server.
```bash
ansible-playbook ./ansible/deploy-docker.yml -i '<DROPLET_IP>,' -e "ansible_host=<DROPLET_IP> ansible_user=root"
```

### 3. Build the Application
Use Gradle to build the application.
```bash
cd java-react-example
gradle clean build
```

### 4. Deploy the Application
Use Docker to build, push, and run the application.
```bash
# Build Docker image
cd java-react-example
docker build -t <DOCKER_USERNAME>/java-app-country:<BUILD_NUMBER> .

# Push image to Docker Hub
docker push <DOCKER_USERNAME>/java-app-country:<BUILD_NUMBER>

# Run the container remotely
ssh -o StrictHostKeyChecking=no root@<DROPLET_IP> "\
  docker pull <DOCKER_USERNAME>/java-app-country:<BUILD_NUMBER> && \
  docker run -d -p 7071:7071 --name java-app <DOCKER_USERNAME>/java-app-country:<BUILD_NUMBER>"
```

### 5. Test the Application
Use Playwright to run end-to-end tests.
```bash
cd pw-tests
docker run --rm \
  --env PLAYWRIGHT_BASE_URL=http://<DROPLET_IP>:7071 \
  rodybothe2/pw-final npx playwright test tests/e2e/verify_url.spec.ts
```

### 6. Store Artifacts
Push the Docker image to Nexus for storage.
```bash
# Tag the image for Nexus
docker tag <DOCKER_USERNAME>/java-app-country:<BUILD_NUMBER> <NEXUS_URL>/<IMAGE_NAME>:<BUILD_NUMBER>

# Push the image to Nexus
docker push <NEXUS_URL>/<IMAGE_NAME>:<BUILD_NUMBER>
```

### 7. Cleanup
Use Terraform to destroy the test environment.
```bash
terraform destroy -var="digitalocean_token=YOUR_DIGITALOCEAN_TOKEN" -auto-approve
```

## Directory Structure
```plaintext
.
├── ansible/            # Ansible playbooks
├── java-react-example/ # Application source code
├── pw-tests/           # Playwright test scripts
├── Jenkinsfile         # CI/CD pipeline definition
├── main.tf             # Terraform provisioning file
└── README.md           # Project documentation
```


