# OWFINANCE2026 Freeze Stitch -> Flujo Core Matrix

Status: Frozen for frontend implementation queue and review checklist.

Authority order for this matrix:

1. `docs/ui-ux/08-frozen-canonical-design-system-brief.md`
2. This matrix for Stitch-to-flow mapping and decomposition decisions.
3. Existing Stitch screens only as visual source material.
4. Existing frontend pages and components only as migration input, not as final UX authority.

## Scope frozen in this task group

- Dashboard / home
- Alta de movimiento
- Listado y filtros de movimientos
- Jars / cantaros
- Perfil / settings
- Navegacion global

Out of scope for this freeze unless reused as a small shared element:

- AI Coach as an independent flow
- Investments as an independent module
- Admin-only finance master data shells
- Decorative premium-only widgets that add complexity without core user value

## Canonical route policy

OWFINANCE2026 keeps one shared product architecture with density-based variants, not separate brands or separate apps.

- Canonical user routes remain `/user/home`, `/user/transactions`, `/user/jars`, `/user/config`.
- Lite and Pro map to the same canonical route family.
- Variant differences are implemented by shell, density, and component composition.
- Modal or sheet flows may be launched from multiple routes and are treated as shared overlays instead of standalone pages.

## Stitch -> Flujo Core Matrix

| flow | route | variant | Stitch source | mapping | OWF canonical owner | reuse / shared components | required overrides | drop / unsupported | status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Global navigation shell | `/user/*` | Lite | `Expanded Navigation Menu` + `OW Finance Dashboard Lite - Home` | Decompose into shared shell parts | `UserLayout.vue` -> new canonical app shell | Bottom nav, top summary bar, FAB launcher, safe-area footer, page container | Replace cyan/dark shell with light baseline, limit to 4 primary destinations, convert menu overlay into bottom-nav + optional drawer, keep SVG icons only | Voice button, QR scanner, AI as first-class nav action, duplicate Home labels | Frozen - implement as shared shell first |
| Global navigation shell | `/user/*` | Pro | `Desktop Pro Dashboard Home`, `Desktop Pro Dashboard - Light Mode`, `Desktop Pro Settings` | Decompose into shared shell parts | `UserLayout.vue` + Pro desktop shell layer | Desktop sidebar, top utility bar, notifications slot, page header region, floating primary action | Replace premium dark/editorial framing with frozen light shell, keep same destination model as Lite, expose denser utility actions without creating admin chrome | Investments and support as primary nav destinations, advisor/shared-with badges, decorative logout rails | Frozen - shared shell with Pro-only density extensions |
| Dashboard / home | `/user/home` | Lite | `OW Finance Dashboard Lite - Home` | 1 screen -> 1 route with light cleanup | `src/pages/user/user_dashboard.vue` | Hero balance card, jars preview list, recent transactions preview, CTA to add movement, bottom-nav context | Use frozen tokens and typography, simplify hero copy, prioritize money hierarchy, keep only one dominant CTA, collapse secondary analytics into links | AI button inside nav, extra insights tab, decorative greeting noise | Frozen - direct route migration |
| Dashboard / home | `/user/home` | Pro | `Desktop Pro Dashboard Home` and `Desktop Pro Dashboard - Light Mode` | Decompose into route + reusable widgets | `src/pages/user/user_dashboard.vue` with Pro composition layer | Global balance card, account summary widget, jars distribution widget, recent activity table, idle-money alert, optional account hierarchy panel | Merge duplicate dashboard variants into one canonical Pro route, use light mode only, preserve productivity density without admin feel | Shared with advisors, investments module blocks, support rail, currency strip overload | Frozen - one Pro dashboard assembled from shared widgets |
| Alta de movimiento | shared overlay on `/user/home`, `/user/transactions`, `/user/jars` | Lite | `Quick Add Modal - Light Mode` | 1 screen -> 1 shared overlay | `TransactionCreateDialog.vue` -> new Lite quick-add sheet | Amount keypad, transaction type toggle, note field, category picker, sticky save CTA | Convert modal to mobile bottom sheet, keep amount-first flow, add category visual picker, remove summary-tab chrome | Profile/activity tabs inside modal, extra navigation labels, decorative close/header noise | Frozen - build as shared overlay before dense forms |
| Alta de movimiento | shared overlay on `/user/home`, `/user/transactions` | Pro | `Quick Add Modal - Light Mode` as baseline only | Decompose and extend shared overlay | `TransactionCreateDialog.vue` / `TransactionForm.vue` | Shared amount-first block, account picker, advanced fields group, validation/submit footer | Reuse Lite entry flow but reveal more fields inline or drawer-style on desktop, keep canonical light tokens | Numeric keypad on desktop, mobile-only tab bar inside modal | Frozen - Pro extends same form contract |
| Movimientos list / filters | `/user/transactions` | Lite | `Transactions - Mobile Lite` | 1 screen -> 1 route with extracted subparts | `src/pages/user/transactions/index.vue` | Transaction row card, compact filter chips, search input, top summary strip, FAB / quick-add launcher | Remove permanent account sidebar, reduce visible filters, switch table to card/list layout, keep period/account/category/status only when needed | Bulk import, column chooser, mass delete, dense toolbar actions | Frozen - direct Lite route with simplification |
| Movimientos list / filters | `/user/transactions` | Pro | `Transactions Pro Super-Grid` | Decompose into route + dense reusable regions | `src/pages/user/transactions/index.vue` | Sticky filter bar, dense data grid, account context panel, KPI summary row, export action, multi-select row actions | Keep dense grid pattern but map to frozen light design, preserve scan-friendly numeric alignment, group destructive actions, avoid admin terminology | Spreadsheet-like overload beyond core columns, investments shortcut, unnecessary terminal branding | Frozen - Pro route assembled from grid + filters + account context |
| Jars | `/user/jars` | Lite | `Cántaros - Mobile Lite` | 1 screen -> 1 route with small cleanup | `src/pages/user/jars/index.vue` | Income summary card, assigned/unassigned totals, stacked jar progress cards, available balance status, nav shell | Simplify to giant balance first, stacked jars second, preserve remaining-budget emphasis, keep actions thumb-reachable | Deep settings inline, drag-and-drop, advanced carry-over rules as default visible content | Frozen - direct Lite route migration |
| Jars | `/user/jars` | Pro | `Desktop Pro Jars Management` | Decompose into route + advanced jar modules | `src/pages/user/jars/index.vue` | KPI bar, jars allocation table, rule cards, idle money alert, month-close action | Retain actionable surplus/deficit context, expose carry-over rules and close-month tools in grouped cards, keep light mode | Admin badge, decorative premium shell labels, over-styled editorial headers | Frozen - Pro route composed from shared jar widgets + advanced panels |
| Profile / settings | `/user/config` | Lite | `Desktop Pro Settings` as structural reference only | Decompose and simplify heavily | `src/pages/user/settings/index.vue` and `src/pages/user/config/index.vue` | Profile card, security card, finance preferences card, helper text blocks | Convert tab-heavy desktop screen into stacked mobile cards, hide advanced structural finance tools by default, maintain one primary action per section | Billing, API keys, upgrade CTA, logout as section card, dark-mode personalization complexity | Frozen - Lite settings derived from shared settings sections |
| Profile / settings | `/user/config` | Pro | `Desktop Pro Settings` | 1 screen -> 1 route with selective pruning | `src/pages/user/settings/index.vue` | Settings section cards, tabs/section nav, profile form, security toggles, finance profile, account/category/tax management entry points | Keep grouped elevated sections, preserve helper copy, expose structural tools without mixing admin modules, align with frozen light shell | Billing/API keys if not in current product scope, decorative analytics labels inside settings | Frozen - direct Pro route with scope pruning |

