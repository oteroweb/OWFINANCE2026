#!/bin/bash

# Script para compilar aplicación móvil
# Uso: ./mobile-build.sh [platform] [mode]
# Platform: ios | android | both
# Mode: dev | prod

PLATFORM=${1:-android}
MODE=${2:-dev}
FRONTEND_DIR="OWFinanceFrontend2025"

echo "📱 Compilando aplicación móvil OWFINANCE"
echo "=================================================="
echo "Plataforma: $PLATFORM"
echo "Modo: $MODE"
echo "=================================================="

cd $FRONTEND_DIR

# Verificar Quasar CLI
if ! command -v quasar &> /dev/null; then
    echo "❌ Quasar CLI no encontrado. Instalando..."
    npm install -g @quasar/cli
fi

# Configurar variables según modo
if [ "$MODE" = "prod" ]; then
    echo "🔧 Configurando para PRODUCCIÓN..."
    # Copiar variables de producción si existen
    if [ -f ".env.production" ]; then
        cp .env.production .env
    fi
else
    echo "🔧 Configurando para DESARROLLO..."
    if [ -f ".env.development" ]; then
        cp .env.development .env
    fi
fi

case $PLATFORM in
    ios)
        echo "🍎 Compilando para iOS..."
        
        # Verificar si estamos en macOS
        if [[ "$OSTYPE" != "darwin"* ]]; then
            echo "❌ iOS solo puede compilarse en macOS"
            exit 1
        fi
        
        # Verificar Xcode
        if ! command -v xcodebuild &> /dev/null; then
            echo "❌ Xcode no está instalado"
            exit 1
        fi
        
        # Agregar plataforma Capacitor iOS si no existe
        if [ ! -d "src-capacitor/ios" ]; then
            echo "📥 Agregando plataforma iOS..."
            quasar mode add capacitor
            cd src-capacitor
            npx cap add ios
            cd ..
        fi
        
        # Build
        quasar build -m capacitor -T ios
        
        echo "✅ Build iOS completado"
        echo "📍 Abrir en Xcode: src-capacitor/ios/App/App.xcworkspace"
        ;;
        
    android)
        echo "🤖 Compilando para Android..."
        
        # Verificar Java/Android SDK
        if [ -z "$ANDROID_HOME" ]; then
            echo "⚠️  ANDROID_HOME no configurado"
            echo "   Configura Android Studio primero"
        fi
        
        # Agregar plataforma Capacitor Android si no existe
        if [ ! -d "src-capacitor/android" ]; then
            echo "📥 Agregando plataforma Android..."
            quasar mode add capacitor
            cd src-capacitor
            npx cap add android
            cd ..
        fi
        
        # Build
        quasar build -m capacitor -T android
        
        echo "✅ Build Android completado"
        echo "📍 Abrir en Android Studio: src-capacitor/android"
        ;;
        
    both)
        echo "🌐 Compilando para iOS y Android..."
        ./mobile-build.sh ios $MODE
        ./mobile-build.sh android $MODE
        ;;
        
    *)
        echo "❌ Plataforma no válida. Opciones: ios, android, both"
        exit 1
        ;;
esac

cd ..

echo ""
echo "=================================================="
echo "✨ Compilación completada"
echo "=================================================="
echo ""
echo "📋 Siguiente pasos:"
echo "   iOS: Abrir Xcode y ejecutar en simulador/dispositivo"
echo "   Android: Abrir Android Studio y ejecutar en emulador/dispositivo"
echo ""
echo "💡 Para modo desarrollo con hot-reload:"
echo "   quasar dev -m capacitor -T [ios|android]"
echo "=================================================="
