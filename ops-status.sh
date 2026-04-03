#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./ops-status.sh [--one-line] [dev|stage|prod]
  ./ops-status.sh --help

Checks:
  dev    Reuses ./status.sh and adds lightweight local HTTP probes
  stage  Uses stage env overrides or local .env.staging files when available
  prod   Uses known active production URLs

Optional env vars for stage:
  OWF_STAGE_FRONTEND_URL
  OWF_STAGE_API_BASE_URL
  OWF_STAGE_HEALTH_URL
EOF
}

trim() {
  local value="$1"
  value="${value#${value%%[![:space:]]*}}"
  value="${value%${value##*[![:space:]]}}"
  printf '%s' "$value"
}

read_env_value() {
  local file_path="$1"
  local key="$2"

  [ -f "$file_path" ] || return 0

  python3 - "$file_path" "$key" <<'PY'
import pathlib
import sys

file_path = pathlib.Path(sys.argv[1])
target = sys.argv[2]

for raw_line in file_path.read_text(encoding="utf-8").splitlines():
    line = raw_line.strip()
    if not line or line.startswith("#") or "=" not in line:
        continue
    key, value = line.split("=", 1)
    if key.strip() != target:
        continue
    value = value.strip().strip('"').strip("'")
    print(value)
    break
PY
}

looks_placeholder() {
  case "$1" in
    ""|*tudominio.com*|*CAMBIAR_*|*example.com*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

origin_from_url() {
  local url="$1"
  python3 - "$url" <<'PY'
from urllib.parse import urlparse
import sys

url = sys.argv[1]
parsed = urlparse(url)
if not parsed.scheme or not parsed.netloc:
    sys.exit(1)
print(f"{parsed.scheme}://{parsed.netloc}")
PY
}

http_probe() {
  local url="$1"
  local label="$2"
  local method="${3:-GET}"
  local code

  code="$(curl --silent --output /dev/null --write-out '%{http_code}' --location --max-time 10 --request "$method" "$url" || true)"

  if [ -n "$code" ] && [ "$code" -ge 200 ] && [ "$code" -lt 400 ]; then
    printf 'OK | %s | %s | %s\n' "$label" "$code" "$url"
    return 0
  fi

  if [ -z "$code" ] || [ "$code" = "000" ]; then
    printf 'FAIL | %s | no-response | %s\n' "$label" "$url"
  else
    printf 'FAIL | %s | %s | %s\n' "$label" "$code" "$url"
  fi
  return 1
}

port_open() {
  local port="$1"
  lsof -Pi :"$port" -sTCP:LISTEN -t >/dev/null 2>&1
}

render_probe_block() {
  local line="$1"
  local state label detail url suffix
  IFS='|' read -r state label detail url <<EOF
$line
EOF
  suffix=""
  if [ -n "$(trim "$url")" ]; then
    suffix=" $(trim "$url")"
  fi
  printf '  - %s: %s (%s)%s\n' "$(trim "$label")" "$(trim "$state")" "$(trim "$detail")" "$suffix"
}

one_line=0
environment="dev"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --one-line)
      one_line=1
      shift
      ;;
    -h|--help|help)
      usage
      exit 0
      ;;
    dev|stage|prod)
      environment="$1"
      shift
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

frontend_url=""
api_base_url=""
health_url=""
configured=1

case "$environment" in
  dev)
    frontend_url="http://localhost:3000"
    api_base_url="http://localhost:8000/api/v1"
    health_url="http://localhost:8000/up"
    ;;
  stage)
    frontend_url="${OWF_STAGE_FRONTEND_URL:-}"
    api_base_url="${OWF_STAGE_API_BASE_URL:-}"
    health_url="${OWF_STAGE_HEALTH_URL:-}"

    if [ -z "$api_base_url" ]; then
      api_base_url="$(read_env_value "$ROOT_DIR/OWFinanceFrontend2025/.env.staging" "VITE_API_BASE_URL")"
    fi

    if [ -z "$frontend_url" ]; then
      frontend_url="$(read_env_value "$ROOT_DIR/OWFINANCEBackend2025/.env.staging" "APP_URL")"
    fi

    if [ -z "$frontend_url" ] && [ -n "$api_base_url" ] && ! looks_placeholder "$api_base_url"; then
      frontend_url="$(origin_from_url "$api_base_url" 2>/dev/null || true)"
    fi

    if [ -z "$health_url" ] && [ -n "$api_base_url" ] && ! looks_placeholder "$api_base_url"; then
      health_url="$(origin_from_url "$api_base_url" 2>/dev/null || true)/up"
    fi

    if looks_placeholder "$frontend_url"; then
      frontend_url=""
    fi
    if looks_placeholder "$api_base_url"; then
      api_base_url=""
    fi
    if looks_placeholder "$health_url"; then
      health_url=""
    fi

    if [ -z "$frontend_url" ] || [ -z "$health_url" ]; then
      configured=0
    fi
    ;;
  prod)
    frontend_url="https://appfinanzas.blockshift.website/app/"
    api_base_url="https://appfinanzas.blockshift.website/api/v1"
    health_url="https://appfinanzas.blockshift.website/up"
    ;;
