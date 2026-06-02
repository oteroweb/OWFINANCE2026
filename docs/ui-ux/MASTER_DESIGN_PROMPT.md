# OWFINANCE 2026 — Master Design Prompt v1.0
> Usar con: Claude.ai / Stitch MCP / Cualquier AI generador de UI
> Última actualización: 2026-05-26

---

## INSTRUCCIONES DE USO

1. Copia TODO este documento (secciones 1-6)
2. Reemplaza `[SECCIÓN 7]` con la pantalla específica que necesitas
3. Pega en claude.ai / Stitch / tu herramienta
4. El output será HTML+CSS responsive listo para convertir a Vue/Quasar

---

## SECCIÓN 1: PRODUCTO

```
You are designing for OWFINANCE — a premium personal finance app based on the "Jars" (Cántaros) budgeting system. Each jar represents a spending category with an assigned percentage of monthly income. The user distributes 100% of their income across jars (e.g. Needs 55%, Education 10%, Savings 10%, Fun 10%, Giving 5%, Emergency 10%). Every dollar has a job.

The app serves a dual audience:
- LITE: Mobile-first users who want quick balance checks, fast transaction entry, and visual jar progress. Zero friction. Premium feel.
- PRO: Desktop power-users who need dense data grids, multi-account trees, drag-and-drop budget reallocation, and analytical tools.

Both variants share the EXACT SAME design system, brand identity, and component language. They differ ONLY by information density and layout posture. Lite is calm and focused; Pro is dense and operational.
```

---

## SECCIÓN 2: DESIGN SYSTEM (CONGELADO — NO MODIFICAR)

```
════════════════════════════════════
 COLOR SYSTEM
════════════════════════════════════

LIGHT MODE (canonical default):
- Page background: #F8FAFC
- Card surface (elevated): #FFFFFF with shadow: 0 10px 30px rgba(15,23,42,0.08)
- Secondary surface: #F1F5F9
- Glass overlay (rare): rgba(255,255,255,0.72)

DARK MODE (secondary variant):
- Page background: #0F172A
- Card surface 1: #131B2E
- Card surface 2: #1A1A2E (primary containers)
- Card surface 3: #222A3D (floating/hover)
- Glass effects: backdrop-filter blur 16-24px, no hard borders

SEMANTIC COLORS (constant in both modes):
- Brand primary: #1E3A8A (deep navy) — CTAs, selected nav, key emphasis
- Brand hover: #1D4ED8
- Brand soft fill: #DBEAFE — selected chips, info pills
- Success/Income: #10B981 — income, healthy jars, completed
- Danger/Expense: #EF4444 — overspend, destructive, errors
- Warning: #F59E0B — attention states, pending
- Info accent: #0EA5E9 — secondary accent ONLY, never main CTA
- Purple: #8B5CF6 — AI/voice features only, always secondary

TEXT:
- Strong (headings, money): #0F172A (light mode) / #E2E8F0 (dark mode)
- Muted (metadata, helpers): #64748B (light) / #94A3B8 (dark)
- Borders/dividers: #E2E8F0 (light) / transparent with glow (dark)

COLOR RULES:
- Navy #1E3A8A is the PRIMARY brand. NOT cyan.
- Cyan may appear as supporting info accent only.
- White cards on #F8FAFC is the default reading environment.
- Purple is forbidden as a primary finance action color.
- Money amounts ALWAYS use the strongest text color available.

════════════════════════════════════
 TYPOGRAPHY
════════════════════════════════════

- Primary typeface: Satoshi (download from Fontshare)
- Fallback typeface: DM Sans (Google Fonts)
- System fallback: ui-sans-serif, system-ui, sans-serif
- DO NOT use Manrope, Inter, or General Sans as baseline

HIERARCHY:
- Display XL (32-40px, weight 600-700): Main balance, hero amounts
- Display L (24-32px, weight 600-700): Jar totals, section KPIs
- Heading (18-24px, weight 600): Card titles, section headers
- Body (14-16px, weight 400-500): Labels, lists, form text
- Meta (12-14px, weight 400-500): Timestamps, captions, helper text

TYPOGRAPHY RULES:
- Money is the DOMINANT information type. Always largest, always boldest.
- Support text: use muted color BEFORE smaller size.
- Never use decorative oversized text for non-financial content.

════════════════════════════════════
 SHAPES & ELEVATION
════════════════════════════════════

- Hero cards / modals / bottom sheets: 24-32px border-radius
- Standard cards: 24px (Lite), 20-24px (Pro)
- Desktop dense panels: 16-20px
- Buttons: pill-shaped (rounded-full / 999px)
- HARD SQUARE CORNERS ARE FORBIDDEN
- NO hard 1px dark borders as dominant framing
- Default card shadow: 0 10px 30px rgba(15,23,42,0.08)
- Glass is subtle and additive, never the main readability layer

════════════════════════════════════
 SPACING
════════════════════════════════════

Scale: 4, 8, 12, 16, 20, 24, 32, 40
- Mobile horizontal padding: 16px default
- Hero/bottom sheet inner padding: 20-24px
- Pro dense regions: 12-16px internal
- Visual hierarchy from spacing BEFORE adding dividers

════════════════════════════════════
 ICONOGRAPHY
════════════════════════════════════

- SVG icon libraries only (Lucide, Heroicons, Material Symbols)
- NO native emoji as system iconography
- Exception: user-created jar icons MAY use emoji as user content
- Safe icon names: home, receipt_long, savings, settings, notifications, person, menu, add, visibility, logout, chevron_left, chevron_right, edit, delete, search, filter, trending_up, trending_down, more_vert
- DO NOT use outlined variants (o_home, o_savings, etc.) as primary system icons

════════════════════════════════════
 MOTION & INTERACTION
════════════════════════════════════

- Standard duration: 220-300ms
- Use transform and opacity only, no layout-shifting
- Mobile overlays open from bottom (bottom sheets)
- Minimum touch target: 48x48px (44x44px absolute minimum)
- Respect prefers-reduced-motion
- All buttons: cursor-pointer with hover transitions (150-300ms)
```

