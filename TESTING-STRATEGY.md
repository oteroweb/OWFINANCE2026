# OWFINANCE2026 Testing Strategy

**Version:** 1.0
**Date:** 2026-06-09
**Status:** Active

---

## Overview

This document defines the testing strategy for the OWFINANCE2026 monorepo, covering backend (Laravel 12), frontend (Quasar 2 + Vue 3 + TypeScript), and mobile (Capacitor/Android) layers.

---

## Backend Testing (Laravel 12 / PHPUnit)

### Test Types

#### Unit Tests
Test individual classes, methods, and business logic in isolation (mocked dependencies).

```bash
# Run all unit tests
cd OWFINANCEBackend2025
php artisan test --testsuite=Unit

# Run with coverage report
php artisan test --testsuite=Unit --coverage --min=80

# Run specific test file
php artisan test tests/Unit/JarServiceTest.php
```

Test location: `tests/Unit/`

Examples:
- `tests/Unit/Services/JarServiceTest.php`
- `tests/Unit/Services/TransactionServiceTest.php`
- `tests/Unit/Models/AccountTest.php`

#### Feature Tests
Test HTTP endpoints end-to-end within the Laravel app (uses `RefreshDatabase` trait).

```bash
# Run all feature tests
php artisan test --testsuite=Feature

# Run a specific group
php artisan test --group=auth
php artisan test --group=jars
php artisan test --group=transactions

# Run with verbose output
php artisan test --testsuite=Feature -v
```

Test location: `tests/Feature/`

Examples:
- `tests/Feature/Auth/LoginTest.php`
- `tests/Feature/Jars/JarCrudTest.php`
- `tests/Feature/Transactions/TransactionFlowTest.php`

#### Integration / API Tests
Test real API responses against a test database (SQLite in-memory or a dedicated test DB).

```bash
# Run all tests with .env.testing
php artisan test --env=testing

# Run in parallel (faster CI)
php artisan test --parallel --processes=4
```

Configure `phpunit.xml`:
```xml
<env name="DB_CONNECTION" value="sqlite"/>
<env name="DB_DATABASE" value=":memory:"/>
<env name="CACHE_DRIVER" value="array"/>
<env name="QUEUE_CONNECTION" value="sync"/>
```

---

## Frontend Testing (Quasar 2 + Vue 3 + TypeScript)

### Unit Tests — Vitest

```bash
cd OWFinanceFrontend2025

# Run all unit tests
npm run test:unit

# Watch mode (development)
npm run test:unit -- --watch

# With coverage
npm run test:unit -- --coverage

# Run specific file
npx vitest run src/stores/__tests__/auth.spec.ts
```

`package.json` script (add if missing):
```json
"test:unit": "vitest run",
"test:unit:watch": "vitest",
"test:unit:coverage": "vitest run --coverage"
```

Test location: `src/**/__tests__/` or `src/**/*.spec.ts`

Examples:
- `src/stores/__tests__/auth.spec.ts`
- `src/stores/__tests__/jars.spec.ts`
- `src/components/__tests__/TransactionCard.spec.ts`
- `src/composables/__tests__/useApi.spec.ts`

### E2E Tests — Playwright

```bash
cd OWFinanceFrontend2025

# Install Playwright browsers (first time)
npx playwright install --with-deps chromium

# Run E2E tests against dev
BASE_URL=https://dev.owfinances.com npx playwright test

# Run E2E tests locally (Quasar dev server must be running)
BASE_URL=http://localhost:9000 npx playwright test

# Run specific test file
npx playwright test e2e/auth.spec.ts

# Run with UI (headed mode for debugging)
npx playwright test --ui

# Generate test report
npx playwright show-report
```

Test location: `e2e/`

Examples:
- `e2e/auth.spec.ts` — login, logout, session expiry
- `e2e/jars.spec.ts` — create/edit/delete jar
- `e2e/transactions.spec.ts` — add income/expense, view history
- `e2e/smoke.spec.ts` — critical path after every deploy

---

## Mobile Testing (Capacitor / Android)

### Strategy

Full automated E2E testing on a physical device or emulator is complex with Capacitor. The recommended approach is a layered strategy:

| Layer | Tool | Scope |
|-------|------|-------|
| Web logic | Vitest + Playwright (web) | Covers ~90% of app logic |
| Native bridge | Manual QA checklist | Camera, file access, push notifications |
| APK smoke test | Manual on device | Install, login, core flow |
| Regression | Appium (optional/future) | Automated native UI flows |

### Manual QA Checklist (Android)

After building APK (`./deploy-mobile.sh android dev`), verify:

- [ ] App installs without errors
- [ ] Login flow works (API reachable from device)
- [ ] Bottom navigation transitions
- [ ] FAB opens action sheet
- [ ] Transaction creation saves correctly
- [ ] Jar balances refresh on pull-to-refresh
- [ ] App recovers from background (token still valid)
- [ ] Offline mode shows appropriate message

### Build Commands

```bash
# Build dev APK for testing
./deploy-mobile.sh android dev

# Build staging APK for QA sign-off
./deploy-mobile.sh android staging

# Build production APK
./deploy-mobile.sh android prod

# Or use lower-level scripts:
./build-apk.sh           # Build APK only
./build-android.sh       # Full Android build
```

---

## Coverage Minimums by Module

