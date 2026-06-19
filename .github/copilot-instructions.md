# Copilot Instructions — OWFINANCE2026

## Session Start

Before helping with any task, read these files to understand current project state:

1. `.owf/STATE.md` — Active work, blockers, what's next
2. `.owf/TASKS.md` — Unified task board (all tasks use OWF-NNN IDs)
3. `.owf/CONTEXT.md` — Architecture decisions, critical files, known gotchas

## Key Facts

- Backend: Laravel 12 + Sanctum, API prefix `/api/v1`
- Frontend: Quasar 2 + Vue 3 + TypeScript, `publicPath: '/app/'`
- 3 environments: dev, stage, prod (see `.deploy/`)
- All tasks referenced by OWF-NNN. Legacy IDs (DS-*, TECH-*) mapped in STATE.md
- The task board is `.owf/TASKS.md`. Do not create parallel task lists.
