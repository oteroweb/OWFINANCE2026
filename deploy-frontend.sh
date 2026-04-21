#!/usr/bin/env bash
# =============================================================================
# deploy-frontend.sh — Build + Deploy OWFinance Frontend
# =============================================================================
# Uso: ./deploy-frontend.sh [stage|dev] ["mensaje de commit"]
#   stage → appfinan1 / branch stage / .env.production
#   dev   → appfinan2 / branch dev   / .env.dev
# =============================================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$ROOT_DIR/deploy-notify-lib.sh"

# ── Entorno ─────────────────────────────────────────────────────────────────
ENV="${1:-stage}"
shift 2>/dev/null || true

REMOTE_HOST="178.156.160.70"
SSH_OPTS="-o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 -o BatchMode=yes"
FRONTEND_DIR="$(cd "$(dirname "$0")/OWFinanceFrontend2025" && pwd)"
DIST_DIR="$FRONTEND_DIR/dist/spa"

if [ "$ENV" = "stage" ]; then
  REMOTE_USER="appfinan1"
  BRANCH="stage"
  ENV_FILE=".env.production"
  SITE_URL="https://appfinanzas.blockshift.website"
  REMOTE_DIR="public_html/app"
elif [ "$ENV" = "dev" ]; then
  REMOTE_USER="appfinan2"
  BRANCH="dev"
  ENV_FILE=".env.dev"
  SITE_URL="https://appfinanzasdev.blockshift.website"
  REMOTE_DIR="OWFINANCEBACKEND2025/public/app"
else
  echo "Uso: $0 [stage|dev] [\"mensaje de commit\"]"; exit 1
fi

COMMIT_MSG="${1:-"deploy frontend ${ENV} $(date +'%Y-%m-%d %H:%M')"}"

# ── Colores ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}▶${NC} $*"; }
success() { echo -e "${GREEN}✔${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC} $*"; }
error()   { echo -e "${RED}✗${NC} $*"; exit 1; }

SCRIPT_START_TS=$(date +%s)
TELEGRAM_NOTIFY_TITLE="Frontend deploy"
OPS_STATUS_ENV="$ENV"
OPS_STATUS_SUMMARY=""
POST_DEPLOY_OPS_SUMMARY=""
DEPLOY_VERIFY_SUMMARY=""
DEPLOY_VERIFY_URL="${SITE_URL}/app/"

if [ "$ENV" = "stage" ]; then
  export OWF_STAGE_FRONTEND_URL="${OWF_STAGE_FRONTEND_URL:-${SITE_URL}/app/}"
  export OWF_STAGE_API_BASE_URL="${OWF_STAGE_API_BASE_URL:-${SITE_URL}/api/v1}"
  export OWF_STAGE_HEALTH_URL="${OWF_STAGE_HEALTH_URL:-${SITE_URL}/up}"
fi

on_exit_notify() {
  local status=$?
  local elapsed=$(( $(date +%s) - SCRIPT_START_TS ))
  local desktop_title="Deploy Frontend (${ENV}) completado"
  local desktop_message="OK en ${elapsed}s"
  local telegram_type="success"
  local telegram_message
  local status_context

  status_context="$(owf_compose_status_context "$OPS_STATUS_SUMMARY" "$POST_DEPLOY_OPS_SUMMARY" "$DEPLOY_VERIFY_SUMMARY")"

  if [ "$status" -eq 0 ]; then
    telegram_message="$(owf_compose_deploy_message finish frontend "$ENV" "$BRANCH" "${SITE_URL}/app/" "$elapsed" "$status" "$status_context")"
  else
    desktop_title="Deploy Frontend (${ENV}) fallido"
    desktop_message="Error (exit ${status}) tras ${elapsed}s"
    telegram_type="error"
    telegram_message="$(owf_compose_deploy_message finish frontend "$ENV" "$BRANCH" "${SITE_URL}/app/" "$elapsed" "$status" "$status_context")"
  fi

  owf_send_desktop_notification "$desktop_title" "$desktop_message"
  owf_send_telegram_notification "$ROOT_DIR" "$telegram_type" "$TELEGRAM_NOTIFY_TITLE" "$telegram_message"
}
trap on_exit_notify EXIT

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}   DEPLOY FRONTEND → ${SITE_URL}/app/                     ${NC}"
echo -e "${CYAN}   Entorno: ${ENV} | Branch: ${BRANCH} | User: ${REMOTE_USER}${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════${NC}"
echo ""

OPS_STATUS_SUMMARY="$(owf_capture_ops_status "$ROOT_DIR" "$OPS_STATUS_ENV")"
if [ -n "$OPS_STATUS_SUMMARY" ]; then
  info "Ops status inicial: $OPS_STATUS_SUMMARY"
  owf_run_ops_status_report "$ROOT_DIR" "$OPS_STATUS_ENV"
fi

START_MESSAGE="$(owf_compose_deploy_message start frontend "$ENV" "$BRANCH" "${SITE_URL}/app/" 0 0 "$OPS_STATUS_SUMMARY")"
owf_send_telegram_notification "$ROOT_DIR" "progress" "$TELEGRAM_NOTIFY_TITLE" "$START_MESSAGE"

