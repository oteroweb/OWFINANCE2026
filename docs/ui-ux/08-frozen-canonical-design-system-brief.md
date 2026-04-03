# OWFINANCE2026 Frozen Canonical Design System Brief

Status: Frozen baseline for Task Group 2 migration work.

This brief converts the approved Task Group 1 rules into the canonical implementation baseline for migrated OWFINANCE2026 screens. When any older document conflicts with this brief, this brief wins.

## 1. Authority and Override Order

1. This document is the frozen implementation brief for migration decisions.
2. `docs/ui-ux/03-unified-design-rules.md` remains the primary design intent source and is the highest-priority legacy reference when older docs disagree.
3. `Liquid Glass Unified` may remain the starting Stitch aesthetic, but Stitch output is only a draft baseline. Any mismatch is overridden by the canonical rules in this brief.
4. Older prompt, palette, or typography instructions in `docs/ui-ux/00-master-design-system-raw.md`, `docs/ui-ux/06-version-matrix-differences.md`, and `docs/ui-ux/07-master-prompt-generator.md` are subordinate to this brief.

## 2. Canonical Design Principles

- Light mode is the default migration baseline unless a screen explicitly requires dark mode.
- Mobile-first validation is mandatory, starting at 375px width before larger breakpoints.
- Lite and Pro share one design system, one visual identity, and one component language.
- Lite and Pro differ by density, information load, control exposure, and layout posture, not by brand, palette, or component family.
- Money is the dominant information type: balances, totals, remaining amounts, and jar status always outrank supporting metadata.
- Interfaces must feel premium, calm, and financially trustworthy, never playful, cluttered, or emoji-driven.

## 3. Frozen Tokens

### 3.1 Color Roles

Use semantic roles, not hardcoded ad hoc color choices.

| Role | Token | Hex | Usage |
| --- | --- | --- | --- |
| App background | `bg-app` | `#F8FAFC` | Default page canvas |
| Primary surface | `surface-card` | `#FFFFFF` | Elevated cards, sheets, modals |
| Secondary surface | `surface-soft` | `#F1F5F9` | Inline groups, filter bars, subdued containers |
| Glass accent surface | `surface-glass` | `rgba(255,255,255,0.72)` | Limited overlays, sticky nav, premium highlights |
| Brand primary | `brand-primary` | `#1E3A8A` | Primary CTA, selected nav, key emphasis |
| Brand interactive hover | `brand-primary-hover` | `#1D4ED8` | Hover, pressed, active elevation states |
| Brand soft fill | `brand-soft` | `#DBEAFE` | Selected chips, info pills, chart highlights |
| Text primary | `text-strong` | `#0F172A` | Headings, money, labels |
| Text secondary | `text-muted` | `#64748B` | Helper copy, metadata |
| Divider/border soft | `border-soft` | `#E2E8F0` | Subtle separators only |
| Success | `state-success` | `#10B981` | Income, healthy jars, completed states |
| Danger | `state-danger` | `#EF4444` | Overspend, destructive actions, errors |
| Warning | `state-warning` | `#F59E0B` | Attention states, pending review |
| Info | `state-info` | `#0EA5E9` | Neutral informational feedback |

Color decisions locked for migration:

- The canonical primary brand is deep navy `#1E3A8A`, not cyan-first.
- Cyan may appear as supporting info accent only, not as the main CTA baseline.
- Purple is not part of the core baseline. If reused for AI or voice entry, it must remain secondary and must never overpower primary finance actions.
- White cards on `#F8FAFC` are the default financial reading environment.

### 3.2 Typography Stack

- Primary family: `Satoshi`.
- Fallback family: `DM Sans`.
- System fallback: `ui-sans-serif, system-ui, sans-serif`.
- Do not use `Manrope` or `Inter` as the canonical baseline for migrated screens.

Typography rules:

- Money amounts use the display tier within the same family, semibold or bold.
- Section titles use strong weight and short line length.
- Body copy remains calm and compact, never oversized for decoration.
- Support text uses muted color before smaller size; readability wins over compression.

Recommended hierarchy:

| Level | Suggested size | Weight | Primary use |
| --- | --- | --- | --- |
| Display XL | 32-40px | 600-700 | Main balance, hero amount |
| Display L | 24-32px | 600-700 | Jar totals, section hero KPIs |
| Heading | 18-24px | 600 | Card titles, section headers |
| Body | 14-16px | 400-500 | Labels, lists, form text |
| Meta | 12-14px | 400-500 | Timestamps, helper text, captions |

### 3.3 Shape, Radius, and Elevation

