# OW Finance 2026 — Design System

A premium personal finance product. This design system documents the **canonical Lite Desktop** experience (Light + Dark) plus the shared visual foundations that Lite and Pro both consume.

> Lite and Pro are the **same product, same brand, same design system.** They differ in **density and layout posture** — never in color, type, or voice.

---

## 1. Product context

OW Finance has two layout modes:

- **Lite** — calm, low-density, money-first. For users who want to glance at balance, see jars, log an action, and leave. Progressive disclosure is the default.
- **Pro** — denser, multi-pane, more simultaneous controls. For power users who want a Bloomberg-style command surface.

Today the frontend (`DynamicRoleLayout`) sends every Lite user — desktop or not — to `LiteMobileLayout.vue`, which renders the mobile shell on desktop. This system defines the **missing Lite Desktop shell** so that the frontend can implement `LiteDesktopLayout.vue` in Quasar with a clear reference.

### Canonical routes
Four **primary** destinations (the bottom nav / nav pill — "no more" than these):
- `/user/home`
- `/user/transactions`
- `/user/jars`
- `/user/config`

Two **secondary** destinations, reached from Home previews + Quick Add (not in the tab bar):
- `/user/debts` — Deudas / planes de pago (Cashea, tarjetas, préstamos)
- `/user/dreams` — Sueños / metas de largo plazo

Both Lite Desktop and the Mobile app implement all six. The Asesor IA chat is a pushed full-screen view, not a route destination.

### Lite Desktop UX commandments
- **No persistent Pro-style sidebar.** Lite uses a floating horizontal **nav pill** or a slim contextual rail. Never a dense admin chrome.
- **No admin shell, no mobile-stretched layout.** Desktop is its own posture.
- **One obvious primary action at a time.** Quick Add is the CTA.
- **Money first.** Hero balance, available, jars, and recent movements dominate the visual hierarchy.
- **Calm whitespace.** Reduced simultaneous controls vs Pro.
- **No hard 1px dark borders** as dominant framing. Use soft elevation and large radii.

---

## 2. Sources of truth (this system was built from)

This project did **not** receive a codebase import or Figma file. It was built from the canonical briefs pasted by the user:

- `docs/ui-ux/08-frozen-canonical-design-system-brief.md`
- `docs/ui-ux/09-freeze-stitch-flujo-core-matrix.md`
- `docs/ui-ux/10-layout-refactor-legacy-pro-lite-mini-spec.md`
- `docs/ui-ux/MASTER_UI_SOURCES.md`
- Stitch project `5968657237763273187`
- Legacy Vue components referenced (not imported):
  - `src/layouts/LiteMobileLayout.vue`
  - `src/layouts/DynamicRoleLayout.vue`
  - `src/components/lite/LiteHeaderDesktop.vue`
  - `src/components/lite/LiteBottomNavDesktop.vue`
  - `src/components/lite/ExpandedNavigationMenuLight.vue`
  - `src/components/liquid/LiquidHeader.vue`, `LiquidBottomNavNew.vue`, `QuickActionSheet.vue`

> 📎 **If you have access to the codebase or Stitch project,** please re-attach via the Import menu so we can pull pixel-perfect component code, real icons, and verified token values. The system currently encodes the briefs faithfully; the codebase will sharpen it.

### ⚠️ Reconciled conflict between briefs

The two source briefs disagree on **brand primary**:

| Source | Primary | Cyan role |
|---|---|---|
| Lite Desktop brief (08–10) | `#1E3A8A` deep navy | `#0EA5E9` is *supporting info accent only* |
| Liquid Glass Unified (master) | `#0EA5E9` cyan | (no navy referenced) |

**Resolution for this system:** Lite Desktop is the active deliverable and its brief is canonical. We use **deep navy `#1E3A8A` as `--brand-primary`** and cyan as a secondary info accent. The "avoid cyan-first CTA hierarchy" rule from the Lite brief governs.

If the wider product later confirms cyan-primary, swap `--brand-primary` once in `colors_and_type.css`; nothing else needs to change.

The two briefs also disagree on type:

| Source | Display | Body |
|---|---|---|
| Lite Desktop brief | Satoshi | DM Sans (fallback) |
| Liquid Glass Unified | Manrope (Bold) | Inter |

**Resolution:** Satoshi / DM Sans is canonical here. Manrope and Inter are loaded as compatible fallbacks so legacy Quasar views render without surprise.

---

## 3. Content fundamentals

### Voice
- **Calm and matter-of-fact.** This is money — never breezy, never alarmist. Short sentences. No hype.
- **Second person, conversational.** "Your balance" / "You spent" / "Set aside". Never "the user".
- **Spanish + English neutral.** Copy may ship in either. Use neutral, professional Spanish (no regional slang). Mirror the same tone in English. Examples below show English; Spanish equivalents use the same calm register.
- **Numbers do the talking.** Headlines are amounts, not adjectives. Let `$ 12,480.50` be the headline; copy supports it.

