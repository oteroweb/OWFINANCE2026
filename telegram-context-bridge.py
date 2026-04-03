#!/usr/bin/env python3
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import textwrap
from datetime import datetime, timezone
from pathlib import Path
from urllib import error, parse, request


ROOT_DIR = Path(__file__).resolve().parent
DEFAULT_RUNTIME_DIR = Path.home() / ".config" / "owfinance-ops" / "context-bridge"
DEFAULT_CONFIG_PATH = Path.home() / ".config" / "owfinance-ops" / "bridge.json"
DEFAULT_CHAT_CONFIG_PATH = Path.home() / ".config" / "owfinance-ops" / "telegram.json"
AUTOMATION_RUN_DIR = Path.home() / ".config" / "owfinance-ops" / "automation" / "run"
BRIDGE_LOOP_LOCK_DIR = AUTOMATION_RUN_DIR / "telegram-bridge-loop.lock"
MAX_MESSAGE_LENGTH = 3500
GEMINI_REPLY_START = "<<OWF_REPLY>>"
GEMINI_REPLY_END = "<<END_OWF_REPLY>>"
ACK_FREEFORM_TEXT = "Recibido. Procesando contexto OWFINANCE..."


def utc_now():
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def fail(message):
    print(message, file=sys.stderr)
    raise SystemExit(1)


def read_text_file(path):
    try:
        return path.read_text(encoding="utf-8").strip()
    except OSError:
        return ""


def pid_is_running(pid_text):
    if not pid_text:
        return False
    try:
        pid = int(pid_text)
    except ValueError:
        return False
    try:
        os.kill(pid, 0)
    except OSError:
        return False
    return True


def active_bridge_loop_pid():
    pid_text = read_text_file(BRIDGE_LOOP_LOCK_DIR / "pid")
    if pid_is_running(pid_text):
        return pid_text
    return ""


def ensure_bridge_polling_available():
    owner_pid = os.getenv("OWF_TELEGRAM_LOOP_OWNER_PID", "").strip()
    active_pid = active_bridge_loop_pid()
    if not active_pid:
        return
    if owner_pid and owner_pid == active_pid:
        return
    fail(f"Telegram bridge loop already running (pid={active_pid}). Use the active loop instead of a second getUpdates poller.")


def read_json_file(path, default):
    if not path.exists():
        return default
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail(f"Invalid JSON in {path}: {exc}")


def write_json_file(path, payload):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def append_jsonl(path, payload):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(payload, sort_keys=True) + "\n")


def read_jsonl(path):
    if not path.exists():
        return []
    rows = []
    with path.open("r", encoding="utf-8") as handle:
        for raw_line in handle:
            line = raw_line.strip()
            if not line:
                continue
            rows.append(json.loads(line))
    return rows


def default_config():
    runtime_dir = str(DEFAULT_RUNTIME_DIR)
    return {
        "project": "OWFINANCE2026",
        "runtime_dir": runtime_dir,
        "state_file": f"{runtime_dir}/state.json",
        "transcript_file": f"{runtime_dir}/shared-transcript.jsonl",
        "inbox_file": f"{runtime_dir}/telegram-inbox.jsonl",
        "snapshot_file": f"{runtime_dir}/context-snapshot.txt",
        "updates_file": f"{runtime_dir}/telegram-updates.jsonl",
        "default_status_env": "dev",
        "context_tail": 12,
        "conversation_tail": 8,
        "doc_excerpt_count": 3,
        "doc_excerpt_length": 280,
        "freeform_mode": "auto",
        "freeform_provider_order": ["gemini-cli", "local-context"],
        "gemini_bin": "gemini",
        "gemini_model": "",
        "gemini_timeout_seconds": 45,
        "doc_files": [
            "PROJECT_CONTEXT.md",
            "README.md",
            "docs/ARQUITECTURA_PROYECTO.md",
            "docs/CONSULTAS_OPERATIVAS.md",
            "docs/01-configuracion/SAAS_ROLE_SYSTEM.md",
            "docs/01-configuracion/TELEGRAM_NOTIFICATIONS.md",
        ],
    }


def load_config():
    config = default_config()
    if DEFAULT_CONFIG_PATH.exists():
        config.update(read_json_file(DEFAULT_CONFIG_PATH, {}))
    else:
        write_json_file(DEFAULT_CONFIG_PATH, config)
    env_overrides = {
        "freeform_mode": os.getenv("OWF_TELEGRAM_FREEFORM_MODE", "").strip(),
        "gemini_bin": os.getenv("OWF_TELEGRAM_GEMINI_BIN", "").strip(),
        "gemini_model": os.getenv("OWF_TELEGRAM_GEMINI_MODEL", "").strip(),
    }
    for key, value in env_overrides.items():
        if value:
            config[key] = value
    return config


