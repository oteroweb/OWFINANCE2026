#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${CYAN}::${NC} $*"; }
success() { echo -e "${GREEN}OK${NC} $*"; }
warn() { echo -e "${YELLOW}WARN${NC} $*"; }
error() { echo -e "${RED}ERR${NC} $*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Uso:
  ./push-workspace.sh <backend|frontend|both> "mensaje de commit" [--push-root]

Ejemplos:
  ./push-workspace.sh frontend "fix(ui): corrige bottom nav"
  ./push-workspace.sh backend "feat(api): agrega settings"
  ./push-workspace.sh both "chore: sincroniza cambios coordinados" --push-root

Que hace:
  1. Detecta la rama objetivo de cada submodulo desde .gitmodules.
  2. Verifica que el subrepo este limpio o hace commit si hay cambios.
  3. Hace push al remoto del subrepo.
  4. Ejecuta ./sync-submodule-pointers.sh --commit en el root.
  5. Si se pasa --push-root, empuja tambien el repo central.
EOF
}

[[ $# -ge 2 ]] || { usage; exit 1; }

TARGET="$1"
shift
COMMIT_MSG="$1"
shift

PUSH_ROOT=0
for arg in "$@"; do
  case "$arg" in
    --push-root)
      PUSH_ROOT=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Argumento no soportado: $arg"
      ;;
  esac
done

repos_for_target() {
  case "$1" in
    backend)
      printf '%s\n' "OWFINANCEBackend2025"
      ;;
    frontend)
      printf '%s\n' "OWFinanceFrontend2025"
      ;;
    both)
      printf '%s\n' "OWFINANCEBackend2025" "OWFinanceFrontend2025"
      ;;
    *)
      error "Target invalido: $1"
      ;;
  esac
}

target_branch_for() {
  local path="$1"
  local branch

  branch="$(git config -f "$ROOT_DIR/.gitmodules" --get "submodule.${path}.branch" || true)"
  if [[ -z "$branch" ]]; then
    branch="dev"
  fi

  printf '%s\n' "$branch"
}

prepare_and_push_repo() {
  local path="$1"
  local branch
  local current_branch

  branch="$(target_branch_for "$path")"

  info "Preparando $path en rama $branch"
  git -C "$ROOT_DIR/$path" fetch --all --prune >/dev/null

  current_branch="$(git -C "$ROOT_DIR/$path" branch --show-current || true)"

  if [[ -z "$current_branch" ]]; then
    if git -C "$ROOT_DIR/$path" merge-base --is-ancestor HEAD "origin/$branch"; then
      warn "$path estaba detached; se normaliza a $branch"
      git -C "$ROOT_DIR/$path" checkout -B "$branch" "origin/$branch" >/dev/null
    else
      error "$path esta detached y HEAD no pertenece a origin/$branch"
    fi
  elif [[ "$current_branch" != "$branch" ]]; then
    info "$path cambia de $current_branch a $branch"
    git -C "$ROOT_DIR/$path" checkout "$branch" >/dev/null 2>&1 || git -C "$ROOT_DIR/$path" checkout -B "$branch" "origin/$branch" >/dev/null
  fi

  if [[ -n "$(git -C "$ROOT_DIR/$path" status --porcelain)" ]]; then
    info "Creando commit en $path"
    git -C "$ROOT_DIR/$path" add -A
    git -C "$ROOT_DIR/$path" commit -m "$COMMIT_MSG"
  else
    info "$path no tiene cambios locales; se reutiliza HEAD actual"
  fi

  git -C "$ROOT_DIR/$path" pull --ff-only origin "$branch" >/dev/null
  git -C "$ROOT_DIR/$path" push origin "$branch"
  success "$path empujado a origin/$branch"
}

cd "$ROOT_DIR"

while IFS= read -r repo; do
  prepare_and_push_repo "$repo"
done < <(repos_for_target "$TARGET")

if [[ "$PUSH_ROOT" -eq 1 ]]; then
  "$ROOT_DIR/sync-submodule-pointers.sh" --commit --push
else
  "$ROOT_DIR/sync-submodule-pointers.sh" --commit
fi
