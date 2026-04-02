#!/bin/bash

# Script de importación de tickets a Notion
# Uso: ./import-to-notion.sh

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${GREEN}📥 Importador de Backlog OWFINANCE2026 a Notion${NC}"
echo "=================================================="

# Verificar token
if [ -z "$NOTION_API_TOKEN" ]; then
  echo -e "${YELLOW}⚠️  No se encontró la variable NOTION_API_TOKEN${NC}"
  echo ""
  echo "Tienes dos opciones:"
  echo "1. Establecer la variable de entorno:"
  echo "   export NOTION_API_TOKEN='secret_...'"
  echo ""
  echo "2. Ejecutar este script con la variable:"
  echo "   NOTION_API_TOKEN='secret_...' ./import-to-notion.sh"
  echo ""
  echo -e "${YELLOW}Si no tienes token, copia manualmente el contenido de los archivos JSON a Notion${NC}"
  exit 1
fi

# Verificar Database ID
if [ -z "$NOTION_DATABASE_ID" ]; then
  NOTION_DATABASE_ID="32de7ace976781958d00dd0d61583eac"
  echo -e "${YELLOW}⚠️  Usando Database ID por defecto: $NOTION_DATABASE_ID${NC}"
fi

echo ""
echo -e "${GREEN}Configuración:${NC}"
echo "  Token: ${NOTION_API_TOKEN:0:20}..."
echo "  Database ID: $NOTION_DATABASE_ID"
echo ""

# Contador de exitos
SUCCESS=0
FAILED=0

# Importar cada ticket
for file in ticket-*.json; do
  if [ -f "$file" ]; then
    echo -e "${YELLOW}→ Importando: $file${NC}"
    
    RESPONSE=$(curl -s -X POST "https://api.notion.com/v1/pages" \
      -H "Authorization: Bearer $NOTION_API_TOKEN" \
      -H "Content-Type: application/json" \
      -H "Notion-Version: 2022-06-28" \
      -d @"$file" 2>&1)
    
    # Verificar si tuvo éxito
    if echo "$RESPONSE" | grep -q '"id":'; then
      echo -e "${GREEN}  ✓ $file importado exitosamente${NC}"
      ((SUCCESS++))
    else
      echo -e "${RED}  ✗ Error al importar $file${NC}"
      echo "  Respuesta: $RESPONSE" | head -c 200
      ((FAILED++))
    fi
    echo ""
  fi
done

echo "=================================================="
echo -e "${GREEN}Resumen:${NC}"
echo "  Exitosos: $SUCCESS"
echo "  Fallidos: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ Todos los tickets fueron importados a Notion!${NC}"
else
  echo -e "${RED}⚠️  Algunos tickets no pudieron ser importados${NC}"
  echo "Revisa los errores arriba o importa manualmente los archivos JSON"
fi

echo ""