- Lite/mobile large panels and hero cards: 24-32px radius.
- Standard cards and sheets: 24px radius on Lite, 20-24px on Pro.
- Desktop dense utility panels: 16-20px radius.
- Buttons and segmented controls: full pill radius.
- Hard square corners are out of system.

Elevation rules:

- Default elevated card shadow: soft, diffuse, low contrast, approximately `0 10px 30px rgba(15, 23, 42, 0.08)`.
- Hover elevation may increase subtly but must not create heavy floating or gaming-style contrast.
- Glass is subtle and additive, never the main readability layer.
- Borders are soft separators, not dominant framing. Avoid heavy 1px dark outlines.

### 3.4 Spacing Scale

Base spacing scale:

- `4`, `8`, `12`, `16`, `20`, `24`, `32`, `40`.
- Mobile layouts default to `16` horizontal padding unless safe-area collision requires edge-aware reduction.
- Hero cards and bottom sheets may use `20-24` inner padding.
- Dense Pro data regions may compress internal spacing to `12-16` while preserving scan clarity.

Spacing rules:

- Visual hierarchy must come from spacing before adding extra dividers.
- Do not mix cramped data rows with oversized decorative padding in the same surface.
- Safe-area handling is mandatory for mobile bottom navigation, floating actions, and bottom sheets.

## 4. Core Interaction and Motion Rules

- Minimum touch target is 48x48px for primary mobile actions; 44x44px is the absolute lower bound only for constrained secondary controls.
- Use SVG icon libraries only. No native emoji in static UI. User-created jar icons may keep emoji as user content, not as system iconography.
- Mobile primary overlays open as bottom sheets or drawers from below.
- Standard motion duration: 220-300ms. Use transform and opacity, not layout-shifting animation.
- Respect reduced-motion preferences.
- Lite interactions prioritize one obvious next step; Pro interactions may expose adjacent actions when they reduce workflow friction.
- Confirmation, destructive actions, and budget reallocation actions must clearly communicate impact before commit.

## 5. State Design Rules

### 5.1 Empty States

- Must explain what is missing, why it matters, and the next action.
- Must include one primary CTA and at most one secondary CTA.
- Lite empty states use a single short explanation and one dominant action.
- Pro empty states may also mention setup dependencies or alternative data-entry paths.

### 5.2 Loading States

- Use skeletons for cards, tables, jar lists, and KPI regions where layout persistence matters.
- Keep container dimensions stable to avoid jumpy finance totals.
- Buttons in async flows show inline loading and disable duplicate submission.

### 5.3 Error States

- Errors must be local first, global second.
- Inline form errors sit beside the field and explain how to recover.
- Surface-level errors use a concise title, plain-language cause, and one recovery action.
- Destructive red is for real failure or overspend, not generic warnings.

## 6. Same Design System, Different Density

Lite and Pro are not separate brands. They are two density modes inside the same canonical system.

### Lite Rules

- Simpler, mobile-first, reduced controls, progressive disclosure.
- One dominant task per screen or section.
- Show fewer simultaneous metrics and fewer configuration branches.
- Prefer stacked cards, step-by-step flows, bottom sheets, and large touch-safe actions.
- Hide advanced structure until explicitly requested.
- Consolidate account and budget context into digestible summaries.
- Prioritize reassurance, clarity, and low-anxiety reading.

### Pro Rules

- Denser, productivity-first, web-first, more simultaneous context.
- Multiple related tools may coexist if they accelerate expert workflows.
- Prefer split layouts, persistent filters, visible hierarchy, and reduced click depth.
- Keep advanced controls available when their presence supports operational speed.
- Increase information density by reducing whitespace and exposing more context, not by shrinking readability below safe thresholds.
- Prioritize comparison, manipulation, auditability, and cross-reference speed.

### Density Translation Rules

- Same tokens, same components, same states, different content density.
- Lite removes or defers controls; Pro reveals them.
- Lite stacks; Pro may split into columns or panels.
- Lite summarizes; Pro exposes supporting context and tools.
- Lite is validated mobile-first; Pro is validated desktop-first after the same 375px baseline survives.

## 7. Frozen Component-Level Rules

### 7.1 App Shell

- Shared shell language across Lite and Pro: light canvas, elevated white surfaces, premium navy actions, consistent top-level spacing.
- Lite shell is vertical, touch-first, and bottom-nav anchored.
- Pro shell may expand to sidebar plus top utility bar, but the visual system remains identical.
- Sticky elements must preserve content readability and avoid consuming critical viewport height.

### 7.2 Top Navigation, Bottom Navigation, and Global Navigation

- Lite mobile default: floating bottom navigation with 4 primary destinations and one central action pattern if required by the flow.
- Lite does not use a persistent sidebar.
- Pro mobile may still use bottom navigation; Pro desktop may use a sidebar with richer labels and secondary tools.
- Global navigation highlights current section with brand primary fill or brand-soft background, never with arbitrary color swaps.
- Navigation labels remain visible where ambiguity would hurt scan speed.

