#!/bin/bash

# Script de configuración inicial para deployment móvil
# Este script ayuda a configurar todo lo necesario para iOS y Android

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "🔧 Configuración Inicial - Deployment Móvil"
echo "=================================================="
echo ""

FRONTEND_DIR="OWFinanceFrontend2025"

# Función para verificar comandos
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✅ $2 instalado${NC}"
        return 0
    else
        echo -e "${RED}❌ $2 NO instalado${NC}"
        return 1
    fi
}

# 1. VERIFICAR REQUISITOS GENERALES
echo -e "${CYAN}=== REQUISITOS GENERALES ===${NC}"
echo ""

check_command "node" "Node.js"
check_command "npm" "NPM"
check_command "quasar" "Quasar CLI"

if ! command -v quasar &> /dev/null; then
    echo -e "${YELLOW}Instalando Quasar CLI...${NC}"
    npm install -g @quasar/cli
fi

echo ""

# 2. VERIFICAR ANDROID
echo -e "${CYAN}=== ANDROID ===${NC}"
echo ""

check_command "java" "Java"

if [ ! -z "$ANDROID_HOME" ]; then
    echo -e "${GREEN}✅ ANDROID_HOME configurado: $ANDROID_HOME${NC}"
else
    echo -e "${RED}❌ ANDROID_HOME no configurado${NC}"
    echo "Configura agregando a tu ~/.zshrc o ~/.bash_profile:"
    echo ""
    echo "export ANDROID_HOME=\$HOME/Library/Android/sdk"
    echo "export PATH=\$PATH:\$ANDROID_HOME/platform-tools"
    echo "export PATH=\$PATH:\$ANDROID_HOME/tools"
fi

check_command "adb" "ADB (Android Debug Bridge)"

# Verificar Android Studio
if [ -d "/Applications/Android Studio.app" ]; then
    echo -e "${GREEN}✅ Android Studio instalado${NC}"
else
    echo -e "${YELLOW}⚠️  Android Studio no encontrado en /Applications${NC}"
fi

echo ""

# 3. VERIFICAR iOS (solo en macOS)
echo -e "${CYAN}=== iOS ===${NC}"
echo ""

if [[ "$OSTYPE" == "darwin"* ]]; then
    check_command "xcodebuild" "Xcode"
    check_command "pod" "CocoaPods"
    
    if ! command -v pod &> /dev/null; then
        echo -e "${YELLOW}¿Instalar CocoaPods? (y/n)${NC}"
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo gem install cocoapods
        fi
    fi
else
    echo -e "${YELLOW}⚠️  No estás en macOS - iOS no disponible${NC}"
fi

echo ""

# 4. CONFIGURAR CAPACITOR
echo -e "${CYAN}=== CAPACITOR ===${NC}"
echo ""

cd $FRONTEND_DIR

if [ -d "src-capacitor" ]; then
    echo -e "${GREEN}✅ Capacitor ya inicializado${NC}"
else
    echo -e "${YELLOW}Capacitor no inicializado${NC}"
    echo "¿Inicializar Capacitor ahora? (y/n)"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        quasar mode add capacitor
        cd src-capacitor
        
        echo ""
        echo "¿Agregar plataforma Android? (y/n)"
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            npx cap add android
        fi
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo ""
            echo "¿Agregar plataforma iOS? (y/n)"
            read -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                npx cap add ios
            fi
        fi
        
        cd ..
    fi
fi

cd ..

echo ""

# 5. CONFIGURAR BUNDLE ID
echo -e "${CYAN}=== CONFIGURACIÓN DE APP ===${NC}"
echo ""

CAPACITOR_CONFIG="$FRONTEND_DIR/src-capacitor/capacitor.config.json"