---

## SECCIÓN 3: SHELL & NAVIGATION

```
════════════════════════════════════
 LITE SHELL
════════════════════════════════════

HEADER:
- Left: Avatar (circle, initials or image) + greeting "Hola, [Name]"
- Right: Notifications bell + Visibility toggle (eye icon) + Currency chip (USD)
- Below header: Horizontal scrollable jar balance bar (jar name: $amount)
- Below jars: Period selector (Todo|Anual|Semestral|Trimestral|Mensual|Quincenal|Semanal|Diario|Custom) + month navigation arrows

BOTTOM NAVIGATION (floating, 5 tabs):
- Tab 1: Home (home icon)
- Tab 2: Transactions (receipt_long icon)
- Tab 3: CENTER ACTION BUTTON — Large circular FAB with add icon, brand-primary fill
- Tab 4: Jars (savings icon)
- Tab 5: Settings (settings icon)
- Active tab: brand-primary fill or brand-soft background
- Above FAB: Small floating AI brain icon (purple accent)

NO sidebar. NO persistent drawer. NO admin chrome.

════════════════════════════════════
 PRO SHELL
════════════════════════════════════

HEADER (top utility bar):
- Left: Logo/brand mark + Search bar
- Right: Currency chips + Visibility toggle + Notifications + Avatar
- Below: Period selector (same as Lite) + AI chat input in header

SIDEBAR (left, expanded with text + icons):
- Navigation items: Home, Transactions, Jars, Reports, Settings
- Each with icon + label
- Active: brand-primary background, white icon/text
- Collapsible to icon-only mode
- Bottom: Account summary mini-widget

FAB: Floating + button in bottom-right corner
AI CHAT: Floating purple icon above FAB

════════════════════════════════════
 SHARED OVERLAYS
════════════════════════════════════

QUICK ADD MODAL (triggered by FAB):
- Bottom sheet on mobile (Lite)
- Centered modal on desktop (Pro)
- Toggle: Gasto (red) / Ingreso (green) / Transferencia (purple)
- GIANT amount input centered ($0.00)
- Description field below
- Category grid with icons (not dropdown)
- Account selector
- Date picker
- Primary CTA: "Guardar" button pill-shaped

QUICK ACTIONS SHEET (expanded from FAB):
- Add Expense / Add Income / Add Transfer
- Voice Input (purple mic icon)
- Scan Receipt (orange camera icon)
- AI Auto-detect (purple sparkle icon)
```