# ── 1. Ir al repo frontend ───────────────────────────────────────────────────
cd "$FRONTEND_DIR"
info "Directorio: $FRONTEND_DIR"

# ── Verificar rama correcta ──────────────────────────────────────────────────
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
  info "Cambiando de branch $CURRENT_BRANCH → $BRANCH"
  git checkout "$BRANCH"
fi

# ── 2. Commit si hay cambios ─────────────────────────────────────────────────
if [ -n "$(git status --porcelain)" ]; then
  info "Commiteando cambios pendientes..."
  git add -A
  git commit -m "$COMMIT_MSG"
  success "Commit: $COMMIT_MSG"
else
  info "Sin cambios locales pendientes."
fi

# ── 3. Push a GitHub ─────────────────────────────────────────────────────────
info "Subiendo a GitHub (origin/${BRANCH})..."
git push origin "$BRANCH"
success "Push completado → github.com/oteroweb/OWFINANCEFRONTEND2025 (${BRANCH})"

# ── 4. Build Quasar SPA (modo producción) ───────────────────────────────────
info "Compilando Quasar SPA con ${ENV_FILE}..."
cp "$ENV_FILE" .env 2>/dev/null || true
npx quasar build -m spa 2>&1 | tail -10
[ -d "$DIST_DIR" ] || error "Build fallido — dist/spa no encontrado"
success "Build completado → $DIST_DIR"

# ── 5. Inyectar .htaccess + PHP wrapper (LiteSpeed no soporta Header en .htaccess) ──
info "Creando .htaccess para SPA..."
cat > "$DIST_DIR/.htaccess" << 'HTACCESS'
Options -Indexes
DirectoryIndex index.php index.html
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /app/
    # Servir archivos estáticos directamente (assets, icons, etc.)
    RewriteCond %{REQUEST_FILENAME} -f [OR]
    RewriteCond %{REQUEST_FILENAME} -d
    RewriteRule ^ - [L]
    # Todo lo demás → index.php (Vue Router history mode + Cache-Control via PHP)
    RewriteRule ^ index.php [L]
</IfModule>
HTACCESS
success ".htaccess creado"

# Renombrar index.html → _app.html y crear PHP wrapper con no-cache headers
# LiteSpeed no admite Header set en .htaccess pero sí procesa PHP
info "Creando PHP wrapper para Cache-Control headers..."
mv "$DIST_DIR/index.html" "$DIST_DIR/_app.html"
cat > "$DIST_DIR/index.php" << 'PHPEOF'
<?php
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');
readfile(__DIR__ . '/_app.html');
PHPEOF
success "PHP wrapper creado (index.php → _app.html)"

# ── 6. Deploy al servidor remoto via rsync ───────────────────────────────────
info "Creando carpeta remota si no existe..."
ssh $SSH_OPTS ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ~/$REMOTE_DIR"
info "Subiendo SPA al servidor remoto (~/$REMOTE_DIR/)..."
rsync -az --delete \
  -e "ssh $SSH_OPTS" \
  "$DIST_DIR/" \
  "${REMOTE_USER}@${REMOTE_HOST}:~/${REMOTE_DIR}/"

FILE_COUNT=$(find "$DIST_DIR" -type f | wc -l | tr -d ' ')
success "$FILE_COUNT archivos subidos → ~/$REMOTE_DIR/"

# ── 7. Actualizar root .htaccess para que apunte a index.php (no index.html) ─
# El root .htaccess de Laravel/LiteSpeed necesita apuntar al PHP wrapper del SPA
info "Actualizando root .htaccess en servidor (SPA entry: index.php)..."
ssh $SSH_OPTS ${REMOTE_USER}@${REMOTE_HOST} \
  "sed -i 's|RewriteRule \^ /app/index\.html \[L\]|RewriteRule ^ /app/index.php [L]|g' ~/public_html/.htaccess && echo OK || echo SKIP"

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}   DEPLOY FRONTEND COMPLETADO (${ENV})                      ${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
echo ""

success "Frontend listo en: ${SITE_URL}/app/"
POST_DEPLOY_OPS_SUMMARY="$(owf_capture_ops_status "$ROOT_DIR" "$OPS_STATUS_ENV")"
if [ -n "$POST_DEPLOY_OPS_SUMMARY" ]; then
  info "Ops status final: $POST_DEPLOY_OPS_SUMMARY"
fi

DEPLOY_VERIFY_SUMMARY="$(owf_capture_http_probe "$DEPLOY_VERIFY_URL" "frontend" || true)"
if [ -n "$DEPLOY_VERIFY_SUMMARY" ]; then
  info "Verificacion HTTP: $DEPLOY_VERIFY_SUMMARY"
fi

case "$DEPLOY_VERIFY_SUMMARY" in
  frontend=FAIL:*)
    error "Verificacion HTTP fallida para $DEPLOY_VERIFY_URL ($DEPLOY_VERIFY_SUMMARY)"
    ;;
esac

echo ""