### 7.3 Cards

- Cards are the primary content container across dashboards, settings blocks, summary widgets, and forms.
- Default card treatment: white surface, soft shadow, generous radius, strong amount hierarchy.
- Lite cards emphasize one decision or one KPI.
- Pro cards may contain denser metadata, controls, and side-by-side metrics if alignment remains clean.
- Card headers should not compete with the amount or chart focal point.

### 7.4 Jars Widgets

- Lite jars: giant balance first, stacked jars second, immediate remaining budget visibility, minimal controls.
- Pro jars: retain hierarchy, comparisons, charts, allocation detail, and actionable surplus/deficit context.
- Overspent jars must be unmistakable through state-danger plus clear textual status, not color alone.
- Healthy jars should show remaining amount and progress together.

### 7.5 Tables and Lists

- Lite transaction views default to simplified cards or short lists with the most relevant fields only.
- Pro transaction views may use dense tables or super-grid patterns with more simultaneous context.
- Numeric columns align consistently for scan speed.
- Row actions must remain discoverable without overwhelming Lite users.
- Empty, loading, and error states must preserve the same container footprint where possible.

### 7.6 Filters

- Lite filters are compact, progressive, and task-focused: period, account, category, or status only when needed.
- Pro filters may remain persistently visible and support multi-dimensional slicing.
- Filter bars should use pills, chips, or segmented controls consistent with the rounded system.
- Hidden advanced filters in Lite must still reuse the same filter components, only deferred into sheets or drawers.

### 7.7 Forms

- Forms are mobile-first and conversion-first.
- The preferred Lite transaction pattern is one-tap wizard behavior: amount first, category second, details after intent is clear.
- Category selection should prefer icon-grid or visual picker patterns over text-heavy dropdowns when the choice set is short and common.
- Primary form CTA stays sticky or visually anchored when keyboard behavior allows.
- Pro forms may expose more simultaneous fields, but grouping and sequencing must remain obvious.
- Inline validation must appear early enough to prevent backend-only correction loops.

### 7.8 Settings Sections

- Settings are grouped into clear, elevated sections with short explanatory copy.
- Lite hides advanced finance structure by default and reveals it behind explicit drill-downs.
- Pro keeps operational tools available, including structural finance controls, as long as grouping remains legible.
- Critical toggles that affect balance calculations or jar rules must include explanatory helper text.

### 7.9 Modals and Drawers

- Lite mobile overlays default to bottom sheets with large radii and thumb-reachable actions.
- Pro may use side drawers or centered modals depending on task length and context dependency.
- Short tasks use sheets; complex multi-step editing may use drawers or full-height work surfaces.
- Closing behavior must be predictable, with explicit cancel paths for high-impact actions.

### 7.10 Feedback States

- Success, warning, and error feedback use semantic color plus clear text plus icon.
- Toasts are for transient confirmations only.
- Blocking failures belong inline or inside the affected surface.
- Budget-impacting warnings must state the financial consequence, not just the technical error.

## 8. Non-Negotiable Acceptance Criteria for Migrated Screens

Every migrated screen must satisfy all checks below before merge.

1. Uses the canonical token system in this brief for color, typography, radius, spacing, and state semantics.
2. Preserves one OWFINANCE visual identity across Lite and Pro; differences are density-based only.
3. Validates at 375px first with no horizontal scroll, clipped actions, or safe-area collisions.
4. Uses dominant money hierarchy where the primary financial amount is visually clearer than secondary metadata.
5. Uses SVG iconography only for system UI; no emoji-based system controls.
6. Meets touch target minimums for mobile primary actions and preserves visible focus states.
7. Provides explicit empty, loading, and error handling for the surface being migrated.
8. Applies Lite progressive disclosure and reduced control exposure where the screen is scoped as Lite.
9. Applies Pro simultaneous-context and productivity rules where the screen is scoped as Pro.
10. Keeps navigation posture correct: Lite bottom-nav/no persistent sidebar; Pro may expand navigation according to device and density.
11. Keeps forms, filters, cards, and overlays consistent with the component rules in this brief.
12. Overrides any conflicting Stitch or older prompt output that violates these canonical rules.

## 9. Verification Checklist for Documentation Consumers

- Confirm design tokens in implementation match the color roles and typography stack here.
- Confirm any screen brief identifies whether the target density is Lite or Pro.
- Confirm any Stitch-generated output is reviewed against this brief before implementation.
- Confirm component decisions for navigation, cards, jars, filters, forms, settings, overlays, and feedback are traceable to these rules.
