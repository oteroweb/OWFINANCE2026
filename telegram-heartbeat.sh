#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./telegram-heartbeat.sh [options] MESSAGE...
  ./telegram-heartbeat.sh --help

Options:
  --interval SECONDS   Seconds between heartbeats (default: 300)
  --count N            Number of heartbeats to send (default: unlimited)
  --title TITLE        Title passed to telegram-notify.sh
  --type TYPE          Message type (default: heartbeat)
  --status ENV         Append ops status summary for dev|stage|prod
  --chat-id ID         Override TELEGRAM_CHAT_ID for this run
  --dry-run            Print messages without calling Telegram
  -h, --help           Show help

Examples:
  ./telegram-heartbeat.sh --title Import --interval 120 "Import still running"
  ./telegram-heartbeat.sh --title Stage --status stage --interval 300 "Stage smoke check still running"
EOF
}

fail() {
  printf '%s\n' "$*" >&2
  exit 1
}

resolve_message_body() {
  if [ "$#" -gt 0 ]; then
    printf '%s' "$*"
    return
  fi

  if [ ! -t 0 ]; then
    cat
    return
  fi

  fail "Missing message text. Pass it as arguments or pipe it on stdin."
}

interval="300"
count="0"
title=""
message_type="heartbeat"
status_env=""
chat_id_override=""
dry_run=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --interval)
      [ "$#" -ge 2 ] || fail "Missing value for --interval"
      interval="$2"
      shift 2
      ;;
    --count)
      [ "$#" -ge 2 ] || fail "Missing value for --count"
      count="$2"
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
      chat_id_override="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

case "$interval" in
  ''|*[!0-9]*) fail "--interval must be a positive integer in seconds" ;;
esac
case "$count" in
  ''|*[!0-9]*) fail "--count must be 0 or a positive integer" ;;
esac
[ "$interval" -gt 0 ] || fail "--interval must be greater than zero"

if [ -n "$status_env" ]; then
  case "$status_env" in
    dev|stage|prod) ;;
    *) fail "--status must be one of: dev, stage, prod" ;;
  esac
fi

body="$(resolve_message_body "$@")"
iteration=1

while :; do
  if [ "$count" -gt 0 ] && [ "$iteration" -gt "$count" ]; then
    break
  fi

  composed_body="$body"
  if [ "$count" -gt 0 ]; then
    composed_body="$composed_body [beat ${iteration}/${count}]"
  else
    composed_body="$composed_body [beat ${iteration}]"
  fi

  if [ -n "$status_env" ]; then
    status_summary="$("$ROOT_DIR/ops-status.sh" --one-line "$status_env" 2>&1 || true)"
    composed_body="$composed_body | $status_summary"
  fi

  command_args=(send --type "$message_type")
  if [ -n "$title" ]; then
    command_args+=(--title "$title")
  fi
  if [ -n "$chat_id_override" ]; then
    command_args+=(--chat-id "$chat_id_override")
  fi
  if [ "$dry_run" -eq 1 ]; then
    command_args+=(--dry-run)
  fi

  "$ROOT_DIR/telegram-notify.sh" "${command_args[@]}" "$composed_body"

  iteration=$((iteration + 1))
  if [ "$count" -gt 0 ] && [ "$iteration" -gt "$count" ]; then
    break
  fi
  sleep "$interval"
done
