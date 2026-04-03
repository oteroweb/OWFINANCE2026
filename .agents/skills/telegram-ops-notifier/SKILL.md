---
name: telegram-ops-notifier
description: Send OWFINANCE low-noise progress updates to Telegram and run lightweight dev/stage/prod ops checks without storing secrets in repo files.
version: 1.0.0
tags: [owfinance, telegram, ops, notifier, status]
---

# Telegram Ops Notifier

Use this skill when the user wants live progress notifications, explicit step updates, optional recurring heartbeats, failure/completion alerts, or quick operational status checks for OWFINANCE environments.

## When to use
- Long-running local tasks, builds, migrations, deploy-adjacent checks, or manual ops work need Telegram progress updates.
- You want concise event notifications when steps happen locally.
- You want a heartbeat during a task that may run for minutes or hours, but only as an exception.
- You need a fast dev or stage status check from the workspace root.
- You need a reusable, secrets-safe way to notify a private chat or group from local scripts.

## Recommended operating mode
- Prefer event-driven updates over heartbeat loops.
- Use `./telegram-step.sh` or `./telegram-context-bridge.py event --send` for meaningful local actions.
- For conversational Telegram use, run `./telegram-bridge-loop.sh start --interval 30 --mode auto` so freeform chat uses the bridge responder automatically.
- Keep heartbeat scripts available for rare silent tasks, not as the default pattern.

## Required env vars
- `TELEGRAM_BOT_TOKEN` - bot token from `@BotFather`
- `TELEGRAM_CHAT_ID` - destination chat id for send/test/heartbeat

Keep both values only in local shell exports or ignored local env files such as `.env.local`. Never store them in tracked repo files, docs, commits, or command history snippets shared back to the user.

## Workspace commands
- Send one message: `./telegram-notify.sh send --type progress --title Backend "Migration started"`
- Send one concise step event: `./telegram-step.sh --title Backend "Migration started"`
- Send one concise success event: `./telegram-step.sh --title Deploy --type success "Frontend deploy finished"`
- Send a heartbeat message: `./telegram-notify.sh send --type heartbeat --title Deploy "Still running"`
- Send a completion message: `./telegram-notify.sh send --type success --title Frontend "Deploy finished"`
- Send a failure message: `./telegram-notify.sh send --type error --title Backend "Health check failed"`
- Dry run formatting only: `./telegram-notify.sh send --dry-run --type heartbeat --title Worker "Still running"`
- Test bot/chat config: `./telegram-notify.sh test --title OWFINANCE`
- Discover chat ids: `./telegram-notify.sh chat-id`
- Run recurring heartbeats: `./telegram-heartbeat.sh --title Import --interval 120 --count 10 "Import still running"`
- Heartbeat with status snapshot: `./telegram-heartbeat.sh --title Stage --interval 300 --status stage "Stage smoke check still running"`
- Quick dev ops status: `./ops-status.sh dev`
- Quick stage ops status: `./ops-status.sh stage`
- One-line status for piping: `./ops-status.sh --one-line dev`

## Ops status behavior
- `dev` reuses `./status.sh` and adds lightweight HTTP checks for `http://localhost:3000` and `http://localhost:8000/up`.
- `stage` reads stage URLs from env vars first, then from local env files when available.
- Preferred stage overrides: `OWF_STAGE_API_BASE_URL`, `OWF_STAGE_FRONTEND_URL`, `OWF_STAGE_HEALTH_URL`.
- If stage values still point to placeholders such as `tudominio.com`, treat them as unset and ask for real values instead of pretending checks are valid.

## Exact chat_id flow
1. Create the bot with `@BotFather`.
2. Export `TELEGRAM_BOT_TOKEN` locally.
3. In Telegram, open the bot and send `/start`.
4. Run `./telegram-notify.sh chat-id` from the workspace root.
5. Copy the correct chat id into a local-only export for `TELEGRAM_CHAT_ID`.

The exact next user action is usually: open the bot in Telegram and send `/start` before trying `chat-id`.

## Safety rules
- Never print or hardcode `TELEGRAM_BOT_TOKEN` in tracked files.
- Never commit `.env.local` or other secret-bearing local env files.
- Use `--dry-run` first if you only need payload verification.
- Prefer concise messages that avoid credentials, personal data, or raw production payloads.
- Treat status checks as read-only; do not turn this skill into a deploy or mutation workflow unless the user explicitly asks.
- For stage/prod-style checks, prefer health endpoints or lightweight GET/HEAD requests over authenticated actions.

## Notes
- A private Telegram chat is not visible to the bot until the user sends `/start`.
- For a group chat, add the bot to the group and send at least one message before running `chat-id`.
- This skill is intentionally shell-first and easy to extend with more environment-specific checks later.
