#!/bin/bash

# Script para detener Backend y Frontend
# Uso: ./dev-stop.sh

echo "🛑 Deteniendo OWFINANCE Development Environment..."
echo "=================================================="

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Función para detener proceso
stop_process() {
    PID_FILE=$1
    SERVICE_NAME=$2
    
    if [ -f "$PID_FILE" ]; then
        PID=$(cat $PID_FILE)
        if ps -p $PID > /dev/null; then
            kill $PID
            echo -e "${GREEN}✅ $SERVICE_NAME detenido (PID: $PID)${NC}"
        else
            echo -e "${RED}⚠️  $SERVICE_NAME no está corriendo${NC}"
        fi
        rm $PID_FILE
    else
        echo -e "${RED}⚠️  No se encontró archivo PID para $SERVICE_NAME${NC}"
    fi
}

# Detener Backend
stop_process ".backend.pid" "Backend"

# Detener Frontend
stop_process ".frontend.pid" "Frontend"

# Limpiar procesos adicionales por puerto (por si acaso)
echo ""
echo "🧹 Limpiando procesos en puertos..."

# Backend (puerto 8000)
BACKEND_PIDS=$(lsof -ti:8000)
if [ ! -z "$BACKEND_PIDS" ]; then
    echo "$BACKEND_PIDS" | xargs kill -9
    echo "  ✓ Limpiado puerto 8000"
fi

# Frontend (puerto 3000)
FRONTEND_PIDS=$(lsof -ti:3000)
if [ ! -z "$FRONTEND_PIDS" ]; then
    echo "$FRONTEND_PIDS" | xargs kill -9
    echo "  ✓ Limpiado puerto 3000"
fi

echo ""
echo "=================================================="
echo -e "${GREEN}✅ Entorno de desarrollo detenido${NC}"
echo "=================================================="