| Module | Backend Unit | Backend Feature | Frontend Unit | E2E |
|--------|-------------|-----------------|---------------|-----|
| **Auth** | 90% | 85% | 80% | Required |
| **Jars** | 80% | 80% | 75% | Required |
| **Transactions** | 85% | 80% | 75% | Required |
| **Accounts** | 80% | 75% | 70% | Optional |
| **Categories** | 75% | 70% | 65% | Optional |
| **Dashboard** | 70% | 65% | 70% | Required |
| **Overall** | **80%** | **75%** | **70%** | — |

> Coverage is measured by line/branch coverage. Use `--coverage` flags. CI fails if minimums are not met.

---

## Test Pipeline by Environment

### DEV (on every push / PR to `dev`)

```
1. Backend
   └── php artisan test --testsuite=Unit          (fast, ~30s)
   └── php artisan test --testsuite=Feature       (DB: SQLite in-memory)
   └── Laravel Pint (linting)

2. Frontend
   └── npm run test:unit                          (Vitest, ~20s)
   └── TypeScript strict check (tsc --noEmit)
   └── ESLint + Prettier check

3. Build verification
   └── quasar build (SPA mode) — confirm no errors

Total target time: < 5 minutes
```

### STAGE (on merge `dev → stage` / PR to `stage`)

```
1. Full DEV pipeline (above)

2. Backend Integration
   └── php artisan test --parallel --env=testing  (all suites)
   └── Coverage check (fail if below minimums)

3. Frontend E2E
   └── BASE_URL=https://stage.owfinances.com npx playwright test e2e/smoke.spec.ts
   └── BASE_URL=https://stage.owfinances.com npx playwright test e2e/auth.spec.ts
   └── BASE_URL=https://stage.owfinances.com npx playwright test e2e/jars.spec.ts

4. Manual QA sign-off required before merge to stage

Total target time: < 15 minutes automated + manual sign-off
```

### PROD (before / after merge `stage → master`)

```
Pre-deploy (gate):
   1. Stage pipeline passed (required)
   2. Manual QA sign-off on stage.owfinances.com
   3. Security check: php artisan audit (if configured)

Post-deploy smoke tests (automated, ~2 min):
   └── See "Smoke Tests" section below
```

---

## Smoke Tests (Post-Deploy)

Run after every deploy to any environment. Script: `tests/smoke/smoke.sh` (to be created).

### API Smoke Tests

```bash
# Health check
curl -f https://app.owfinances.com/up

# API reachable
curl -f https://app.owfinances.com/api/v1/ping

# Auth endpoint responds
curl -s -o /dev/null -w "%{http_code}" \
  -X POST https://app.owfinances.com/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"wrong@test.com","password":"x"}' \
  | grep -E "^(401|422)$"
```

### Playwright Smoke E2E

```bash
# Minimal smoke: login + home page loads
BASE_URL=https://app.owfinances.com npx playwright test e2e/smoke.spec.ts

# Smoke test covers:
# - Page loads without JS errors
# - Login form renders and submits
# - Home/dashboard route accessible post-login
# - API calls return 2xx (not 500)
```

`e2e/smoke.spec.ts` must include at minimum:
1. Load app URL → HTTP 200, no console errors
2. Login with test credentials → redirect to dashboard
3. Dashboard renders jar list (at least 1 API call succeeds)
4. Logout → redirect to login

### Mobile Smoke (Manual, per APK build)

```
After installing APK:
- [ ] App launches < 3s
- [ ] Login completes
- [ ] Dashboard loads with data
- [ ] Can create a test transaction
```

---

## Running the Full Test Suite Locally

```bash
# ---- Backend ----
cd OWFINANCEBackend2025
cp .env.example .env.testing        # configure test DB
php artisan key:generate --env=testing
php artisan test                    # all suites
php artisan test --coverage         # with coverage

# ---- Frontend ----
cd OWFinanceFrontend2025
npm install
npm run test:unit                   # Vitest unit
npm run build                       # verify build

# ---- E2E (Playwright) ----
npx playwright install --with-deps chromium
BASE_URL=http://localhost:9000 npx playwright test   # requires quasar dev running

# ---- All at once (convenience, run from repo root) ----
# Run backend tests
(cd OWFINANCEBackend2025 && php artisan test)
# Run frontend tests
(cd OWFinanceFrontend2025 && npm run test:unit)
```

---

## Recommended Tools Setup

### PHPUnit (Laravel)

```bash
composer require --dev phpunit/phpunit
# Already included with Laravel 12
```

### Vitest (Frontend)

```bash
cd OWFinanceFrontend2025
npm install --save-dev vitest @vue/test-utils jsdom @vitest/coverage-v8
```

`vitest.config.ts`:
```typescript
import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    environment: 'jsdom',
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'lcov'],
      thresholds: { lines: 70, functions: 70, branches: 65 }
    }
  }
})
```

### Playwright (E2E)

```bash
cd OWFinanceFrontend2025
npm install --save-dev @playwright/test
npx playwright install chromium
```

`playwright.config.ts`:
```typescript
import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  timeout: 30_000,
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:9000',
    headless: true,
    screenshot: 'only-on-failure',
    video: 'retain-on-failure'
  },
  reporter: [['html', { open: 'never' }], ['list']]
})
```

---

**Last Updated:** 2026-06-09
**Next Review:** End of current sprint
