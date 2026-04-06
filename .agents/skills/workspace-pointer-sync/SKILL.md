---
name: workspace-pointer-sync
description: Standard OWFINANCE workflow for pushing backend/frontend repos and then syncing the central workspace pointers safely.
version: 1.0.0
tags: [git, submodules, workspace, sync, release, devops]
---

# Workspace Pointer Sync

Use this skill whenever work changes `OWFINANCEBackend2025` or `OWFinanceFrontend2025` and the central repo `OWFINANCE2026` must stay aligned.

## Mission

Prevent drift between:
- subrepo commits already pushed to GitHub;
- the commit pointers recorded in the central workspace repo;
- the branch policy defined in `.gitmodules`.

## Use when

- A backend change was committed or pushed.
- A frontend change was committed or pushed.
- Both repos advanced and the root repo must record the new official workspace state.
- A repo was left in detached HEAD and needs normalization before more work.

## Core rules

- Read the target branch from `.gitmodules`; do not guess.
- Do not run root pointer sync if the root has unrelated local changes.
- Normalize detached HEAD before pull or push.
- Prefer `pull --ff-only` over implicit merge pulls.
- Commit the root pointer update separately so the workspace history stays readable.

## Operational commands

Diagnose pointer drift:
```bash
./sync-submodule-pointers.sh --report
```

Record pointer drift in the root repo:
```bash
./sync-submodule-pointers.sh --commit
```

Push a subrepo and sync the root in one pass:
```bash
./push-workspace.sh backend "feat(api): mensaje"
./push-workspace.sh frontend "fix(ui): mensaje"
./push-workspace.sh both "chore: mensaje coordinado"
```

Push the root after syncing:
```bash
./push-workspace.sh frontend "fix(ui): mensaje" --push-root
```

## Workflow

1. Detect the affected repo: backend, frontend, or both.
2. Normalize the repo to the branch declared in `.gitmodules`.
3. Commit and push the changed subrepo if needed.
4. Run root pointer sync.
5. Push the root only when the workspace pointer must become the shared official state immediately.

## Required output from the agent

1. Which subrepo(s) were normalized.
2. Which branch(es) were used.
3. Whether the root pointer changed.
4. Whether the root was committed and/or pushed.
5. Any blocked state such as dirty working tree or detached HEAD not contained by the target branch.
