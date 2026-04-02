#!/bin/bash

# Script para desarrollo rápido en dispositivo Android
# Hot-reload + instalación automática
# Uso: ./dev-mobile.sh

FRONTEND_DIR="OWFinanceFrontend2025"

echo "📱 Modo Desarrollo Móvil - Hot Reload"
echo "=================================================="

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar dispositivo Android
echo "🔍 Verificando dispositivo Android..."
DEVICES=$(adb devices | grep -v "List" | grep "device$" | wc -l)

if [ $DEVICES -eq 0 ]; then
    echo -e "${RED}❌ No hay dispositivos Android conectados${NC}"
    echo ""
    echo "Pasos:"
    echo "1. Conecta tu dispositivo por USB"
    echo "2. Habilita 'Depuración USB' en Opciones de desarrollador"
    echo "3. Ejecuta: adb devices"
    exit 1
fi

echo -e "${GREEN}✓ Dispositivo detectado:${NC}"
adb devices | grep "device$"

cd $FRONTEND_DIR

# Configurar para usar backend remoto (dispositivos no pueden acceder a localhost)
echo ""
echo -e "${BLUE}🔧 Configurando backend remoto para móvil...${NC}"
if [ -f ".env.mobile" ]; then
    cp .env.mobile .env
    echo -e "${GREEN}✓ Usando backend remoto${NC}"
    grep "VITE_API_BASE_URL" .env | head -1
else
    echo -e "${YELLOW}⚠️  .env.mobile no existe, usando .env actual${NC}"
fi

# Verificar si Android está configurado
if [ ! -d "src-capacitor/android" ]; then
    echo ""
    echo -e "${YELLOW}⚠️  Configurando Android por primera vez...${NC}"
    
    if [ ! -d "src-capacitor" ]; then
        quasar mode add capacitor
    fi
    
    cd src-capacitor
    npx cap add android
    cd ..
fi

echo ""
echo -e "${BLUE}🚀 Iniciando modo desarrollo con hot-reload...${NC}"
echo ""
echo "Esto hará:"
echo "  1. Iniciar servidor de desarrollo"
echo "  2. Compilar y abrir Android Studio"
echo "  3. Desplegar en tu dispositivo"
echo "  4. Hot-reload automático en cada cambio"
echo ""
echo -e "${YELLOW}Presiona Ctrl+C para detener${NC}"
echo ""

# Iniciar Quasar en modo Capacitor para Android
quasar dev -m capacitor -T android

cd ..