---

## SECCIÓN 4: PATRONES DE COMPONENTES

```
JAR CARD:
- Color indicator (left border or icon background)
- Jar name + emoji (user content)
- Progress bar (filled = spent, remaining = available)
- Amount: "Disponible $XX.XX" in strong text
- Subtitle: "Gastado $YY.YY de $ZZ.ZZ (PP%)"
- Status: success (healthy), warning (>80%), danger (overspent)
- Pro version adds: inline percent editor, drag handle, trend arrow

TRANSACTION ROW:
- Left: Category icon (circle, category color)
- Center: Description (strong) + date + account name (muted)
- Right: Amount (green=income, red=expense) + secondary currency in muted
- Pro version adds: checkbox for multi-select, inline edit on double-click

ACCOUNT TREE (Pro only):
- Folders with chevron expand/collapse
- Accounts nested under folders
- Each account: icon + name + balance + checkbox + more_vert menu
- Drag & drop to reorder

HERO BALANCE CARD:
- Massive amount in Display XL (balance total)
- Below: Income (green ↑) and Expenses (red ↓) side by side
- Currency toggle chips
- Visibility toggle to mask amounts
- Pro version: split into multiple KPI widgets

CATEGORY PICKER (transaction form):
- Grid of 2-3 columns
- Each item: colored circle icon + category name
- Selected state: brand-soft background + brand-primary border
- Short lists use grid; long lists use searchable grid
```

---

## SECCIÓN 5: REGLAS OBLIGATORIAS

```
MANDATORY RULES:
1. Light mode is the DEFAULT. Always design light mode first.
2. Money amounts are ALWAYS the most prominent text element.
3. NO emoji as system icons. SVG/Material icons only.
4. NO hard 1px dark borders. Use soft shadows and spacing for separation.
5. NO cyan (#0EA5E9) as primary CTA. Navy (#1E3A8A) is brand.
6. NO purple for finance actions. Purple is for AI/voice only.
7. ALL cards must have generous border-radius (24px minimum).
8. ALL buttons must be pill-shaped (rounded-full).
9. Touch targets minimum 48x48px on mobile.
10. Empty states must explain what's missing + provide a CTA.
11. Loading states use skeletons (preserve layout dimensions).
12. Error states are local first, global second. Inline when possible.
13. Destructive actions (delete, overspend) must confirm before commit.
14. Mobile bottom sheets slide up with 300ms transition.
15. Respect safe-area on iOS/Android for nav and FAB.
16. Validate at 375px width FIRST for all mobile views.
17. Pro views validate desktop-first AFTER mobile baseline passes.

AESTHETIC DIRECTION:
Premium, calm, financially trustworthy. Apple Wallet meets Bloomberg Terminal.
NOT playful, NOT cluttered, NOT emoji-driven, NOT gaming-style.
Clean typography, generous whitespace, strong hierarchy.
```

---

## SECCIÓN 6: FORMATO DE OUTPUT

```
OUTPUT REQUIREMENTS:
- Generate a single self-contained HTML file
- Include all CSS inline (no external stylesheets)
- Use Google Fonts CDN for Satoshi and DM Sans
- Use Tailwind CSS via CDN for utility classes
- Make it fully responsive: 375px (mobile) / 768px (tablet) / 1024px+ (desktop)
- Include ARIA labels on interactive elements
- Use semantic HTML5 elements (main, nav, section, article)
- All text in Spanish (labels, headings, placeholders)
- Use realistic sample data (names, amounts, dates in Venezuelan context)
- Amounts in USD with 2 decimal places
- Include both light and dark mode versions if specified
- Add CSS custom properties for the color tokens so they can be extracted

SAMPLE DATA CONTEXT:
- User name: Jose
- Currency: USD (primary), VES/Bs (secondary, tasa ~693)
- Monthly income: $1,200
- Jars: Necesidades 55%, Educación 10%, Ahorro 10%, Diversión 10%, Dar 5%, Emergencias 10%
- Accounts: Banesco (Bs), Efectivo ($), Binance (USDT)
- Recent transactions: Supermercado $45.30, Recarga teléfono $3.00, Ingreso freelance $200
```

