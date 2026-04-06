# Stitch Integration — Central Resource Index

**Última actualización**: 2026-04-05
**Status**: Complete pipeline designed, ready for pilot implementation

---

## Overview

OWFINANCE2026 now has a **complete, reusable pipeline for integrating Stitch-generated UI components into Vue 3** with full data binding, API integration, and testing protocols.

This document serves as the **central navigation hub** for all Stitch-related resources.

---

## Core Documents (READ THESE FIRST)

### 1. Quick Start Guide (5-minute read)
📄 **File**: `/docs/STITCH_QUICK_START.md`
**For**: Developers who need to implement a view **right now**
**Contains**:
- 5-step pipeline overview
- Minimal copy-paste templates (prompts + Vue components)
- Common issues & fixes
- Key commands
- When to ask for help

**Start here if**: You have a view specification and need to implement it quickly.

---

### 2. Complete Integration Pipeline (Reference)
📄 **File**: `/OWFinanceFrontend2025/docs/STITCH_INTEGRATION_PIPELINE.md`
**For**: Architects, technical leads, comprehensive understanding
**Contains** (2,000+ lines):
- Full 5-phase pipeline with ASCII diagrams
- Reusable prompt template (4 precompiled blocks)
- Vue component implementation checklist (500+ lines)
- Complete working example: Dashboard component
- 4 data binding patterns (mocks → real API)
- Decision matrix: what Stitch can/cannot do
- 7 gotchas & anti-patterns with solutions
- Testing checklist
- FAQ & troubleshooting
- Metrics & success criteria

**Start here if**: You want deep understanding of the pipeline architecture.

---

### 3. Architectural Decisions (Decision Log)
📄 **File**: `/.claude/STITCH_DECISIONS.md`
**For**: Team leads, architects, future decision-makers
**Contains**:
- 10 key architectural decisions
- Rationale for each (why this approach?)
- Tradeoffs & constraints
- When to use/not use
- Known gotchas
- Success metrics

**Start here if**: You want to understand WHY the pipeline is designed this way.

---

## Quick Links

| Need | Resource | Time |
|------|----------|------|
| Implement a view now | `/docs/STITCH_QUICK_START.md` | 5 min read + 90 min code |
| Understand the full pipeline | `/docs/STITCH_INTEGRATION_PIPELINE.md` | 20 min read |
| Understand decisions/rationale | `/.claude/STITCH_DECISIONS.md` | 10 min read |
| Prompt templates | `/docs/STITCH_INTEGRATION_PIPELINE.md` section 2 | Copy-paste |
| Vue component template | `/docs/STITCH_QUICK_START.md` section "Templates" | Copy-paste |
| Example component | `/docs/STITCH_INTEGRATION_PIPELINE.md` section 3.6 | 200+ lines |
| Troubleshoot issue | `/docs/STITCH_QUICK_START.md` or `/docs/STITCH_INTEGRATION_PIPELINE.md` section 10 | 5 min |

---

## Pipeline at a Glance

```
5-Phase Pipeline: 1.5-2 hours per view

Phase 1: DESIGN (30 min)
  → Specification document

Phase 2: STITCH (10 min)
  → HTML + CSS output

Phase 3: VUE IMPLEMENTATION (60-90 min)
  → Components with data binding

Phase 4: TESTING (30 min)
  → Responsive, A11y, binding, auth

Phase 5: DEPLOY (automatic)
  → GitHub Actions → LiteSpeed
```

---

## Key Patterns

### Reusable Prompt Template
**Location**: `/docs/STITCH_INTEGRATION_PIPELINE.md` section 2

4 blocks (precompiled, reuse in all views):
1. `[CONTEXTO_APP]` — OWFINANCE context (entities, API endpoints)
2. `[DISEÑO_SISTEMA]` — Design tokens (colors, typography, components)
3. `[VISTA_A_GENERAR]` — Variable per view (layout, data points, interactions)
4. `[INSTRUCCIONES]` — Stitch instructions (HTML/CSS requirements, validation)

**Benefit**: Copy-paste + fill variable. No context re-documentation.

### Vue Component Structure
**Location**: `/docs/STITCH_QUICK_START.md` or `/docs/STITCH_INTEGRATION_PIPELINE.md` section 3.1

