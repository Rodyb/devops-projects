const { test, expect } = require('@playwright/test');

test('Visit the specified URL', async ({ page }) => {
    // Navigate to the URL
    await page.goto(`${process.env.PLAYWRIGHT_BASE_URL}`);

    // Verify the page loads by checking the title or any element on the page
    const title = await page.title();
    console.log(`Page Title: ${title}`);

    // Expect the title to not be empty
    expect(title).not.toBe('');
});
