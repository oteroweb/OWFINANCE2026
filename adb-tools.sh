#!/bin/bash

# Script para gestionar dispositivos Android con ADB
# Uso: ./adb-tools.sh [comando]

comando=${1:-devices}

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

case $comando in
    devices|list)
        echo "📱 Dispositivos Android Conectados:"
        echo "=================================================="
        adb devices -l
        ;;
        
    install)
        APK=${2:-"OWFinanceFrontend2025/src-capacitor/android/app/build/outputs/apk/debug/app-debug.apk"}
        echo "📦 Instalando APK en dispositivo..."
        if [ -f "$APK" ]; then
            adb install -r "$APK"
            echo -e "${GREEN}✅ Instalado${NC}"
        else
            echo -e "${RED}❌ APK no encontrado: $APK${NC}"
            exit 1
        fi
        ;;
        
    uninstall)
        echo "🗑️  Desinstalando OWFINANCE..."
        adb uninstall org.capacitor.quasar.app
        echo -e "${GREEN}✅ Desinstalado${NC}"
        ;;
        
    logs)
        echo "📋 Logs en tiempo real (Ctrl+C para detener):"
        echo "=================================================="
        adb logcat | grep -E "(Capacitor|Console|chromium)"
        ;;
        
    screen)
        echo "📸 Capturando pantalla..."
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        FILENAME="screenshot_${TIMESTAMP}.png"
        adb shell screencap -p /sdcard/$FILENAME
        adb pull /sdcard/$FILENAME ./logs/
        adb shell rm /sdcard/$FILENAME
        echo -e "${GREEN}✅ Guardado en: logs/$FILENAME${NC}"
        ;;
        
    info)
        echo "📊 Información del Dispositivo:"
        echo "=================================================="
        echo -e "${BLUE}Marca y modelo:${NC}"
        adb shell getprop ro.product.manufacturer
        adb shell getprop ro.product.model
        echo ""
        echo -e "${BLUE}Versión Android:${NC}"
        adb shell getprop ro.build.version.release
        echo ""
        echo -e "${BLUE}SDK Level:${NC}"
        adb shell getprop ro.build.version.sdk
        echo ""
        echo -e "${BLUE}Arquitectura:${NC}"
        adb shell getprop ro.product.cpu.abi
        ;;
        
    restart)
        echo "🔄 Reiniciando ADB server..."
        adb kill-server
        sleep 1
        adb start-server
        echo -e "${GREEN}✅ ADB reiniciado${NC}"
        ;;
        
    wireless)
        echo "📡 Configurando ADB Wireless..."
        echo "=================================================="
        echo "1. Conecta el dispositivo por USB"
        echo "2. Asegúrate que esté en la misma red WiFi"
        echo ""
        
        # Obtener IP del dispositivo
        DEVICE_IP=$(adb shell ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
        
        if [ -z "$DEVICE_IP" ]; then
            echo -e "${RED}❌ No se pudo obtener la IP del dispositivo${NC}"
            exit 1
        fi
        
        echo -e "${BLUE}IP del dispositivo: $DEVICE_IP${NC}"
        echo ""
        
        # Configurar puerto
        adb tcpip 5555
        sleep 2
        
        # Conectar
        echo "Conectando..."
        adb connect $DEVICE_IP:5555
        
        echo ""
        echo -e "${GREEN}✅ Configurado${NC}"
        echo "Ahora puedes desconectar el cable USB"
        echo ""
        echo "Para reconectar: adb connect $DEVICE_IP:5555"
        echo "Para volver a USB: adb usb"
        ;;
        
    help|*)
        echo "🛠️  Herramientas ADB para OWFINANCE"
        echo "=================================================="
        echo "Uso: ./adb-tools.sh [comando]"
        echo ""
        echo "Comandos disponibles:"
        echo "  devices    - Listar dispositivos conectados"
        echo "  install    - Instalar APK en dispositivo"
        echo "  uninstall  - Desinstalar app del dispositivo"
        echo "  logs       - Ver logs en tiempo real"
        echo "  screen     - Capturar pantalla"
        echo "  info       - Información del dispositivo"
        echo "  restart    - Reiniciar servidor ADB"
        echo "  wireless   - Configurar ADB por WiFi"
        echo "  help       - Mostrar esta ayuda"
        echo ""
        echo "Ejemplos:"
        echo "  ./adb-tools.sh devices"
        echo "  ./adb-tools.sh logs"
        echo "  ./adb-tools.sh install ruta/al/apk"
        echo "=================================================="
        ;;
esac
