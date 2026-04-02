#!/bin/bash

# Script para arreglar problemas de versión de Java en Android
# Uso: ./fix-java-android.sh

FRONTEND_DIR="OWFinanceFrontend2025"

echo "🔧 Arreglando configuración de Java para Android"
echo "=================================================="

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Detectar versión de Java actual
echo "🔍 Detectando instalaciones de Java..."
echo ""
/usr/libexec/java_home -V 2>&1 | grep -E "Java|openjdk|Eclipse|Azul"

echo ""
echo "Java actual en uso:"
java -version

# Buscar Java 17
JAVA_17_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null)

if [ -z "$JAVA_17_HOME" ]; then
    echo ""
    echo -e "${RED}❌ Java 17 no encontrado${NC}"
    echo ""
    echo "Instala Java 17:"
    echo "  brew install --cask zulu17"
    echo "O:"
    echo "  brew install openjdk@17"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Java 17 encontrado en: $JAVA_17_HOME${NC}"

# Actualizar gradle.properties
GRADLE_PROPS="$FRONTEND_DIR/src-capacitor/android/gradle.properties"

if [ ! -f "$GRADLE_PROPS" ]; then
    echo -e "${RED}❌ No se encuentra gradle.properties${NC}"
    exit 1
fi

echo ""
echo "📝 Actualizando gradle.properties..."

# Agregar o actualizar la configuración de Java
if grep -q "org.gradle.java.home" "$GRADLE_PROPS"; then
    # Actualizar línea existente
    sed -i '' "s|org.gradle.java.home=.*|org.gradle.java.home=$JAVA_17_HOME|" "$GRADLE_PROPS"
else
    # Agregar nueva línea
    echo "" >> "$GRADLE_PROPS"
    echo "# Configurar Java 17 para compatibilidad con Capacitor" >> "$GRADLE_PROPS"
    echo "org.gradle.java.home=$JAVA_17_HOME" >> "$GRADLE_PROPS"
fi

echo -e "${GREEN}✅ gradle.properties actualizado${NC}"

# Verificar build.gradle de app
APP_BUILD_GRADLE="$FRONTEND_DIR/src-capacitor/android/app/build.gradle"

if ! grep -q "sourceCompatibility JavaVersion.VERSION_17" "$APP_BUILD_GRADLE"; then
    echo ""
    echo "📝 Actualizando app/build.gradle..."
    
    # Crear backup
    cp "$APP_BUILD_GRADLE" "$APP_BUILD_GRADLE.backup"
    
    # Agregar compileOptions si no existe
    if ! grep -q "compileOptions" "$APP_BUILD_GRADLE"; then
        # Insertar antes del último }
        awk '/^}$/ && !found {
            print "    compileOptions {"
            print "        sourceCompatibility JavaVersion.VERSION_17"
            print "        targetCompatibility JavaVersion.VERSION_17"
            print "    }"
            found=1
        }
        {print}' "$APP_BUILD_GRADLE.backup" > "$APP_BUILD_GRADLE"
        
        echo -e "${GREEN}✅ app/build.gradle actualizado${NC}"
    else
        echo -e "${BLUE}ℹ️  compileOptions ya existe en app/build.gradle${NC}"
    fi
fi

# Limpiar builds anteriores
echo ""
echo "🧹 Limpiando builds anteriores..."
cd "$FRONTEND_DIR/src-capacitor/android"

rm -rf .gradle
rm -rf build
rm -rf app/build
rm -rf capacitor-cordova-android-plugins/build

echo -e "${GREEN}✅ Limpieza completada${NC}"

cd ../../..

echo ""
echo "=================================================="
echo -e "${GREEN}✨ Configuración corregida${NC}"
echo "=================================================="
echo ""
echo "Java configurado: $JAVA_17_HOME"
echo ""
echo "Siguiente paso:"
echo "  ./deploy-mobile.sh android dev"
echo ""
echo "=================================================="