## Decomposition decisions

### Clean one-screen to one-route mappings

- `OW Finance Dashboard Lite - Home` -> Lite `/user/home`
- `Transactions - Mobile Lite` -> Lite `/user/transactions`
- `Cántaros - Mobile Lite` -> Lite `/user/jars`
- `Desktop Pro Settings` -> Pro `/user/config` after scope pruning

### Screens that must be decomposed into reusable parts

- `Expanded Navigation Menu` -> shared Lite shell primitives, not its own route
- `Quick Add Modal - Light Mode` -> shared transaction overlay, reused across home, transactions, and jars
- `Transactions Pro Super-Grid` -> filter bar + account context + dense grid + action rail
- `Desktop Pro Jars Management` -> KPI row + jars table + rule cards + month-close action
- `Desktop Pro Dashboard Home` and `Desktop Pro Dashboard - Light Mode` -> one canonical Pro dashboard assembled from shared widgets

## Duplicate and obsolete Stitch screens

| Stitch screen | Issue | Resolution |
| --- | --- | --- |
| `OW Finance Dashboard Lite` | Older Lite dashboard variant duplicates the newer home direction | Keep only as secondary reference for hero balance and jars card proportions; do not implement as separate route |
| `OW Finance Dashboard Lite - Home` | Newer Lite dashboard/home variant overlaps with `OW Finance Dashboard Lite` | Use as the canonical Lite home source |
| `Desktop Pro Dashboard Home` | Duplicate Pro dashboard concept in dark-heavy premium style | Keep layout/data density cues only; merge into one canonical Pro dashboard |
| `Desktop Pro Dashboard - Light Mode` | Same flow as `Desktop Pro Dashboard Home` but closer to frozen light baseline | Prefer this as the dominant visual source for Pro dashboard implementation |
| `Expanded Navigation Menu` | Navigation treatment, not a standalone user flow | Decompose into shell pieces and remove as an implementation target |
| `AI Coach Chat` | Outside frozen core scope | Defer to a later task group; only allow future launcher slot in shell if needed |