---

## SECCIÓN 7: PANTALLA A GENERAR (REEMPLAZAR)

```
┌─────────────────────────────────────────────────────┐
│  REEMPLAZAR ESTA SECCIÓN CON LA PANTALLA DESEADA   │
│                                                     │
│  Especificar:                                       │
│  - Nombre de la vista                               │
│  - Variante: Lite o Pro                             │
│  - Dispositivo: Mobile o Desktop                    │
│  - Modo: Light o Dark                               │
│  - Elementos específicos que debe contener          │
│  - Datos de ejemplo si son diferentes al default    │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## EJEMPLOS DE SECCIÓN 7 (LISTOS PARA COPIAR)

### Ejemplo A: Dashboard Lite Mobile Light
```
Generate the HOME DASHBOARD screen for OWFINANCE.

VARIANT: Lite Mobile
MODE: Light
DEVICE: Mobile (375px primary)

SCREEN ELEMENTS:
1. Header: Avatar + "Hola, Jose" + notifications bell + visibility toggle + USD chip
2. Hero balance card: Total balance $1,847.32, Income ↑ $1,200.00, Expenses ↓ $842.67
3. Period selector chips: Mensual (active), Semanal, Quincenal
4. Jars section: 6 jar cards stacked vertically
   - Necesidades 55%: Disponible $214.30, Gastado $445.70 de $660.00 (67%)
   - Educación 10%: Disponible $98.00, Gastado $22.00 de $120.00 (18%)
   - Ahorro 10%: Disponible $120.00, Gastado $0.00 de $120.00 (0%)
   - Diversión 10%: Disponible $48.50, Gastado $71.50 de $120.00 (60%)
   - Dar 5%: Disponible $60.00, Gastado $0.00 de $60.00 (0%)
   - Emergencias 10%: Disponible $120.00, Gastado $0.00 de $120.00 (0%)
5. Recent transactions (last 5):
   - Supermercado Central - $45.30 - Categoría: Alimentación - Hoy
   - Recarga Movistar - $3.00 - Categoría: Servicios - Ayer
   - Ingreso Freelance Web + $200.00 - Categoría: Freelance - 22 May
   - Gasolina - $15.00 - Categoría: Transporte - 21 May
   - Proteína Gym - $28.50 - Categoría: Salud - 20 May
6. "Ver todas las transacciones" link
7. Bottom nav: Home(active), Transactions, [+], Jars, Settings
8. Floating AI icon above FAB

STATE: Normal operation, no empty states, no errors.
```

### Ejemplo B: Cántaros Pro Desktop Light
```
Generate the JARS MANAGEMENT screen for OWFINANCE.

VARIANT: Pro Desktop
MODE: Light
DEVICE: Desktop (1440px primary)

SCREEN ELEMENTS:
1. Top utility bar: Logo + "Cántaros" breadcrumb + Period selector (Mayo 2026) + AI chat input + Currency chips + Visibility toggle + Notifications + Avatar
2. Left sidebar: Navigation with Home, Transactions, Jars(active), Reports, Settings
3. KPI summary row (3 cards):
   - Ingreso Esperado: $1,200.00
   - Total Asignado: $1,200.00 (100%)
   - Total Disponible: $660.80
4. Jars allocation table:
   Columns: Jar | % | Presupuesto | Ajustes | Presup. Ajustado | Gastado | Disponible | Restante | Acciones
   Rows with sample data for all 6 jars
   Footer row with totals
