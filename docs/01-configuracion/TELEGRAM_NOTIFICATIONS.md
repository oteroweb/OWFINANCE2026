# Telegram Notifications

Practical local setup for low-noise Telegram events, explicit status commands, freeform chat replies, completion updates, and a shared context bridge in this workspace.

## Files

- `./telegram-notify.sh` - local helper to send or inspect Telegram updates using env vars only
- `./telegram-heartbeat.sh` - optional recurring heartbeat loop for unusually long silent tasks
- `./ops-status.sh` - quick operational checks for dev, stage, and prod
- `./telegram-context-bridge.py` - shared transcript/context bridge with inbound queue, command replies, and freeform chat replies
- `./telegram-bridge-loop.sh` - background launcher for event polling and auto-replying to supported commands and freeform chat
- `./telegram-heartbeat-loop.sh` - background launcher for optional heartbeat automation
- `./telegram-notify-wrap.sh` - wrapper that sends success/error notifications when a command finishes
- `./telegram-step.sh` - helper to log a concise local step and optionally send it to Telegram

## Recommended operating mode

Default to event-driven communication, not constant heartbeat chatter.

- Send Telegram only when something meaningful happens here.
- Pull Telegram updates on a lightweight interval and answer explicit commands plus natural chat.
- Keep incoming Telegram messages visible in the shared transcript and inbox logs.
- Use heartbeats only for rare long-running tasks that would otherwise look stalled.

## Bridge model and limitation

This setup can make Telegram feel synchronized with OWFINANCE work, but it cannot become the exact same live native OpenCode chat session 1:1.

What is possible:

- shared rolling transcript in local runtime storage
- explicit context snapshots pushed from the workspace to Telegram
- Telegram messages pulled into a local inbox queue/log for another local process or agent
- simple local replies to `/status`, `/status dev`, `/status stage`, `/status prod`, `/last`, `/context`, and `/help`
- freeform replies via local Gemini CLI when already available without new secrets, otherwise deterministic replies built from the shared transcript, local snapshot, and local OWFINANCE docs summaries

What is not possible safely here:

- perfect mirroring of hidden model state, live tool context, or the exact native session token-by-token

Closest safe model:

- a shared context bridge backed by transcript files, snapshots, pulled Telegram messages, and local docs summaries

## Required env vars

- `TELEGRAM_BOT_TOKEN` - bot token created with `@BotFather`
- `TELEGRAM_CHAT_ID` - destination chat id for `send` or `test`

Keep both values out of the repo. This workspace already ignores root `.env.local`, so a local-only option is:

```bash
cat > .env.local <<'EOF'
export TELEGRAM_BOT_TOKEN='paste-your-token-here'
export TELEGRAM_CHAT_ID='paste-your-chat-id-here'
EOF

source .env.local
```

You can also export the vars directly in your shell instead of using `.env.local`.

Optional local non-secret bridge config already supported outside the repo:

```bash
~/.config/owfinance-ops/bridge.json
~/.config/owfinance-ops/telegram.json
```

`~/.config/owfinance-ops/telegram.json` can also hold the bot token and chat id locally, outside the repo, for example:

```json
{
  "telegram_bot_token": "set-locally",
  "telegram_chat_id": "set-locally"
}
```

## Exact steps to get the chat_id

1. Create the bot with `@BotFather` and keep the token only in local env vars.
2. In Telegram, open the bot and send `/start`.
3. Run:

```bash
./telegram-notify.sh chat-id
```

4. Copy the correct chat id from the output and store it locally as `TELEGRAM_CHAT_ID`.

Notes:

- A bot cannot start a direct conversation with you first, so `/start` is required before `getUpdates` can see your private chat.
- For a group chat, add the bot to the group and send at least one message or command there before running `chat-id`.

## Test the setup

After `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID` are set:

```bash
./telegram-notify.sh test --title OWFINANCE
```

If you want to validate formatting locally without calling Telegram:

```bash
./telegram-notify.sh send --dry-run --type progress --title Backend "Deploy step started"
```

## Common usage

```bash
./telegram-notify.sh send --type progress --title Backend "Migration step started"
./telegram-notify.sh send --type success --title Frontend "Deploy finished"
./telegram-notify.sh send --type error --title Backend "Health check failed"
./telegram-step.sh --title Backend "Migration step started"
./telegram-step.sh --title Deploy --type success "Deploy finished"
./telegram-step.sh --title Stage --type info --log-only "Need manual stage review"
./telegram-heartbeat.sh --title Worker --interval 120 "Long task still running"
./telegram-heartbeat.sh --title Stage --status stage --interval 300 "Smoke check still running"
./telegram-context-bridge.py init
./telegram-context-bridge.py snapshot --title Context --send "Roadmap review moved to pricing and onboarding"
./telegram-context-bridge.py event --send --type progress --title Backend "Migration batch started"
./telegram-context-bridge.py chat "What is the current OWFINANCE bridge model?"
./telegram-context-bridge.py pull --respond
./telegram-context-bridge.py pull --respond   # mode auto by default
./telegram-bridge-loop.sh start --interval 30
./telegram-bridge-loop.sh start --interval 30 --mode auto
./telegram-bridge-loop.sh start --interval 30 --mode local-context
./telegram-bridge-loop.sh status
./telegram-bridge-loop.sh stop
./telegram-heartbeat-loop.sh start --interval 60 --title Worker --status dev "Long task still running"
./telegram-heartbeat-loop.sh status
./telegram-heartbeat-loop.sh stop
./telegram-notify-wrap.sh --title BackendCheck -- ./ops-status.sh dev
./telegram-notify-wrap.sh --title Deploy --notify-start -- ./deploy-frontend.sh "UI polish"
./telegram-context-bridge.py context --send
./telegram-context-bridge.py last 5
./ops-status.sh dev
./ops-status.sh stage
```

