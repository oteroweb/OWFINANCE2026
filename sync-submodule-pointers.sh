#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TARGETS=(
  "OWFINANCEBackend2025"
  "OWFinanceFrontend2025"
)

AUTO_COMMIT=0
AUTO_PUSH=0
UPDATE_BRANCHES=1
MODE="sync"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${CYAN}::${NC} $*"; }
success() { echo -e "${GREEN}OK${NC} $*"; }
warn() { echo -e "${YELLOW}WARN${NC} $*"; }
error() { echo -e "${RED}ERR${NC} $*" >&2; exit 1; }

git_cfg_get() {
  local scope="$1"
  local key="$2"
  local value

  value="$(git config "$scope" --get "$key" 2>/dev/null || true)"
  if [[ -z "$value" && -x "$(command -v git.exe 2>/dev/null || true)" ]]; then
    value="$(git.exe config "$scope" --get "$key" 2>/dev/null || true)"
  fi

  printf '%s\n' "$value"
}

ensure_git_identity() {
  local name
  local email

  name="$(git config --local --get user.name 2>/dev/null || true)"
  email="$(git config --local --get user.email 2>/dev/null || true)"

  if [[ -n "$name" && -n "$email" ]]; then
    return 0
  fi

  name="${name:-$(git_cfg_get --global user.name)}"
  email="${email:-$(git_cfg_get --global user.email)}"

  [[ -n "$name" ]] || error "No se encontro user.name para Git"
  [[ -n "$email" ]] || error "No se encontro user.email para Git"

  git config --local user.name "$name"
  git config --local user.email "$email"
}

usage() {
  cat <<'EOF'
Uso:
  ./sync-submodule-pointers.sh [--report] [--commit] [--push] [--no-pull]

Modos:
  --report   Solo diagnostica. No cambia ramas ni stagea nada.
  --commit   Stagea los punteros de submodulo en el repo raiz y crea commit.
  --push     Hace push del repo raiz despues del commit. Requiere --commit.
  --no-pull  No hace fetch/pull fast-forward sobre backend/frontend.

Flujo por defecto:
  1. Verifica root limpio fuera de punteros de submodulo.
  2. Normaliza backend/frontend sobre su rama objetivo.
  3. Hace pull --ff-only si el subrepo esta limpio.
  4. Detecta si el repo raiz quedo con punteros desfasados.
  5. Si se pasa --commit, crea un commit en el repo raiz con esos punteros.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --report)
      MODE="report"
      ;;
    --commit)
      AUTO_COMMIT=1
      ;;
    --push)
      AUTO_PUSH=1
      ;;
    --no-pull)
      UPDATE_BRANCHES=0
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

if [[ "$AUTO_PUSH" -eq 1 && "$AUTO_COMMIT" -ne 1 ]]; then
  error "--push requiere --commit"
fi

cd "$ROOT_DIR"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || error "El root no es un repo git"
ensure_git_identity

ROOT_BRANCH="$(git branch --show-current)"
[[ -n "$ROOT_BRANCH" ]] || error "El repo raiz esta en detached HEAD"

is_allowed_root_change() {
  local line="$1"
  local path

  path="${line:3}"
  for submodule_path in "${TARGETS[@]}"; do
    if [[ "$path" == "$submodule_path" ]]; then
      return 0
    fi
  done
  return 1
}

