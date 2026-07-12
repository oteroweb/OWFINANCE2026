#!/bin/bash
# run-claude-tasks.sh — Ejecuta las tareas P1 pendientes en Claude Code
set -e
WORKSPACE="/Users/otero/OW_Ecosystem/apps/owfinance/central"
PROMPTS_DIR="$WORKSPACE/.owf/claude-prompts"

echo "OWFinance - Claude Code Task Runner"

# Verificar auth
if ! claude -p "echo" --allowedTools "Bash" 2>/dev/null | grep -q "echo"; then
  echo "ERROR: Claude Code no autenticado. Corre: claude login"
  exit 1
fi
echo "OK: Claude Code autenticado"

# Tarea 1: OWF-221
echo "OWF-221: Consolidar tasas de cambio..."
claude -p "$(cat $PROMPTS_DIR/OWF-221.md)\nLee .owf/STATE.md y .owf/TASKS.md primero." --allowedTools "Read,Edit,Write,Bash,Glob,Grep"

# Tarea 2: OWF-222
echo "OWF-222: monthly_income en Lite..."
claude -p "$(cat $PROMPTS_DIR/OWF-222.md)\nLee .owf/STATE.md y .owf/TASKS.md primero." --allowedTools "Read,Edit,Write,Bash,Glob,Grep"

# Tarea 3: OWF-271
echo "OWF-271: Movimientos especiales..."
claude -p "$(cat $PROMPTS_DIR/OWF-271.md)\nLee .owf/STATE.md y .owf/TASKS.md primero." --allowedTools "Read,Edit,Write,Bash,Glob,Grep"

echo "Las 3 tareas completadas - revisar cambios"
