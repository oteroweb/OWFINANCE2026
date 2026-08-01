#!/usr/bin/env bash
# =============================================================================
# deploy-backend.sh — Deploy backend por rsync+SSH
# =============================================================================
# Uso: ./deploy-backend.sh <dev|stage|prod>   (default: stage)
#
# Configuracion:
#   Local:   .deploy/<env>.sh   (gitignored)
#   CI/CD:   Variables de entorno inyectadas por GitHub Actions desde Secrets
# =============================================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$ROOT_DIR/deploy-notify-lib.sh"

ENV="${1:-stage}"

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

# ── Alias locales (compatibilidad con el resto del script) ───────────────────
REMOTE_HOST="$DEPLOY_HOST"
REMOTE_USER="$DEPLOY_USER"
SSH_OPTS="${DEPLOY_SSH_OPTS:-}"
BRANCH="$DEPLOY_BRANCH"
SITE_URL="$DEPLOY_SITE_URL"
REMOTE_DIR="$DEPLOY_BACKEND_DIR"
BACKEND_DIR="$(cd "$(dirname "$0")/OWFINANCEBackend2025" && pwd)"

# ── Colores ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}▶${NC} $*"; }
success() { echo -e "${GREEN}✔${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC} $*"; }
error()   { echo -e "${RED}✗${NC} $*"; exit 1; }

SCRIPT_START_TS=$(date +%s)
TELEGRAM_NOTIFY_TITLE="Backend deploy"
OPS_STATUS_ENV="$ENV"
OPS_STATUS_SUMMARY=""
POST_DEPLOY_OPS_SUMMARY=""
DEPLOY_VERIFY_SUMMARY=""
DEPLOY_VERIFY_URL="${SITE_URL}/up"

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

CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
  info "Cambiando de branch $CURRENT_BRANCH → $BRANCH"
  git checkout "$BRANCH"
fi

info "Respaldando estado actual en el servidor (para rollback si el deploy falla)..."
ROLLBACK_BACKUP_OK=1
if owf_remote_backup_dir "$SSH_OPTS" "$REMOTE_USER" "$REMOTE_HOST" "$REMOTE_DIR"; then
  ROLLBACK_BACKUP_OK=0
  success "Backup remoto creado (~/${REMOTE_DIR}.rollback-backup/)"
else
  warn "No se pudo crear el backup remoto — el deploy sigue, pero sin red de rollback si falla"
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

POST_DEPLOY_OUTPUT="$(ssh $SSH_OPTS "${REMOTE_USER}@${REMOTE_HOST}" /bin/bash << ENDSSH
set -e
cd "\$HOME/${REMOTE_DIR}"
PHP="php"
echo "  [1/6] composer install..."
composer install --no-dev --prefer-dist --no-interaction --quiet 2>/dev/null || true
echo "  [2/6] migraciones..."
\$PHP artisan migrate --force
echo "  [3/6] storage:link..."
\$PHP artisan storage:link || true
echo "  [4/6] caches..."
\$PHP artisan config:cache
\$PHP artisan route:cache
\$PHP artisan view:cache
\$PHP artisan event:cache 2>/dev/null || true
echo "  [5/6] cache:clear..."
\$PHP artisan cache:clear
echo "  [6/6] version..."
\$PHP artisan --version
echo ""
echo "  \u2714 Post-deploy completado."
ENDSSH
)"
echo "$POST_DEPLOY_OUTPUT"

MIGRATIONS_RAN=0
if echo "$POST_DEPLOY_OUTPUT" | grep -q "Migrating:"; then
  MIGRATIONS_RAN=1
fi

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
    warn "Health check falló ($DEPLOY_VERIFY_SUMMARY) — iniciando rollback automático..."
    ROLLBACK_MSG=""
    if [ "$ROLLBACK_BACKUP_OK" -eq 0 ]; then
      if owf_remote_restore_dir "$SSH_OPTS" "$REMOTE_USER" "$REMOTE_HOST" "$REMOTE_DIR"; then
        info "Archivos restaurados desde el backup — re-cacheando..."
        ssh $SSH_OPTS "${REMOTE_USER}@${REMOTE_HOST}" "cd \"\$HOME/${REMOTE_DIR}\" && php artisan config:cache && php artisan route:cache && php artisan view:cache && php artisan cache:clear" || true
        ROLLBACK_VERIFY="$(owf_capture_http_probe "$DEPLOY_VERIFY_URL" "backend-health-post-rollback" || true)"
        case "$ROLLBACK_VERIFY" in
          backend-health-post-rollback=OK:*)
            ROLLBACK_MSG="ROLLBACK EXITOSO — el deploy falló ($DEPLOY_VERIFY_SUMMARY) pero se restauró el código anterior y el servicio volvió a responder ($ROLLBACK_VERIFY)."
            ;;
          *)
            ROLLBACK_MSG="ROLLBACK FALLÓ — el deploy falló Y la restauración no dejó el servicio saludable ($ROLLBACK_VERIFY). Requiere intervención manual inmediata."
            ;;
        esac
      else
        ROLLBACK_MSG="ROLLBACK FALLÓ — no se pudo restaurar el backup remoto. Requiere intervención manual inmediata."
      fi
    else
      ROLLBACK_MSG="Sin backup disponible para rollback (falló al crearlo antes del deploy). Requiere intervención manual inmediata."
    fi

    if [ "$MIGRATIONS_RAN" -eq 1 ]; then
      ROLLBACK_MSG="$ROLLBACK_MSG ADVERTENCIA: este deploy corrió migraciones nuevas que NO se revirtieron automáticamente — revisar el estado de la base de datos a mano antes de reintentar."
    fi

    error "$ROLLBACK_MSG"
    ;;
esac

echo ""
