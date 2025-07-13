## Lambda-based API Testing with Terraform, Docker & Jenkins

This project demonstrates a CI/CD pipeline for a serverless API, including infrastructure provisioning, deployment, and integration testing.

### Stack

* **Terraform** – For provisioning AWS resources (Lambda, API Gateway, DynamoDB)
* **Jenkins** – Automates deployment and testing pipeline
* **Docker** – Runs tests in a containerized Node.js environment
* **Jest & Axios** – Used for integration testing against live endpoints

### What it does

* Deploys a RESTful Lambda API (`POST /users`, `GET /users/{id}`) using Terraform
* Automatically runs integration tests after deployment using Dockerized Jest tests
* Uses `terraform output` to pass the deployed API URL into the test container
* Optionally destroys all infrastructure in the final Jenkins stage

### Jenkins pipeline flow

1. Provision infrastructure with Terraform
2. Build Docker image for tests (`integrationtest`)
3. Run integration tests using Jest inside the Docker container
4. Run a basic smoke test (`curl`)
5. Destroy infra using `terraform destroy`

```bash
 docker run --rm \
 -e API_URL=${env.API_URL} \
 integrationtest"
```

### Purpose
This project showcases how to test serverless APIs after deployment, leveraging infrastructure as code and container-based testing to ensure production readiness before promoting changes.

