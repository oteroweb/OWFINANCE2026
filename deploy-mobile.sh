#!/bin/bash

# Script de Deployment Unificado para iOS y Android
# Uso: ./deploy-mobile.sh [platform] [environment]
# Platform: ios | android | both
# Environment: dev | staging | prod

PLATFORM=${1:-both}
ENVIRONMENT=${2:-dev}
FRONTEND_DIR="OWFinanceFrontend2025"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "🚀 OWFINANCE - Deployment Móvil"
echo "=================================================="
echo "Plataforma: $PLATFORM"
echo "Entorno: $ENVIRONMENT"
echo "=================================================="

# Verificar que estamos en macOS para iOS
if [[ "$PLATFORM" == "ios" || "$PLATFORM" == "both" ]]; then
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}❌ iOS solo puede compilarse en macOS${NC}"
        if [ "$PLATFORM" == "both" ]; then
            echo "Continuando solo con Android..."
            PLATFORM="android"
        else
            exit 1
        fi
    fi
fi

# Función para verificar requisitos
check_requirements() {
    local platform=$1
    
    if [ "$platform" == "android" ] || [ "$platform" == "both" ]; then
        echo -e "${BLUE}🔍 Verificando requisitos de Android...${NC}"
        
        # Verificar ANDROID_HOME
        if [ -z "$ANDROID_HOME" ]; then
            echo -e "${YELLOW}⚠️  ANDROID_HOME no configurado${NC}"
            echo "Configura: export ANDROID_HOME=\$HOME/Library/Android/sdk"
            return 1
        fi
        
        # Verificar Java
        if ! command -v java &> /dev/null; then
            echo -e "${RED}❌ Java no encontrado${NC}"
            return 1
        fi
        
        # Verificar Gradle
        if [ ! -f "$FRONTEND_DIR/src-capacitor/android/gradlew" ]; then
            echo -e "${YELLOW}⚠️  Gradle wrapper no encontrado${NC}"
        fi
        
        echo -e "${GREEN}✅ Requisitos de Android OK${NC}"
    fi
    
    if [ "$platform" == "ios" ] || [ "$platform" == "both" ]; then
        echo -e "${BLUE}🔍 Verificando requisitos de iOS...${NC}"
        
        # Verificar Xcode
        if ! command -v xcodebuild &> /dev/null; then
            echo -e "${RED}❌ Xcode no encontrado${NC}"
            return 1
        fi
        
        # Verificar CocoaPods
        if ! command -v pod &> /dev/null; then
            echo -e "${YELLOW}⚠️  CocoaPods no encontrado${NC}"
            echo "Instala: sudo gem install cocoapods"
            return 1
        fi
        
        echo -e "${GREEN}✅ Requisitos de iOS OK${NC}"
    fi
    
    return 0
}

# Función para configurar entorno
setup_environment() {
    local env=$1
    
    echo ""
    echo -e "${BLUE}🔧 Configurando entorno: $env${NC}"
    
    case $env in
        dev)
            # Para desarrollo móvil, SIEMPRE usar backend remoto
            # Los dispositivos no pueden acceder a localhost
            if [ -f "$FRONTEND_DIR/.env.mobile" ]; then
                cp "$FRONTEND_DIR/.env.mobile" "$FRONTEND_DIR/.env"
                echo -e "${GREEN}✓ Entorno MOBILE-DEV configurado (backend remoto)${NC}"
            else
                echo -e "${YELLOW}⚠️  .env.mobile no existe, usando .env actual${NC}"
            fi
            ;;
        staging)
            if [ -f "$FRONTEND_DIR/.env.staging" ]; then
                cp "$FRONTEND_DIR/.env.staging" "$FRONTEND_DIR/.env"
            elif [ -f "$FRONTEND_DIR/.env.remote" ]; then
                cp "$FRONTEND_DIR/.env.remote" "$FRONTEND_DIR/.env"
            else
                echo -e "${YELLOW}⚠️  .env.staging no existe, usando .env actual${NC}"
            fi
            echo -e "${GREEN}✓ Entorno STAGING configurado${NC}"
            ;;
        prod)
            if [ -f "$FRONTEND_DIR/.env.production" ]; then
                cp "$FRONTEND_DIR/.env.production" "$FRONTEND_DIR/.env"
            else
                echo -e "${RED}❌ .env.production no existe${NC}"
                exit 1
            fi
            echo -e "${GREEN}✓ Entorno PRODUCCIÓN configurado${NC}"
            ;;
    esac
    
    # Mostrar configuración aplicada
    echo ""
    echo "API configurada:"
    grep "VITE_API_BASE_URL" "$FRONTEND_DIR/.env" | head -1
}

