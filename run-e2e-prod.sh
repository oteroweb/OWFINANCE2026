#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# run-e2e-prod.sh — Smoke tests post-deploy contra https://owfinances.com
#
# Uso:
#   ./run-e2e-prod.sh                         # todos los specs
#   ./run-e2e-prod.sh --api-only              # solo transaction-api.spec.ts
#   ./run-e2e-prod.sh --ui-only               # solo transaction-ui.spec.ts
#   ./run-e2e-prod.sh --spec e2e/auth.spec.ts # spec concreto
#
# Vars requeridas (en .env o export antes de llamar):
#   PLAYWRIGHT_TEST_EMAIL
#   PLAYWRIGHT_TEST_PASSWORD
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

FRONTEND_DIR="$(cd "$(dirname "$0")/OWFinanceFrontend2025" && pwd)"
CONFIG="playwright.prod.config.cjs"
SPEC=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --api-only) SPEC="e2e/transaction-api.spec.ts"; shift ;;
    --ui-only)  SPEC="e2e/transaction-ui.spec.ts";  shift ;;
    --spec)     SPEC="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

# Load .env if present
if [[ -f "$(dirname "$0")/.env" ]]; then
  set -a; source "$(dirname "$0")/.env"; set +a
fi

# Validate credentials
if [[ -z "${PLAYWRIGHT_TEST_EMAIL:-}" ]]; then
  echo "❌ PLAYWRIGHT_TEST_EMAIL not set. Export it or add to .env"
  exit 1
fi

echo ""
echo "══════════════════════════════════════════════"
echo "  OWFinance E2E — prod smoke tests"
echo "  target: https://owfinances.com"
echo "  email:  $PLAYWRIGHT_TEST_EMAIL"
echo "══════════════════════════════════════════════"
echo ""

cd "$FRONTEND_DIR"

CMD="npx playwright test --config $CONFIG"
[[ -n "$SPEC" ]] && CMD="$CMD $SPEC"

eval "$CMD"
EXIT=$?

echo ""
if [[ $EXIT -eq 0 ]]; then
  echo "✅ Todos los tests pasaron"
else
  echo "❌ Algunos tests fallaron (exit $EXIT)"
  echo "   Ver reporte: $FRONTEND_DIR/playwright-report-prod/index.html"
fi

exit $EXIT