if [ -f "$CAPACITOR_CONFIG" ]; then
    CURRENT_APP_ID=$(grep -o '"appId": *"[^"]*"' "$CAPACITOR_CONFIG" | grep -o '"[^"]*"$' | tr -d '"')
    CURRENT_APP_NAME=$(grep -o '"appName": *"[^"]*"' "$CAPACITOR_CONFIG" | grep -o '"[^"]*"$' | tr -d '"')
    
    echo "Bundle ID actual: $CURRENT_APP_ID"
    echo "Nombre actual: $CURRENT_APP_NAME"
    echo ""
    
    if [ "$CURRENT_APP_ID" == "org.capacitor.quasar.app" ]; then
        echo -e "${YELLOW}⚠️  Usando Bundle ID por defecto${NC}"
        echo "¿Configurar Bundle ID personalizado? (y/n)"
        read -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Ingresa tu Bundle ID (ejemplo: com.tuempresa.owfinance):"
            read NEW_BUNDLE_ID
            
            echo "Ingresa el nombre de la app (ejemplo: OwFinance):"
            read NEW_APP_NAME
            
            # Actualizar capacitor.config.json
            sed -i '' "s|\"appId\": \"$CURRENT_APP_ID\"|\"appId\": \"$NEW_BUNDLE_ID\"|" "$CAPACITOR_CONFIG"
            sed -i '' "s|\"appName\": \"$CURRENT_APP_NAME\"|\"appName\": \"$NEW_APP_NAME\"|" "$CAPACITOR_CONFIG"
            
            echo -e "${GREEN}✅ Configuración actualizada${NC}"
            echo "Bundle ID: $NEW_BUNDLE_ID"
            echo "Nombre: $NEW_APP_NAME"
        fi
    fi
fi

echo ""

# 6. CONFIGURAR VARIABLES DE ENTORNO
echo -e "${CYAN}=== VARIABLES DE ENTORNO ===${NC}"
echo ""

ENV_FILES=(
    "$FRONTEND_DIR/.env.development"
    "$FRONTEND_DIR/.env.staging"
    "$FRONTEND_DIR/.env.production"
)

for ENV_FILE in "${ENV_FILES[@]}"; do
    if [ -f "$ENV_FILE" ]; then
        echo -e "${GREEN}✅ $(basename $ENV_FILE) existe${NC}"
    else
        echo -e "${YELLOW}⚠️  $(basename $ENV_FILE) no existe${NC}"
    fi
done

if [ ! -f "$FRONTEND_DIR/.env.development" ]; then
    echo ""
    echo "¿Crear archivos .env para cada entorno? (y/n)"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Development
        cat > "$FRONTEND_DIR/.env.development" << EOF
VITE_API_BASE_URL=http://localhost:8000/api
VITE_API_KEY=dev-key
VITE_ENV=development
EOF

        # Staging
        cat > "$FRONTEND_DIR/.env.staging" << EOF
VITE_API_BASE_URL=https://staging.tudominio.com/api
VITE_API_KEY=staging-key
VITE_ENV=staging
EOF

        # Production
        cat > "$FRONTEND_DIR/.env.production" << EOF
VITE_API_BASE_URL=https://api.tudominio.com/api
VITE_API_KEY=prod-key
VITE_ENV=production
EOF

        echo -e "${GREEN}✅ Archivos .env creados${NC}"
        echo -e "${YELLOW}⚠️  Recuerda actualizar las URLs y keys${NC}"
    fi
fi

echo ""

# 7. CREAR DIRECTORIOS
echo -e "${CYAN}=== ESTRUCTURA DE DIRECTORIOS ===${NC}"
echo ""

mkdir -p releases/android
mkdir -p releases/ios
mkdir -p logs

echo -e "${GREEN}✅ Directorios creados${NC}"

echo ""

# 8. RESUMEN
echo "=================================================="
echo -e "${CYAN}📋 RESUMEN DE CONFIGURACIÓN${NC}"
echo "=================================================="
echo ""

echo "Próximos pasos:"
echo ""
echo "1️⃣  Android:"
echo "   - Verifica ANDROID_HOME en tu shell config"
echo "   - Si no está configurado: source ~/.zshrc"
echo "   - Prueba: ./deploy-mobile.sh android dev"
echo ""

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "2️⃣  iOS:"
    echo "   - Abre Xcode y configura tu Apple Developer Account"
    echo "   - En Xcode > Preferences > Accounts"
    echo "   - Prueba: ./deploy-mobile.sh ios dev"
    echo ""
fi

echo "3️⃣  Testing:"
echo "   - Android: ./dev-mobile.sh (hot-reload)"
echo "   - Verifica dispositivos: ./adb-tools.sh devices"
echo ""

echo "4️⃣  Producción:"
echo "   - Android: Configura keystore (ver MOBILE_DEPLOYMENT_GUIDE.md)"
echo "   - iOS: Configura certificados en Apple Developer"
echo ""

echo "📚 Lee la guía completa: MOBILE_DEPLOYMENT_GUIDE.md"
echo ""
echo "=================================================="
echo -e "${GREEN}✨ Configuración inicial completada${NC}"
echo "=================================================="
