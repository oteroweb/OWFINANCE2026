#!/usr/bin/env bash
# deploy-backend.sh — Deploy backend por rsync+SSH
# Uso: ./deploy-backend.sh [stage|dev]   (default: stage)
set -euo pipefail

ENV="${1:-stage}"

REMOTE_HOST="178.156.160.70"
SSH_OPTS="-o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 -o BatchMode=yes"
BACKEND_DIR="$(cd "$(dirname "$0")/OWFINANCEBackend2025" && pwd)"

if [ "$ENV" = "stage" ]; then
  REMOTE_USER="appfinan1"
  BRANCH="stage"
  SITE_URL="https://appfinanzas.blockshift.website"
elif [ "$ENV" = "dev" ]; then
  REMOTE_USER="appfinan2"
  BRANCH="dev"
  SITE_URL="https://appfinanzasdev.blockshift.website"
else
  echo "Uso: $0 [stage|dev]"; exit 1
fi
REMOTE_DIR="OWFINANCEBACKEND2025"

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}▶${NC} $*"; }
success() { echo -e "${GREEN}✔${NC} $*"; }
error()   { echo -e "${RED}✗${NC} $*"; exit 1; }

SCRIPT_START_TS=$(date +%s)
notify_desktop() {
  local title="$1"
  local message="$2"
  if [[ "${OSTYPE:-}" == darwin* ]] && command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"${message}\" with title \"${title}\"" >/dev/null 2>&1 || true
  fi
}

on_exit_notify() {
  local status=$?
  local elapsed=$(( $(date +%s) - SCRIPT_START_TS ))
  if [ "$status" -eq 0 ]; then
    notify_desktop "Deploy Backend (${ENV}) completado" "OK en ${elapsed}s"
  else
    notify_desktop "Deploy Backend (${ENV}) fallido" "Error (exit ${status}) tras ${elapsed}s"
  fi
}
trap on_exit_notify EXIT

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}   DEPLOY BACKEND → ${SITE_URL}${NC}"
echo -e "${CYAN}   Entorno: ${ENV} | Branch: ${BRANCH} | User: ${REMOTE_USER}${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo ""

cd "$BACKEND_DIR"
info "Directorio: $BACKEND_DIR"

# Verificar que estamos en la rama correcta
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
  info "Cambiando de branch $CURRENT_BRANCH → $BRANCH"
  git checkout "$BRANCH"
fi

info "Subiendo archivos por rsync..."
rsync -az --delete \
  --exclude='.git' \
  --exclude='.env' \
  --exclude='vendor/' \
  --exclude='node_modules/' \
  --exclude='public/app/' \
  --exclude='storage/logs/*.log' \
  --exclude='storage/framework/cache/' \
  --exclude='storage/framework/sessions/' \
  --exclude='storage/framework/views/' \
  -e "ssh $SSH_OPTS" \
  "$BACKEND_DIR/" \
  "${REMOTE_USER}@${REMOTE_HOST}:~/${REMOTE_DIR}/"

success "Archivos sincronizados → ~/${REMOTE_DIR}/"

info "Ejecutando post-deploy en servidor..."
echo ""

ssh $SSH_OPTS "${REMOTE_USER}@${REMOTE_HOST}" /bin/bash << ENDSSH
set -e
cd "\$HOME/${REMOTE_DIR}"
PHP="php"
echo "  [1/5] composer install..."
composer install --no-dev --prefer-dist --no-interaction --quiet 2>/dev/null || true
echo "  [2/5] migraciones..."
\$PHP artisan migrate --force
echo "  [3/5] caches..."
\$PHP artisan config:cache
\$PHP artisan route:cache
\$PHP artisan view:cache
\$PHP artisan event:cache 2>/dev/null || true
echo "  [4/5] cache:clear..."
\$PHP artisan cache:clear
echo "  [5/5] version..."
\$PHP artisan --version
echo ""
echo "  \u2714 Post-deploy completado."
ENDSSH

echo ""
success "DEPLOY EXITOSO → ${SITE_URL}/api/v1"
echo ""