ROOT_STATUS="$(git status --porcelain)"
if [[ -n "$ROOT_STATUS" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if ! is_allowed_root_change "$line"; then
      error "El repo raiz tiene cambios fuera de los submodulos objetivo: $line"
    fi
  done <<<"$ROOT_STATUS"
fi

declare -a DIRTY_POINTERS=()
declare -a SUMMARY_LINES=()

target_branch_for() {
  local path="$1"
  local branch

  branch="$(git config -f "$ROOT_DIR/.gitmodules" --get "submodule.${path}.branch" || true)"
  if [[ -z "$branch" ]]; then
    branch="dev"
  fi

  printf '%s\n' "$branch"
}

sync_one() {
  local path="$1"
  local target_branch="$2"
  local current_branch
  local expected_commit
  local actual_commit
  local short_expected
  local short_actual

  [[ -d "$ROOT_DIR/$path/.git" || -f "$ROOT_DIR/$path/.git" ]] || error "No existe el repo de submodulo: $path"

  info "Revisando $path -> rama objetivo $target_branch"

  git -C "$ROOT_DIR/$path" fetch --all --prune >/dev/null 2>&1 || error "No se pudo hacer fetch en $path"

  current_branch="$(git -C "$ROOT_DIR/$path" branch --show-current || true)"

  if [[ -z "$current_branch" ]]; then
    if git -C "$ROOT_DIR/$path" merge-base --is-ancestor HEAD "origin/$target_branch"; then
      warn "$path esta detached; se normaliza a $target_branch"
      git -C "$ROOT_DIR/$path" checkout -B "$target_branch" "origin/$target_branch" >/dev/null
      current_branch="$target_branch"
    else
      error "$path esta detached y HEAD no pertenece a origin/$target_branch"
    fi
  fi

  if [[ "$current_branch" != "$target_branch" ]]; then
    info "$path cambia de $current_branch a $target_branch"
    git -C "$ROOT_DIR/$path" checkout "$target_branch" >/dev/null 2>&1 || git -C "$ROOT_DIR/$path" checkout -B "$target_branch" "origin/$target_branch" >/dev/null
    current_branch="$target_branch"
  fi

  if [[ -n "$(git -C "$ROOT_DIR/$path" status --porcelain)" ]]; then
    error "$path tiene cambios locales. Limpialos o committealos antes de sincronizar"
  fi

  git -C "$ROOT_DIR/$path" branch --set-upstream-to="origin/$target_branch" "$target_branch" >/dev/null 2>&1 || true

  if [[ "$MODE" != "report" && "$UPDATE_BRANCHES" -eq 1 ]]; then
    git -C "$ROOT_DIR/$path" pull --ff-only origin "$target_branch" >/dev/null || error "No se pudo hacer pull --ff-only en $path"
  fi

  expected_commit="$(git ls-tree HEAD "$path" | awk '{print $3}')"
  actual_commit="$(git -C "$ROOT_DIR/$path" rev-parse HEAD)"
  short_expected="${expected_commit:0:7}"
  short_actual="${actual_commit:0:7}"

  if [[ "$expected_commit" != "$actual_commit" ]]; then
    DIRTY_POINTERS+=("$path")
    SUMMARY_LINES+=("$path ${short_expected:-none} -> $short_actual")
    warn "$path queda desfasado en root: ${short_expected:-none} -> $short_actual"
  else
    SUMMARY_LINES+=("$path sincronizado en $short_actual")
    success "$path ya coincide con el puntero del root ($short_actual)"
  fi
}

for path in "${TARGETS[@]}"; do
  target_branch="$(target_branch_for "$path")"
  sync_one "$path" "$target_branch"
done

echo ""
info "Resumen"
for line in "${SUMMARY_LINES[@]}"; do
  echo " - $line"
done

if [[ "${#DIRTY_POINTERS[@]}" -eq 0 ]]; then
  success "No hay punteros por actualizar en el repo raiz"
  exit 0
fi

if [[ "$AUTO_COMMIT" -ne 1 ]]; then
  warn "Hay punteros pendientes en root. Ejecuta con --commit para registrarlos"
  exit 0
fi

git add "${DIRTY_POINTERS[@]}"

commit_message="chore(submodules): sync workspace pointers"
if [[ "${#DIRTY_POINTERS[@]}" -eq 1 ]]; then
  commit_message="chore(submodule): sync ${DIRTY_POINTERS[0]} pointer"
fi

git commit -m "$commit_message"
success "Commit creado en root: $commit_message"

if [[ "$AUTO_PUSH" -eq 1 ]]; then
  git push origin "$ROOT_BRANCH"
  success "Push completado en origin/$ROOT_BRANCH"
fi
