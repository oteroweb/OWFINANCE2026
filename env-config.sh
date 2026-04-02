#!/bin/bash

# Gestor de Variables de Entorno para OWFINANCE
# Uso: ./env-config.sh [environment]
# Entornos disponibles: dev, staging, prod

ENVIRONMENT=${1:-dev}
BACKEND_DIR="OWFINANCEBackend2025"
FRONTEND_DIR="OWFinanceFrontend2025"

echo "🔧 Configurando entorno: $ENVIRONMENT"
echo "=================================================="

case $ENVIRONMENT in
    dev)
        # Backend Development
        cat > $BACKEND_DIR/.env << EOF
APP_NAME=OWFINANCE
APP_ENV=local
APP_KEY=base64:$(openssl rand -base64 32)
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=owfinancebackend2025
DB_USERNAME=root
DB_PASSWORD=

SESSION_DRIVER=database
CACHE_STORE=database
QUEUE_CONNECTION=database

CORS_ALLOWED_ORIGINS=http://localhost:3000
EOF

        # Frontend Development
        cat > $FRONTEND_DIR/.env << EOF
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_API_KEY=dev-key
VITE_ENV=development
EOF
        echo "✅ Configuración DEV aplicada"
        ;;
        
    staging)
        echo "⚠️  Configurar manualmente $BACKEND_DIR/.env para STAGING"
        echo "⚠️  Configurar manualmente $FRONTEND_DIR/.env para STAGING"
        cat > $BACKEND_DIR/.env.staging << EOF
APP_NAME=OWFINANCE
APP_ENV=staging
APP_DEBUG=false
APP_URL=https://staging.tudominio.com

# Configurar base de datos de staging
DB_CONNECTION=mysql
DB_HOST=staging-db-host
DB_PORT=3306
DB_DATABASE=owfinance_staging
DB_USERNAME=staging_user
DB_PASSWORD=CAMBIAR_PASSWORD

CORS_ALLOWED_ORIGINS=https://staging.tudominio.com
EOF

        cat > $FRONTEND_DIR/.env.staging << EOF
VITE_API_BASE_URL=https://staging.tudominio.com/api/v1
VITE_API_KEY=staging-key
VITE_ENV=staging
EOF
        echo "✅ Archivos .env.staging creados (revisar y renombrar a .env)"
        ;;
        
    prod)
        echo "⚠️  PRODUCCIÓN - Configurar con EXTREMA PRECAUCIÓN"
        cat > $BACKEND_DIR/.env.production << EOF
APP_NAME=OWFINANCE
APP_ENV=production
APP_DEBUG=false
APP_URL=https://tudominio.com

# ⚠️ CONFIGURAR CREDENCIALES REALES
DB_CONNECTION=mysql
DB_HOST=prod-db-host
DB_PORT=3306
DB_DATABASE=owfinance_prod
DB_USERNAME=prod_user
DB_PASSWORD=CAMBIAR_PASSWORD_SEGURO

CORS_ALLOWED_ORIGINS=https://tudominio.com

# Seguridad
SESSION_SECURE_COOKIE=true
EOF

        cat > $FRONTEND_DIR/.env.production << EOF
VITE_API_BASE_URL=https://tudominio.com/api/v1
VITE_API_KEY=CAMBIAR_KEY_PRODUCCION
VITE_ENV=production
EOF
        echo "✅ Archivos .env.production creados (revisar y renombrar a .env)"
        ;;
        
    *)
        echo "❌ Entorno no válido. Opciones: dev, staging, prod"
        exit 1
        ;;
esac

echo "=================================================="
echo "✨ Configuración completada para: $ENVIRONMENT"
echo ""
echo "Siguiente paso:"
echo "  cd $BACKEND_DIR && php artisan migrate --seed"
echo "=================================================="
