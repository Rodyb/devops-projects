## PLAYWRIGHT API & UI TESTS.

## Local Environment.
* To install Playwright locally `npm install`
* To run the docker compose file `docker-compose -f docker-compose-local.yml --env-file .env.example up` this will start the Dyflexis application
* To run the tests against the local environment via the test runner `acceptancePassword=<pass> dbPassword='db' PLAYWRIGHT_BASE_URL=http://localhost/customer npx playwright test --ui` and pick the tests you want to run. 
* To run them without the runner `acceptancePassword=<pass> dbPassword='db' PLAYWRIGHT_BASE_URL=http://localhost/customer npx playwright test <folder of tests> --headed ` this will run with browser open
* All test results can be found in teams: Team QA channel and in the Allure report.
  ![image info](gitlab/allure.png)

## DOCKERFILES RELATED TO PROJECT
* All dockerfiles used in Gitlab can be found in the docker folder
* Playwright, K6, dotenv, allure

## SCRIPTS
There are multiple scripts that have different functions
- Get monolith image tag, does some api calls to retrieve latest successful master, and populate docker compose (this is used in the pipeline if there is no trigger from monolith repo)
- Insert feature flags inserts all sorts of settings which are used in the tests into the db in docker compose
- replace env password, is used to substitute the password from the env file in gitlab
- Run trend histroy is used to populate the trend line in the allure report for master
- Notify teams sends a message of the test results to MS teams
- splits tests, splits the test folder into different parallels. 

## REPOSITORY
The repository consists of pages, helpers, tests and global setup
- Pages holds the page object models where all methods and selectors are defined
- Helpers hold the page helpers, that have methods which are used to setup certain states and are not directly related to the pages
- global setup holds the authentication which is done via API requests to enable wodan
- Tests 

## Best practices
* https://dyflexis.atlassian.net/wiki/spaces/DEV/pages/249167911/Guidelines

## TEST RESULTS
* This can be found MS teams QA channel