#!/bin/bash

# Script para ver logs de la app Android en tiempo real
# Uso: ./android-logs.sh

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}📱 LOGS ANDROID - OWFINANCE${NC}"
echo "=================================================="

# Verificar dispositivo
DEVICE_NAME=$(adb devices | grep -v "List" | grep "device" | head -1 | awk '{print $1}')
if [ -z "$DEVICE_NAME" ]; then
    echo -e "${RED}✗ No hay dispositivos conectados${NC}"
    echo ""
    echo "Conecta tu dispositivo y ejecuta:"
    echo "  ./adb-tools.sh info"
    exit 1
fi

echo -e "${GREEN}✓ Dispositivo: $DEVICE_NAME${NC}"
echo "=================================================="
echo ""
echo "🔍 Esperando logs de la app..."
echo "   (Abre la app e intenta hacer login)"
echo ""
echo "=================================================="

# Limpiar logs anteriores y mostrar solo consola JavaScript
adb logcat -c
adb logcat | grep -E "(Console|chromium|SystemWebChromeClient)" | grep -v "RenderThread"

