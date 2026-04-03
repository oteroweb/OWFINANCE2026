#!/usr/bin/env bash

owf_trim_line() {
  local value="$1"
  value="${value//$'\r'/}"
  value="${value//$'\n'/ }"
  value="${value#${value%%[![:space:]]*}}"
  value="${value%${value##*[![:space:]]}}"
  printf '%s' "$value"
}

owf_capture_ops_status() {
  local root_dir="$1"
  local status_env="$2"
  local status_output=""

  [ -n "$status_env" ] || return 0
  [ -x "$root_dir/ops-status.sh" ] || return 0

  status_output="$("$root_dir/ops-status.sh" --one-line "$status_env" 2>&1 || true)"
  owf_trim_line "$status_output"
}

owf_compose_deploy_message() {
  local phase="$1"
  local component="$2"
  local deploy_env="$3"
  local branch="$4"
  local target_url="$5"
  local elapsed_seconds="$6"
  local exit_code="$7"
  local ops_summary="${8:-}"
  local message=""

  if [ "$phase" = "start" ]; then
    message="Deploy ${component} (${deploy_env}) started | branch=${branch} | target=${target_url}"
  else
    if [ "$exit_code" -eq 0 ]; then
      message="Deploy ${component} (${deploy_env}) completed | branch=${branch} | target=${target_url} | elapsed=${elapsed_seconds}s"
    else
      message="Deploy ${component} (${deploy_env}) failed | branch=${branch} | target=${target_url} | exit=${exit_code} | elapsed=${elapsed_seconds}s"
    fi
  fi

  if [ -n "$ops_summary" ]; then
    message="${message} | ops=${ops_summary}"
  fi

  printf '%s' "$message"
}

owf_capture_http_probe() {
  local target_url="$1"
  local label="$2"
  local code=""

  [ -n "$target_url" ] || return 0
  command -v curl >/dev/null 2>&1 || return 0

  code="$(curl --silent --output /dev/null --write-out '%{http_code}' --location --max-time 15 "$target_url" || true)"

  if [ -n "$code" ] && [ "$code" -ge 200 ] && [ "$code" -lt 400 ]; then
    printf '%s=OK:%s' "$label" "$code"
    return 0
  fi

  if [ -z "$code" ] || [ "$code" = "000" ]; then
    printf '%s=FAIL:no-response' "$label"
    return 1
  fi

  printf '%s=FAIL:%s' "$label" "$code"
  return 1
}

owf_compose_status_context() {
  local before_summary="${1:-}"
  local after_summary="${2:-}"
  local verify_summary="${3:-}"
  local context=""

  if [ -n "$before_summary" ]; then
    context="ops-before=${before_summary}"
  fi

  if [ -n "$after_summary" ]; then
    if [ -n "$context" ]; then
      context="${context} | "
    fi
    context="${context}ops-after=${after_summary}"
  fi

  if [ -n "$verify_summary" ]; then
    if [ -n "$context" ]; then
      context="${context} | "
    fi
    context="${context}verify=${verify_summary}"
  fi

  printf '%s' "$context"
}

owf_send_telegram_notification() {
  local root_dir="$1"
  local message_type="$2"
  local title="$3"
  local body="$4"
  local notifier="$root_dir/telegram-notify.sh"
  local notifier_status=0

  [ -x "$notifier" ] || return 0

  if [ -z "${TELEGRAM_BOT_TOKEN:-}" ] || [ -z "${TELEGRAM_CHAT_ID:-}" ]; then
    if [ ! -f "${HOME}/.config/owfinance-ops/telegram.json" ]; then
      return 0
    fi
  fi

  "$notifier" send --type "$message_type" --title "$title" "$body" >/dev/null 2>&1 || notifier_status=$?
  if [ "$notifier_status" -ne 0 ]; then
    printf 'Warning: Telegram notification failed for %s\n' "$title" >&2
  fi
}

owf_run_ops_status_report() {
  local root_dir="$1"
  local status_env="$2"

  [ -n "$status_env" ] || return 0
  [ -x "$root_dir/ops-status.sh" ] || return 0

  "$root_dir/ops-status.sh" "$status_env" || true
}

owf_escape_applescript() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '%s' "$value"
}

owf_send_desktop_notification() {
  local title="$1"
  local message="$2"
  local escaped_title
  local escaped_message

  if [ "${OWF_ENABLE_DESKTOP_NOTIFICATIONS:-1}" = "0" ]; then
    return 0
  fi

  if [[ "${OSTYPE:-}" == darwin* ]] && command -v osascript >/dev/null 2>&1; then
    escaped_title="$(owf_escape_applescript "$title")"
    escaped_message="$(owf_escape_applescript "$message")"
    osascript -e "display notification \"${escaped_message}\" with title \"${escaped_title}\"" >/dev/null 2>&1 || true
  fi
}
