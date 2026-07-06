#!/usr/bin/env bash
# =============================================================================
# deploy-downloads.sh — Publica releases/downloads/ en https://owfinances.com/downloads/
# =============================================================================
# Uso: ./deploy-downloads.sh <dev|stage|prod>   (default: prod)
#
# Sube el contenido de releases/downloads/ (APKs de prueba + index.html) a
# public_html/downloads/ en el servidor. Esa ruta se sirve estática (bypassea
# el router SPA) porque el .htaccess de public_html deja pasar archivos que
# existen en disco antes de reenviar a index.php.
# =============================================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV="${1:-prod}"

source "$ROOT_DIR/.deploy/config.sh"
owf_deploy_load_config "$ENV" || { echo "Error cargando config para '$ENV'" >&2; exit 1; }
owf_deploy_validate || exit 1

SRC_DIR="$ROOT_DIR/releases/downloads/"

if [ ! -d "$SRC_DIR" ]; then
  echo "Error: no existe $SRC_DIR" >&2
  exit 1
fi

echo "▶ Publicando $SRC_DIR → ${DEPLOY_SITE_URL}/downloads/"

rsync -avz -e "ssh $DEPLOY_SSH_OPTS" \
  "$SRC_DIR" \
  "${DEPLOY_USER}@${DEPLOY_HOST}:~/public_html/downloads/"

echo "✔ Publicado → ${DEPLOY_SITE_URL}/downloads/"