Standard structure:
```
<template>    <!-- Stitch HTML -->
<script setup> <!-- Imports, types, state, methods -->
<style scoped> <!-- Stitch CSS -->
```

### Data Binding Modes
**Location**: `/docs/STITCH_INTEGRATION_PIPELINE.md` section 4

- **Mock Mode**: Hardcoded data, no API (development)
- **Real API Mode**: Fetch from `/api/v1/*` with Sanctum auth (production)
- **Hybrid**: Mock by default, API with feature flag

Switch via: `VITE_USE_MOCKS=true|false`

---

## File Structure

```
OWFINANCE2026/
├── docs/
│   ├── STITCH_QUICK_START.md              ← START HERE (developers)
│   ├── STITCH_INTEGRATION_PIPELINE.md     ← Reference (architects)
│   └── STITCH_RESOURCES.md                ← This file
│
├── .claude/
│   ├── STITCH_DECISIONS.md                ← Rationale (decision log)
│   └── stitch-prompts/ (future)
│       ├── dashboard-home.md
│       ├── transactions-list.md
│       └── ...
│
├── OWFinanceFrontend2025/
│   └── src/
│       ├── components/
│       │   └── views/
│       │       ├── LiteHomeView.vue       ← Example (Stitch-generated)
│       │       ├── LiteTransactionsView.vue
│       │       └── ...
│       │
│       ├── pages/user/
│       │   └── DynamicHomePage.vue        ← Router dispatcher
│       │
│       ├── css/
│       │   └── tokens.css                 ← Design tokens
│       │
│       └── boot/
│           └── axios.ts                   ← API config + Sanctum
```

---

## Component Naming Convention

| Pattern | Example | Usage |
|---------|---------|-------|
| `Lite*View.vue` | `LiteHomeView.vue` | Lite layout (simplified, mobile-first) |
| `Pro*View.vue` | `ProDashboardView.vue` | Pro layout (advanced analytics) — future |
| `Legacy*View.vue` | `LegacyTransactionsPage.vue` | Legacy layout (existing system) |

**Location**: `src/components/views/`
**Router**: `src/pages/user/DynamicHomePage.vue` selects based on `auth.user.layout_mode`

---

## Decision Matrix: What Stitch Generates

### Stitch GENERATES (90-95%)
✅ HTML structure (semantic, valid)
✅ CSS responsive (mobile-first, 320/768/1024px breakpoints)
✅ Glassmorphism styling
✅ ARIA labels/roles (basic accessibility)
✅ CSS animations (smooth transitions)

### Stitch DOES NOT GENERATE (Programmer adds)
❌ Data binding (`v-bind`, `{{ }}`)
❌ Event handlers (`@click`, `@submit`)
❌ Loops (`v-for`)
❌ Conditionals (`v-if`, `v-show`)
❌ API calls (`fetch`, `axios`)
❌ State management (`ref`, `reactive`, `computed`)
❌ Form validation (`Vee-Validate`, custom)
❌ Component composition (nesting, slots)

**Implication**: Accept ~95% HTML from Stitch, add ~5% Vue logic.

---

## Common Gotchas (with Solutions)

| Problem | Solution |
|---------|----------|
| **CSS has unused styles** | Review & delete post-Stitch |
| **Breakpoints misaligned** | Edit media queries (320, 768, 1024) |
| **Colors generic, not tokens** | Find/replace hex or use SCSS variables |
| **No Quasar components** | Normal; convert HTML → q-* manually (5-10% effort) |
| **API endpoint changed** | TypeScript catches it; update endpoint |
| **Token expires, crashes** | Always check `if (!auth.token)` before API call |
| **Data undefined in template** | Use optional chaining: `{{ data?.field \|\| '—' }}` |

**Reference**: `/docs/STITCH_INTEGRATION_PIPELINE.md` section 6

---

## Testing Checklist

Before merging:

**Programmer checks**:
- [ ] Responsive: 320px, 768px, 1024px
- [ ] Loading state (spinner visible)
- [ ] Error state (message visible)
- [ ] Empty state ("No data" message)
- [ ] Auth: token validated before API
- [ ] TypeScript: no `any` types
- [ ] CSS: variables used, no hardcoded colors
- [ ] No console.logs or debugger statements

