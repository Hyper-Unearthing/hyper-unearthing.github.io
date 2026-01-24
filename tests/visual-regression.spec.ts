import { test, expect } from '@playwright/test';
import * as fs from 'fs';
import * as path from 'path';

const OUTPUT_DIR = path.join(__dirname, '..');
const DIFF_IMAGE = path.join(OUTPUT_DIR, 'visual-regression-diff.png');
const CURRENT_IMAGE = path.join(OUTPUT_DIR, 'visual-regression-current.png');

test('home page visual regression', async ({ page }, testInfo) => {
  await page.goto('/');

  // Wait for the page to be fully loaded
  await page.waitForLoadState('networkidle');

  // Always save the current screenshot
  const screenshot = await page.screenshot({ fullPage: true });
  fs.writeFileSync(CURRENT_IMAGE, screenshot);

  try {
    await expect(page).toHaveScreenshot('home-page.png', {
      fullPage: true,
      maxDiffPixelRatio: 0.01,
    });

    // Test passed - remove diff image if it exists
    if (fs.existsSync(DIFF_IMAGE)) {
      fs.unlinkSync(DIFF_IMAGE);
    }
    console.log(`✓ No visual differences detected.`);
    console.log(`  Current screenshot: ${CURRENT_IMAGE}`);
  } catch (error) {
    // Test failed - find and copy the diff image
    const attachments = testInfo.attachments;
    const diffAttachment = attachments.find(a => a.name === 'home-page-diff.png');

    if (diffAttachment && diffAttachment.path) {
      fs.copyFileSync(diffAttachment.path, DIFF_IMAGE);
      console.log(`✗ Visual differences detected!`);
      console.log(`  Diff image: ${DIFF_IMAGE}`);
      console.log(`  Current screenshot: ${CURRENT_IMAGE}`);
    } else {
      console.log(`✗ Visual differences detected.`);
      console.log(`  Current screenshot: ${CURRENT_IMAGE}`);
    }

    throw error;
  }
});