esac

port_backend="down"
port_frontend="down"
if [ "$environment" = "dev" ]; then
  if port_open 8000; then
    port_backend="up"
  fi
  if port_open 3000; then
    port_frontend="up"
  fi
fi

http_results=()
failures=0

if [ "$environment" = "dev" ]; then
  probe_output="$(http_probe "$frontend_url" "frontend" "GET" || true)"
  http_results+=("$probe_output")
  case "$probe_output" in OK*) ;; *) failures=$((failures + 1)) ;; esac

  probe_output="$(http_probe "$health_url" "backend-health" "GET" || true)"
  http_results+=("$probe_output")
  case "$probe_output" in OK*) ;; *) failures=$((failures + 1)) ;; esac
else
  if [ "$configured" -eq 1 ]; then
    probe_output="$(http_probe "$frontend_url" "frontend" "GET" || true)"
    http_results+=("$probe_output")
    case "$probe_output" in OK*) ;; *) failures=$((failures + 1)) ;; esac

    probe_output="$(http_probe "$health_url" "backend-health" "GET" || true)"
    http_results+=("$probe_output")
    case "$probe_output" in OK*) ;; *) failures=$((failures + 1)) ;; esac
  fi
fi

overall="OK"
if [ "$configured" -eq 0 ]; then
  overall="NOT_CONFIGURED"
elif [ "$failures" -gt 0 ]; then
  overall="DEGRADED"
fi

if [ "$one_line" -eq 1 ]; then
  if [ "$environment" = "dev" ]; then
    printf 'env=%s overall=%s backend_port=%s frontend_port=%s frontend_url=%s health_url=%s\n' \
      "$environment" "$overall" "$port_backend" "$port_frontend" "$frontend_url" "$health_url"
  else
    printf 'env=%s overall=%s frontend_url=%s health_url=%s\n' \
      "$environment" "$overall" "${frontend_url:-unset}" "${health_url:-unset}"
  fi
  if [ "$overall" = "OK" ]; then
    exit 0
  fi
  exit 1
fi

printf 'OWFINANCE ops status (%s)\n' "$environment"
printf '========================================\n'

if [ "$environment" = "dev" ]; then
  printf 'Base workspace status\n'
  printf '%s\n' '----------------------------------------'
  "$ROOT_DIR/status.sh" || true
  printf '\n'
  printf 'Local runtime summary\n'
  printf '%s\n' '----------------------------------------'
  printf '  - backend port 8000: %s\n' "$port_backend"
  printf '  - frontend port 3000: %s\n' "$port_frontend"
  printf '  - api base: %s\n' "$api_base_url"
else
  printf 'Resolved targets\n'
  printf '%s\n' '----------------------------------------'
  printf '  - frontend: %s\n' "${frontend_url:-unset}"
  printf '  - api base: %s\n' "${api_base_url:-unset}"
  printf '  - health: %s\n' "${health_url:-unset}"
fi

printf 'HTTP probes\n'
printf '%s\n' '----------------------------------------'

if [ "$configured" -eq 0 ]; then
  printf '  - %s\n' 'Environment is not configured with real URLs. Set OWF_STAGE_FRONTEND_URL and OWF_STAGE_HEALTH_URL, or update local .env.staging values.'
else
  for result in "${http_results[@]}"; do
    render_probe_block "$result"
  done
fi

printf '\nOverall: %s\n' "$overall"

if [ "$overall" = "OK" ]; then
  exit 0
fi

exit 1
