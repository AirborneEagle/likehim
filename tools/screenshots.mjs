// Captures phone-shaped screenshots of Like Him by driving a release Flutter
// web build via Playwright + headless Chromium.
//
// Usage:
//   node tools/screenshots.mjs                  # marketing site shots (414×896 @2x)
//   node tools/screenshots.mjs --target=ios-69  # App Store 6.9-inch (1320×2868)
//   node tools/screenshots.mjs --target=ios-65  # App Store 6.5-inch (1284×2778)
//
// Prereq: a static server at localhost:8080 serving build/web from `flutter
// build web --release`.

import { chromium } from 'playwright';
import { fileURLToPath } from 'url';
import path from 'path';
import fs from 'fs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');

const URL_ = 'http://localhost:8080/';

// Targets keyed by --target=<name>. Each emits a PNG at `viewport × dsf`
// physical pixels. The `outDir` is created if missing.
const TARGETS = {
  marketing: {
    viewport: { width: 414, height: 896 },
    dsf: 2,
    outDir: path.join(repoRoot, 'marketing'),
    homeName: 'screenshot-home.png',
    introName: 'screenshot-intro.png',
  },
  'ios-69': {
    // iPhone 17 Pro Max — App Store requires 1320×2868
    viewport: { width: 440, height: 956 },
    dsf: 3,
    outDir: path.join(repoRoot, 'marketing', 'store-screenshots', 'ios-69'),
    homeName: 'home.png',
    introName: 'intro.png',
  },
  'ios-65': {
    // iPhone XS Max / 11 Pro Max — App Store requires 1284×2778
    viewport: { width: 428, height: 926 },
    dsf: 3,
    outDir: path.join(repoRoot, 'marketing', 'store-screenshots', 'ios-65'),
    homeName: 'home.png',
    introName: 'intro.png',
  },
};

const targetName = (process.argv.find((a) => a.startsWith('--target='))?.split('=')[1]) ?? 'marketing';
const TARGET = TARGETS[targetName];
if (!TARGET) {
  console.error(`Unknown target "${targetName}". Valid: ${Object.keys(TARGETS).join(', ')}`);
  process.exit(2);
}
fs.mkdirSync(TARGET.outDir, { recursive: true });
console.log(`Target: ${targetName} → ${TARGET.viewport.width}×${TARGET.viewport.height} @${TARGET.dsf}x → ${TARGET.outDir}`);

const VIEWPORT = TARGET.viewport;

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
  const ctx = await browser.newContext({ viewport: VIEWPORT, deviceScaleFactor: TARGET.dsf });
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
  // the canvas directly. Coords scale with viewport.
  const W = VIEWPORT.width;
  const H = VIEWPORT.height;
  const cx = W / 2;

  // --- Long-press brand mark in the app bar ---
  console.log('→ long-press brand mark (app bar)');
  await page.mouse.move(40, 32);
  await page.mouse.down();
  await page.waitForTimeout(1300);
  await page.mouse.up();
  await page.waitForTimeout(900);
  await snap(page, '03_dev_sheet');

  // Bottom sheet items: each ListTile is ~56–72 tall. From the bottom of the
  // sheet upwards: Delete (last), Set focus, Seed, Auto-fill (top). Sheet
  // hugs the bottom of the viewport with a small inset.
  const tileFromBottom = (n) => H - (36 + n * 76); // 0 = Delete, 1 = Set focus, 2 = Seed, 3 = Auto-fill

  // First: clean up any draft left over from a prior failed run.
  console.log('→ delete all (cleanup)');
  await page.mouse.click(cx, tileFromBottom(0));
  await page.waitForTimeout(800);
  // Confirm dialog: Delete button on the right, vertically near center.
  await page.mouse.click(W - 114, H / 2 + 30);
  await page.waitForTimeout(2000);
  await snap(page, '03b_after_clean');

  // --- Long-press brand mark again, this time to seed history ---
  console.log('→ long-press brand mark (again)');
  await page.mouse.move(40, 32);
  await page.mouse.down();
  await page.waitForTimeout(1300);
  await page.mouse.up();
  await page.waitForTimeout(900);

  console.log('→ tap Seed historical reflections');
  await page.mouse.click(cx, tileFromBottom(2));
  await page.waitForTimeout(6500);
  await snap(page, '04_after_seed');

  const homePath = path.join(TARGET.outDir, TARGET.homeName);
  await page.screenshot({ path: homePath });
  console.log('  saved', homePath);

  // --- Tap "Reflect again" card on home (sits ~215px below the app bar) ---
  console.log('→ tap Reflect again');
  await page.mouse.click(cx, 215);
  await page.waitForTimeout(2500);
  await snap(page, '05_after_reflect');

  const introPath = path.join(TARGET.outDir, TARGET.introName);
  await page.screenshot({ path: introPath });
  console.log('  saved', introPath);

  await browser.close();
  console.log('done');
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