5. Idle money alert card: "Tienes $120.00 en la cuenta Efectivo sin asignar a ningún cántaro"
6. Quick actions: Ajustar balance | Transferir entre cántaros | Cerrar mes | Ver ahorro teórico
7. FAB in bottom-right corner + AI floating icon above it

INTERACTIVE HINTS:
- Drag handle on jar rows (reorder priority)
- Inline percent editing (click to edit)
- Surplus jars show green, deficit show red
- Progress bars per jar showing spent vs allocated
```

### Ejemplo C: Transacciones Lite Mobile Dark
```
Generate the TRANSACTIONS LIST screen for OWFINANCE.

VARIANT: Lite Mobile
MODE: Dark
DEVICE: Mobile (375px primary)

SCREEN ELEMENTS:
1. Header: "Transacciones" title + Search icon + Filter icon
2. Period chips: Esta Semana | Este Mes (active) | Este Año
3. Summary cards (2 side by side): Ingresos $1,200.00 (green) | Gastos $842.67 (red)
4. Category filter: Horizontal scrollable pills — Todos(active), 🏠 Necesidades, 📚 Educación, 💰 Ahorro, 🎮 Diversión, 🤝 Dar, 🚑 Emergencias
5. Transaction list (cards):
   - Supermercado Central | Alimentación | - $45.30 | Hoy, 2:30pm
   - Recarga Movistar | Servicios | - $3.00 | Ayer, 10:15am
   - Ingreso Freelance | Freelance | + $200.00 | 22 May
   - Gasolina | Transporte | - $15.00 | 21 May
   - Proteína Gym | Salud | - $28.50 | 20 May
   - Cashea Cuota #2 | Financiamiento | - $9.33 | 19 May
   - Pago Banesco Servicios | Servicios | - Bs 1,250 (~$1.80) | 18 May
6. "Cargar más" button at bottom
7. Bottom nav: Home, Transactions(active), [+], Jars, Settings
8. FAB for quick add

STATE: Normal with data. Show secondary currency for Bs transactions in muted text.
```

### Ejemplo D: Quick Add Modal Light
```
Generate the QUICK ADD TRANSACTION MODAL for OWFINANCE.

VARIANT: Lite (bottom sheet on mobile)
MODE: Light
DEVICE: Mobile (375px primary)

SCREEN ELEMENTS:
1. Bottom sheet with drag handle at top
2. Type toggle: Gasto (red, active) | Ingreso (green) | Transferencia (purple)
3. Giant amount input: "$ 0.00" centered, Display XL size
4. Description input: "¿En qué gastaste?" placeholder
5. Category picker grid (2 columns):
   - 🍔 Alimentación, 🚗 Transporte, 🏠 Vivienda, 💊 Salud
   - 📚 Educación, 🎮 Diversión, 👕 Ropa, 📱 Servicios
   - 🤝 Dar, 💰 Ahorro, 🚑 Emergencia, 📦 Otro
6. Account selector: Efectivo ($) | Banesco (Bs) | Binance (USDT)
7. Date: "Hoy" with calendar icon
8. Primary CTA: "Guardar" pill button, full width, brand-primary
9. Secondary: "Más opciones" text link

STATE: Empty form, ready for input. Category "Alimentación" pre-selected as hint.
```

---

## NOTAS TÉCNICAS PARA CONVERSIÓN A QUASAR/VUE3

```
Cuando conviertas el output HTML a componentes Vue/Quasar:
- <button> → <q-btn> con same styling
- <input> → <q-input> o <q-field>
- Cards → <q-card> con custom CSS para radius/shadow
- Toggle → <q-btn-toggle> o <q-tabs>
- Progress → <q-linear-progress>
- Chips → <q-chip>
- Dialogs → <q-dialog> con <q-card>
- Bottom sheet → <q-dialog position="bottom">
- Icons → <q-icon name="material-symbols:home" />
- Layout → <q-layout> + <q-header> + <q-footer> + <q-page>
- Store → Pinia (auth, jars, transactions, ui, period)
- API calls → Axios interceptor con /api/v1 prefix y Sanctum token
```
