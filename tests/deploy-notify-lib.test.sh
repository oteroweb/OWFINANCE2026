#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_PATH="$ROOT_DIR/deploy-notify-lib.sh"

if [ ! -f "$LIB_PATH" ]; then
  printf 'Missing library under test: %s\n' "$LIB_PATH" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$LIB_PATH"

assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    printf 'Expected to find %q in:\n%s\n' "$needle" "$haystack" >&2
    exit 1
  fi
}

assert_equals() {
  local actual="$1"
  local expected="$2"
  if [ "$actual" != "$expected" ]; then
    printf 'Expected %q, got %q\n' "$expected" "$actual" >&2
    exit 1
  fi
}

test_capture_ops_status_success() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  cat > "$tmp_dir/ops-status.sh" <<'EOF'
#!/usr/bin/env bash
printf 'env=%s overall=OK\n' "$2"
EOF
  chmod +x "$tmp_dir/ops-status.sh"

  local output
  output="$(owf_capture_ops_status "$tmp_dir" dev)"
  assert_equals "$output" 'env=dev overall=OK'

  rm -rf "$tmp_dir"
}

test_capture_ops_status_failure_is_nonfatal() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  cat > "$tmp_dir/ops-status.sh" <<'EOF'
#!/usr/bin/env bash
printf 'probe failed\n' >&2
exit 1
EOF
  chmod +x "$tmp_dir/ops-status.sh"

  local output
  output="$(owf_capture_ops_status "$tmp_dir" dev)"
  assert_equals "$output" 'probe failed'

  rm -rf "$tmp_dir"
}

test_compose_start_message_includes_context_and_status() {
  local message
  message="$(owf_compose_deploy_message start frontend dev dev https://example.com/app/ 0 0 'env=dev overall=OK')"
  assert_contains "$message" 'Deploy frontend (dev) started'
  assert_contains "$message" 'branch=dev'
  assert_contains "$message" 'target=https://example.com/app/'
  assert_contains "$message" 'ops=env=dev overall=OK'
}

test_compose_failure_message_includes_exit_code_and_elapsed() {
  local message
  message="$(owf_compose_deploy_message finish backend stage stage https://example.com/api 19 7 'env=stage overall=DEGRADED')"
  assert_contains "$message" 'Deploy backend (stage) failed'
  assert_contains "$message" 'exit=7'
  assert_contains "$message" 'elapsed=19s'
  assert_contains "$message" 'ops=env=stage overall=DEGRADED'
}

test_compose_status_context_includes_before_after_and_verify() {
  local context
  context="$(owf_compose_status_context 'env=stage overall=OK' 'env=stage overall=OK frontend_url=https://example.com/app/' 'frontend=OK:200')"
  assert_contains "$context" 'ops-before=env=stage overall=OK'
  assert_contains "$context" 'ops-after=env=stage overall=OK frontend_url=https://example.com/app/'
  assert_contains "$context" 'verify=frontend=OK:200'
}

test_capture_http_probe_success() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  cat > "$tmp_dir/curl" <<'EOF'
#!/usr/bin/env bash
printf '204'
EOF
  chmod +x "$tmp_dir/curl"

  local output
  output="$(PATH="$tmp_dir:$PATH" owf_capture_http_probe 'https://example.com/app/' 'frontend')"
  assert_equals "$output" 'frontend=OK:204'

  rm -rf "$tmp_dir"
}

test_capture_http_probe_failure_without_response() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  cat > "$tmp_dir/curl" <<'EOF'
#!/usr/bin/env bash
printf '000'
EOF
  chmod +x "$tmp_dir/curl"

  local output
  output="$(PATH="$tmp_dir:$PATH" owf_capture_http_probe 'https://example.com/app/' 'frontend' || true)"
  assert_equals "$output" 'frontend=FAIL:no-response'

  rm -rf "$tmp_dir"
}

test_send_telegram_notification_uses_notifier_when_configured() {
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  cat > "$tmp_dir/telegram-notify.sh" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" > "$TMP_TELEGRAM_ARGS_FILE"
EOF
  chmod +x "$tmp_dir/telegram-notify.sh"

  local args_file
  args_file="$(mktemp)"
  export TMP_TELEGRAM_ARGS_FILE="$args_file"
  export TELEGRAM_BOT_TOKEN='token'
  export TELEGRAM_CHAT_ID='chat'

  owf_send_telegram_notification "$tmp_dir" success 'Deploy frontend' 'done'

  local recorded
  recorded="$(<"$args_file")"
  assert_contains "$recorded" 'send --type success --title Deploy frontend done'

  unset TMP_TELEGRAM_ARGS_FILE TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID
  rm -rf "$tmp_dir"
  rm -f "$args_file"
}

test_send_telegram_notification_skips_without_config() {
  local tmp_dir
  local fake_home
  tmp_dir="$(mktemp -d)"
  fake_home="$(mktemp -d)"
  cat > "$tmp_dir/telegram-notify.sh" <<'EOF'
#!/usr/bin/env bash
printf 'unexpected call\n' >&2
exit 99
EOF
  chmod +x "$tmp_dir/telegram-notify.sh"

  HOME="$fake_home" TELEGRAM_BOT_TOKEN='' TELEGRAM_CHAT_ID='' owf_send_telegram_notification "$tmp_dir" success 'Deploy frontend' 'done'

  rm -rf "$tmp_dir"
  rm -rf "$fake_home"
}

main() {
  test_capture_ops_status_success
  test_capture_ops_status_failure_is_nonfatal
  test_compose_start_message_includes_context_and_status
  test_compose_failure_message_includes_exit_code_and_elapsed
  test_compose_status_context_includes_before_after_and_verify
  test_capture_http_probe_success
  test_capture_http_probe_failure_without_response
  test_send_telegram_notification_uses_notifier_when_configured
  test_send_telegram_notification_skips_without_config
  printf 'deploy-notify-lib tests passed\n'
}

main "$@"
