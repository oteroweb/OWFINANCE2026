#!/bin/bash

# Script para ver el estado actual de configuración
# Uso: ./status.sh

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "📊 Estado Actual del Proyecto OWFINANCE"
echo "=================================================="

# Backend
echo ""
echo -e "${CYAN}🔧 BACKEND${NC}"
if [ -f "OWFINANCEBackend2025/.env" ]; then
    BACKEND_URL=$(grep "APP_URL=" OWFINANCEBackend2025/.env | cut -d= -f2)
    DB_TYPE=$(grep "DB_CONNECTION=" OWFINANCEBackend2025/.env | cut -d= -f2)
    echo "  URL: $BACKEND_URL"
    echo "  Base de datos: $DB_TYPE"
else
    echo -e "  ${YELLOW}⚠️  .env no encontrado${NC}"
fi

# Frontend - Configuración actual
echo ""
echo -e "${CYAN}🎨 FRONTEND${NC}"
if [ -f "OWFinanceFrontend2025/.env" ]; then
    API_URL=$(grep "VITE_API_BASE_URL=" OWFinanceFrontend2025/.env | head -1 | cut -d= -f2)
    ENV_TYPE=$(grep "VITE_ENV=" OWFinanceFrontend2025/.env | cut -d= -f2)
    
    echo "  API Backend: $API_URL"
    echo "  Tipo: $ENV_TYPE"
    
    # Determinar modo
    if [[ $API_URL == *"localhost"* ]]; then
        echo -e "  ${GREEN}✓ Modo: DESARROLLO LOCAL${NC}"
    elif [[ $ENV_TYPE == *"mobile"* ]]; then
        echo -e "  ${BLUE}✓ Modo: DESARROLLO MÓVIL${NC}"
    elif [[ $ENV_TYPE == *"production"* ]]; then
        echo -e "  ${YELLOW}✓ Modo: PRODUCCIÓN${NC}"
    else
        echo -e "  ${CYAN}✓ Modo: DESARROLLO REMOTO${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠️  .env no encontrado${NC}"
fi

# Dispositivos Android
echo ""
echo -e "${CYAN}📱 DISPOSITIVOS ANDROID${NC}"
DEVICES=$(adb devices 2>/dev/null | grep -v "List" | grep "device$" | wc -l)
if [ $DEVICES -gt 0 ]; then
    echo -e "  ${GREEN}✓ $DEVICES dispositivo(s) conectado(s)${NC}"
    adb devices 2>/dev/null | grep "device$" | awk '{print "    - " $1 " (" $3 $4 ")"}'
else
    echo "  ⚠️  No hay dispositivos conectados"
fi

# APK compilado
if [ -f "OWFinanceFrontend2025/src-capacitor/android/app/build/outputs/apk/debug/app-debug.apk" ]; then
    APK_SIZE=$(du -h "OWFinanceFrontend2025/src-capacitor/android/app/build/outputs/apk/debug/app-debug.apk" | cut -f1)
    APK_DATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "OWFinanceFrontend2025/src-capacitor/android/app/build/outputs/apk/debug/app-debug.apk")
    echo ""
    echo -e "${CYAN}📦 ÚLTIMO APK${NC}"
    echo "  Tamaño: $APK_SIZE"
    echo "  Fecha: $APK_DATE"
fi

# Git status
echo ""
echo -e "${CYAN}📝 GIT${NC}"
if [ -d ".git" ]; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    CHANGES=$(git status --porcelain 2>/dev/null | wc -l)
    
    if [ ! -z "$BRANCH" ]; then
        echo "  Rama actual: $BRANCH"
    fi
    
    if [ $CHANGES -gt 0 ]; then
        echo -e "  ${YELLOW}⚠️  $CHANGES archivo(s) con cambios${NC}"
    else
        echo -e "  ${GREEN}✓ Sin cambios pendientes${NC}"
    fi
else
    echo "  ℹ️  No es un repositorio Git"
fi

# Servicios corriendo
echo ""
echo -e "${CYAN}🚀 SERVICIOS${NC}"

# Backend
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "  ${GREEN}✓ Backend (puerto 8000) corriendo${NC}"
else
    echo "  ⚪ Backend no está corriendo"
fi

# Frontend
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "  ${GREEN}✓ Frontend (puerto 3000) corriendo${NC}"
else
    echo "  ⚪ Frontend no está corriendo"
fi

echo ""
echo "=================================================="
echo ""
echo "💡 Comandos rápidos:"
echo ""
echo "  Cambiar a local:    ./switch-env.sh local"
echo "  Cambiar a remoto:   ./switch-env.sh remote"
echo "  Cambiar a móvil:    ./switch-env.sh mobile"
echo "  Iniciar dev:        ./dev-start.sh"
echo "  Dev móvil:          ./dev-mobile.sh"
echo "  Ver dispositivos:   ./adb-tools.sh devices"
echo "  Instalar APK:       ./adb-tools.sh install"
echo ""
echo "=================================================="