def runtime_paths(config):
    return {
        "runtime_dir": Path(config["runtime_dir"]),
        "state_file": Path(config["state_file"]),
        "transcript_file": Path(config["transcript_file"]),
        "inbox_file": Path(config["inbox_file"]),
        "snapshot_file": Path(config["snapshot_file"]),
        "updates_file": Path(config["updates_file"]),
    }


def ensure_runtime(config):
    paths = runtime_paths(config)
    paths["runtime_dir"].mkdir(parents=True, exist_ok=True)
    if not paths["state_file"].exists():
        write_json_file(
            paths["state_file"],
            {
                "created_at": utc_now(),
                "last_update_id": 0,
                "last_command_update_id": 0,
                "updated_at": utc_now(),
            },
        )
    for key in ("transcript_file", "inbox_file", "updates_file"):
        paths[key].touch(exist_ok=True)
    if not paths["snapshot_file"].exists():
        paths["snapshot_file"].write_text(
            "OWFINANCE shared context snapshot initialized.\n",
            encoding="utf-8",
        )
    if not DEFAULT_CONFIG_PATH.exists():
        write_json_file(DEFAULT_CONFIG_PATH, config)
    return paths


def load_state(paths):
    return read_json_file(paths["state_file"], {})


def save_state(paths, state):
    state["updated_at"] = utc_now()
    write_json_file(paths["state_file"], state)


def resolve_chat_id(explicit_chat_id=None):
    if explicit_chat_id:
        return str(explicit_chat_id)
    env_chat_id = os.getenv("TELEGRAM_CHAT_ID")
    if env_chat_id:
        return env_chat_id
    local_chat_config = read_json_file(DEFAULT_CHAT_CONFIG_PATH, {})
    if local_chat_config.get("telegram_chat_id"):
        return str(local_chat_config["telegram_chat_id"])
    return None


def resolve_token():
    token = os.getenv("TELEGRAM_BOT_TOKEN")
    if token:
        return token
    local_chat_config = read_json_file(DEFAULT_CHAT_CONFIG_PATH, {})
    token = local_chat_config.get("telegram_bot_token")
    if not token:
        fail("TELEGRAM_BOT_TOKEN is required in the shell environment.")
    return token


def telegram_api(token, method, params=None):
    params = params or {}
    encoded = parse.urlencode(params).encode("utf-8")
    url = f"https://api.telegram.org/bot{token}/{method}"
    req = request.Request(url, data=encoded, method="POST")
    try:
        with request.urlopen(req, timeout=20) as response:
            payload = json.loads(response.read().decode("utf-8"))
    except error.HTTPError as exc:
        fail(f"Telegram API HTTP error for {method}: {exc.code}")
    except error.URLError as exc:
        fail(f"Telegram API network error for {method}: {exc.reason}")
    if not payload.get("ok"):
        fail(payload.get("description", f"Telegram API error for {method}"))
    return payload


def shell_send(message, message_type="info", title="", chat_id=None):
    command = [str(ROOT_DIR / "telegram-notify.sh"), "send", "--type", message_type]
    if title:
        command.extend(["--title", title])
    if chat_id:
        command.extend(["--chat-id", str(chat_id)])
    command.append(message)
    completed = subprocess.run(command, cwd=ROOT_DIR, capture_output=True, text=True, check=False)
    if completed.returncode != 0:
        stderr = completed.stderr.strip() or completed.stdout.strip() or "telegram-notify.sh failed"
        fail(stderr)
    return completed.stdout.strip() or "Telegram message sent."


def append_transcript(paths, direction, source, text, **extra):
    entry = {
        "timestamp": utc_now(),
        "direction": direction,
        "source": source,
        "text": text,
    }
    entry.update(extra)
    append_jsonl(paths["transcript_file"], entry)
    return entry


def append_inbox(paths, text, **extra):
    entry = {
        "timestamp": utc_now(),
        "text": text,
    }
    entry.update(extra)
    append_jsonl(paths["inbox_file"], entry)
    return entry


def trim_message(text, limit=MAX_MESSAGE_LENGTH):
    compact = text.strip()
    if len(compact) <= limit:
        return compact
    return compact[: limit - 3].rstrip() + "..."


def ascii_clean(text):
    return text.encode("ascii", "ignore").decode("ascii")


def shorten_line(text, limit):
    single_line = ascii_clean(" ".join(text.split()))
    if len(single_line) <= limit:
        return single_line
    return single_line[: limit - 3].rstrip() + "..."


def positive_int(value, default):
    try:
        parsed = int(value)
    except (TypeError, ValueError):
        return default
    return parsed if parsed > 0 else default


def read_message_argument(message_arg):
    if message_arg:
        return " ".join(message_arg).strip()
    if not sys.stdin.isatty():
        return sys.stdin.read().strip()
    return ""


