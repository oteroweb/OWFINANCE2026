#!/usr/bin/env bash
# =============================================================================
# .deploy/config.sh — Loader centralizado de configuracion de deploy
# =============================================================================
# Uso: source "$(dirname "$0")/config.sh" "dev"
#      source "$(dirname "$0")/config.sh" "stage"
#      source "$(dirname "$0")/config.sh" "prod"
#
# Exporta todas las variables DEPLOY_* para que los scripts las consuman.
# =============================================================================

DEPLOY_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

owf_deploy_load_config() {
  local env="${1:-}"
  local config_file

  if [ -z "$env" ]; then
    echo "Error: se requiere un entorno (dev|stage|prod)" >&2
    return 1
  fi

  config_file="$DEPLOY_CONFIG_DIR/${env}.sh"

  if [ ! -f "$config_file" ]; then
    echo "Error: no existe $config_file" >&2
    echo "  Copia .deploy/example.sh → .deploy/${env}.sh y configura los valores." >&2
    return 1
  fi

  # shellcheck source=/dev/null
  source "$config_file"

  if [ "${DEPLOY_ENV:-}" != "$env" ]; then
    echo "Error: $config_file tiene DEPLOY_ENV='${DEPLOY_ENV:-}' pero se esperaba '$env'" >&2
    return 1
  fi

  # ── Defaults si no estan definidos ──────────────────────────────────────────
  DEPLOY_PORT="${DEPLOY_PORT:-22}"
  DEPLOY_SSH_KEY="${DEPLOY_SSH_KEY:-}"
  DEPLOY_API_URL="${DEPLOY_API_URL:-${DEPLOY_SITE_URL}/api/v1}"
  DEPLOY_FRONTEND_URL="${DEPLOY_FRONTEND_URL:-${DEPLOY_SITE_URL}/app/}"

  # ── Construir opciones SSH ─────────────────────────────────────────────────
  DEPLOY_SSH_OPTS="-o StrictHostKeyChecking=accept-new -o ConnectTimeout=15 -o BatchMode=yes"
  if [ -n "$DEPLOY_SSH_KEY" ]; then
    DEPLOY_SSH_OPTS="$DEPLOY_SSH_OPTS -i $DEPLOY_SSH_KEY"
  fi

  export DEPLOY_ENV
  export DEPLOY_HOST
  export DEPLOY_PORT
  export DEPLOY_USER
  export DEPLOY_SSH_KEY
  export DEPLOY_BRANCH
  export DEPLOY_SITE_URL
  export DEPLOY_API_URL
  export DEPLOY_FRONTEND_URL
  export DEPLOY_BACKEND_DIR
  export DEPLOY_FRONTEND_DIR
  export DEPLOY_FRONTEND_ENV_FILE
  export DEPLOY_HTACCESS_PATH
  export DEPLOY_SSH_OPTS
  export DEPLOY_REMOTE="${DEPLOY_USER}@${DEPLOY_HOST}"
}

owf_deploy_validate() {
  local missing=()

  [ -z "${DEPLOY_HOST:-}" ]       && missing+=("DEPLOY_HOST")
  [ -z "${DEPLOY_USER:-}" ]       && missing+=("DEPLOY_USER")
  [ -z "${DEPLOY_BRANCH:-}" ]     && missing+=("DEPLOY_BRANCH")
  [ -z "${DEPLOY_SITE_URL:-}" ]   && missing+=("DEPLOY_SITE_URL")
  [ -z "${DEPLOY_BACKEND_DIR:-}" ] && missing+=("DEPLOY_BACKEND_DIR")

  if [ "${#missing[@]}" -gt 0 ]; then
    echo "Error: faltan variables requeridas: ${missing[*]}" >&2
    return 1
  fi

  return 0
}

owf_deploy_print_summary() {
  echo "  Entorno:     $DEPLOY_ENV"
  echo "  Servidor:    $DEPLOY_REMOTE:$DEPLOY_PORT"
  echo "  Branch:      $DEPLOY_BRANCH"
  echo "  Site URL:    $DEPLOY_SITE_URL"
  echo "  API URL:     $DEPLOY_API_URL"
  echo "  Backend dir: ~/$DEPLOY_BACKEND_DIR"
  echo "  Frontend:    ~/$DEPLOY_FRONTEND_DIR"
}
