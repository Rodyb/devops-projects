# Pipelines – Local Usage

This folder contains a small demo setup showing how an application, API tests, and reporting fit together.

The setup is intentionally simple:
- Docker Compose runs the application
- Tests run in a Docker container
- Allure is used for reporting
- Slack is used for notifications (via the pipeline)

---

## Prerequisites

Make sure you have installed:

- Docker
- Docker Compose
- Java (only if you want to run tests outside Docker)
- Allure CLI (optional, for local report generation)

---

## Start the application locally

From the repository root:

```bash
cd pipelines/application
docker compose up -d
````
This will build and start the application stack in the background.
If you navigate to your browser: [http://localhost:5100](http://localhost:5100)
You will see the application that we are going to test.

To stop and clean up:

```bash
docker compose down -v
```

---

## Build the test image

The API tests run inside a Docker container.

```bash
cd pipelines/rest-assured
docker build -t messageboard-rest-tests .
```

---

## Run tests locally

### Integration tests

From the repo root:

```bash
docker run --rm \
  --network application_messageboard-network \
  -v "$(pwd)/allure-results:/tests/target/allure-results" \
  messageboard-rest-tests \
  mvn -B -Dtest=IntegrationTest test
```

---

### E2E tests

```bash
docker run --rm \
  --network application_messageboard-network \
  -v "$(pwd)/allure-results:/tests/target/allure-results" \
  messageboard-rest-tests \
  mvn -B -Dtest=e2eTest test
```

Allure results will be written directly to the local `rest-assured/allure-results` folder.

---

## Generate an Allure report locally 

If you have **Allure CLI** installed:
You can either create the Allure folder or a singel HTML
```bash
allure generate allure-results -o allure-report --clean --single-file
allure open allure-report
```

This will generate a single HTML file and open it in your browser.

```bash
allure generate allure-results -o allure-report --clean 
allure open allure-report
```
---

## Notes

* The Jenkins pipeline uses the same building blocks, but orchestrates them automatically
* Test execution happens inside containers 
* Reporting and notifications are handled separately from test execution

