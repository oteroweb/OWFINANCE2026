# GHA Testing Routine: Frontend Views & Backend Services

This document defines the automated testing routine to be implemented in GitHub Actions for OW Finance 2026.

## 1. Strategy Overview

Automated tests are triggered on every push to `main`, `stage`, and `dev` branches to ensure architectural integrity and prevent regressions in core flows.

- **Backend:** Focus on API contract validation and business logic.
- **Frontend:** Focus on view-level snapshots, user journeys, and component interactions.

## 2. Backend Service Testing (Laravel)

The backend uses **Pest PHP** for modern, readable API testing.

### Routine Steps
1. **Environment Setup:** Spin up a MariaDB/MySQL service container.
2. **Dependencies:** `composer install --no-interaction --prefer-dist`.
3. **Database Migration:** `php artisan migrate`.
4. **Execution:** `php artisan test` (or `./vendor/bin/pest`).

### Key Test Categories
- **Auth:** Login, Register, Sanctum token lifecycle.
- **Transactions:** CRUD operations, balance consistency, currency conversion.
- **Jars:** Allocation logic, percentage validation (<= 100%), surplus/deficit reporting.
- **Settings:** Singular `user/settings` route persistence.

---

## 3. Frontend View Testing (Quasar/Vue 3)

The frontend uses **Vitest** for units and **Playwright** for high-fidelity E2E view testing.

### Routine Steps (Unit/Component)
1. **Dependencies:** `npm install`.
2. **Execution:** `npm run test:unit` (Vitest).
3. **Scope:** Store logic (Pinia), utility functions, and isolated component mounting.

### Routine Steps (E2E / Views)
1. **Build:** `npx quasar build -m spa`.
2. **Server:** Start a lightweight static server or use Playwright's built-in webServer.
3. **Execution:** `npx playwright test`.

### Key View Scenarios
- **Lite Layout Navigation:** Verify bottom nav destinations (`/home`, `/transactions`, `/jars`, `/config`).
- **Quick Add Flow:** Verify the FAB opens the transaction sheet and submits correctly.
- **Responsive Check:** Mandatory validation at **375px** width.
- **Theme Check:** Verify Navy `#1E3A8A` and Satoshi font presence.

---

## 4. Trigger & Notification Policy

- **Failures:** Any failing test blocks the merge for PRs and sends an immediate alert to the Telegram Ops channel via `./telegram-notify.sh`.
- **Performance:** GHA jobs should aim for < 5 mins execution time by leveraging caching for `vendor/` and `node_modules/`.
