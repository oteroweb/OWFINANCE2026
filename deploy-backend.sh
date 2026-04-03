#!/usr/bin/env bash
# deploy-backend.sh — Deploy backend por rsync+SSH
# Uso: ./deploy-backend.sh [stage|dev]   (default: stage)
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$ROOT_DIR/deploy-notify-lib.sh"

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
TELEGRAM_NOTIFY_TITLE="Backend deploy"
OPS_STATUS_ENV="$ENV"
OPS_STATUS_SUMMARY=""
POST_DEPLOY_OPS_SUMMARY=""
DEPLOY_VERIFY_SUMMARY=""
DEPLOY_VERIFY_URL="${SITE_URL}/up"

if [ "$ENV" = "stage" ]; then
  export OWF_STAGE_FRONTEND_URL="${OWF_STAGE_FRONTEND_URL:-${SITE_URL}/app/}"
  export OWF_STAGE_API_BASE_URL="${OWF_STAGE_API_BASE_URL:-${SITE_URL}/api/v1}"
  export OWF_STAGE_HEALTH_URL="${OWF_STAGE_HEALTH_URL:-${SITE_URL}/up}"
fi

on_exit_notify() {
  local status=$?
  local elapsed=$(( $(date +%s) - SCRIPT_START_TS ))
  local desktop_title="Deploy Backend (${ENV}) completado"
  local desktop_message="OK en ${elapsed}s"
  local telegram_type="success"
  local telegram_message
  local status_context

  status_context="$(owf_compose_status_context "$OPS_STATUS_SUMMARY" "$POST_DEPLOY_OPS_SUMMARY" "$DEPLOY_VERIFY_SUMMARY")"

  if [ "$status" -eq 0 ]; then
    telegram_message="$(owf_compose_deploy_message finish backend "$ENV" "$BRANCH" "${SITE_URL}/api/v1" "$elapsed" "$status" "$status_context")"
  else
    desktop_title="Deploy Backend (${ENV}) fallido"
    desktop_message="Error (exit ${status}) tras ${elapsed}s"
    telegram_type="error"
    telegram_message="$(owf_compose_deploy_message finish backend "$ENV" "$BRANCH" "${SITE_URL}/api/v1" "$elapsed" "$status" "$status_context")"
  fi

  owf_send_desktop_notification "$desktop_title" "$desktop_message"
  owf_send_telegram_notification "$ROOT_DIR" "$telegram_type" "$TELEGRAM_NOTIFY_TITLE" "$telegram_message"
}
trap on_exit_notify EXIT

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}   DEPLOY BACKEND → ${SITE_URL}${NC}"
echo -e "${CYAN}   Entorno: ${ENV} | Branch: ${BRANCH} | User: ${REMOTE_USER}${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
echo ""

OPS_STATUS_SUMMARY="$(owf_capture_ops_status "$ROOT_DIR" "$OPS_STATUS_ENV")"
if [ -n "$OPS_STATUS_SUMMARY" ]; then
  info "Ops status inicial: $OPS_STATUS_SUMMARY"
  owf_run_ops_status_report "$ROOT_DIR" "$OPS_STATUS_ENV"
fi

START_MESSAGE="$(owf_compose_deploy_message start backend "$ENV" "$BRANCH" "${SITE_URL}/api/v1" 0 0 "$OPS_STATUS_SUMMARY")"
owf_send_telegram_notification "$ROOT_DIR" "progress" "$TELEGRAM_NOTIFY_TITLE" "$START_MESSAGE"

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
POST_DEPLOY_OPS_SUMMARY="$(owf_capture_ops_status "$ROOT_DIR" "$OPS_STATUS_ENV")"
if [ -n "$POST_DEPLOY_OPS_SUMMARY" ]; then
  info "Ops status final: $POST_DEPLOY_OPS_SUMMARY"
fi

DEPLOY_VERIFY_SUMMARY="$(owf_capture_http_probe "$DEPLOY_VERIFY_URL" "backend-health" || true)"
if [ -n "$DEPLOY_VERIFY_SUMMARY" ]; then
  info "Verificacion HTTP: $DEPLOY_VERIFY_SUMMARY"
fi

case "$DEPLOY_VERIFY_SUMMARY" in
  backend-health=FAIL:*)
    error "Verificacion HTTP fallida para $DEPLOY_VERIFY_URL ($DEPLOY_VERIFY_SUMMARY)"
    ;;
esac

echo ""