def build_last_text(paths, count):
    rows = read_jsonl(paths["transcript_file"])
    if not rows:
        return "No shared transcript entries yet."
    tail = rows[-count:]
    lines = []
    for row in tail:
        ts = row.get("timestamp", "unknown-time")
        direction = row.get("direction", "unknown")
        source = row.get("source", "unknown")
        event_type = row.get("event_type", "")
        title = row.get("title", "")
        text = row.get("text", "")
        label = source
        if event_type:
            label = f"{label}:{event_type}"
        if title:
            label = f"{label}[{title}]"
        lines.append(f"- {ts} | {direction} | {label} | {text}")
    return "Last shared transcript entries:\n" + "\n".join(lines)


def build_context_text(config, paths):
    snapshot = paths["snapshot_file"].read_text(encoding="utf-8").strip()
    tail_count = int(config.get("context_tail", 12))
    last_text = build_last_text(paths, tail_count)
    return trim_message(
        "Shared OWFINANCE context bridge\n\n"
        + "Mode: shared transcript + local snapshot + local docs summaries. This is not the exact native OpenCode session.\n\n"
        + "Snapshot:\n"
        + (snapshot or "No snapshot saved yet.")
        + "\n\n"
        + last_text,
        MAX_MESSAGE_LENGTH,
    )


def run_ops_status(config, requested_env=None):
    target_env = requested_env or config.get("default_status_env", "dev")
    command = [str(ROOT_DIR / "ops-status.sh"), "--one-line", target_env]
    completed = subprocess.run(command, cwd=ROOT_DIR, capture_output=True, text=True, check=False)
    output = completed.stdout.strip() or completed.stderr.strip() or f"env={target_env} overall=UNKNOWN"
    return output


def extract_message_from_update(update):
    for field in ("message", "edited_message", "channel_post", "edited_channel_post"):
        if field in update:
            return update[field], field
    return None, None


def normalize_command(text):
    if not text.startswith("/"):
        return "", []
    tokens = text.strip().split()
    raw_command = tokens[0][1:]
    command = raw_command.split("@", 1)[0].lower()
    return command, tokens[1:]


def resolve_status_env(config, args):
    if args and args[0] in {"dev", "stage", "prod"}:
        return args[0]
    return config.get("default_status_env", "dev")


def keyword_tokens(text):
    stop_words = {
        "a",
        "about",
        "and",
        "are",
        "as",
        "con",
        "como",
        "context",
        "cual",
        "cuales",
        "cuanto",
        "de",
        "del",
        "el",
        "en",
        "for",
        "how",
        "is",
        "la",
        "las",
        "los",
        "me",
        "need",
        "necesito",
        "para",
        "por",
        "que",
        "quiero",
        "status",
        "the",
        "una",
        "un",
        "what",
        "with",
        "y",
    }
    tokens = []
    for token in re.findall(r"[a-z0-9]{3,}", text.lower()):
        if token not in stop_words:
            tokens.append(token)
    return tokens


def relative_label(path):
    try:
        return str(path.relative_to(ROOT_DIR))
    except ValueError:
        return str(path)


def load_doc_paths(config):
    doc_paths = []
    for raw_path in config.get("doc_files", []):
        path = Path(raw_path)
        if not path.is_absolute():
            path = ROOT_DIR / path
        if path.exists() and path.is_file():
            doc_paths.append(path)
    return doc_paths


def paragraph_chunks(text):
    normalized = text.replace("\r\n", "\n")
    return [chunk.strip() for chunk in re.split(r"\n\s*\n", normalized) if chunk.strip()]


def select_doc_excerpts(config, message_text):
    tokens = keyword_tokens(message_text)
    excerpts = []
    excerpt_limit = int(config.get("doc_excerpt_count", 3))
    excerpt_length = int(config.get("doc_excerpt_length", 280))

    for path in load_doc_paths(config):
        content = path.read_text(encoding="utf-8")
        for chunk in paragraph_chunks(content):
            lowered = chunk.lower()
            score = 0
            for token in tokens:
                if token in lowered:
                    score += 1
            if not score and tokens:
                continue
            if not tokens:
                if not excerpts and len(chunk) > 40:
                    excerpts.append(
                        {
                            "score": 0,
                            "path": relative_label(path),
                            "text": shorten_line(chunk, excerpt_length),
                        }
                    )
                continue
            excerpts.append(
                {
                    "score": score,
                    "path": relative_label(path),
                    "text": shorten_line(chunk, excerpt_length),
                }
            )

    excerpts.sort(key=lambda item: (-item["score"], item["path"], item["text"]))

    selected = []
    seen = set()
    for item in excerpts:
        key = (item["path"], item["text"])
        if key in seen:
            continue
        seen.add(key)
        selected.append(item)
        if len(selected) >= excerpt_limit:
            break
    return selected


