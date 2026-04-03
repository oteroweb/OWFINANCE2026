---
name: telegram-context-bridge
description: Bridge OWFINANCE context to Telegram with a shared local transcript, inbound queue, low-noise event logging, freeform chat replies, and operational command replies.
version: 1.0.0
tags: [owfinance, telegram, bridge, context, transcript]
---

# Telegram Context Bridge

Use this skill when the user wants Telegram to act as a low-noise parallel OWFINANCE interface without pretending it is the exact same native agent chat.

## What this bridge does
- Keeps a shared rolling transcript in local runtime storage under `~/.config/owfinance-ops/context-bridge/`.
- Stores a current context snapshot text file that can be refreshed from this workspace.
- Sends summaries, explicit step events, updates, or context snapshots from the workspace to Telegram.
- Pulls Telegram updates into a local append-only inbox log so another local process or agent can consume them.
- Logs inbound Telegram messages and commands into the shared transcript as clear conversation events.
- Responds to `/status`, `/status dev`, `/status stage`, `/status prod`, `/last`, `/context`, and `/help` when the local bridge is run with `pull --respond`.
- Replies to non-command Telegram messages using local Gemini CLI when already available without new secrets, otherwise the shared transcript, local snapshot, and local OWFINANCE docs summaries.

## What this bridge does not do
- It does not become the exact same OpenCode or local CLI chat session.
- It does not mirror hidden model state, tool state, or every live token of the native chat 1:1.
- The safe practical model is a shared context bridge: rolling transcript + explicit snapshots + pulled messages + local replies.
- The recommended mode is event-driven communication; recurring heartbeat traffic is optional, not the default.

## Required local setup
- `TELEGRAM_BOT_TOKEN` in the shell environment.
- `TELEGRAM_CHAT_ID` in the shell environment, or `~/.config/owfinance-ops/telegram.json` with `telegram_chat_id`.
- Keep secrets out of tracked repo files.

## Core commands
- Initialize runtime: `./telegram-context-bridge.py init`
- Save a local snapshot: `./telegram-context-bridge.py snapshot --title Context "Current planning summary"`
- Save and send a snapshot: `./telegram-context-bridge.py snapshot --title Context --send "Current planning summary"`
- Send a quick update: `./telegram-context-bridge.py send --type progress --title Worker "Backend batch started"`
- Log or send a local event: `./telegram-context-bridge.py event --send --type success --title Backend "Migration finished"`
- Simulate freeform chat locally: `./telegram-context-bridge.py chat "What changed in the shared context?"`
- Pull Telegram updates into the local queue: `./telegram-context-bridge.py pull`
- Pull and reply to supported commands and freeform chat: `./telegram-context-bridge.py pull --respond`
- Run the automatic loop in preferred mode: `./telegram-bridge-loop.sh start --interval 30 --mode auto`
- Force deterministic fallback mode: `./telegram-bridge-loop.sh start --interval 30 --mode local-context`
- Send local status summary: `./telegram-context-bridge.py status --send dev`
- Send latest shared context: `./telegram-context-bridge.py context --send`

## Runtime files
- Config: `~/.config/owfinance-ops/bridge.json`
- Shared transcript: `~/.config/owfinance-ops/context-bridge/shared-transcript.jsonl`
- Telegram inbox queue: `~/.config/owfinance-ops/context-bridge/telegram-inbox.jsonl`
- Raw pulled update log: `~/.config/owfinance-ops/context-bridge/telegram-updates.jsonl`
- Shared context snapshot: `~/.config/owfinance-ops/context-bridge/context-snapshot.txt`
- Bridge state: `~/.config/owfinance-ops/context-bridge/state.json`

## Telegram commands handled locally
- `/status [dev|stage|prod]`
- `/last [n]`
- `/context`
- `/help`

## Freeform chat behavior
- Non-command Telegram messages are logged into `telegram-inbox.jsonl` and `shared-transcript.jsonl`.
- In `auto`, replies try local Gemini CLI first and fall back automatically if needed.
- Replies are always framed as a parallel OWFINANCE bridge chat, not the exact same native OpenCode session.
- Context sources include the shared transcript, the local snapshot, and concise local docs aligned to the Drive-first documentation model.

Run `./telegram-context-bridge.py pull --respond` from the workspace root to process them.

## Safety rules
- Never commit bot tokens or secret env files.
- Keep runtime state in `~/.config/owfinance-ops`, not inside the repo.
- Be explicit that synchronization is approximate and transcript-based, not identical native session mirroring.