### Casing
- **Sentence case for everything** in product chrome: navigation labels, buttons, section headers. ("Recent transactions", not "Recent Transactions".)
- **All-caps only for tiny meta labels** (KPI eyebrows, currency codes): `AVAILABLE`, `USD`, `THIS MONTH`. Track +60 letter-spacing.

### Tone examples
| Don't | Do |
|---|---|
| "🎉 Awesome job saving!" | "On track for your March goal." |
| "Oops, transaction failed!" | "Transfer didn't go through. Try again." |
| "Welcome back, superstar!" | "Hi, José." |
| "Click here to view all" | "View all" |

### Emoji & decorative chars
- **No native emoji as system iconography.** Ever.
- Material Icons (the safe baseline subset only — see ICONOGRAPHY) carries all glyph weight.
- Currency symbols (`$`, `€`, `S/`) are part of typography, not decoration — set them tabular.

### Money formatting
- Always with thousand separators and two decimals: `$ 12,480.50`.
- Currency code as a short uppercase chip beside large amounts: `USD`.
- Negative values: leading `−` (true minus, U+2212), `--expense` color. Never parentheses.
- Hidden state when visibility is off: replace digits with `••••••` of the same width.

---

## 4. Visual foundations

### Color
- **Light is the canonical baseline.** Dark mirrors the same structure, never inverts hierarchy.
- **Navy `#1E3A8A` is the brand-primary.** It owns active nav state, the one CTA, and the focused chip.
- **Cyan `#0EA5E9` is a supporting info accent** — info badges, link-styled secondaries, sparkline strokes. Never the primary CTA.
- **Semantic colors are functional**, not decorative: success `#10B981` (income, on-track), danger `#EF4444` (expense, over budget), warning `#F59E0B` (idle money, attention needed).
- **Surfaces:** Light = white cards on `#F8FAFC`. Dark = `#131B2E` cards on `#0F172A` base.

See `colors_and_type.css` for the full token list.

### Type
- **Display:** Satoshi (Variable). Used for amounts, section headers, hero numbers. Tracked tight at large sizes (-1% to -2%).
- **Body:** DM Sans. 400 / 500 / 600. Used for everything ≤ 18px.
- **Money** is its own type role — always Satoshi 600/700, **tabular numerals** (`font-variant-numeric: tabular-nums`).
- Manrope and Inter are loaded as legacy fallbacks.

### Spacing
8px base grid. Tokens: `--space-1` (4) through `--space-12` (96). Lite Desktop tends to use the higher end (`--space-6` / `--space-8`) between cards to keep the calm.

### Radii
Generous. Card = 20px. Hero card = 28px. Buttons = 999px (pill). Chips = 999px. Inputs = 12px. **No square corners** anywhere in chrome.

### Borders
- **No 1px hard borders** as dominant framing.
- Where separation is needed, use elevation (shadow) or surface contrast (`--surface-1` vs `--surface-2`), not strokes.
- The one exception: a 1px hairline at `--border-hairline` (very low alpha) is allowed inside dense lists like the transactions ledger — it must be barely-there.

### Elevation / shadow
- Light mode: `0 4px 24px rgba(15, 23, 42, 0.06)` for cards. `0 8px 32px rgba(15, 23, 42, 0.10)` for hero / floating nav. **No drop shadow visible on white-on-white** — only on cards floating above the `#F8FAFC` canvas.
- Dark mode: shadows are barely visible; rely on **surface contrast** (S1/S2/S3 stack) plus an optional inner-ring `inset 0 1px 0 rgba(255,255,255,0.04)` to lift a card off its background.
- **No glassmorphism in Lite Desktop chrome.** (The wider Liquid Glass system uses blur on mobile hero modals; the Lite Desktop shell stays flat and trust-first.)

