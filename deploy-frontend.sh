#!/usr/bin/env bash
# =============================================================================
# deploy-frontend.sh — Build + Deploy OWFinance Frontend
# =============================================================================
# Uso: ./deploy-frontend.sh <dev|stage|prod> ["mensaje de commit"]
#
# Configuracion:
#   Local:   .deploy/<env>.sh   (gitignored)
#   CI/CD:   Variables de entorno inyectadas por GitHub Actions desde Secrets
# =============================================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$ROOT_DIR/deploy-notify-lib.sh"

# ── Parsear argumentos ───────────────────────────────────────────────────────
ENV="${1:-stage}"
shift 2>/dev/null || true
COMMIT_MSG="${1:-"deploy frontend ${ENV} $(date +'%Y-%m-%d %H:%M')"}"

# ── Cargar configuracion del entorno ─────────────────────────────────────────
DEPLOY_CONFIG_FILE="$ROOT_DIR/.deploy/${ENV}.sh"
if [ -f "$DEPLOY_CONFIG_FILE" ]; then
  # shellcheck source=/dev/null
  source "$ROOT_DIR/.deploy/config.sh"
  owf_deploy_load_config "$ENV" || { echo "Error cargando config para '$ENV'" >&2; exit 1; }
  owf_deploy_validate || exit 1
else
  if [ -z "${DEPLOY_HOST:-}" ] || [ -z "${DEPLOY_USER:-}" ]; then
    echo "Error: no existe .deploy/${ENV}.sh y no hay variables DEPLOY_* en el entorno." >&2
    echo "  Local:  copia .deploy/example.sh → .deploy/${ENV}.sh" >&2
    echo "  CI/CD:  configura los Secrets DEPLOY_HOST, DEPLOY_USER, etc." >&2
    exit 1
  fi
fi

# ── Alias locales ────────────────────────────────────────────────────────────
REMOTE_HOST="$DEPLOY_HOST"
REMOTE_USER="$DEPLOY_USER"
SSH_OPTS="${DEPLOY_SSH_OPTS:-}"
BRANCH="$DEPLOY_BRANCH"
SITE_URL="$DEPLOY_SITE_URL"
REMOTE_DIR="$DEPLOY_FRONTEND_DIR"
ENV_FILE="${DEPLOY_FRONTEND_ENV_FILE:-.env.production}"
FRONTEND_DIR="$(cd "$(dirname "$0")/OWFinanceFrontend2025" && pwd)"
DIST_DIR="$FRONTEND_DIR/dist/spa"

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
DEPLOY_VERIFY_URL="${DEPLOY_FRONTEND_URL}"

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
    telegram_message="$(owf_compose_deploy_message finish frontend "$ENV" "$BRANCH" "${DEPLOY_FRONTEND_URL}" "$elapsed" "$status" "$status_context")"
  else
    desktop_title="Deploy Frontend (${ENV}) fallido"
    desktop_message="Error (exit ${status}) tras ${elapsed}s"
    telegram_type="error"
    telegram_message="$(owf_compose_deploy_message finish frontend "$ENV" "$BRANCH" "${DEPLOY_FRONTEND_URL}" "$elapsed" "$status" "$status_context")"
  fi

  owf_send_desktop_notification "$desktop_title" "$desktop_message"
  owf_send_telegram_notification "$ROOT_DIR" "$telegram_type" "$TELEGRAM_NOTIFY_TITLE" "$telegram_message"
}
trap on_exit_notify EXIT

echo ""
echo -e "${CYAN}══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}   DEPLOY FRONTEND → ${DEPLOY_FRONTEND_URL}          ${NC}"
echo -e "${CYAN}   Entorno: ${ENV} | Branch: ${BRANCH} | User: ${REMOTE_USER}${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════${NC}"
echo ""

OPS_STATUS_SUMMARY="$(owf_capture_ops_status "$ROOT_DIR" "$OPS_STATUS_ENV")"
if [ -n "$OPS_STATUS_SUMMARY" ]; then
  info "Ops status inicial: $OPS_STATUS_SUMMARY"
  owf_run_ops_status_report "$ROOT_DIR" "$OPS_STATUS_ENV"
fi

START_MESSAGE="$(owf_compose_deploy_message start frontend "$ENV" "$BRANCH" "${DEPLOY_FRONTEND_URL}" 0 0 "$OPS_STATUS_SUMMARY")"
owf_send_telegram_notification "$ROOT_DIR" "progress" "$TELEGRAM_NOTIFY_TITLE" "$START_MESSAGE"

