#!/bin/bash
# =============================================================================
# build-android.sh — Compila e instala la app Android (variante prod o dev)
#
# Uso:
#   ./build-android.sh dev          # Compila OWFinance Dev (debug) e instala via ADB
#   ./build-android.sh dev release  # Compila OWFinance Dev (release)
#   ./build-android.sh prod         # Compila OWFinance (debug) e instala via ADB
#   ./build-android.sh prod release # Compila OWFinance (release)
# =============================================================================
set -euo pipefail

VARIANT="${1:-dev}"
BUILD_TYPE="${2:-debug}"
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
FRONTEND_DIR="$ROOT_DIR/OWFinanceFrontend2025"
ANDROID_DIR="$FRONTEND_DIR/src-capacitor/android"

export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"

# Seleccionar env file segun variante
if [ "$VARIANT" = "dev" ]; then
  ENV_FILE=".env.mobile-dev"
  FLAVOR="dev"
  APP_LABEL="OWFinance Dev"
elif [ "$VARIANT" = "prod" ]; then
  ENV_FILE=".env.mobile"
  FLAVOR="prod"
  APP_LABEL="OWFinance"
else
  echo "❌ Variante invalida: $VARIANT (usa 'dev' o 'prod')"
  exit 1
fi

echo "=========================================="
echo "📱 Build Android: $APP_LABEL ($BUILD_TYPE)"
echo "   Flavor: $FLAVOR"
echo "   Env:    $ENV_FILE"
echo "=========================================="

# 0. Auto-bump patch version
cd "$FRONTEND_DIR"
CURRENT_VERSION=$(grep '"version"' package.json | head -1 | sed 's/.*"version": "\(.*\)".*/\1/')
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
PATCH=$((PATCH + 1))
NEW_VERSION="$MAJOR.$MINOR.$PATCH"
sed -i '' "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" package.json
echo "🔢 Versión: $CURRENT_VERSION → $NEW_VERSION"

# 1. Copiar env apropiado
cd "$FRONTEND_DIR"
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ No existe $ENV_FILE"
  exit 1
fi
cp "$ENV_FILE" .env
echo "✅ .env configurado desde $ENV_FILE"

# 2. Build Quasar para Capacitor
echo ""
echo "🔨 Compilando Quasar para Capacitor..."
npx quasar build -m capacitor -T android --skip-pkg

echo "✅ Web assets generados en src-capacitor/www/"

# 3. Sync Capacitor
echo ""
echo "🔄 Sincronizando Capacitor..."
cd src-capacitor
npx cap sync android

# 4. Build Gradle con flavor
echo ""
echo "🏗️  Compilando APK con Gradle (${FLAVOR} ${BUILD_TYPE})..."
cd android

# Capitalize first letter for Gradle task name (compatible with zsh + macOS)
FLAVOR_CAP="$(echo "$FLAVOR" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')"
BUILD_CAP="$(echo "$BUILD_TYPE" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')"
GRADLE_TASK="assemble${FLAVOR_CAP}${BUILD_CAP}"
./gradlew "$GRADLE_TASK" --no-daemon

# 5. Localizar APK
if [ "$BUILD_TYPE" = "debug" ]; then
  APK_PATH="app/build/outputs/apk/${FLAVOR}/debug/app-${FLAVOR}-debug.apk"
else
  APK_PATH="app/build/outputs/apk/${FLAVOR}/release/app-${FLAVOR}-release-unsigned.apk"
fi

if [ ! -f "$APK_PATH" ]; then
  echo "⚠️  APK no encontrado en $APK_PATH, buscando..."
  APK_PATH=$(find app/build/outputs/apk/ -name "*.apk" | head -1)
fi

echo ""
echo "✅ APK generado: $APK_PATH"
APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
echo "   Tamaño: $APK_SIZE"

# 6. Instalar via ADB si hay dispositivo y es debug
if [ "$BUILD_TYPE" = "debug" ]; then
  DEVICE_COUNT=$(adb devices | grep -c "device$" || true)
  if [ "$DEVICE_COUNT" -gt 0 ]; then
    echo ""
    echo "📲 Instalando en dispositivo via ADB..."
    adb install -r "$APK_PATH"
    echo "✅ Instalado correctamente"

    # Lanzar la app
    if [ "$VARIANT" = "dev" ]; then
      PACKAGE="com.owfinance.app.dev"
    else
      PACKAGE="com.owfinance.app"
    fi
    echo "🚀 Lanzando $PACKAGE..."
    adb shell am start -n "${PACKAGE}/com.owfinance.app.MainActivity"
    echo "✅ App iniciada"
  else
    echo ""
    echo "⚠️  No hay dispositivo ADB conectado. APK disponible en:"
    echo "   $ANDROID_DIR/$APK_PATH"
  fi
fi

echo ""
echo "=========================================="
echo "✅ Build completado: $APP_LABEL ($BUILD_TYPE)"
echo "=========================================="
