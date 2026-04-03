#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./telegram-notify-wrap.sh [options] -- COMMAND [ARG...]

Options:
  --title TITLE        Notification title (default: wrapped command basename)
  --chat-id ID         Override TELEGRAM_CHAT_ID for this run
  --notify-start       Send a progress notification before the command starts
  --dry-run            Print notification payloads without calling Telegram
  -h, --help           Show help

Examples:
  ./telegram-notify-wrap.sh --title Backend -- ./ops-status.sh dev
  ./telegram-notify-wrap.sh --title Deploy --notify-start -- ./deploy-frontend.sh "UI polish"
EOF
}

fail() {
  printf '%s\n' "$*" >&2
  exit 1
}

send_notification() {
  local message_type="$1"
  local title="$2"
  local body="$3"
  shift 3

  local -a cmd
  cmd=("$ROOT_DIR/telegram-notify.sh" send --type "$message_type")
  if [ -n "$title" ]; then
    cmd+=(--title "$title")
  fi
  if [ -n "$chat_id" ]; then
    cmd+=(--chat-id "$chat_id")
  fi
  if [ "$dry_run" -eq 1 ]; then
    cmd+=(--dry-run)
  fi
  cmd+=("$body")

  if ! "${cmd[@]}"; then
    printf 'Warning: Telegram notification failed for %s\n' "$title" >&2
  fi

  local -a event_cmd
  event_cmd=("$ROOT_DIR/telegram-context-bridge.py" event --type "$message_type" --source "notify-wrap" --event-type "wrapped-command")
  if [ -n "$title" ]; then
    event_cmd+=(--title "$title")
  fi
  if [ -n "$chat_id" ]; then
    event_cmd+=(--chat-id "$chat_id")
  fi
  event_cmd+=("$body")

  if ! "${event_cmd[@]}" >/dev/null 2>&1; then
    printf 'Warning: local event log failed for %s\n' "$title" >&2
  fi
}

title=""
chat_id=""
notify_start=0
dry_run=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --title)
      [ "$#" -ge 2 ] || fail "Missing value for --title"
      title="$2"
      shift 2
      ;;
    --chat-id)
      [ "$#" -ge 2 ] || fail "Missing value for --chat-id"
      chat_id="$2"
      shift 2
      ;;
    --notify-start)
      notify_start=1
      shift
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
      fail "Unknown argument: $1"
      ;;
  esac
done

[ "$#" -gt 0 ] || fail "Missing wrapped command. Pass it after --"

command_label="$title"
if [ -z "$command_label" ]; then
  command_label="$(basename "$1")"
fi

started_at_epoch="$(date +%s)"
started_at_text="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

if [ "$notify_start" -eq 1 ]; then
  send_notification "progress" "$command_label" "Started at ${started_at_text}: $*"
fi

set +e
"$@"
command_status=$?
set -e

finished_at_epoch="$(date +%s)"
duration_seconds="$((finished_at_epoch - started_at_epoch))"

if [ "$command_status" -eq 0 ]; then
  send_notification "success" "$command_label" "Completed successfully in ${duration_seconds}s: $*"
else
  send_notification "error" "$command_label" "Failed with exit ${command_status} after ${duration_seconds}s: $*"
fi

exit "$command_status"
