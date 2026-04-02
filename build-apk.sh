#!/bin/bash

# Script para generar APK de OWFINANCE y desplegarlo en dispositivo Android
# Uso: ./build-apk.sh [release|debug] [install]
# Ejemplos:
#   ./build-apk.sh debug          - Genera APK debug
#   ./build-apk.sh debug install  - Genera APK debug e instala en dispositivo
#   ./build-apk.sh release         - Genera APK release firmado

BUILD_TYPE=${1:-debug}
INSTALL=${2:-}
FRONTEND_DIR="OWFinanceFrontend2025"

echo "📱 Generando APK de OWFINANCE"
echo "=================================================="

# Incrementar versión automáticamente en cada build
CURRENT_VERSION=$(grep '"version"' "$FRONTEND_DIR/package.json" | head -1 | sed 's/.*"version": "\(.*\)".*/\1/')
echo "Versión actual: $CURRENT_VERSION"

echo "Tipo de build: $BUILD_TYPE"
echo "=================================================="

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verificar que estamos en el directorio correcto
if [ ! -d "$FRONTEND_DIR" ]; then
    echo -e "${RED}❌ No se encuentra el directorio $FRONTEND_DIR${NC}"
    exit 1
fi

cd $FRONTEND_DIR

# 1. Verificar que exista src-capacitor
if [ ! -d "src-capacitor" ]; then
    echo -e "${RED}❌ No existe src-capacitor${NC}"
    echo "Ejecuta primero: quasar mode add capacitor"
    exit 1
fi

# 2. Verificar que exista Android
if [ ! -d "src-capacitor/android" ]; then
    echo -e "${YELLOW}⚠️  Android no está inicializado${NC}"
    echo "Inicializando Android..."
    cd src-capacitor
    npx cap add android
    cd ..
fi

# 3. Configurar variables de entorno según tipo de build
if [ "$BUILD_TYPE" = "release" ]; then
    echo -e "${BLUE}🔧 Configurando para PRODUCCIÓN...${NC}"
    if [ -f ".env.production" ]; then
        cp .env.production .env
    else
        echo -e "${YELLOW}⚠️  No existe .env.production, usando .env actual${NC}"
    fi
else
    echo -e "${BLUE}🔧 Configurando para DESARROLLO...${NC}"
    if [ -f ".env.development" ]; then
        cp .env.development .env
    fi
fi

# 4. Build de Quasar
echo ""
echo -e "${BLUE}📦 Compilando aplicación Quasar...${NC}"
quasar build -m capacitor -T android

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error en build de Quasar${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build de Quasar completado${NC}"

# 5. Sincronizar con Capacitor
echo ""
echo -e "${BLUE}🔄 Sincronizando con Capacitor...${NC}"
cd src-capacitor
npx cap sync android

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error en sync de Capacitor${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Sync completado${NC}"

# 6. Compilar APK con Gradle
echo ""
echo -e "${BLUE}🏗️  Compilando APK con Gradle...${NC}"
cd android

if [ "$BUILD_TYPE" = "release" ]; then
    echo -e "${YELLOW}📝 Build RELEASE - Necesita keystore configurado${NC}"
    ./gradlew assembleRelease
    
    if [ $? -eq 0 ]; then
        APK_PATH="app/build/outputs/apk/release/app-release.apk"
        echo ""
        echo -e "${GREEN}✅ APK Release generado exitosamente!${NC}"
        echo "📍 Ubicación: src-capacitor/android/$APK_PATH"
        
        # Información del APK
        if [ -f "$APK_PATH" ]; then
            APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
            echo "📊 Tamaño: $APK_SIZE"
        fi
    else
        echo -e "${RED}❌ Error al generar APK Release${NC}"
        echo ""
        echo "Para builds release necesitas configurar el keystore:"
        echo "1. Genera un keystore: keytool -genkey -v -keystore owfinance.keystore -alias owfinance -keyalg RSA -keysize 2048 -validity 10000"
        echo "2. Configura en android/app/build.gradle"
        exit 1
    fi
else
    echo -e "${BLUE}🔨 Build DEBUG${NC}"
    ./gradlew assembleDebug
    
    if [ $? -eq 0 ]; then
        APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
        echo ""
        echo -e "${GREEN}✅ APK Debug generado exitosamente!${NC}"
        echo "📍 Ubicación: src-capacitor/android/$APK_PATH"
        
        # Información del APK
        if [ -f "$APK_PATH" ]; then
            APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
            echo "📊 Tamaño: $APK_SIZE"
        fi
    else
        echo -e "${RED}❌ Error al generar APK Debug${NC}"
        exit 1
    fi
fi

# 7. Instalar en dispositivo si se solicitó
if [ "$INSTALL" = "install" ]; then
    echo ""
    echo -e "${BLUE}📲 Instalando en dispositivo Android...${NC}"
    
    # Verificar que haya un dispositivo conectado
    DEVICES=$(adb devices | grep -v "List" | grep "device$" | wc -l)
    
    if [ $DEVICES -eq 0 ]; then
        echo -e "${RED}❌ No se encontró ningún dispositivo Android conectado${NC}"
        echo ""
        echo "Opciones:"
        echo "1. Conecta tu dispositivo Android por USB"
        echo "2. Habilita 'Depuración USB' en Opciones de desarrollador"
        echo "3. Verifica con: adb devices"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Dispositivo(s) detectado(s):${NC}"
    adb devices | grep "device$"
    
    echo ""
    echo "📦 Instalando APK..."
    adb install -r "$APK_PATH"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ ¡APK instalado exitosamente en el dispositivo!${NC}"
        echo ""
        echo "🚀 Puedes abrir la app 'OwFinance App' en tu dispositivo"
    else
        echo -e "${RED}❌ Error al instalar APK${NC}"
        exit 1
    fi
fi

# Regresar al directorio raíz
cd ../../../../

echo ""
echo "=================================================="
echo -e "${GREEN}✨ Proceso completado${NC}"
echo "=================================================="

if [ "$BUILD_TYPE" = "release" ]; then
    echo "📦 APK Release: $FRONTEND_DIR/src-capacitor/android/app/build/outputs/apk/release/app-release.apk"
else
    echo "📦 APK Debug: $FRONTEND_DIR/src-capacitor/android/app/build/outputs/apk/debug/app-debug.apk"
fi

echo ""
echo "📋 Comandos útiles:"
echo "   Ver dispositivos: adb devices"
echo "   Instalar APK: adb install -r ruta/al/apk"
echo "   Desinstalar: adb uninstall org.capacitor.quasar.app"
echo "   Ver logs: adb logcat | grep Capacitor"
echo ""
echo "💡 Para instalar directamente en dispositivo:"
echo "   ./build-apk.sh $BUILD_TYPE install"
echo "=================================================="