You can also pipe a message body:

```bash
printf 'Long task finished successfully' | ./telegram-notify.sh send --type success --title Worker
```

## Discoverability note

Use these helpers from local scripts, agent workflows, or long-running shell commands whenever you want low-noise Telegram notifications without embedding secrets in repo files.

## Bridge runtime files

Runtime state stays outside the repo under `~/.config/owfinance-ops/context-bridge/`:

- `shared-transcript.jsonl` - rolling OWFINANCE transcript shared across local and Telegram bridge events, including inbound Telegram messages and local step notifications
- `context-snapshot.txt` - latest explicit shared context snapshot
- `telegram-inbox.jsonl` - append-only local queue/log of pulled Telegram messages
- `telegram-updates.jsonl` - normalized update log from Telegram pulls
- `state.json` - bridge offsets so pulls do not repeat old updates

Another local process or agent can consume `telegram-inbox.jsonl` while this bridge keeps Telegram polling and command replies simple.

## Automation runtime files

Background automation stores local state outside the repo under `~/.config/owfinance-ops/automation/`:

- `run/telegram-bridge-loop.pid` - active pid for the polling/respond loop
- `logs/telegram-bridge-loop.log` - polling/respond loop log
- `run/telegram-heartbeat-loop.pid` - active pid for the recurring heartbeat loop
- `logs/telegram-heartbeat-loop.log` - recurring heartbeat log

## Exact start/stop commands

1. Start Telegram polling with command replies plus natural chat every 30 seconds:

```bash
./telegram-bridge-loop.sh start --interval 30
```

Optional explicit modes:

```bash
./telegram-bridge-loop.sh start --interval 30 --mode auto
./telegram-bridge-loop.sh start --interval 30 --mode gemini-cli
./telegram-bridge-loop.sh start --interval 30 --mode local-context
```

2. Stop it:

```bash
./telegram-bridge-loop.sh stop
```

3. Start a heartbeat every minute only when you really need it:

```bash
./telegram-heartbeat-loop.sh start --interval 60 --title Worker --status dev "Task still running"
```

4. Stop it:

```bash
./telegram-heartbeat-loop.sh stop
```

5. Wrap a command so Telegram gets completion status automatically:

```bash
./telegram-notify-wrap.sh --title OpsCheck -- ./ops-status.sh dev
```

## Telegram bridge commands and chat mode

The bridge responds when you run `./telegram-context-bridge.py pull --respond`:

- `/status [dev|stage|prod]`
- `/last [n]`
- `/context`
- `/help`
- any non-command message as freeform chat

Supported command preservation is exact:

- `/status`
- `/status dev`
- `/status stage`
- `/status prod`
- `/help`
- `/last`
- `/context`

Examples:

- `/status`
- `/status dev`
- `/status stage`
- `/status prod`
- `/last`
- `/context`
- `/help`
- `Que sabemos del entorno dev hoy?`
- `Resume el contexto compartido actual`
- `How does the bridge work?`

Freeform replies come from local files and scripts, not from a full remote AI chat session. In `auto` mode the bridge tries this order:

- local Gemini CLI already available on this machine, if it runs without new secrets
- deterministic local-context responder

The responder uses:

- `~/.config/owfinance-ops/context-bridge/shared-transcript.jsonl`
- `~/.config/owfinance-ops/context-bridge/context-snapshot.txt`
- local workspace summaries such as `PROJECT_CONTEXT.md`, `README.md`, `docs/ARQUITECTURA_PROYECTO.md`, `docs/CONSULTAS_OPERATIVAS.md`, `docs/01-configuracion/SAAS_ROLE_SYSTEM.md`, and this Telegram doc

This is intentionally honest: it is a parallel chat with shared context, not the exact same native OpenCode session.

## Local response behavior

- Each inbound Telegram message gets one immediate short ack in Spanish before the final reply is generated.
- Command messages are parsed and answered deterministically with the existing command set unchanged.
- Non-command messages are logged into the shared transcript and inbox.
- In `auto`, a local Gemini CLI prompt gets the shared snapshot, recent transcript, and matching doc excerpts.
- If Gemini CLI is unavailable or fails, a deterministic local responder builds a useful answer from snapshot text, recent transcript lines, and matching local doc excerpts.
- If a message asks about status or environment health, the responder also includes `./ops-status.sh` output when practical.
- The local docs are treated as summaries under the Drive-first documentation model, where the canonical shared source of truth remains the OWFINANCE Drive hub.

## Stage/prod status notes

- `./ops-status.sh dev` reuses `./status.sh` and adds HTTP probes for `http://localhost:3000` and `http://localhost:8000/up`.
- `./ops-status.sh stage` prefers `OWF_STAGE_FRONTEND_URL`, `OWF_STAGE_API_BASE_URL`, and `OWF_STAGE_HEALTH_URL`.
- If those vars are unset, `./ops-status.sh stage` falls back to local `.env.staging` files when they contain real URLs.
- `./ops-status.sh prod` uses the known active production frontend `https://appfinanzas.blockshift.website/app/` and backend health endpoint `https://appfinanzas.blockshift.website/up`.

## Exact next user action

Open the bot in Telegram and send `/start`, then run:

```bash
./telegram-notify.sh chat-id
```

Store the returned id only in a local env export such as `.env.local` or your shell profile.
