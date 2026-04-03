#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./telegram-notify.sh send [options] MESSAGE...
  ./telegram-notify.sh test [options]
  ./telegram-notify.sh chat-id
  ./telegram-notify.sh --help

Environment:
  TELEGRAM_BOT_TOKEN   Bot token from BotFather
  TELEGRAM_CHAT_ID     Target chat id for send/test

Optional local config:
  ~/.config/owfinance-ops/telegram.json with:
    {"telegram_bot_token":"...","telegram_chat_id":"..."}

Options:
  --type TYPE          info|progress|heartbeat|success|error (default: info)
  --title TITLE        Short label added before the message body
  --chat-id ID         Override TELEGRAM_CHAT_ID for this run
  --sound              Play a local notification sound if successful
  --dry-run            Print the final payload without calling Telegram
  -h, --help           Show this help

Examples:
  ./telegram-notify.sh test --title OWFINANCE
  ./telegram-notify.sh send --type heartbeat --title Backend "Deploy still running"
  printf 'Build finished' | ./telegram-notify.sh send --type success --title Mobile
  ./telegram-notify.sh chat-id
EOF
}

fail() {
  printf '%s\n' "$*" >&2
  exit 1
}

CONFIG_TELEGRAM_JSON="${HOME}/.config/owfinance-ops/telegram.json"
BRIDGE_LOOP_LOCK_DIR="${HOME}/.config/owfinance-ops/automation/run/telegram-bridge-loop.lock"

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

load_local_config_value() {
  local key="$1"

  [ -f "$CONFIG_TELEGRAM_JSON" ] || return 0

  require_command python3

  python3 - "$CONFIG_TELEGRAM_JSON" "$key" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
key = sys.argv[2]

try:
    payload = json.loads(path.read_text(encoding="utf-8"))
except Exception:
    sys.exit(0)

value = payload.get(key, "")
if value is None:
    value = ""
print(str(value), end="")
PY
}

read_bridge_loop_pid() {
  [ -f "$BRIDGE_LOOP_LOCK_DIR/pid" ] || return 1
  tr -d '[:space:]' <"$BRIDGE_LOOP_LOCK_DIR/pid"
}

bridge_loop_running() {
  local pid
  pid="$(read_bridge_loop_pid 2>/dev/null || true)"
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

ensure_no_active_bridge_loop_for_updates() {
  if bridge_loop_running; then
    fail "Telegram bridge loop already running (pid=$(read_bridge_loop_pid)). Stop it before using chat-id/getUpdates directly."
  fi
}

ensure_telegram_config() {
  if [ -z "${TELEGRAM_BOT_TOKEN:-}" ]; then
    TELEGRAM_BOT_TOKEN="$(load_local_config_value "telegram_bot_token")"
    export TELEGRAM_BOT_TOKEN
  fi

  if [ -z "${TELEGRAM_CHAT_ID:-}" ]; then
    TELEGRAM_CHAT_ID="$(load_local_config_value "telegram_chat_id")"
    export TELEGRAM_CHAT_ID
  fi
}

uppercase() {
  printf '%s' "$1" | tr '[:lower:]' '[:upper:]'
}

format_message() {
  local type_label
  type_label="$(uppercase "$1")"

  if [ -n "$2" ]; then
    printf '[%s] %s: %s' "$type_label" "$2" "$3"
  else
    printf '[%s] %s' "$type_label" "$3"
  fi
}

telegram_api_post() {
  local method="$1"
  shift

  require_command curl

  curl --silent --show-error --request POST \
    --url "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/${method}" \
    "$@"
}

print_chat_ids() {
  local response="$1"

  require_command python3

  python3 - "$response" <<'PY'
import json
import sys

data = json.loads(sys.argv[1])
if not data.get("ok"):
    print(data.get("description", "Telegram API error"), file=sys.stderr)
    sys.exit(1)

seen = {}
for item in data.get("result", []):
    message = (
        item.get("message")
        or item.get("edited_message")
        or item.get("channel_post")
        or item.get("edited_channel_post")
    )
    if not message:
        continue

    chat = message.get("chat") or {}
    chat_id = chat.get("id")
    if chat_id is None:
        continue

    label = chat.get("title") or chat.get("username")
    if not label:
        first_name = chat.get("first_name") or ""
        last_name = chat.get("last_name") or ""
        label = (first_name + " " + last_name).strip()
    if not label:
        label = "unknown"

    seen[str(chat_id)] = f"{chat.get('type', 'unknown')} | {label}"

if not seen:
    print(
        "No chat ids found yet. Open Telegram, send /start to the bot "
        "(or add the bot to a group and send a message), then run this command again.",
        file=sys.stderr,
    )
    sys.exit(2)

for chat_id in sorted(seen):
    print(f"{chat_id}\t{seen[chat_id]}")
PY
}

confirm_send() {
  local response="$1"

  require_command python3

  python3 - "$response" <<'PY'
import json
import sys

data = json.loads(sys.argv[1])
if not data.get("ok"):
    print(data.get("description", "Telegram API error"), file=sys.stderr)
    sys.exit(1)

result = data.get("result") or {}
message_id = result.get("message_id", "unknown")
chat = result.get("chat") or {}
chat_id = chat.get("id", "unknown")
print(f"Telegram notification sent (chat_id={chat_id}, message_id={message_id}).")
PY
  local status=$?
  if [ "$status" -eq 0 ] && [ "${play_sound:-0}" -eq 1 ]; then
    if [[ "${OSTYPE:-}" == darwin* ]] && command -v afplay >/dev/null 2>&1; then
      afplay /System/Library/Sounds/Glass.aiff >/dev/null 2>&1 &
    fi
  fi
  return "$status"
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

command_name="send"
ensure_telegram_config
if [ "$#" -gt 0 ]; then
  case "$1" in
    send|test|chat-id)
      command_name="$1"
      shift
      ;;
    -h|--help|help)
      usage
      exit 0
      ;;
  esac