# Función para build de Quasar
build_quasar() {
    echo ""
    echo -e "${CYAN}📦 Compilando aplicación Quasar...${NC}"
    
    cd $FRONTEND_DIR
    
    # Limpiar build anterior
    rm -rf dist/capacitor
    
    # Verificar y aplicar fix de Java si es necesario
    if [ -f "src-capacitor/android/build.gradle" ]; then
        if ! grep -q "sourceCompatibility JavaVersion.VERSION_17" "src-capacitor/android/build.gradle"; then
            echo "🔧 Aplicando fix de compatibilidad Java..."
            ../fix-java-android.sh > /dev/null 2>&1
        fi
    fi
    
    # Build
    quasar build -m capacitor -T android
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error en build de Quasar${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Build Quasar completado${NC}"
    cd ..
}

# Función para deploy Android
deploy_android() {
    local env=$1
    
    echo ""
    echo -e "${CYAN}🤖 === DEPLOYMENT ANDROID ===${NC}"
    
    cd $FRONTEND_DIR/src-capacitor
    
    # Sync Capacitor
    echo "Sincronizando Capacitor..."
    npx cap sync android
    
    cd android
    
    if [ "$env" == "prod" ]; then
        echo ""
        echo -e "${YELLOW}📝 Build RELEASE (Producción)${NC}"
        echo "Asegúrate de tener el keystore configurado"
        echo ""
        
        # Build release
        ./gradlew assembleRelease
        
        if [ $? -eq 0 ]; then
            APK_PATH="app/build/outputs/apk/release/app-release.apk"
            AAB_PATH="app/build/outputs/bundle/release/app-release.aab"
            
            echo ""
            echo -e "${GREEN}✅ Build Android Release completado${NC}"
            
            # Verificar si existe APK
            if [ -f "$APK_PATH" ]; then
                APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
                echo "📦 APK: $APK_PATH ($APK_SIZE)"
                
                # Copiar a directorio de releases
                mkdir -p ../../../../releases/android
                TIMESTAMP=$(date +%Y%m%d_%H%M%S)
                cp "$APK_PATH" "../../../../releases/android/owfinance-${env}-${TIMESTAMP}.apk"
                echo "📁 Copiado a: releases/android/owfinance-${env}-${TIMESTAMP}.apk"
            fi
            
            # Verificar si existe AAB (para Google Play)
            if [ -f "$AAB_PATH" ]; then
                AAB_SIZE=$(du -h "$AAB_PATH" | cut -f1)
                echo "📦 AAB: $AAB_PATH ($AAB_SIZE)"
                
                mkdir -p ../../../../releases/android
                TIMESTAMP=$(date +%Y%m%d_%H%M%S)
                cp "$AAB_PATH" "../../../../releases/android/owfinance-${env}-${TIMESTAMP}.aab"
                echo "📁 Copiado a: releases/android/owfinance-${env}-${TIMESTAMP}.aab"
            fi
        else
            echo -e "${RED}❌ Error en build release${NC}"
            cd ../../../..
            exit 1
        fi
    else
        echo ""
        echo -e "${BLUE}🔨 Build DEBUG (${env})${NC}"
        
        ./gradlew assembleDebug
        
        if [ $? -eq 0 ]; then
            APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
            
            echo ""
            echo -e "${GREEN}✅ Build Android Debug completado${NC}"
            
            if [ -f "$APK_PATH" ]; then
                APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
                echo "📦 APK: $APK_PATH ($APK_SIZE)"
                
                # Verificar si hay dispositivo conectado
                DEVICES=$(adb devices | grep -v "List" | grep "device$" | wc -l)
                
                if [ $DEVICES -gt 0 ]; then
                    echo ""
                    read -p "¿Instalar en dispositivo conectado? (y/n) " -n 1 -r
                    echo
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        adb install -r "$APK_PATH"
                        echo -e "${GREEN}✅ Instalado en dispositivo${NC}"
                    fi
                fi
            fi
        else
            echo -e "${RED}❌ Error en build debug${NC}"
            cd ../../../..
            exit 1
        fi
    fi
    
    cd ../../../..
}

# Función para deploy iOS
deploy_ios() {
    local env=$1
    
    echo ""
    echo -e "${CYAN}🍎 === DEPLOYMENT iOS ===${NC}"
    
    cd $FRONTEND_DIR/src-capacitor
    
    # Verificar si iOS está inicializado
    if [ ! -d "ios" ]; then
        echo "Inicializando iOS..."
        npx cap add ios
    fi
    
    # Sync Capacitor
    echo "Sincronizando Capacitor..."
    npx cap sync ios
    
    # Instalar pods
    cd ios/App
    echo "Instalando CocoaPods..."
    pod install
    
    cd ../..
    
    if [ "$env" == "prod" ]; then
        echo ""
        echo -e "${YELLOW}📝 Build RELEASE (Producción)${NC}"
        echo ""
        echo "Para compilar para producción en iOS:"
        echo "1. Abre: src-capacitor/ios/App/App.xcworkspace"
        echo "2. Selecciona el esquema 'App'"
        echo "3. Product > Archive"
        echo "4. Distribuye a App Store Connect o Ad Hoc"
        echo ""
        read -p "¿Abrir en Xcode? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open ios/App/App.xcworkspace
        fi
    else
        echo ""
        echo -e "${BLUE}🔨 Build DEBUG (${env})${NC}"
        echo ""
        echo "Para instalar en dispositivo iOS:"
        echo "1. Conecta tu iPhone por USB"
        echo "2. Confía en la computadora desde el iPhone"
        echo ""
        read -p "¿Abrir en Xcode para instalar? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            open ios/App/App.xcworkspace
            echo ""
            echo "En Xcode:"
            echo "1. Selecciona tu iPhone como destino"
            echo "2. Presiona ▶️ Run"
        fi
    fi
    
    cd ../..
}

# EJECUCIÓN PRINCIPAL
echo ""

# Verificar requisitos
check_requirements $PLATFORM
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Faltan requisitos necesarios${NC}"
    exit 1
fi

# Configurar entorno
setup_environment $ENVIRONMENT

# Build Quasar
build_quasar

# Deploy según plataforma
case $PLATFORM in
    android)
        deploy_android $ENVIRONMENT
        ;;
    ios)
        deploy_ios $ENVIRONMENT
        ;;
    both)
        deploy_android $ENVIRONMENT
        deploy_ios $ENVIRONMENT
        ;;
esac

echo ""
echo "=================================================="
echo -e "${GREEN}✨ DEPLOYMENT COMPLETADO${NC}"
echo "=================================================="

if [ "$ENVIRONMENT" == "prod" ]; then
    echo ""
    echo -e "${CYAN}📋 Siguiente pasos para PRODUCCIÓN:${NC}"
    echo ""
    echo "Android:"
    echo "  - APK está en: releases/android/"
    echo "  - Sube el AAB a Google Play Console"
    echo "  - O distribuye el APK directamente"
    echo ""
    echo "iOS:"
    echo "  - Archive desde Xcode"
    echo "  - Distribuye a App Store Connect"
    echo "  - O genera IPA para distribución Ad Hoc/TestFlight"
fi

echo ""
echo "=================================================="
