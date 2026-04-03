#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${OWF_OPS_CONFIG_DIR:-${HOME}/.config/owfinance-ops}"
AUTOMATION_DIR="${CONFIG_DIR}/automation"
RUN_DIR="${AUTOMATION_DIR}/run"
LOG_DIR="${AUTOMATION_DIR}/logs"
PID_FILE="${RUN_DIR}/telegram-bridge-loop.pid"
LOCK_DIR="${RUN_DIR}/telegram-bridge-loop.lock"
LOG_FILE="${LOG_DIR}/telegram-bridge-loop.log"

usage() {
  cat <<'EOF'
Usage:
  ./telegram-bridge-loop.sh start [--interval SECONDS] [--limit N] [--mode MODE]
  ./telegram-bridge-loop.sh stop
  ./telegram-bridge-loop.sh status
  ./telegram-bridge-loop.sh once [--limit N] [--mode MODE]
  ./telegram-bridge-loop.sh run [--interval SECONDS] [--limit N] [--mode MODE]

Options:
  --interval SECONDS   Seconds between event polls (default: 30)
  --limit N            Max Telegram updates per pull (default: 25)
  --mode MODE          auto|gemini-cli|local-context (default: auto)
  -h, --help           Show help

Runtime files:
  ~/.config/owfinance-ops/automation/run/telegram-bridge-loop.pid
  ~/.config/owfinance-ops/automation/run/telegram-bridge-loop.lock/
  ~/.config/owfinance-ops/automation/logs/telegram-bridge-loop.log
EOF
}

fail() {
  printf '%s\n' "$*" >&2
  exit 1
}

ensure_dirs() {
  mkdir -p "$RUN_DIR" "$LOG_DIR"
}

read_pid() {
  [ -f "$PID_FILE" ] || return 1
  tr -d '[:space:]' <"$PID_FILE"
}

read_lock_pid() {
  [ -f "$LOCK_DIR/pid" ] || return 1
  tr -d '[:space:]' <"$LOCK_DIR/pid"
}

is_running() {
  local pid
  pid="$(read_pid 2>/dev/null || true)"
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

lock_is_running() {
  local pid
  pid="$(read_lock_pid 2>/dev/null || true)"
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

clear_stale_pid() {
  if [ -f "$PID_FILE" ] && ! is_running && ! lock_is_running; then
    rm -f "$PID_FILE"
  fi
}

clear_stale_lock() {
  if [ -d "$LOCK_DIR" ] && ! lock_is_running; then
    rm -rf "$LOCK_DIR"
  fi
}

bridge_command() {
  printf '%s\n' "${OWF_TELEGRAM_BRIDGE_COMMAND:-$ROOT_DIR/telegram-context-bridge.py}"
}

acquire_lock() {
  ensure_dirs
  clear_stale_lock
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    printf '%s\n' "$$" >"$LOCK_DIR/pid"
    return 0
  fi

  local pid
  pid="$(read_lock_pid 2>/dev/null || true)"
  fail "Bridge loop already running (pid=${pid:-unknown})"
}

release_lock() {
  rm -rf "$LOCK_DIR"
}

log_line() {
  ensure_dirs
  printf '%s %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$*" >>"$LOG_FILE"
}

run_once() {
  local limit="$1"
  local mode="$2"
  local cmd
  cmd="$(bridge_command)"
  OWF_TELEGRAM_FREEFORM_MODE="$mode" OWF_TELEGRAM_LOOP_OWNER_PID="$$" "$cmd" pull --respond --limit "$limit"
}

run_loop() {
  local interval="$1"
  local limit="$2"
  local mode="$3"

  acquire_lock
  printf '%s\n' "$$" >"$PID_FILE"
  trap 'rm -f "$PID_FILE"; release_lock' EXIT INT TERM

  log_line "bridge-loop started interval=${interval}s limit=${limit} mode=${mode}"
  while :; do
    if run_once "$limit" "$mode" >>"$LOG_FILE" 2>&1; then
      log_line "bridge-loop poll ok"
    else
      log_line "bridge-loop poll failed exit=$?"
    fi
    sleep "$interval"
  done
}

start_loop() {
  local interval="$1"
  local limit="$2"
  local mode="$3"

  clear_stale_pid
  clear_stale_lock
  if is_running || lock_is_running; then
    printf 'Bridge loop already running (pid=%s)\n' "$(read_lock_pid 2>/dev/null || read_pid)"
    return 0
  fi

  ensure_dirs
  nohup "$0" run --interval "$interval" --limit "$limit" --mode "$mode" >>"$LOG_FILE" 2>&1 &
  sleep 1

  if is_running; then
    printf 'Bridge loop started (pid=%s)\n' "$(read_pid)"
    printf 'Log: %s\n' "$LOG_FILE"
    return 0
  fi

  fail "Bridge loop failed to start. Check ${LOG_FILE}"
}

stop_loop() {
  clear_stale_pid
  clear_stale_lock
  if ! is_running && ! lock_is_running; then
    printf 'Bridge loop is not running\n'
    return 0
  fi

  local pid
  pid="$(read_pid 2>/dev/null || read_lock_pid)"
  kill "$pid"
  rm -f "$PID_FILE"
  release_lock
  printf 'Bridge loop stopped (pid=%s)\n' "$pid"
}

status_loop() {
  clear_stale_pid
  clear_stale_lock
  if is_running || lock_is_running; then
    printf 'Bridge loop: running (pid=%s)\n' "$(read_pid 2>/dev/null || read_lock_pid)"
  else
    printf 'Bridge loop: stopped\n'
  fi
  printf 'PID file: %s\n' "$PID_FILE"
  printf 'Lock dir: %s\n' "$LOCK_DIR"
  printf 'Log file: %s\n' "$LOG_FILE"
}

subcommand="${1:-status}"
if [ "$#" -gt 0 ]; then
  shift
fi

interval="30"
limit="25"
mode="${OWF_TELEGRAM_FREEFORM_MODE:-auto}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --interval)
      [ "$#" -ge 2 ] || fail "Missing value for --interval"
      interval="$2"
      shift 2
      ;;
    --limit)
      [ "$#" -ge 2 ] || fail "Missing value for --limit"
      limit="$2"
      shift 2
      ;;
    --mode)
      [ "$#" -ge 2 ] || fail "Missing value for --mode"
      mode="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

case "$interval" in
  ''|*[!0-9]*) fail "--interval must be a positive integer" ;;
esac
case "$limit" in
  ''|*[!0-9]*) fail "--limit must be a positive integer" ;;
esac
[ "$interval" -gt 0 ] || fail "--interval must be greater than zero"
[ "$limit" -gt 0 ] || fail "--limit must be greater than zero"
case "$mode" in
  auto|gemini-cli|local-context) ;;
  *) fail "--mode must be auto, gemini-cli, or local-context" ;;
esac

case "$subcommand" in
  start)
    start_loop "$interval" "$limit" "$mode"
    ;;
  stop)
    stop_loop
    ;;
  status)
    status_loop
    ;;
  once)
    run_once "$limit" "$mode"
    ;;
  run)
    run_loop "$interval" "$limit" "$mode"
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    fail "Unknown subcommand: ${subcommand}"
    ;;
esac