fi

message_type="info"
title=""
chat_id_override=""
dry_run=0
play_sound=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --type)
      [ "$#" -ge 2 ] || fail "Missing value for --type"
      message_type="$2"
      shift 2
      ;;
    --title)
      [ "$#" -ge 2 ] || fail "Missing value for --title"
      title="$2"
      shift 2
      ;;
    --chat-id)
      [ "$#" -ge 2 ] || fail "Missing value for --chat-id"
      chat_id_override="$2"
      shift 2
      ;;
    --sound)
      play_sound=1
      shift
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

case "$command_name" in
  chat-id)
    [ "$dry_run" -eq 0 ] || fail "--dry-run is not supported with chat-id"
    [ -n "${TELEGRAM_BOT_TOKEN:-}" ] || fail "TELEGRAM_BOT_TOKEN is required for chat-id"
    ensure_no_active_bridge_loop_for_updates
    response="$(telegram_api_post "getUpdates")"
    print_chat_ids "$response"
    ;;
  test)
    timestamp="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
    body="Telegram test from OWFINANCE2026 at ${timestamp}"
    rendered_message="$(format_message "${message_type}" "${title}" "${body}")"

    if [ "$dry_run" -eq 1 ]; then
      printf 'DRY RUN\nchat_id=%s\nmessage=%s\n' "${chat_id_override:-${TELEGRAM_CHAT_ID:-<unset>}}" "$rendered_message"
      exit 0
    fi

    [ -n "${TELEGRAM_BOT_TOKEN:-}" ] || fail "TELEGRAM_BOT_TOKEN is required for test"
    target_chat_id="${chat_id_override:-${TELEGRAM_CHAT_ID:-}}"
    [ -n "$target_chat_id" ] || fail "TELEGRAM_CHAT_ID is required for test"

    response="$(telegram_api_post "sendMessage" --data-urlencode "chat_id=${target_chat_id}" --data-urlencode "text=${rendered_message}")"
    confirm_send "$response"
    ;;
  send)
    body="$(resolve_message_body "$@")"
    rendered_message="$(format_message "${message_type}" "${title}" "${body}")"

    if [ "$dry_run" -eq 1 ]; then
      printf 'DRY RUN\nchat_id=%s\nmessage=%s\n' "${chat_id_override:-${TELEGRAM_CHAT_ID:-<unset>}}" "$rendered_message"
      exit 0
    fi

    [ -n "${TELEGRAM_BOT_TOKEN:-}" ] || fail "TELEGRAM_BOT_TOKEN is required for send"
    target_chat_id="${chat_id_override:-${TELEGRAM_CHAT_ID:-}}"
    [ -n "$target_chat_id" ] || fail "TELEGRAM_CHAT_ID is required for send"

    response="$(telegram_api_post "sendMessage" --data-urlencode "chat_id=${target_chat_id}" --data-urlencode "text=${rendered_message}")"
    confirm_send "$response"
    ;;
  *)
    fail "Unknown command: ${command_name}"
    ;;
esac
