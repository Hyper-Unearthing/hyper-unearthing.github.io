# Managerbot Website

## Development

### Prerequisites

- Ruby (with Bundler)
- Node.js (for visual regression tests)

### Running locally

```bash
bundle install
bundle exec jekyll serve
```

The site will be available at `http://localhost:4000`.

## Visual Regression Testing

Visual regression tests use Playwright to capture screenshots of the home page and compare them against a baseline to detect unintended visual changes.

### Setup

```bash
npm install
npx playwright install chromium
```

### Running tests

1. Start the Jekyll server:
   ```bash
   bundle exec jekyll serve
   ```

2. In a separate terminal, run the visual regression test:
   ```bash
   npm run visual-regression:check
   ```

### Updating the baseline

If you've made intentional visual changes, update the baseline snapshot:

```bash
npm run visual-regression
```

### Output

Each test run saves images in the root directory:
- `visual-regression-current.png` - the current screenshot (always saved)
- `visual-regression-diff.png` - diff image highlighting visual changes (only when differences detected)
