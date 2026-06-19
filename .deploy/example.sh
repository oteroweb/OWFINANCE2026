#!/usr/bin/env bash
# =============================================================================
# .deploy/example.sh — Template de configuracion por entorno
# =============================================================================
# COPIAR a dev.sh / stage.sh / prod.sh y rellenar valores reales.
# Estos archivos estan en .gitignore — NUNCA se commitean.
# =============================================================================
# Uso desde scripts: source "$(dirname "$0")/../.deploy/config.sh" "$ENV"
# =============================================================================

export DEPLOY_ENV="example"

# ── Servidor remoto ──────────────────────────────────────────────────────────
export DEPLOY_HOST="178.156.160.70"
export DEPLOY_PORT="22"
export DEPLOY_USER="appfinan1"
export DEPLOY_SSH_KEY=""                           # vacio = default SSH key

# ── Branch Git ───────────────────────────────────────────────────────────────
export DEPLOY_BRANCH="main"

# ── URLs publicas ────────────────────────────────────────────────────────────
export DEPLOY_SITE_URL="https://appfinanzas.blockshift.website"
export DEPLOY_API_URL="${DEPLOY_SITE_URL}/api/v1"
export DEPLOY_FRONTEND_URL="${DEPLOY_SITE_URL}/app/"

# ── Directorios remotos (rutas relativas al HOME del usuario SSH) ────────────
export DEPLOY_BACKEND_DIR="OWFINANCEBACKEND2025"
export DEPLOY_FRONTEND_DIR="public_html/app"

# ── Frontend build ───────────────────────────────────────────────────────────
export DEPLOY_FRONTEND_ENV_FILE=".env.production"

# ── Backend .htaccess root path (para sed de SPA entry point) ────────────────
export DEPLOY_HTACCESS_PATH="public_html/.htaccess"
