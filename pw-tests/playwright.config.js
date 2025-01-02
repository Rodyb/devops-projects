const { defineConfig, devices } = require("@playwright/test");
const { testPlanFilter } = require("allure-playwright/dist/testplan");

require("dotenv").config({ path: "./.env" });
const baseURL = process.env.PLAYWRIGHT_BASE_URL;

module.exports = defineConfig({
  timeout: 20000,
  expect: { timeout: 20000 },
  testDir: "./tests",
  testMatch: "**/e2e/flow.spec.js", // Include the specific JS test file
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 0,
  workers: 1,
  grep: testPlanFilter(),
  reporter: [
    ["html"],
    ["json", { outputFile: "test-results/results.json" }],
    ["junit", { outputFile: "test-results/results.xml" }],
    ["allure-playwright"],
  ],
  use: {
    headless: true,
    baseURL: baseURL,
    trace: "on",
    video: {
      mode: "retain-on-failure",
      size: { width: 1280, height: 720 },
    },
    screenshot: "on",
  },
  outputDir: "./videos",
  projects: [
    { name: "setup", testMatch: "./global-setup.ts" },
    {
      name: "poc",
      use: {
        ...devices["Desktop Chrome"],
        storageState: "playwright/.auth/loggedInStatewodan.json",
      },
      dependencies: ["setup"],
    },
  ],
});
