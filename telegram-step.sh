#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./telegram-step.sh [options] MESSAGE...

Options:
  --title TITLE        Short event title
  --type TYPE          progress|info|success|error (default: progress)
  --source SOURCE      Transcript source label (default: local-step)
  --event-type LABEL   Transcript event type (default: step)
  --tag TAG            Optional transcript tag
  --log-only           Log locally without sending to Telegram
  --chat-id ID         Override TELEGRAM_CHAT_ID for this run
  -h, --help           Show help

Examples:
  ./telegram-step.sh --title Backend "Migration step started"
  ./telegram-step.sh --title Deploy --type success "Frontend deploy finished"
  printf 'Need review on stage' | ./telegram-step.sh --title Stage --type info
EOF
}

fail() {
  printf '%s\n' "$*" >&2
  exit 1
}

title=""
message_type="progress"
source_label="local-step"
event_type="step"
tag=""
chat_id=""
send_event=1

while [ "$#" -gt 0 ]; do
  case "$1" in
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
    --source)
      [ "$#" -ge 2 ] || fail "Missing value for --source"
      source_label="$2"
      shift 2
      ;;
    --event-type)
      [ "$#" -ge 2 ] || fail "Missing value for --event-type"
      event_type="$2"
      shift 2
      ;;
    --tag)
      [ "$#" -ge 2 ] || fail "Missing value for --tag"
      tag="$2"
      shift 2
      ;;
    --log-only)
      send_event=0
      shift
      ;;
    --chat-id)
      [ "$#" -ge 2 ] || fail "Missing value for --chat-id"
      chat_id="$2"
      shift 2
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

if [ "$#" -gt 0 ]; then
  message="$*"
elif [ ! -t 0 ]; then
  message="$(cat)"
else
  fail "Missing message text. Pass it as arguments or pipe it on stdin."
fi

cmd=("$ROOT_DIR/telegram-context-bridge.py" event --type "$message_type" --source "$source_label" --event-type "$event_type")
if [ -n "$title" ]; then
  cmd+=(--title "$title")
fi
if [ -n "$tag" ]; then
  cmd+=(--tag "$tag")
fi
if [ -n "$chat_id" ]; then
  cmd+=(--chat-id "$chat_id")
fi
if [ "$send_event" -eq 1 ]; then
  cmd+=(--send)
fi
cmd+=("$message")

exec "${cmd[@]}"
