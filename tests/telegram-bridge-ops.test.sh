#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BRIDGE_LOOP="$ROOT_DIR/telegram-bridge-loop.sh"
BRIDGE_PY="$ROOT_DIR/telegram-context-bridge.py"
NOTIFY_SH="$ROOT_DIR/telegram-notify.sh"

assert_contains() {
  local haystack="$1"
  local needle="$2"
  if [[ "$haystack" != *"$needle"* ]]; then
    printf 'Expected to find %q in:\n%s\n' "$needle" "$haystack" >&2
    exit 1
  fi
}

assert_nonzero() {
  local status="$1"
  if [ "$status" -eq 0 ]; then
    printf 'Expected non-zero exit status\n' >&2
    exit 1
  fi
}

wait_for_pid_exit() {
  local pid="$1"
  local attempts="${2:-20}"
  local i
  for ((i = 0; i < attempts; i += 1)); do
    if ! kill -0 "$pid" 2>/dev/null; then
      return 0
    fi
    sleep 0.2
  done
  return 1
}

make_fake_bridge() {
  local target="$1"
  cat >"$target" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [ "${1:-}" != "pull" ]; then
  printf 'Unexpected fake bridge command: %s\n' "$*" >&2
  exit 91
fi
sleep "${FAKE_BRIDGE_SLEEP:-5}"
EOF
  chmod +x "$target"
}

start_fake_loop() {
  local fake_home="$1"
  local fake_bridge="$2"
  local output_file="$3"

  HOME="$fake_home" \
  OWF_TELEGRAM_BRIDGE_COMMAND="$fake_bridge" \
  FAKE_BRIDGE_SLEEP=5 \
  "$BRIDGE_LOOP" run --interval 5 --limit 1 --mode auto >"$output_file" 2>&1 &
  LOOP_PID=$!
  sleep 1
}

stop_fake_loop() {
  if [ -n "${LOOP_PID:-}" ]; then
    kill "$LOOP_PID" 2>/dev/null || true
    sleep 1
    kill -9 "$LOOP_PID" 2>/dev/null || true
    wait "$LOOP_PID" 2>/dev/null || true
  fi
  LOOP_PID=""
}

test_bridge_loop_run_rejects_second_instance() {
  local fake_home fake_bridge first_output second_output second_pid second_status output
  fake_home="$(mktemp -d)"
  fake_bridge="$fake_home/fake-bridge.sh"
  first_output="$fake_home/first.out"
  second_output="$fake_home/second.out"
  make_fake_bridge "$fake_bridge"

  LOOP_PID=""
  trap 'stop_fake_loop; rm -rf "$fake_home"' RETURN
  start_fake_loop "$fake_home" "$fake_bridge" "$first_output"

  HOME="$fake_home" \
  OWF_TELEGRAM_BRIDGE_COMMAND="$fake_bridge" \
  FAKE_BRIDGE_SLEEP=5 \
  "$BRIDGE_LOOP" run --interval 5 --limit 1 --mode auto >"$second_output" 2>&1 &
  second_pid=$!
  sleep 1

  set +e
  wait "$second_pid"
  second_status=$?
  set -e
  output="$(<"$second_output")"
  assert_nonzero "$second_status"
  assert_contains "$output" 'already running'

  trap - RETURN
  stop_fake_loop
  rm -rf "$fake_home"
}

test_pull_refuses_when_loop_is_active() {
  local fake_home fake_bridge first_output status output
  fake_home="$(mktemp -d)"
  fake_bridge="$fake_home/fake-bridge.sh"
  first_output="$fake_home/first.out"
  make_fake_bridge "$fake_bridge"

  LOOP_PID=""
  trap 'stop_fake_loop; rm -rf "$fake_home"' RETURN
  start_fake_loop "$fake_home" "$fake_bridge" "$first_output"

  set +e
  output="$(HOME="$fake_home" TELEGRAM_BOT_TOKEN='test-token' "$BRIDGE_PY" pull --limit 1 2>&1)"
  status=$?
  set -e

  assert_nonzero "$status"
  assert_contains "$output" 'already running'

  trap - RETURN
  stop_fake_loop
  rm -rf "$fake_home"
}

test_chat_id_refuses_when_loop_is_active() {
  local fake_home fake_bridge first_output status output
  fake_home="$(mktemp -d)"
  fake_bridge="$fake_home/fake-bridge.sh"
  first_output="$fake_home/first.out"
  make_fake_bridge "$fake_bridge"

  LOOP_PID=""
  trap 'stop_fake_loop; rm -rf "$fake_home"' RETURN
  start_fake_loop "$fake_home" "$fake_bridge" "$first_output"

  set +e
  output="$(HOME="$fake_home" TELEGRAM_BOT_TOKEN='test-token' "$NOTIFY_SH" chat-id 2>&1)"
  status=$?
  set -e

  assert_nonzero "$status"
  assert_contains "$output" 'already running'

  trap - RETURN
  stop_fake_loop
  rm -rf "$fake_home"
}

test_status_and_stop_work_with_lock_only_runtime() {
  local fake_home fake_bridge first_output status_output run_dir pid_file
  fake_home="$(mktemp -d)"
  fake_bridge="$fake_home/fake-bridge.sh"
  first_output="$fake_home/first.out"
  make_fake_bridge "$fake_bridge"

  LOOP_PID=""
  trap 'stop_fake_loop; rm -rf "$fake_home"' RETURN
  start_fake_loop "$fake_home" "$fake_bridge" "$first_output"

  run_dir="$fake_home/.config/owfinance-ops/automation/run"
  pid_file="$run_dir/telegram-bridge-loop.pid"
  rm -f "$pid_file"

  status_output="$(HOME="$fake_home" "$BRIDGE_LOOP" status)"
  assert_contains "$status_output" 'Bridge loop: running'

  HOME="$fake_home" "$BRIDGE_LOOP" stop >/dev/null

  if ! wait_for_pid_exit "$LOOP_PID" 30; then
    printf 'Bridge loop stop should terminate lock-only runtime\n' >&2
    exit 1
  fi

  trap - RETURN
  stop_fake_loop
  rm -rf "$fake_home"
}

main() {
  test_bridge_loop_run_rejects_second_instance
  test_pull_refuses_when_loop_is_active
  test_chat_id_refuses_when_loop_is_active
  test_status_and_stop_work_with_lock_only_runtime
  printf 'telegram bridge ops tests passed\n'
}

main "$@"
