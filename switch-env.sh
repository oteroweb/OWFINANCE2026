#!/bin/bash

# Script para cambiar entre configuraciones de API
# Uso: ./switch-env.sh [config]
# Configs: local | remote | mobile | production

CONFIG=${1:-local}
FRONTEND_DIR="OWFinanceFrontend2025"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "🔄 Cambiando Configuración de API"
echo "=================================================="

case $CONFIG in
    local)
        echo -e "${BLUE}📍 Backend Local (localhost:8000)${NC}"
        echo "   Para: Desarrollo web con backend local"
        cp "$FRONTEND_DIR/.env.local" "$FRONTEND_DIR/.env"
        ;;
        
    remote)
        echo -e "${CYAN}🌐 Backend Remoto (appfinanzas.blockshift.website)${NC}"
        echo "   Para: Desarrollo web con backend remoto"
        cp "$FRONTEND_DIR/.env.remote" "$FRONTEND_DIR/.env"
        ;;
        
    mobile)
        echo -e "${CYAN}📱 Móvil - Backend Remoto${NC}"
        echo "   Para: Desarrollo de apps móviles"
        cp "$FRONTEND_DIR/.env.mobile" "$FRONTEND_DIR/.env"
        ;;
        
    production|prod)
        echo -e "${YELLOW}🚀 PRODUCCIÓN${NC}"
        echo "   Para: Builds finales"
        cp "$FRONTEND_DIR/.env.production" "$FRONTEND_DIR/.env"
        ;;
        
    *)
        echo -e "${RED}❌ Configuración no válida${NC}"
        echo ""
        echo "Uso: ./switch-env.sh [config]"
        echo ""
        echo "Configuraciones disponibles:"
        echo "  local      - Backend local (localhost:8000)"
        echo "  remote     - Backend remoto en navegador"
        echo "  mobile     - Desarrollo móvil (backend remoto)"
        echo "  production - Producción"
        exit 1
        ;;
esac

# Mostrar configuración actual
echo ""
echo -e "${GREEN}✅ Configuración aplicada${NC}"
echo "=================================================="
echo ""
cat "$FRONTEND_DIR/.env"
echo ""
echo "=================================================="

# Mostrar siguiente paso según configuración
echo ""
echo "💡 Siguiente paso:"
case $CONFIG in
    local)
        echo "   ./dev-start.sh              # Backend + Frontend local"
        echo "   cd OWFINANCEBackend2025 && php artisan serve"
        ;;
    remote)
        echo "   cd OWFinanceFrontend2025 && npm run dev"
        ;;
    mobile)
        echo "   ./dev-mobile.sh             # Desarrollo móvil con hot-reload"
        echo "   ./deploy-mobile.sh both dev # O build completo"
        ;;
    production|prod)
        echo "   ./deploy-mobile.sh both prod"
        ;;
esac
echo ""
