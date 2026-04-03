#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${OWF_OPS_CONFIG_DIR:-${HOME}/.config/owfinance-ops}"
AUTOMATION_DIR="${CONFIG_DIR}/automation"
RUN_DIR="${AUTOMATION_DIR}/run"
LOG_DIR="${AUTOMATION_DIR}/logs"
PID_FILE="${RUN_DIR}/telegram-heartbeat-loop.pid"
LOG_FILE="${LOG_DIR}/telegram-heartbeat-loop.log"

usage() {
  cat <<'EOF'
Usage:
  ./telegram-heartbeat-loop.sh start [options] MESSAGE...
  ./telegram-heartbeat-loop.sh stop
  ./telegram-heartbeat-loop.sh status
  ./telegram-heartbeat-loop.sh run [options] MESSAGE...

Options:
  --interval SECONDS   Seconds between heartbeats (default: 60)
  --title TITLE        Title passed to telegram-heartbeat.sh
  --type TYPE          Message type (default: heartbeat)
  --status ENV         Append ops status for dev|stage|prod
  --chat-id ID         Override TELEGRAM_CHAT_ID for this run
  --dry-run            Print heartbeat payloads without calling Telegram
  -h, --help           Show help

Runtime files:
  ~/.config/owfinance-ops/automation/run/telegram-heartbeat-loop.pid
  ~/.config/owfinance-ops/automation/logs/telegram-heartbeat-loop.log
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

is_running() {
  local pid
  pid="$(read_pid 2>/dev/null || true)"
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

clear_stale_pid() {
  if [ -f "$PID_FILE" ] && ! is_running; then
    rm -f "$PID_FILE"
  fi
}

run_loop() {
  local interval="$1"
  local title="$2"
  local message_type="$3"
  local status_env="$4"
  local chat_id="$5"
  local dry_run="$6"
  shift 6

  ensure_dirs
  printf '%s\n' "$$" >"$PID_FILE"
  trap 'rm -f "$PID_FILE"' EXIT INT TERM

  local -a cmd
  cmd=("$ROOT_DIR/telegram-heartbeat.sh" --interval "$interval" --type "$message_type")
  if [ -n "$title" ]; then
    cmd+=(--title "$title")
  fi
  if [ -n "$status_env" ]; then
    cmd+=(--status "$status_env")
  fi
  if [ -n "$chat_id" ]; then
    cmd+=(--chat-id "$chat_id")
  fi
  if [ "$dry_run" -eq 1 ]; then
    cmd+=(--dry-run)
  fi
  if [ "$#" -gt 0 ]; then
    cmd+=("$@")
  else
    cmd+=("OWFINANCE automation heartbeat")
  fi

  exec "${cmd[@]}"
}

start_loop() {
  local interval="$1"
  local title="$2"
  local message_type="$3"
  local status_env="$4"
  local chat_id="$5"
  local dry_run="$6"
  shift 6

  clear_stale_pid
  if is_running; then
    printf 'Heartbeat loop already running (pid=%s)\n' "$(read_pid)"
    return 0
  fi

  ensure_dirs
  local -a cmd
  cmd=("$0" run --interval "$interval" --type "$message_type")
  if [ -n "$title" ]; then
    cmd+=(--title "$title")
  fi
  if [ -n "$status_env" ]; then
    cmd+=(--status "$status_env")
  fi
  if [ -n "$chat_id" ]; then
    cmd+=(--chat-id "$chat_id")
  fi
  if [ "$dry_run" -eq 1 ]; then
    cmd+=(--dry-run)
  fi
  cmd+=(--)
  if [ "$#" -gt 0 ]; then
    cmd+=("$@")
  fi

  nohup "${cmd[@]}" >>"$LOG_FILE" 2>&1 &
  sleep 1

  if is_running; then
    printf 'Heartbeat loop started (pid=%s)\n' "$(read_pid)"
    printf 'Log: %s\n' "$LOG_FILE"
    return 0
  fi

  fail "Heartbeat loop failed to start. Check ${LOG_FILE}"
}

stop_loop() {
  clear_stale_pid
  if ! is_running; then
    printf 'Heartbeat loop is not running\n'
    return 0
  fi

  local pid
  pid="$(read_pid)"
  kill "$pid"
  rm -f "$PID_FILE"
  printf 'Heartbeat loop stopped (pid=%s)\n' "$pid"
}

status_loop() {
  clear_stale_pid
  if is_running; then
    printf 'Heartbeat loop: running (pid=%s)\n' "$(read_pid)"
  else
    printf 'Heartbeat loop: stopped\n'
  fi
  printf 'PID file: %s\n' "$PID_FILE"
  printf 'Log file: %s\n' "$LOG_FILE"
}

subcommand="${1:-status}"
if [ "$#" -gt 0 ]; then
  shift
fi

interval="60"
title=""
message_type="heartbeat"
status_env=""
chat_id=""
dry_run=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --interval)
      [ "$#" -ge 2 ] || fail "Missing value for --interval"
      interval="$2"
      shift 2
      ;;
    --title)
      [ "$#" -ge 2 ] || fail "Missing value for --title"
      title="$2"
      shift 2
      ;;
    --type)
      [ "$#" -ge 2 ] || fail "Missing value for --type"
      message_type="$2"
      shift 2
      ;;
    --status)
      [ "$#" -ge 2 ] || fail "Missing value for --status"
      status_env="$2"
      shift 2
      ;;
    --chat-id)
      [ "$#" -ge 2 ] || fail "Missing value for --chat-id"
      chat_id="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --)
      shift
      break
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

case "$interval" in
  ''|*[!0-9]*) fail "--interval must be a positive integer" ;;
esac
[ "$interval" -gt 0 ] || fail "--interval must be greater than zero"

if [ -n "$status_env" ]; then
  case "$status_env" in
    dev|stage|prod) ;;
    *) fail "--status must be one of: dev, stage, prod" ;;
  esac
fi

case "$subcommand" in
  start)
    start_loop "$interval" "$title" "$message_type" "$status_env" "$chat_id" "$dry_run" "$@"
    ;;
  stop)
    stop_loop
    ;;
  status)
    status_loop
    ;;
  run)
    run_loop "$interval" "$title" "$message_type" "$status_env" "$chat_id" "$dry_run" "$@"
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    fail "Unknown subcommand: ${subcommand}"
    ;;
esac