def build_recent_conversation_text(config, paths):
    rows = read_jsonl(paths["transcript_file"])
    if not rows:
        return []
    tail = rows[-int(config.get("conversation_tail", 8)) :]
    rendered = []
    for row in tail:
        direction = row.get("direction", "unknown")
        source = row.get("source", "unknown")
        text = shorten_line(row.get("text", ""), 140)
        rendered.append(ascii_clean(f"- {direction}/{source}: {text}"))
    return rendered


def infer_status_request(config, message_text):
    lowered = message_text.lower()
    if not any(word in lowered for word in ("status", "estado", "health", "salud", "deploy", "dev", "stage", "prod", "production")):
        return ""
    if "stage" in lowered or "staging" in lowered:
        requested_env = "stage"
    elif "prod" in lowered or "production" in lowered:
        requested_env = "prod"
    elif "dev" in lowered or "local" in lowered:
        requested_env = "dev"
    else:
        requested_env = config.get("default_status_env", "dev")
    return run_ops_status(config, requested_env)


def build_freeform_context_bundle(config, paths, message_text):
    snapshot = paths["snapshot_file"].read_text(encoding="utf-8").strip()
    doc_excerpts = select_doc_excerpts(config, message_text)
    recent_lines = build_recent_conversation_text(config, paths)
    status_line = infer_status_request(config, message_text)
    return {
        "snapshot": snapshot,
        "doc_excerpts": doc_excerpts,
        "recent_lines": recent_lines,
        "status_line": status_line,
    }


def build_deterministic_freeform_reply(bundle):
    lines = [
        "OWFINANCE parallel bridge reply",
        "",
        "Mode: deterministic shared transcript/snapshot/docs responder, not the exact native OpenCode session.",
    ]

    if bundle["snapshot"]:
        lines.extend(
            [
                "",
                "Current snapshot:",
                shorten_line(bundle["snapshot"], 420),
            ]
        )

    if bundle["status_line"]:
        lines.extend(
            [
                "",
                "Relevant local status:",
                bundle["status_line"],
            ]
        )

    if bundle["doc_excerpts"]:
        lines.append("")
        lines.append("Relevant local docs and summaries:")
        for item in bundle["doc_excerpts"]:
            lines.append(f"- {item['path']}: {item['text']}")

    if bundle["recent_lines"]:
        lines.append("")
        lines.append("Recent shared transcript:")
        lines.extend(bundle["recent_lines"][-4:])

    if not bundle["doc_excerpts"] and not bundle["status_line"]:
        lines.extend(
            [
                "",
                "Helpful next actions:",
                "- Use /context for the shared snapshot.",
                "- Use /last 5 for recent transcript entries.",
                "- Use /status dev|stage|prod for quick ops state.",
            ]
        )

    lines.extend(
        [
            "",
            "Drive-first note: local docs here are summaries and snapshots of the canonical OWFINANCE Drive documentation model.",
        ]
    )
    return trim_message(ascii_clean("\n".join(lines)))


def freeform_provider_order(config):
    raw_order = config.get("freeform_provider_order", ["gemini-cli", "local-context"])
    if isinstance(raw_order, str):
        return [item.strip() for item in raw_order.split(",") if item.strip()]
    if isinstance(raw_order, list):
        return [str(item).strip() for item in raw_order if str(item).strip()]
    return ["gemini-cli", "local-context"]


def extract_marked_block(text, start_marker, end_marker):
    if start_marker not in text or end_marker not in text:
        return ""
    start_index = text.index(start_marker) + len(start_marker)
    end_index = text.index(end_marker, start_index)
    return text[start_index:end_index].strip()


def build_gemini_prompt(bundle, message_text):
    doc_lines = [f"- {item['path']}: {item['text']}" for item in bundle["doc_excerpts"]]
    recent_lines = bundle["recent_lines"][-6:]
    prompt_sections = [
        "You are the OWFINANCE Telegram bridge parallel chat responder.",
        "",
        "Rules:",
        "- Answer as a parallel OWFINANCE chat with shared context.",
        "- Never claim to be the exact same native OpenCode, Gemini, or hidden model session.",
        "- Use only the supplied local context. If context is missing, say that clearly.",
        "- Keep the answer concise and practical.",
        "- Output ASCII only.",
        "- Do not mention internal chain-of-thought.",
        "",
        "Return only the reply between these markers:",
        GEMINI_REPLY_START,
        "your reply here",
        GEMINI_REPLY_END,
        "",
        "Use this exact reply structure:",
        "OWFINANCE parallel bridge reply",
        "Mode: local Gemini CLI over shared transcript/snapshot/docs, not the exact native session.",
        "Answer: <direct answer>",
        "Context used: <short note>",
        "Next: <optional next step or omit if unnecessary>",
        "",
        f"User message: {message_text}",
        "",
        "Snapshot:",
        bundle["snapshot"] or "No shared snapshot saved.",
        "",
        "Relevant local status:",
        bundle["status_line"] or "No explicit status signal inferred from the message.",
        "",
        "Relevant docs:",
    ]
    prompt_sections.extend(doc_lines or ["- No directly matching local doc excerpts found."])
    prompt_sections.extend(["", "Recent shared transcript:"])
    prompt_sections.extend(recent_lines or ["- No recent transcript lines available."])
    return "\n".join(prompt_sections)


