#!/usr/bin/env bash
# =============================================================================
# deploy-ios.sh — Build + instalar + lanzar en el iPhone conectado por USB
# =============================================================================
# Uso: ./deploy-ios.sh
#
# Requisitos (una sola vez, ya hechos en esta Mac):
#   - Xcode.app completo instalado (no solo Command Line Tools)
#   - Apple ID cargado en Xcode > Settings > Accounts
#   - Team seleccionado en Signing & Capabilities del target App
#   - Developer Mode activado en el iPhone (Ajustes > Privacidad y seguridad)
#   - iPhone conectado por USB y "Confiar" aceptado (una vez por Mac)
#
# Auto-detecta el primer dispositivo iOS físico conectado (available/connected).
# =============================================================================
set -euo pipefail

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRONTEND_DIR="$ROOT_DIR/OWFinanceFrontend2025"
IOS_APP_DIR="$FRONTEND_DIR/src-capacitor/ios/App"
BUNDLE_ID="com.owfinance.app"

GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()    { echo -e "${BLUE}▶${NC} $*"; }
success() { echo -e "${GREEN}✔${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC} $*"; }
error()   { echo -e "${RED}✗${NC} $*"; exit 1; }

echo ""
echo "=================================================="
echo "  🍎 DEPLOY iOS — OWFINANCE (dispositivo físico)"
echo "=================================================="

# 1. Detectar iPhone/iPad conectado.
#    `devicectl list devices` filtra por modelo (excluye la propia Mac), pero
#    su columna Identifier es un GUID que xcodebuild/devicectl NO aceptan como
#    destino — hay que resolverlo al UDID real vía `device info details`.
info "Buscando iPhone conectado..."
DEVICE_GUID=$(xcrun devicectl list devices 2>/dev/null | awk '/iPhone|iPad/ {print $3}' | head -1)

if [ -z "$DEVICE_GUID" ]; then
  error "No se encontró ningún iPhone/iPad conectado. Conectalo por USB, desbloqueá la pantalla y reintentá."
fi

DEVICE_ID=$(xcrun devicectl device info details --device "$DEVICE_GUID" 2>/dev/null | awk -F': ' '/udid:/{print $2}' | head -1 | tr -d ' ')

if [ -z "$DEVICE_ID" ]; then
  error "Se detectó el dispositivo pero no se pudo resolver su UDID."
fi
success "Dispositivo: $DEVICE_ID"

# 2. Build web (Quasar). --skip-pkg = solo bundlear la UI en www/, sin que
#    quasar dispare su propio build nativo (side-effect real que vimos con
#    -T android → gradle y -T ios → xcodebuild genérico, ambos redundantes
#    con el xcodebuild explícito que hacemos nosotros más abajo).
info "Compilando Quasar..."
cd "$FRONTEND_DIR"
npx quasar build -m capacitor -T ios --skip-pkg > /tmp/owf-ios-quasar-build.log 2>&1 || {
  error "Falló el build de Quasar. Ver: /tmp/owf-ios-quasar-build.log"
}
success "Build Quasar OK"

# 3. Sync Capacitor iOS
info "Sincronizando Capacitor iOS..."
cd "$FRONTEND_DIR/src-capacitor"
npx cap sync ios > /tmp/owf-ios-sync.log 2>&1 || {
  error "Falló cap sync ios. Ver: /tmp/owf-ios-sync.log"
}
success "Sync OK"

# 4. Build Xcode a dispositivo
info "Compilando con Xcode (puede tardar unos minutos la primera vez)..."
cd "$IOS_APP_DIR"
xcodebuild -workspace App.xcworkspace -scheme App -destination "id=$DEVICE_ID" -allowProvisioningUpdates build \
  > /tmp/owf-ios-xcodebuild.log 2>&1 || {
  error "Falló xcodebuild. Ver: /tmp/owf-ios-xcodebuild.log (si menciona firma/certificado, revisá Signing & Capabilities en Xcode)"
}
success "Build Xcode OK"

# 5. Ubicar el .app generado. showBuildSettings sin -target mezcla los
#    valores de varios targets (App, Pods-App, etc.) — más simple y confiable
#    buscar directo el bundle más reciente en DerivedData.
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -path "*/Build/Products/Debug-iphoneos/App.app" -maxdepth 6 -print0 2>/dev/null \
  | xargs -0 ls -dt 2>/dev/null | head -1)

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
  error "No se encontró el .app compilado en: $APP_PATH"
fi

# 6. Instalar
info "Instalando en el dispositivo..."
xcrun devicectl device install app --device "$DEVICE_ID" "$APP_PATH" || error "Falló la instalación"
success "Instalado"

# 7. Lanzar
info "Abriendo la app..."
xcrun devicectl device process launch --device "$DEVICE_ID" "$BUNDLE_ID" || {
  warn "App instalada pero no se pudo abrir automáticamente. Motivos posibles:"
  warn "  1. Pantalla bloqueada → desbloqueá el iPhone y abrí la app a mano."
  warn "  2. Primera vez con este certificado → en el iPhone: Ajustes → General →"
  warn "     VPN y gestión de dispositivos → confiar en tu Apple ID, y reintentá."
  exit 1
}

echo ""
echo "=================================================="
success "APP CORRIENDO EN TU IPHONE"
echo "=================================================="
