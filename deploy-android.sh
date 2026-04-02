#!/bin/bash

# Deploy rápido a Android con auto-incremento de versión
# Uso: ./deploy-android.sh

FRONTEND_DIR="OWFinanceFrontend2025"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}🚀 DEPLOY ANDROID - OWFINANCE${NC}"
echo "=================================================="

# 1. Incrementar versión automáticamente
echo ""
echo -e "${YELLOW}📦 Incrementando versión...${NC}"
CURRENT_VERSION=$(grep '"version"' "$FRONTEND_DIR/package.json" | head -1 | sed 's/.*"version": "\(.*\)".*/\1/')
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR="${VERSION_PARTS[0]}"
MINOR="${VERSION_PARTS[1]}"
PATCH="${VERSION_PARTS[2]}"
PATCH=$((PATCH + 1))
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

sed -i '' "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" "$FRONTEND_DIR/package.json"
echo -e "${GREEN}   ✓ $CURRENT_VERSION → $NEW_VERSION${NC}"

# 2. Verificar dispositivo conectado
echo ""
echo -e "${YELLOW}📱 Verificando dispositivo...${NC}"
DEVICE_NAME=$(adb devices | grep -v "List" | grep "device" | head -1 | awk '{print $1}')
if [ -z "$DEVICE_NAME" ]; then
    echo -e "${RED}   ✗ No hay dispositivos conectados${NC}"
    echo ""
    echo "   Conecta tu dispositivo y ejecuta:"
    echo "   ./adb-tools.sh info"
    exit 1
fi
echo -e "${GREEN}   ✓ Dispositivo encontrado: $DEVICE_NAME${NC}"

# 3. Configurar entorno mobile
echo ""
echo -e "${YELLOW}🔧 Configurando entorno mobile...${NC}"
if [ -f "$FRONTEND_DIR/.env.mobile" ]; then
    cp "$FRONTEND_DIR/.env.mobile" "$FRONTEND_DIR/.env"
    echo -e "${GREEN}   ✓ Backend remoto configurado${NC}"
else
    echo -e "${YELLOW}   ⚠️  Usando .env actual${NC}"
fi

# 4. Construir APK
echo ""
echo -e "${YELLOW}🔨 Construyendo APK...${NC}"
cd "$FRONTEND_DIR"

# Quasar build
echo "   → Building Quasar..."
quasar build -m capacitor -T android > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}   ✗ Error en build de Quasar${NC}"
    cd ..
    exit 1
fi
echo -e "${GREEN}   ✓ Quasar build completo${NC}"

# Capacitor sync
echo "   → Syncing Capacitor..."
npx cap sync android > /dev/null 2>&1
echo -e "${GREEN}   ✓ Capacitor sync completo${NC}"

# Gradle build
echo "   → Building APK..."
cd src-capacitor/android
./gradlew assembleDebug > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}   ✗ Error en build de Gradle${NC}"
    cd ../../..
    exit 1
fi
echo -e "${GREEN}   ✓ APK generado${NC}"

cd ../../..

# 5. Instalar en dispositivo
echo ""
echo -e "${YELLOW}📲 Instalando en dispositivo...${NC}"
APK_PATH="$FRONTEND_DIR/src-capacitor/android/app/build/outputs/apk/debug/app-debug.apk"
adb -s "$DEVICE_NAME" install -r "$APK_PATH" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
    echo -e "${GREEN}   ✓ APK instalado exitosamente ($APK_SIZE)${NC}"
else
    echo -e "${RED}   ✗ Error al instalar APK${NC}"
    exit 1
fi

# 6. Resumen
echo ""
echo "=================================================="
echo -e "${GREEN}✅ DEPLOY COMPLETO${NC}"
echo "=================================================="
echo -e "   📱 Dispositivo: $DEVICE_NAME"
echo -e "   📦 Versión: ${BLUE}v$NEW_VERSION${NC}"
echo -e "   💾 APK: $APK_SIZE"
echo ""
echo "💡 La app ya está actualizada en tu dispositivo"
echo "   Abre OWFINANCE para ver v$NEW_VERSION"
echo ""
