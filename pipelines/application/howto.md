## Messageboard Application – Local & Docker Test Guide

This document explains how to:

1. Run the messageboard application locally using Docker Compose
2. Run REST-Assured tests locally (without Docker)
3. Run REST-Assured tests via Docker (recommended / CI-style)

---

## Prerequisites

### Required tools

* Docker
* Docker Compose
* Java 17 (only needed for local Maven test runs)
* Maven (only needed for local Maven test runs)

Optional (for reports):

* Allure CLI (`brew install allure` on macOS)

---

## 1. Run the Application Locally (Docker Compose)

The application and database are always run via Docker Compose.

### Start the application stack

From the **application** directory:

```bash
cd application
docker compose up -d
```

This will start:

* PostgreSQL database
* Messageboard API
* Messageboard Frontend

The API is exposed on:

```
http://localhost:5100
```

---

### Verify the application is running

```bash
curl http://localhost:5100/api/health
```

Expected response:

```json
{
  "status": "ok"
}
```

---

### Stop the application stack

```bash
docker compose down -v
```

---

## 2. Run Tests Locally (Without Docker)

This is useful for fast feedback during development.

### Prerequisites

* Application must already be running (`docker compose up -d`)
* Java 17
* Maven

---

### Run all tests locally

From the **rest-assured** directory:

```bash
cd rest-assured
mvn test
```

---

### Run only Integration tests

```bash
mvn -Dtest=IntegrationTest test
```

---

### Run only E2E tests

```bash
mvn -Dtest=e2eTest test
```

---

### Environment variables (optional)

By default, tests target:

```
http://localhost:5100
```

Override if needed:

```bash
export BASE_URL=http://localhost:5100
mvn test
```

---

## 3. Run Tests Using Docker (CI-style / Recommended)

This is how the pipeline runs tests and is the **most reliable setup**.

### Build the REST-Assured test image

From the **rest-assured** directory:

```bash
docker build -t messageboard-rest-tests .
```

---

### Run Integration Tests via Docker

Make sure the application stack is running first.

```bash
docker run --rm \
  --network application_messageboard-network \
  -v $(pwd)/allure-results:/tests/target/allure-results \
  messageboard-rest-tests \
  mvn -B -Dtest=IntegrationTest test
```

---

### Run E2E Tests via Docker

```bash
docker run --rm \
  --network application_messageboard-network \
  -v $(pwd)/allure-results:/tests/target/allure-results \
  messageboard-rest-tests \
  mvn -B -Dtest=e2eTest test
```

---

## 4. Generate Allure Report Locally

After tests have run and `allure-results` exists:

```bash
allure generate allure-results -o allure-report --clean
allure open allure-report
```

This will open the report in your browser.
If you want only a simple html with the results

```
allure generate allure-results -o allure-report --clean --sinlge-file

```
---

## 5. Typical Local Workflow

Recommended development flow:

```bash
# 1. Start application
cd application
docker compose up -d

# 2. Run tests
cd ../rest-assured
mvn test

# 3. Generate report
allure generate allure-results -o allure-report --clean
allure open allure-report

# 4. Stop application when done
cd ../application
docker compose down -v
```

---

## Notes & Gotchas

* Tests **will fail** if the application is not running
* API is exposed on **localhost:5100**, not 5000
* Docker-based tests must use the **Docker Compose network**
* Allure reports are generated **outside the container** via volume mounts
* Local Maven tests are faster; Docker tests are closer to CI reality

---

## CI / Jenkins

The Jenkins pipeline:

* Builds the application
* Starts the Docker Compose stack
* Runs Integration tests
* Runs E2E tests
* Generates Allure report
* Sends Slack notification
* Cleans up everything

No manual steps are required for CI.