### Backgrounds
- **Plain solid surfaces only.** No background images, gradients, or patterns in product chrome.
- Marketing surfaces (outside this system's scope) may carry brand imagery; product surfaces do not.

### Imagery
- **Avatar circles** are the only routine image surface in chrome. Initials fallback (navy circle, white letter) when no photo.
- **Empty state illustrations** are allowed (placeholders here — see `assets/placeholders/`).
- No stock photography, no abstract gradients, no AI imagery.

### Animation
- **Subtle, fast, deliberate.** 150–220ms is the working range.
- Easing: `cubic-bezier(0.2, 0.8, 0.2, 1)` (a slightly-bouncy ease-out) for entrances, `ease-in-out` for state changes.
- **No bouncy springs, no parallax, no decorative motion.** Money UI should feel like a Swiss watch.
- Number changes use a quick crossfade (120ms), never a slot-machine rolling counter.

### Hover states
- **Buttons:** primary darkens 6%, secondary surfaces shift `--surface-1 → --surface-2`.
- **Nav items:** background fades to `--surface-2` at ~150ms.
- **Cards:** elevation increases (shadow stronger), no scale, no rotation.
- **Links:** underline-by-default off; on hover, `text-decoration: underline` with `text-underline-offset: 3px`.

### Press / active states
- Buttons compress slightly (`transform: scale(0.98)`), 80ms in.
- Nav items darken background one more step (`--surface-2 → --surface-3`).

### Focus
- Always visible. 2px outline in `--brand-primary` with 2px offset. Never remove it; never replace with a glow.

### Transparency / blur
- Allowed only on **the expanded contextual menu** (popover overlay), with a 12px backdrop blur and ~92% opacity. Nowhere else in Lite Desktop chrome.

### Layout rules
- Lite Desktop content max-width: **1200px** (`--container-max`).
- Header is **non-sticky in v1** (Lite calm posture) but the nav pill **floats fixed** at the bottom center.
- Page padding: 32px horizontal at desktop, scaling down to 24px below 1024px (Lite Desktop is desktop-only; below 1024px the user gets the mobile shell).

### Cards
- Background: `--surface-1` (white in light, `#131B2E` in dark).
- Radius: 20px (most), 28px (hero).
- Padding: 24px (default), 32px (hero).
- Shadow per above. No border.

---

## 5. Iconography

See [`ICONOGRAPHY.md`](./ICONOGRAPHY.md) for the safe-set policy. Short version:

- **Material Icons (filled)** via the Quasar default `material-icons` font is the only system icon source.
- **Safe names only:** `home`, `receipt_long`, `savings`, `settings`, `notifications`, `person`, `menu`, `add`, `visibility`, `visibility_off`, `chevron_right`, `arrow_outward`, `arrow_downward`, `more_horiz`, `close`, `check`, `search`.
- **Banned in this system:** `o_*` outlined-variant prefixes (depend on an icon set Quasar isn't configured for), any Material Symbols-only glyphs, emoji.
- 24px is the default size. 20px in dense rows. 32px in hero affordances.

---

## 6. Index

```
README.md                    ← you are here
ICONOGRAPHY.md               ← icon policy & safe names
SKILL.md                     ← agent-skill manifest
colors_and_type.css          ← all tokens, light + dark, type roles
fonts/                       ← Satoshi (Fontshare), DM Sans, Manrope, Inter
assets/
  logos/                     ← OW Finance logos (placeholders + svg marks)
  placeholders/              ← avatar / empty-state placeholders
preview/                     ← Design System tab cards (registered assets)
ui_kits/
  lite-desktop/
    README.md
    index.html               ← interactive 4-route Lite Desktop demo (Light + Dark toggle)
    LiteShell.jsx            ← page frame, header + floating nav pill + expanded menu
    LiteHeader.jsx
    LiteNavPill.jsx
    ExpandedMenu.jsx
    HeroBalance.jsx
    JarsPreview.jsx
    RecentTransactions.jsx
    Buttons.jsx               ← PillButton, IconButton, CTA
    Chips.jsx                 ← CurrencyChip, StatusChip
    routes/
      HomeRoute.jsx
      TransactionsRoute.jsx
      JarsRoute.jsx
      DebtsRoute.jsx          ← Deudas / planes de pago (Cashea, tarjetas, préstamos)
      DreamsRoute.jsx         ← Sueños / metas de largo plazo
      ConfigRoute.jsx
  mobile/                      ← MOBILE APP kit — Lite + Pro, Dark + Light, 8 screens
    README.md                 ← 📱 screen-by-screen guide + navigation map (start here)
    index.html               ← interactive phone-frame demo (Modo + Tema toggles)
    Shell.jsx · data.jsx · tokens.js
    components/               ← Atoms, Navigation, BalanceCard, Jar/Debt/Dream/Tx, sheets, chat
    screens/                 ← Home (Lite/Pro), Transacciones, Jars, Deudas, Sueños, Config, IA
```

> 📱 **Mobile app:** the phone posture of the same product. It also ships **Lite and Pro** modes (a toggle in the demo header) and now includes the **Deudas** and **Sueños** screens at parity with Lite Desktop. See [`ui_kits/mobile/README.md`](./ui_kits/mobile/README.md) for the full per-screen guide and the navigation/interconnection map.

---

## 7. Iterate with us

This system is intentionally tight and opinionated to keep Lite **Lite**. If you find:
- a spec gap (a component the brief didn't name),
- a token that needs to differ between Lite and Pro,
- or a place the navy/cyan resolution feels wrong,

flag it and we'll adjust. The next high-value step is **attaching the real codebase** so the UI kit becomes pixel-true to `LiteHeaderDesktop.vue` and friends.
