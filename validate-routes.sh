#!/bin/bash
# validate-routes.sh - Validar que no existan rutas con /app/ en el código frontend

set -euo pipefail

FRONTEND_DIR="OWFinanceFrontend2025/src"
FOUND_ISSUES=0

echo "🔍 Validando rutas en frontend..."
echo ""

# Buscar /app/ en archivos .vue y .ts (excluyendo comentarios)
echo "Buscando rutas con /app/ incorrectas..."
RESULTS=$(grep -rn "to=\"/app/" "$FRONTEND_DIR" 2>/dev/null || true)
if [[ -n "$RESULTS" ]]; then
  echo "❌ Encontradas rutas <router-link to=\"/app/\">:"
  echo "$RESULTS"
  FOUND_ISSUES=1
fi

RESULTS=$(grep -rn "push('/app/" "$FRONTEND_DIR" 2>/dev/null || true)
if [[ -n "$RESULTS" ]]; then
  echo "❌ Encontradas rutas router.push('/app/'):"
  echo "$RESULTS"
  FOUND_ISSUES=1
fi

RESULTS=$(grep -rn "route: '/app/" "$FRONTEND_DIR" 2>/dev/null || true)
if [[ -n "$RESULTS" ]]; then
  echo "❌ Encontradas rutas route: '/app/':"
  echo "$RESULTS"
  FOUND_ISSUES=1
fi

RESULTS=$(grep -rn "includes('/app/" "$FRONTEND_DIR" 2>/dev/null || true)
if [[ -n "$RESULTS" ]]; then
  echo "❌ Encontradas rutas includes('/app/'):"
  echo "$RESULTS"
  FOUND_ISSUES=1
fi

if [[ $FOUND_ISSUES -eq 0 ]]; then
  echo "✅ No se encontraron rutas con /app/ incorrectas"
  echo ""
  echo "✅ VALIDACIÓN EXITOSA: Todas las rutas usan /user/ o /admin/ correctamente"
  exit 0
else
  echo ""
  echo "❌ VALIDACIÓN FALLIDA: Se encontraron rutas con /app/ que pueden causar duplicación /app/app/"
  echo ""
  echo "💡 Regla: Cuando publicPath='/app/', las rutas deben ser:"
  echo "   - /user/* (para rutas de usuario)"
  echo "   - /admin/* (para rutas de admin)"
  echo "   - /login, /register, etc (para rutas públicas)"
  echo "   NUNCA usar /app/user/* o /app/admin/*"
  exit 1
fi
