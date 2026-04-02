#!/bin/bash

# Script para iniciar Backend y Frontend en modo desarrollo
# Uso: ./dev-start.sh

echo "🚀 Iniciando OWFINANCE Development Environment..."
echo "=================================================="

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directorios
BACKEND_DIR="OWFINANCEBackend2025"
FRONTEND_DIR="OWFinanceFrontend2025"

# Función para verificar si un puerto está en uso
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null ; then
        echo "⚠️  Puerto $1 ya está en uso"
        return 1
    else
        return 0
    fi
}

# Verificar puertos
echo "🔍 Verificando puertos disponibles..."
check_port 8000 || { echo "❌ Backend port 8000 ocupado"; exit 1; }
check_port 3000 || { echo "❌ Frontend port 3000 ocupado"; exit 1; }

# Iniciar Backend Laravel
echo -e "${BLUE}📦 Iniciando Backend Laravel en puerto 8000...${NC}"
cd $BACKEND_DIR
if [ ! -f ".env" ]; then
    echo "⚠️  No existe .env, copiando de .env.example..."
    cp .env.example .env
    php artisan key:generate
fi

# Verificar composer
if [ ! -d "vendor" ]; then
    echo "📥 Instalando dependencias de Composer..."
    composer install
fi

# Iniciar servidor Laravel en background
php artisan serve --host=0.0.0.0 --port=8000 > ../logs/backend.log 2>&1 &
BACKEND_PID=$!
echo -e "${GREEN}✅ Backend iniciado (PID: $BACKEND_PID)${NC}"
echo "   📍 URL: http://localhost:8000"

cd ..

# Iniciar Frontend Quasar
echo -e "${BLUE}🎨 Iniciando Frontend Quasar en puerto 3000...${NC}"
cd $FRONTEND_DIR

# Verificar node_modules
if [ ! -d "node_modules" ]; then
    echo "📥 Instalando dependencias de NPM..."
    npm install
fi

# Iniciar servidor Quasar en background
npm run dev > ../logs/frontend.log 2>&1 &
FRONTEND_PID=$!
echo -e "${GREEN}✅ Frontend iniciado (PID: $FRONTEND_PID)${NC}"
echo "   📍 URL: http://localhost:3000"

cd ..

# Guardar PIDs
echo "$BACKEND_PID" > .backend.pid
echo "$FRONTEND_PID" > .frontend.pid

echo ""
echo "=================================================="
echo -e "${GREEN}🎉 ¡Entorno de desarrollo iniciado!${NC}"
echo "=================================================="
echo "Backend:  http://localhost:8000"
echo "Frontend: http://localhost:3000"
echo ""
echo "📋 Logs disponibles en:"
echo "   Backend:  logs/backend.log"
echo "   Frontend: logs/frontend.log"
echo ""
echo "Para detener: ./dev-stop.sh"
echo "=================================================="

# Esperar a que los servicios estén listos
echo ""
echo "⏳ Esperando servicios (5 segundos)..."
sleep 5

# Abrir navegadores (opcional, comentar si no deseas)
echo "🌐 Abriendo navegadores..."
open http://localhost:8000 2>/dev/null || true
open http://localhost:3000 2>/dev/null || true

echo ""
echo "✨ ¡Listo para desarrollar!"