## Unsupported or decorative Stitch elements to drop

- Dark-mode-first shell treatments that conflict with the frozen light baseline.
- Cyan-first CTA hierarchy that competes with `brand-primary` navy.
- Investments as a core navigation destination inside the frozen core scope.
- Support / advisor / premium-admin labeling that changes product posture away from core consumer finance.
- Duplicate voice, QR, and AI entry points in primary navigation.
- Decorative badges such as `Premium`, `ADMIN`, `shared with advisors`, and other status ornaments that do not affect the core flow.
- Keyboard/keypad patterns on desktop when standard input is faster.
- Spreadsheet overload in Pro views beyond the required operational columns and filters.
- Billing and API keys inside the core settings freeze unless product scope explicitly reintroduces them.

## Canonical owners in current frontend structure

- Shell and navigation: `OWFinanceFrontend2025/src/layouts/UserLayout.vue`
- Route map: `OWFinanceFrontend2025/src/router/routes.ts`
- Lite/Pro destination registry: `OWFinanceFrontend2025/src/pages/user/config.ts`
- Dashboard route owner: `OWFinanceFrontend2025/src/pages/user/user_dashboard.vue`
- Transactions route owner: `OWFinanceFrontend2025/src/pages/user/transactions/index.vue`
- Jars route owner: `OWFinanceFrontend2025/src/pages/user/jars/index.vue`
- Settings route owner: `OWFinanceFrontend2025/src/pages/user/settings/index.vue`
- Shared transaction overlay owner: `OWFinanceFrontend2025/src/components/TransactionCreateDialog.vue`
- Shared finance widgets already reusable or partially reusable: `JarCard.vue`, `JarsBalanceBar.vue`, `MonthlyIncomePanel.vue`, `PeriodFilterBar.vue`, `ExpenseDistributionChart.vue`, `AccountsSidebarWidget.vue`

## Implementation handoff rules

Use this matrix as both queue and review checklist.

1. Build shared shell primitives first, because all route work depends on them.
2. Build the Lite quick-add overlay early, because home, transactions, and jars all launch it.
3. Implement one canonical route per flow, then apply Lite/Pro density through composition rather than route duplication.
4. When a Stitch source is marked `Decompose`, implementation must create reusable subcomponents before route polish.
5. When a Stitch element is listed under `drop / unsupported`, do not carry it into Vue/Quasar unless product scope is explicitly reopened.
6. Every frontend PR for these flows must point back to the relevant matrix row and confirm: route, variant, reused components, overrides, and dropped decorations.

## Recommended implementation order

1. Shared shell: Lite bottom nav, Pro sidebar/topbar, FAB contract, page header slots.
2. Shared transaction overlay: Lite sheet first, Pro extension second.
3. Lite home.
4. Lite transactions.
5. Lite jars.
6. Lite settings.
7. Pro home.
8. Pro transactions.
9. Pro jars.
10. Pro settings.

## Verification

This matrix was frozen against the following evidence:

- Stitch project `projects/5968657237763273187` screen inventory and individual screen payloads.
- Frozen canonical design brief in `docs/ui-ux/08-frozen-canonical-design-system-brief.md`.
- Legacy design rules in `docs/ui-ux/03-unified-design-rules.md` and Lite/Pro differences in `docs/ui-ux/06-version-matrix-differences.md`.
- Existing frontend route owners in `OWFinanceFrontend2025/src/router/routes.ts`.
- Existing shell and screen owners in `OWFinanceFrontend2025/src/layouts/UserLayout.vue`, `OWFinanceFrontend2025/src/pages/user/user_dashboard.vue`, `OWFinanceFrontend2025/src/pages/user/transactions/index.vue`, `OWFinanceFrontend2025/src/pages/user/jars/index.vue`, and `OWFinanceFrontend2025/src/pages/user/settings/index.vue`.

Verification checks completed:

- Confirmed every in-scope core flow has at least one Stitch source or an explicit structural derivation.
- Confirmed every matrix row maps to an existing canonical user route or a shared overlay contract.
- Confirmed duplicate Stitch dashboards are merged rather than implemented as separate routes.
- Confirmed unsupported decorative elements are explicitly listed for removal to protect simplicity and performance.

## Next recommended task group

Task Group 4: implement the shared canonical shell and route scaffolding using this matrix as the execution order, starting with navigation + app shell + quick-add overlay contracts.