def run_gemini_freeform_reply(config, bundle, message_text):
    gemini_bin_name = str(config.get("gemini_bin", "gemini")).strip() or "gemini"
    gemini_bin = shutil.which(gemini_bin_name)
    if not gemini_bin:
        return "", "gemini-cli-unavailable"

    prompt = build_gemini_prompt(bundle, message_text)
    command = [gemini_bin, "--prompt", prompt, "--output-format", "text"]
    gemini_model = str(config.get("gemini_model", "")).strip()
    if gemini_model:
        command.extend(["--model", gemini_model])

    env = os.environ.copy()
    env["NO_COLOR"] = "1"
    env["TERM"] = "dumb"
    timeout_seconds = positive_int(config.get("gemini_timeout_seconds", 45), 45)

    try:
        completed = subprocess.run(
            command,
            cwd=ROOT_DIR,
            capture_output=True,
            text=True,
            check=False,
            timeout=timeout_seconds,
            env=env,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        return "", f"gemini-cli-error:{exc}"

    combined_output = "\n".join(part.strip() for part in (completed.stdout, completed.stderr) if part.strip())
    if completed.returncode != 0:
        return "", f"gemini-cli-exit-{completed.returncode}"

    reply_text = extract_marked_block(combined_output, GEMINI_REPLY_START, GEMINI_REPLY_END)
    if not reply_text:
        return "", "gemini-cli-empty"
    return trim_message(ascii_clean(reply_text)), "gemini-cli"


def build_freeform_reply(config, paths, message_text):
    bundle = build_freeform_context_bundle(config, paths, message_text)
    freeform_mode = str(config.get("freeform_mode", "auto")).strip().lower()
    provider_order = freeform_provider_order(config)

    if freeform_mode == "local-context":
        return build_deterministic_freeform_reply(bundle), "local-context"
    if freeform_mode == "gemini-cli":
        reply_text, reply_provider = run_gemini_freeform_reply(config, bundle, message_text)
        if reply_text:
            return reply_text, reply_provider
        return build_deterministic_freeform_reply(bundle), "local-context-fallback"

    for provider in provider_order:
        if provider == "gemini-cli":
            reply_text, reply_provider = run_gemini_freeform_reply(config, bundle, message_text)
            if reply_text:
                return reply_text, reply_provider
        if provider == "local-context":
            return build_deterministic_freeform_reply(bundle), "local-context"

    return build_deterministic_freeform_reply(bundle), "local-context"


def render_help_text():
    return textwrap.dedent(
        """\
        OWFINANCE Telegram bridge commands
        Freeform messages - logged and answered by Gemini CLI when available, otherwise from deterministic local context
        /status - return the default local status summary
        /status dev - return the dev status summary
        /status stage - return the stage status summary
        /status prod - return the prod status summary
        /last [n] - return the last transcript entries
        /context - return the current shared context snapshot
        /help - show this help

        Recommended mode: event-driven updates plus explicit commands.
        Heartbeats stay available for rare long-running tasks, but they are not the default workflow.
        Note: this bridge is a parallel OWFINANCE chat with rolling transcript, local docs, and snapshots. It does not become the exact same native OpenCode chat session.
        """
    ).strip()


def build_command_reply(config, paths, message_text):
    command, args = normalize_command(message_text)
    if command == "start":
        return render_help_text(), "help"
    if command == "status":
        if args and args[0] not in {"dev", "stage", "prod"}:
            return "Usage: /status [dev|stage|prod]", "help"
        requested_env = args[0] if args else None
        return run_ops_status(config, requested_env), "status"
    if command == "last":
        count = 5
        if args:
            try:
                count = max(1, min(20, int(args[0])))
            except ValueError:
                return "Usage: /last [n]", "help"
        return trim_message(build_last_text(paths, count)), "last"
    if command == "context":
        return build_context_text(config, paths), "context"
    if command == "help":
        return render_help_text(), "help"
    return "Unknown command. Use /help for supported commands.", "help"


def build_command_ack_text(config, message_text):
    command, args = normalize_command(message_text)
    if command == "status":
        return f"Recibido. Procesando estado {resolve_status_env(config, args)}..."
    if command == "context":
        return "Recibido. Procesando contexto OWFINANCE..."
    if command == "last":
        return "Recibido. Procesando ultimas entradas del bridge..."
    if command in {"help", "start"}:
        return "Recibido. Preparando ayuda del bridge..."
    return f"Recibido. Procesando comando /{command or 'help'}..."


def build_ack_text(item):
    if item.get("is_command"):
        return build_command_ack_text(item.get("config", {}), item.get("text", ""))
    return ACK_FREEFORM_TEXT


def prefix_final_reply(reply_text, reply_kind):
    if reply_kind not in {"status", "context", "last", "help"}:
        return reply_text
    if not reply_text:
        return reply_text
    if reply_text.startswith("Listo"):
        return reply_text
    separator = "\n\n" if "\n" in reply_text else " "
    return f"Listo.{separator}{reply_text}"


def log_local_event(paths, text, title="", message_type="info", event_type="event", source="local-event", **extra):
    payload = {
        "title": title,
        "message_type": message_type,
        "event_type": event_type,
    }
    payload.update(extra)
    append_transcript(paths, "local", source, text, **payload)


def cmd_init(args):
    config = load_config()
    paths = ensure_runtime(config)
    print(f"Initialized bridge runtime in {paths['runtime_dir']}")
    print(f"Config file: {DEFAULT_CONFIG_PATH}")


def cmd_snapshot(args):
    config = load_config()
    paths = ensure_runtime(config)
    message = read_message_argument(args.message)
    if not message:
        fail("Snapshot text is required.")
    snapshot_text = trim_message(message, 12000)
    paths["snapshot_file"].write_text(snapshot_text + "\n", encoding="utf-8")
    log_local_event(paths, snapshot_text, title=args.title or "", message_type=args.type, event_type="snapshot", source="snapshot")
    if args.send:
        title = args.title or "Context"
        response = shell_send(trim_message(snapshot_text), message_type=args.type, title=title, chat_id=resolve_chat_id(args.chat_id))
        print(response)
    print(f"Snapshot saved to {paths['snapshot_file']}")


def cmd_send(args):
    config = load_config()
    paths = ensure_runtime(config)
    message = read_message_argument(args.message)
    if not message:
        fail("Message text is required.")
    response = shell_send(trim_message(message), message_type=args.type, title=args.title or "", chat_id=resolve_chat_id(args.chat_id))
    log_local_event(paths, message, title=args.title or "", message_type=args.type, event_type="telegram-send", source="telegram-send")
    print(response)


def cmd_event(args):
    config = load_config()
    paths = ensure_runtime(config)
    message = read_message_argument(args.message)
    if not message:
        fail("Event text is required.")
    log_local_event(
        paths,
        message,
        title=args.title or "",
        message_type=args.type,
        event_type=args.event_type,
        source=args.source,
        tag=args.tag or "",
    )
    if args.send:
        response = shell_send(trim_message(message), message_type=args.type, title=args.title or "", chat_id=resolve_chat_id(args.chat_id))
        print(response)
    print(f"Event logged to {paths['transcript_file']}")


def cmd_status(args):
    config = load_config()
    paths = ensure_runtime(config)
    text = run_ops_status(config, args.environment)
    log_local_event(
        paths,
        text,
        title="Status",
        message_type="info",
        event_type="status-snapshot",
        source="status-snapshot",
        environment=args.environment or config.get("default_status_env", "dev"),
    )
    if args.send:
        response = shell_send(trim_message(text), message_type="info", title="Status", chat_id=resolve_chat_id(args.chat_id))
        print(response)
    print(text)


def cmd_last(args):
    config = load_config()
    paths = ensure_runtime(config)
    text = build_last_text(paths, args.count)
    if args.send:
        response = shell_send(trim_message(text), message_type="info", title="Last", chat_id=resolve_chat_id(args.chat_id))
        print(response)
    print(text)


def cmd_context(args):
    config = load_config()
    paths = ensure_runtime(config)
    text = build_context_text(config, paths)
    if args.send:
        response = shell_send(trim_message(text), message_type="info", title="Context", chat_id=resolve_chat_id(args.chat_id))
        print(response)
    print(text)


def cmd_chat(args):
    config = load_config()
    paths = ensure_runtime(config)
    message = read_message_argument(args.message)
    if not message:
        fail("Chat text is required.")
    append_inbox(
        paths,
        message,
        chat_id="local-cli",
        chat_label="local-cli",
        chat_type="local",
        command_args=[],
        command_name="",
        event_type="local-chat",
        from_username=os.getenv("USER", "local-user"),
        is_command=False,
        message_field="local",
        message_id="local",
        update_id=int(datetime.now(timezone.utc).timestamp()),
    )
    append_transcript(
        paths,
        "local",
        "local-chat",
        message,
        event_type="local-chat",
        is_command=False,
    )
    reply_text, reply_provider = build_freeform_reply(config, paths, message)
    append_transcript(
        paths,
        "local",
        "local-chat-reply",
        reply_text,
        event_type="local-chat-reply",
        reply_kind="freeform",
        reply_provider=reply_provider,
    )
    if args.send:
        response = shell_send(trim_message(reply_text), message_type="info", title=args.title or "TG chat", chat_id=resolve_chat_id(args.chat_id))
        print(response)
    print(reply_text)


def pull_updates(config, paths, state, limit):
    token = resolve_token()
    last_update_id = int(state.get("last_update_id", 0))
    params = {"timeout": 1, "offset": last_update_id + 1, "limit": limit}
    payload = telegram_api(token, "getUpdates", params)
    updates = payload.get("result", [])
    processed = []
    for update in updates:
        update_id = int(update.get("update_id", 0))
        message, message_field = extract_message_from_update(update)
        if not message:
            state["last_update_id"] = max(state.get("last_update_id", 0), update_id)
            continue
        text = message.get("text") or message.get("caption") or ""
        chat = message.get("chat") or {}
        from_user = message.get("from") or {}
        normalized = {
            "timestamp": utc_now(),
            "update_id": update_id,
            "message_field": message_field,
            "message_id": message.get("message_id"),
            "chat_id": chat.get("id"),
            "chat_type": chat.get("type"),
            "chat_label": chat.get("title") or chat.get("username") or chat.get("first_name") or "unknown",
            "from_username": from_user.get("username") or from_user.get("first_name") or "unknown",
            "text": text,
            "is_command": text.startswith("/"),
        }
        command_name, command_args = normalize_command(text)
        normalized["command_name"] = command_name
        normalized["command_args"] = command_args
        normalized["event_type"] = "telegram-command" if normalized["is_command"] else "telegram-message"
        metadata = dict(normalized)
        metadata.pop("timestamp", None)
        metadata.pop("text", None)
        append_jsonl(paths["updates_file"], normalized)
        append_inbox(paths, text, **metadata)
        append_transcript(paths, "telegram", normalized["event_type"], text, **metadata)
        processed.append(normalized)
        state["last_update_id"] = max(state.get("last_update_id", 0), update_id)
    save_state(paths, state)
    return processed


def respond_to_updates(config, paths, state, updates):
    responses = []
    last_reply_update_id = int(state.get("last_reply_update_id", state.get("last_command_update_id", 0)))
    for item in updates:
        update_id = int(item.get("update_id", 0))
        if update_id <= last_reply_update_id:
            continue
        ack_item = dict(item)
        ack_item["config"] = config
        ack_text = build_ack_text(ack_item)
        shell_send(trim_message(ack_text), message_type="info", chat_id=item.get("chat_id"))
        append_transcript(
            paths,
            "local",
            "telegram-ack",
            ack_text,
            event_type="telegram-ack",
            reply_kind="ack",
            reply_to_update_id=update_id,
            chat_id=item.get("chat_id"),
        )
        reply_provider = "command-handler"
        if item.get("is_command"):
            reply_text, reply_kind = build_command_reply(config, paths, item.get("text", ""))
            response_source = "telegram-command-reply"
            event_type = "telegram-command-reply"
        else:
            reply_text, reply_provider = build_freeform_reply(config, paths, item.get("text", ""))
            reply_kind = "freeform"
            response_source = "telegram-chat-reply"
            event_type = "telegram-chat-reply"
        reply_text = prefix_final_reply(reply_text, reply_kind)
        if not reply_text:
            continue
        shell_send(trim_message(reply_text), message_type="info", title=f"TG {reply_kind}", chat_id=item.get("chat_id"))
        append_transcript(
            paths,
            "local",
            response_source,
            reply_text,
            event_type=event_type,
            reply_kind=reply_kind,
            reply_provider=reply_provider,
            reply_to_update_id=update_id,
            chat_id=item.get("chat_id"),
        )
        responses.append({"update_id": update_id, "reply_kind": reply_kind, "reply_provider": reply_provider, "chat_id": item.get("chat_id")})
        state["last_reply_update_id"] = update_id
        if item.get("is_command"):
            state["last_command_update_id"] = update_id
    save_state(paths, state)
    return responses


def cmd_pull(args):
    config = load_config()
    paths = ensure_runtime(config)
    state = load_state(paths)
    ensure_bridge_polling_available()
    updates = pull_updates(config, paths, state, args.limit)
    print(f"Pulled {len(updates)} update(s) into {paths['inbox_file']}")
    if args.respond:
        responses = respond_to_updates(config, paths, state, updates)
        print(f"Responded to {len(responses)} update(s)")
    if updates:
        latest = updates[-1]
        print(f"Last update id: {latest['update_id']}")


def build_parser():
    parser = argparse.ArgumentParser(
        description="OWFINANCE Telegram context bridge",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=textwrap.dedent(
            """\
            Examples:
              ./telegram-context-bridge.py init
              ./telegram-context-bridge.py snapshot --title Sprint --send "Refined OWFINANCE bridge plan"
              ./telegram-context-bridge.py send --type progress --title Worker "Daily summary pushed"
              ./telegram-context-bridge.py event --send --type success --title Backend "Migration finished"
              ./telegram-context-bridge.py chat "What changed in OWFINANCE today?"
              ./telegram-context-bridge.py pull --respond
              ./telegram-context-bridge.py status --send dev
              ./telegram-context-bridge.py last --send 5
              ./telegram-context-bridge.py context --send
            """
        ),
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    subparsers.add_parser("init", help="Initialize local runtime files").set_defaults(func=cmd_init)

    snapshot_parser = subparsers.add_parser("snapshot", help="Persist a shared context snapshot")
    snapshot_parser.add_argument("message", nargs="*", help="Snapshot text, or pipe via stdin")
    snapshot_parser.add_argument("--title", default="", help="Optional Telegram title")
    snapshot_parser.add_argument("--type", default="info", help="Telegram message type when --send is used")
    snapshot_parser.add_argument("--send", action="store_true", help="Send the snapshot to Telegram")
    snapshot_parser.add_argument("--chat-id", default="", help="Override chat id for this run")
    snapshot_parser.set_defaults(func=cmd_snapshot)

    send_parser = subparsers.add_parser("send", help="Send a Telegram update and log it")
    send_parser.add_argument("message", nargs="*", help="Message text, or pipe via stdin")
    send_parser.add_argument("--title", default="", help="Optional Telegram title")
    send_parser.add_argument("--type", default="info", help="Telegram message type")
    send_parser.add_argument("--chat-id", default="", help="Override chat id for this run")
    send_parser.set_defaults(func=cmd_send)

    event_parser = subparsers.add_parser("event", help="Log a local event and optionally send it to Telegram")
    event_parser.add_argument("message", nargs="*", help="Event text, or pipe via stdin")
    event_parser.add_argument("--title", default="", help="Optional Telegram/event title")
    event_parser.add_argument("--type", default="progress", help="Telegram message type")
    event_parser.add_argument("--event-type", default="event", help="Transcript event type label")
    event_parser.add_argument("--source", default="local-event", help="Transcript source label")
    event_parser.add_argument("--tag", default="", help="Optional tag stored in the transcript")
    event_parser.add_argument("--send", action="store_true", help="Send the event to Telegram")
    event_parser.add_argument("--chat-id", default="", help="Override chat id for this run")
    event_parser.set_defaults(func=cmd_event)

    chat_parser = subparsers.add_parser("chat", help="Log a freeform message and build a local shared-context reply")
    chat_parser.add_argument("message", nargs="*", help="Freeform chat text, or pipe via stdin")
    chat_parser.add_argument("--send", action="store_true", help="Send the generated reply to Telegram")
    chat_parser.add_argument("--title", default="", help="Optional Telegram title for --send")
    chat_parser.add_argument("--chat-id", default="", help="Override chat id for this run")
    chat_parser.set_defaults(func=cmd_chat)

    pull_parser = subparsers.add_parser("pull", help="Read Telegram updates into the local bridge queue")
    pull_parser.add_argument("--limit", type=int, default=25, help="Maximum updates to request from Telegram")
    pull_parser.add_argument("--respond", action="store_true", help="Reply to supported Telegram slash commands and freeform chat")
    pull_parser.set_defaults(func=cmd_pull)

    status_parser = subparsers.add_parser("status", help="Create a local status summary")
    status_parser.add_argument("environment", nargs="?", choices=["dev", "stage", "prod"], help="Target environment")
    status_parser.add_argument("--send", action="store_true", help="Send the status summary to Telegram")
    status_parser.add_argument("--chat-id", default="", help="Override chat id for this run")
    status_parser.set_defaults(func=cmd_status)

    last_parser = subparsers.add_parser("last", help="Show the last transcript entries")
    last_parser.add_argument("count", nargs="?", type=int, default=5, help="Number of transcript lines to show")
    last_parser.add_argument("--send", action="store_true", help="Send the transcript summary to Telegram")
    last_parser.add_argument("--chat-id", default="", help="Override chat id for this run")
    last_parser.set_defaults(func=cmd_last)

    context_parser = subparsers.add_parser("context", help="Show the shared context snapshot")
    context_parser.add_argument("--send", action="store_true", help="Send the context snapshot to Telegram")
    context_parser.add_argument("--chat-id", default="", help="Override chat id for this run")
    context_parser.set_defaults(func=cmd_context)

    return parser


def main():
    parser = build_parser()
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
