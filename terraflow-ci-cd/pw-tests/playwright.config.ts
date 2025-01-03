import { defineConfig, devices } from "@playwright/test";
import { testPlanFilter } from "allure-playwright/dist/testplan";

import dotenv from "dotenv";
dotenv.config({ path: "./.env" });
const baseURL = process.env.PLAYWRIGHT_BASE_URL
export default defineConfig({
  timeout: 120000,
  expect: { timeout: 20000 },
  testDir: "./tests",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 0,
  workers: 1,
  // workers: process.env.CI ? 1 : undefined,
  grep: testPlanFilter(),
  reporter: [["html"], ["json", { outputFile: "test-results/results.json" }], ["junit", { outputFile: "test-results/results.xml" }], ["allure-playwright"]],
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
    {
      use: {
        ...devices["Desktop Chrome"],
      },
    },
  ],
});
