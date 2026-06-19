#!/usr/bin/env bash
# =============================================================================
# .deploy/sync-secrets.sh — Sincroniza .deploy/<env>.sh → GitHub Secrets
# =============================================================================
# Uso: .deploy/sync-secrets.sh <dev|stage|prod> <repo>
#
# Lee las variables DEPLOY_* del archivo local y las sube como GitHub Secrets
# usando `gh secret set`. Solo sincroniza las variables que no estan vacias.
#
# Ejemplos:
#   .deploy/sync-secrets.sh stage OWFINANCEBACKEND2025
#   .deploy/sync-secrets.sh prod  OWFINANCEBACKEND2025
# =============================================================================
set -euo pipefail

DEPLOY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$DEPLOY_DIR/.." && pwd)"

ENV="${1:-}"
REPO="${2:-}"

if [ -z "$ENV" ] || [ -z "$REPO" ]; then
  echo "Uso: $0 <dev|stage|prod> <repo>"
  echo ""
  echo "Repos disponibles:"
  echo "  OWFINANCEBACKEND2025"
  echo "  OWFINANCEFRONTEND2025"
  echo ""
  echo "Ejemplo: $0 prod OWFINANCEBACKEND2025"
  exit 1
fi

CONFIG_FILE="$DEPLOY_DIR/${ENV}.sh"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: no existe $CONFIG_FILE" >&2
  echo "  Copia .deploy/example.sh → .deploy/${ENV}.sh y configura los valores." >&2
  exit 1
fi

command -v gh >/dev/null 2>&1 || { echo "Error: gh CLI no instalado" >&2; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Error: gh CLI no autenticado. Ejecuta: gh auth login" >&2; exit 1; }

FULL_REPO="oteroweb/${REPO}"

echo "Sincronizando secrets de ${ENV} → ${FULL_REPO}"
echo ""

source "$DEPLOY_DIR/config.sh"
owf_deploy_load_config "$ENV" || exit 1

SECRETS_SET=0
SECRETS_SKIPPED=0

set_secret() {
  local name="$1"
  local value="$2"

  if [ -z "$value" ]; then
    echo "  SKIP $name (vacio)"
    SECRETS_SKIPPED=$((SECRETS_SKIPPED + 1))
    return
  fi

  echo "$value" | gh secret set "$name" --repo "$FULL_REPO" 2>&1
  echo "  OK   $name"
  SECRETS_SET=$((SECRETS_SET + 1))
}

echo "Subiendo variables DEPLOY_*..."
set_secret "DEPLOY_HOST"          "${DEPLOY_HOST:-}"
set_secret "DEPLOY_PORT"          "${DEPLOY_PORT:-}"
set_secret "DEPLOY_USER"          "${DEPLOY_USER:-}"
set_secret "DEPLOY_BRANCH"        "${DEPLOY_BRANCH:-}"
set_secret "DEPLOY_SITE_URL"      "${DEPLOY_SITE_URL:-}"
set_secret "DEPLOY_API_URL"       "${DEPLOY_API_URL:-}"
set_secret "DEPLOY_BACKEND_DIR"   "${DEPLOY_BACKEND_DIR:-}"
set_secret "DEPLOY_FRONTEND_DIR"  "${DEPLOY_FRONTEND_DIR:-}"
set_secret "DEPLOY_FRONTEND_ENV_FILE" "${DEPLOY_FRONTEND_ENV_FILE:-}"
set_secret "DEPLOY_HTACCESS_PATH" "${DEPLOY_HTACCESS_PATH:-}"

echo ""
echo "Resultado: ${SECRETS_SET} secrets configurados, ${SECRETS_SKIPPED} omitidos (vacios)"
echo ""
echo "Verificar:"
echo "  gh secret list --repo ${FULL_REPO}"
