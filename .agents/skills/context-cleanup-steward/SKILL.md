---
name: context-cleanup-steward
description: Final release gate that consolidates, archives, and de-drifts OWFINANCE repo docs against code, Notion, Drive, and route reality.
version: 1.0.0
tags: [docs, cleanup, context, release-gate, notion, drive, stitch]
---

# Context Cleanup Steward

Use this skill at the end of a stable delivery, never as a substitute for implementation.

## Mission

Detect and reduce drift between:
- repo docs;
- real code and routes;
- Notion ticket metadata;
- Drive canonical context;
- Stitch references used by UI work.

## When to run

- After a deploy has been validated.
- After a stable batch of tickets is closed.
- When the workspace has accumulated duplicate or conflicting docs.

## Core rules

- Archive before deleting.
- Do not invent source-of-truth ownership.
- Do not rewrite strategy docs that belong in Drive unless explicitly requested.
- Treat `/lite` and `/pro` as historical or future-context references unless current code proves otherwise.
- If Git hygiene is not clean, report it before recommending repo cleanup.

## Required outputs

1. Documents to consolidate.
2. Documents to archive.
3. Documents that remain active and why.
4. Notion tickets or updates needed.
5. Risks of deleting too early.

## Workflow

1. Check current routes, runtime docs, and active workflow docs.
2. Compare duplicates and outdated references.
3. Identify the active authority for each topic.
4. Propose archive moves first.
5. Update indexes and status labels.
6. Create or update Notion cleanup tickets when drift cannot be resolved immediately.
