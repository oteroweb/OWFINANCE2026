#!/usr/bin/env bash
# =============================================================================
# .owf/sync-engram.sh — Bridge bidireccional entre .owf/ (repo) y Engram (local)
# =============================================================================
# Uso:
#   .owf/sync-engram.sh push    → .owf/ files → Engram (despues de una sesion)
#   .owf/sync-engram.sh pull    → Engram → .owf/ files (al iniciar en nueva maquina)
#   .owf/sync-engram.sh status  → compara timestamps de ambos lados
# =============================================================================
set -euo pipefail

OWF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$OWF_DIR/.." && pwd)"
PROJECT="owfinance2026"

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()    { echo -e "${CYAN}▶${NC} $*"; }
success() { echo -e "${GREEN}✔${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC} $*"; }
error()   { echo -e "${RED}✗${NC} $*"; exit 1; }

command -v engram >/dev/null 2>&1 || error "engram CLI no encontrado"

engram_push_file() {
  local key="$1"
  local file="$2"
  local label="$3"

  if [ ! -f "$file" ]; then
    warn "$label: archivo no encontrado ($file)"
    return
  fi

  local content
  content="$(cat "$file")"

  if [ -z "$content" ]; then
    warn "$label: archivo vacio"
    return
  fi

  engram save "owf/${key}" "$content" \
    --type project \
    --project "$PROJECT" \
    --scope project \
    >/dev/null 2>&1

  success "$label → Engram (owf/${key})"
}

engram_pull_file() {
  local key="$1"
  local file="$2"
  local label="$3"

  local search_output
  search_output="$(engram search "owf/${key}" --project "$PROJECT" --limit 1 2>&1)" || true

  if echo "$search_output" | grep -q "Found 0 memories"; then
    warn "$label: no encontrado en Engram"
    return
  fi

  local obs_id
  obs_id="$(echo "$search_output" | grep -oE '#[0-9]+' | head -1 | tr -d '#')"

  if [ -z "$obs_id" ]; then
    warn "$label: no se pudo extraer ID de Engram"
    return
  fi

  local engram_content
  engram_content="$(engram show "$obs_id" 2>&1 | tail -n +3)" || true

  if [ -z "$engram_content" ]; then
    warn "$label: contenido vacio en Engram"
    return
  fi

  if [ -f "$file" ]; then
    local file_ts engram_ts
    file_ts="$(grep -oP 'Updated:\s+\K[^\s]+' "$file" 2>/dev/null || echo "1970-01-01")"
    echo "$search_output" | grep -q "2026" && engram_ts="$(echo "$search_output" | grep -oP '\d{4}-\d{2}-\d{2}' | head -1)" || engram_ts="1970-01-01"

    if [[ "$engram_ts" > "$file_ts" ]]; then
      echo "$engram_content" > "$file"
      success "Engram → $label (owf/${key}, mas reciente)"
    else
      info "$label: archivo local es mas reciente, no se sobreescribe"
    fi
  else
    echo "$engram_content" > "$file"
    success "Engram → $label (owf/${key})"
  fi
}

case "${1:-}" in
  push)
    info "Push .owf/ → Engram (project: $PROJECT)"
    engram_push_file "state"   "$OWF_DIR/STATE.md"   "STATE.md"
    engram_push_file "tasks"   "$OWF_DIR/TASKS.md"   "TASKS.md"
    engram_push_file "context" "$OWF_DIR/CONTEXT.md"  "CONTEXT.md"
    echo ""
    success "Push completado. Engram actualizado con estado del repo."
    ;;

  pull)
    info "Pull Engram → .owf/ (project: $PROJECT)"
    engram_pull_file "state"   "$OWF_DIR/STATE.md"   "STATE.md"
    engram_pull_file "tasks"   "$OWF_DIR/TASKS.md"   "TASKS.md"
    engram_pull_file "context" "$OWF_DIR/CONTEXT.md"  "CONTEXT.md"
    echo ""
    success "Pull completado. Archivos .owf/ actualizados desde Engram."
    ;;

  status)
    info "Comparando .owf/ ↔ Engram"
    echo ""

    for key in state tasks context; do
      file="$OWF_DIR/STATE.md"
      [ "$key" = "tasks" ] && file="$OWF_DIR/TASKS.md"
      [ "$key" = "context" ] && file="$OWF_DIR/CONTEXT.md"

      label="$(basename "$file")"

      local_ts="N/A"
      engram_ts="N/A"

      if [ -f "$file" ]; then
        local_ts="$(grep -oP 'Updated:\s+\K[^\sZ]+' "$file" 2>/dev/null || echo "unknown")"
      fi

      search_output="$(engram search "owf/${key}" --project "$PROJECT" --limit 1 2>&1)" || true
      if ! echo "$search_output" | grep -q "Found 0 memories"; then
        engram_ts="$(echo "$search_output" | grep -oP '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}' | head -1)"
        engram_ts="${engram_ts:-N/A}"
      fi

      printf "  %-12s  Repo: %-20s  Engram: %s\n" "$label" "$local_ts" "$engram_ts"
    done
    ;;

  *)
    echo "Uso: $0 <push|pull|status>"
    echo ""
    echo "  push    → .owf/ files → Engram (despues de trabajar)"
    echo "  pull    → Engram → .owf/ files (al iniciar en nueva maquina/sesion)"
    echo "  status  → compara timestamps de ambos lados"
    exit 1
    ;;
esac
