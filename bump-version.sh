#!/bin/bash

# Script para incrementar versión automáticamente
# Uso: ./bump-version.sh [major|minor|patch]

TYPE=${1:-patch}
PACKAGE_JSON="OWFinanceFrontend2025/package.json"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔢 Incrementando versión..."
echo "=================================================="

# Obtener versión actual
CURRENT_VERSION=$(grep '"version"' "$PACKAGE_JSON" | head -1 | sed 's/.*"version": "\(.*\)".*/\1/')
echo "Versión actual: $CURRENT_VERSION"

# Separar en major, minor, patch
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR="${VERSION_PARTS[0]}"
MINOR="${VERSION_PARTS[1]}"
PATCH="${VERSION_PARTS[2]}"

# Incrementar según tipo
case $TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo -e "${YELLOW}⚠️  Tipo no válido. Opciones: major, minor, patch${NC}"
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

# Actualizar package.json
sed -i '' "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/" "$PACKAGE_JSON"

echo -e "${GREEN}✅ Nueva versión: $NEW_VERSION${NC}"
echo "=================================================="
echo ""
echo "💡 Siguiente paso:"
echo "   ./build-apk.sh debug install"
echo ""