**QA checks**:
- [ ] Accessibility: WCAG AA (4.5:1 contrast, 44x44px buttons)
- [ ] Data binding: values correct, formatting OK
- [ ] API: endpoints correct, payload validated
- [ ] Error scenarios: 401, 403, 500, network timeout
- [ ] User flow: natural, no confusion

**CI/CD**:
- [ ] Build passes
- [ ] Tests pass (if configured)
- [ ] Linting passes

**Reference**: `/docs/STITCH_INTEGRATION_PIPELINE.md` section 9

---

## Success Metrics

**Target**: < 2 hours per view (fully implemented)

Breakdown:
- Stitch generation: 10 minutes
- Vue implementation: 60-90 minutes
- Testing & QA: 30 minutes
- PR review: < 30 minutes

**If taking longer**: Likely causes:
- Prompt too vague → be more specific
- API changed → document new endpoint
- Scope creep → split into smaller views

**Reference**: `/.claude/STITCH_DECISIONS.md` section 10

---

## Next Steps (for the Team)

### Week 1-2: Pilot
- [ ] Choose small view (Settings or About)
- [ ] Implement using full pipeline
- [ ] Gather feedback

### Week 2-3: Validation
- [ ] Is process smooth?
- [ ] Is time reasonable?
- [ ] Is code maintainable?
- [ ] Is Stitch output predictable?

### Week 3-4: Iteration
- [ ] Refine prompt template
- [ ] Document new gotchas
- [ ] Update guides
- [ ] Train team

### Week 4+: Scale
- [ ] Apply to all new views
- [ ] Maintain docs (bi-weekly review)
- [ ] Monitor metrics

**Reference**: `/docs/STITCH_INTEGRATION_PIPELINE.md` section 11

---

## Commands Reference

```bash
# Development
npm run dev              # Start local server (http://localhost:5173)

# Type checking
npm run type-check      # TypeScript validation

# Linting
npm run lint            # ESLint + Prettier

# Build & Deploy
npm run build           # Production build
# Deploy: Automatic via GitHub Actions

# Testing (if configured)
npm run test:unit       # Unit tests
npm run test:e2e        # E2E tests
```

---

## Support & Questions

| Question | Resource | Time |
|----------|----------|------|
| "How do I use the templates?" | `/docs/STITCH_QUICK_START.md` section "Templates Copy-Paste" | 5 min |
| "Stitch generated unexpected HTML" | `/docs/STITCH_INTEGRATION_PIPELINE.md` section 6 | 10 min |
| "How do I implement Vue binding?" | `/docs/STITCH_INTEGRATION_PIPELINE.md` section 3 | 15 min |
| "Why this approach?" | `/.claude/STITCH_DECISIONS.md` | 10 min |
| "What's the full flow?" | `/docs/STITCH_INTEGRATION_PIPELINE.md` section 1 | 10 min |
| "Quick troubleshoot" | `/docs/STITCH_QUICK_START.md` section "Common Issues" | 5 min |

---

## Commits

Created during this design phase:

**Frontend (dev branch)**:
```
67b2fe4 docs(stitch): add complete Stitch integration pipeline and documentation
```

**Main repo (master branch)**:
```
a9ee789 docs(stitch): add quick-start guide and architectural decisions
```

---

## Document Maintenance

| Cadence | Action |
|---------|--------|
| **Weekly** | Team standups: Quick feedback on pilot |
| **Bi-weekly** | Review gotchas & learnings; update docs |
| **Monthly** | Metrics review: time per view, bug rate, satisfaction |
| **Quarterly** | Full pipeline audit; propose improvements |

---

## Key Contacts

- **Architecture**: Review `/.claude/STITCH_DECISIONS.md`
- **Implementation**: Review `/docs/STITCH_QUICK_START.md`
- **Reference**: Review `/docs/STITCH_INTEGRATION_PIPELINE.md`
- **Feedback**: Open GitHub issue or discuss in standup

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-04-05 | Initial design: Complete 5-phase pipeline with templates, Vue patterns, decisions |

---

**Last Updated**: 2026-04-05
**Status**: Ready for pilot implementation
**Next Review**: 2026-04-19 (bi-weekly)
