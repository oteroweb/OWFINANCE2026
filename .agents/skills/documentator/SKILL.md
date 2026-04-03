---
name: documentator
description: Treat the Drive folder `OWFINANCE` as the canonical documentation hub/source of truth, preserve role ownership, and keep local summaries lean.
version: 1.1.1
tags: [owfinance, docs, drive, planning, context]
---

# Documentator

Use this skill when the user needs to discover, read, summarize, create, or update OWFINANCE2026 documentation, especially strategy, roles, planning, or operating context.

## When to use
- Find the latest strategy, role, planning, roadmap, or context docs.
- Extract decisions or role context from Drive docs into concise working notes.
- Create or update planning docs in the canonical Drive documentation axis.
- Cross-link Drive planning outputs with Notion backlog, tasks, or local repo docs when needed.

## Core rules
- Treat the Drive folder `OWFINANCE` (`https://drive.google.com/drive/folders/1tjxzCrWceyWPXydOL374FytD0ExM_Jkh`) as the canonical documentation axis and source of truth.
- Visible top-level folders: `01_GERENCIA_ESTRATEGIA`, `02_PRODUCTO_Y_TECNOLOGIA`, `03_MARKETING_Y_CONTENIDO`, `04_OPERACIONES_Y_CLIENTE`, `05_FINANZAS_Y_RIESGO`, `06_AI_CONTEXT`, `Manual de Cultura y Metas`.
- Every OWF role owns its canonical docs, playbooks, and decision logs in its assigned hub folder; `documentator` helps structure, discover, and sync them.
- Prefer docs inside the Drive folder itself as the source of truth for strategy, roles, planning, and shared context.
- Sync summaries back to local docs only when the repo needs a durable working note, registry reference, or agent instruction.
- Keep local copies concise; do not duplicate full Drive or workspace setup docs.
- Use verified folder or file identifiers only when already confirmed in current context; otherwise refer to the folder by name.

## Inputs
- User goal or question.
- Known doc names, Drive links, folder hints, role names, project names, or planning topics.
- Optional Notion destination for backlog/task follow-up.

## Outputs
- Concise documentation summary, source list, role/context extraction, planning brief, or update plan.
- Drive-first recommendations for where a doc should live.
- Cross-links or follow-up actions for Notion/tasks when relevant.

## Workflow
1. Start from the Drive folder `OWFINANCE` itself and locate the most relevant docs by title, recency, role owner, and planning relevance.
2. Read only the needed sources and extract decisions, responsibilities, timelines, dependencies, and open questions.
3. State which Drive docs appear authoritative and note any conflicts or stale local summaries.
4. If creating or updating planning material, keep the canonical version in the role-owned Drive folder first, then add only minimal local references or summaries when the workspace needs them.
5. When work should continue in Notion, cross-link the Drive artifact with backlog, sprint, or task entries rather than duplicating the content.

## Planning guidance
- For roadmap, sprint, role, and operating docs, create or update the canonical Drive document in `OWFINANCE` first.
- Add a short local summary only if agents need stable repo context.
- When tasks follow from the doc, reference the Drive source in Notion or task systems so execution points back to the canonical plan.

## Safety and limitations
- Do not expose OAuth tokens, cookies, raw auth payloads, or other secrets.
- Do not invent Drive ids, ownership, or permissions.
- Avoid destructive document changes unless clearly requested.
- If Drive access or identifiers are unverified, keep wording generic and report the uncertainty.
- Avoid copying large doc bodies into local files when a short summary or link note is enough.
