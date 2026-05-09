// Captures the two landing-page screenshots by driving a release Flutter web build.

import { chromium } from 'playwright';
import { fileURLToPath } from 'url';
import path from 'path';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');

const URL_ = 'http://localhost:8080/';
const VIEWPORT = { width: 414, height: 896 };

async function snap(page, name) {
  const p = path.join(__dirname, `_step_${name}.png`);
  await page.screenshot({ path: p });
  console.log(`  snap → ${p}`);
}

async function enableA11y(page) {
  await page.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click());
  await page.waitForTimeout(2000);
}

// Find the live screen-space bounding box of a flt-semantics node by exact text.
// Returns null if not found.
async function findBox(page, text, { role = null, pick = 'first' } = {}) {
  return await page.evaluate(
    ({ text, role, pick }) => {
      const sel = role ? `flt-semantics[role="${role}"]` : 'flt-semantics';
      const matches = [...document.querySelectorAll(sel)].filter(
        (e) => (e.textContent || '').trim() === text
      );
      if (matches.length === 0) return null;
      let target;
      if (pick === 'last') target = matches[matches.length - 1];
      else if (pick === 'lowest') {
        target = matches.reduce((a, b) =>
          b.getBoundingClientRect().y > a.getBoundingClientRect().y ? b : a
        );
      } else target = matches[0];
      const r = target.getBoundingClientRect();
      return { x: r.x, y: r.y, w: r.width, h: r.height };
    },
    { text, role, pick }
  );
}

async function clickBox(page, b) {
  await page.mouse.click(b.x + b.w / 2, b.y + b.h / 2);
}

async function waitForBox(page, text, { role = null, timeout = 15_000 } = {}) {
  const deadline = Date.now() + timeout;
  while (Date.now() < deadline) {
    const b = await findBox(page, text, { role });
    if (b && b.w > 0 && b.h > 0) return b;
    await page.waitForTimeout(250);
  }
  throw new Error(`timeout waiting for "${text}"`);
}

(async () => {
  const browser = await chromium.launch({
    headless: true,
    args: ['--use-gl=swiftshader', '--enable-unsafe-swiftshader'],
  });
  const ctx = await browser.newContext({ viewport: VIEWPORT, deviceScaleFactor: 2 });
  const page = await ctx.newPage();
  page.on('pageerror', (e) => console.log('  [pageerror]', e.message));

  console.log('→ load app');
  await page.goto(URL_, { waitUntil: 'load' });
  await page.waitForFunction(() => !!document.querySelector('flt-glass-pane'), null, { timeout: 30_000 });
  await page.waitForTimeout(2500);

  console.log('→ enable a11y tree');
  await enableA11y(page);

  // --- Sign in anonymously by clicking the actual TextButton box ---
  console.log('→ tap "Try Like Him without an account"');
  await waitForBox(page, 'Try Like Him without an account', { role: 'button' });
  const anonLocator = page.locator('flt-semantics[role="button"]').filter({ hasText: 'Try Like Him without an account' }).first();
  await anonLocator.click({ force: true });
  // Anon sign-in takes a moment; home then needs to bind Firestore + render.
  await page.waitForTimeout(8000);
  // Re-enable a11y on the new screen so semantic nodes are exposed again.
  await enableA11y(page);
  await snap(page, '02_after_anon');

  // From here on, use pixel coords for everything — Flutter web doesn't reliably
  // repopulate the semantic tree after the post-auth navigation, so we drive
  // the canvas directly. Coordinates are read from snap captures.

  // --- Long-press brand mark in the app bar ---
  console.log('→ long-press brand mark (app bar)');
  // App bar toolbar is 64px tall; brand row sits left-aligned with default 16px.
  // Center of icon ≈ (32, 32). Press anywhere on the row.
  await page.mouse.move(40, 32);
  await page.mouse.down();
  await page.waitForTimeout(1300);
  await page.mouse.up();
  await page.waitForTimeout(900);
  await snap(page, '03_dev_sheet');

  // First: clean up any draft left over from a prior failed run by tapping
  // "Delete all my reflections" (last item ≈ y=860) → confirm "Delete" button.
  console.log('→ delete all (cleanup)');
  await page.mouse.click(207, 860);
  await page.waitForTimeout(800);
  // Confirm dialog has "Cancel" and "Delete" buttons. "Delete" is the right
  // FilledButton; on a 414w viewport it sits ≈ (300, 470).
  await page.mouse.click(300, 470);
  await page.waitForTimeout(2000);
  await snap(page, '03b_after_clean');

  // --- Long-press brand mark again, this time to seed history ---
  console.log('→ long-press brand mark (again)');
  await page.mouse.move(40, 32);
  await page.mouse.down();
  await page.waitForTimeout(1300);
  await page.mouse.up();
  await page.waitForTimeout(900);

  // Seed tile is the SECOND ListTile in the dev sheet — title text ≈ y=700.
  console.log('→ tap Seed historical reflections');
  await page.mouse.click(207, 700);
  // Snackbar + radar render + wait out snackbar
  await page.waitForTimeout(6500);
  await snap(page, '04_after_seed');

  const homePath = path.join(repoRoot, 'marketing', 'screenshot-home.png');
  await page.screenshot({ path: homePath });
  console.log('  saved', homePath);

  // --- Tap "Reflect again" card ---
  // Order on home (post-seed, no draft): greeting → "Reflect again" gradient
  // card → "Where you are right now" radar card → attributes list.
  // Reflect-again card center ≈ y=215.
  console.log('→ tap Reflect again');
  await page.mouse.click(207, 215);
  await page.waitForTimeout(2500);
  await snap(page, '05_after_reflect');

  const introPath = path.join(repoRoot, 'marketing', 'screenshot-intro.png');
  await page.screenshot({ path: introPath });
  console.log('  saved', introPath);

  await browser.close();
  console.log('done');
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