# ── 1. Ir al repo frontend ───────────────────────────────────────────────────
cd "$FRONTEND_DIR"
info "Directorio: $FRONTEND_DIR"

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

# ── 4. Build Quasar SPA ─────────────────────────────────────────────────────
info "Compilando Quasar SPA con ${ENV_FILE}..."
cp "$ENV_FILE" .env 2>/dev/null || true
npx quasar build -m spa 2>&1 | tail -10
[ -d "$DIST_DIR" ] || error "Build fallido — dist/spa no encontrado"
success "Build completado → $DIST_DIR"

# ── 5. Inyectar .htaccess + PHP wrapper ──────────────────────────────────────
info "Creando .htaccess para SPA..."
cat > "$DIST_DIR/.htaccess" << 'HTACCESS'
Options -Indexes
DirectoryIndex index.php index.html
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /app/
    RewriteCond %{REQUEST_FILENAME} -f [OR]
    RewriteCond %{REQUEST_FILENAME} -d
    RewriteRule ^ - [L]
    RewriteRule ^ index.php [L]
</IfModule>
HTACCESS
success ".htaccess creado"

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
ssh $SSH_OPTS "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p ~/$REMOTE_DIR"
info "Subiendo SPA al servidor remoto (~/$REMOTE_DIR/)..."
rsync -az --delete \
  -e "ssh $SSH_OPTS" \
  "$DIST_DIR/" \
  "${REMOTE_USER}@${REMOTE_HOST}:~/${REMOTE_DIR}/"

FILE_COUNT=$(find "$DIST_DIR" -type f | wc -l | tr -d ' ')
success "$FILE_COUNT archivos subidos → ~/$REMOTE_DIR/"

# ── 7. Sync assets al root public_html/assets/ ───────────────────────────────
# Los assets deben estar en /assets/ (publicPath '/') para que el proxy del root
# los sirva directamente sin pasar por index.php.
ROOT_ASSETS_DIR="${REMOTE_DIR%/app}/assets"
info "Sincronizando assets al root (~/$ROOT_ASSETS_DIR/)..."
ssh $SSH_OPTS "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p ~/$ROOT_ASSETS_DIR"
rsync -az --delete \
  -e "ssh $SSH_OPTS" \
  "$DIST_DIR/assets/" \
  "${REMOTE_USER}@${REMOTE_HOST}:~/${ROOT_ASSETS_DIR}/"
success "Assets actualizados en root"

# ── 8. Actualizar PHP proxy del root ─────────────────────────────────────────
# Garantiza que _app.html y index.html sean aceptados como entry point del SPA.
if [ -n "${DEPLOY_HTACCESS_PATH:-}" ]; then
  ROOT_PHP="${DEPLOY_HTACCESS_PATH%/.htaccess}/index.php"
  info "Actualizando PHP proxy (~/${ROOT_PHP})..."
  ssh $SSH_OPTS "${REMOTE_USER}@${REMOTE_HOST}" bash << 'REMOTE_PHP'
cat > ~/public_html/index.php << 'PHPEOF'
<?php
$uri = $_SERVER['REQUEST_URI'] ?? '/';
$path = strtok($uri, '?');

// /api/* y /up → Laravel backend
if (preg_match('#^/api(/|$)#', $path) || $path === '/up') {
    $laravel_public = __DIR__ . '/../OWFINANCEBACKEND2025/public';
    chdir($laravel_public);
    $_SERVER['DOCUMENT_ROOT'] = $laravel_public;
    $_SERVER['SCRIPT_FILENAME'] = $laravel_public . '/index.php';
    require $laravel_public . '/index.php';
    exit;
}

// Todo lo demas → SPA
// Acepta _app.html (deploy con PHP wrapper) e index.html (deploy directo)
$spa = __DIR__ . '/app/_app.html';
if (!file_exists($spa)) {
    $spa = __DIR__ . '/app/index.html';
}
if (file_exists($spa)) {
    header('Cache-Control: no-cache, no-store, must-revalidate');
    header('Pragma: no-cache');
    header('Expires: 0');
    readfile($spa);
} else {
    http_response_code(503);
    echo 'Frontend not deployed yet';
}
PHPEOF
REMOTE_PHP
  success "PHP proxy actualizado"
fi

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}   DEPLOY FRONTEND COMPLETADO (${ENV})                      ${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}"
echo ""

success "Frontend listo en: ${DEPLOY_FRONTEND_URL}"
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
