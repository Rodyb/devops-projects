const { test, expect } = require('@playwright/test');

test('Visit the specified URL', async ({ page }) => {
    await page.goto(`${process.env.PLAYWRIGHT_BASE_URL}`);

    const title = await page.title();
    console.log(`Page Title: ${title}`);

    expect(title).not.toBe('');
});
