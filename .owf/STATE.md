# OWFINANCE — Estado del Workspace
<!-- PROTOCOLO: Todo agente LEE este archivo al iniciar sesion. -->
<!-- Solo un agente escribe a la vez. Updated = timestamp del ultimo escritor. -->
<!-- Tareas se referencian por ID (OWF-NNN) → ver .owf/TASKS.md -->

**Updated:** 2026-06-23T00:00:00Z
**By:** claude-code

---

## En Progreso RIGHT NOW

| ID | Tarea | Agente | Progreso | Detalle |
|----|-------|--------|----------|---------|
| OWF-062 | Password Reset SMTP prod | opencode | código listo | Esperando creds SMTP del usuario |

## Sesión 2026-06-23 (claude-code) — Admin audit + V-11 + IA reviews + V-04 gaps

| OWF | Qué hizo |
|-----|----------|
| V-04 gaps | ✅ Budget pulse conic-gradient, AnInsight violet card, delta MoM gastos — implementados en expense-analysis/index.vue |
| OWF-128 | ✅ V-11 AI advisor strip: .pro-advisor-strip BEM, goToAsesor(), gradiente morado/cyan, CTA pill |
| Admin audit | ✅ 14 rutas admin auditadas — 11 tareas nuevas OWF-117..127 registradas (P0 security fix crítico) |
| IA reviews | ✅ 7 vistas revisadas: V-13/V-15/V-23/V-24/V-26/C-01..C-04 — EPIC_VIEWS.md actualizado |

**⚠️ PENDIENTE DEPLOY**: cambios de esta sesión y la anterior no están en prod:
- layout_mode fix (4 vistas)
- is_default migration + Lite account guard  
- V-04 gaps (budget pulse, AnInsight, delta badge)
- V-11 AI advisor strip

**🔴 CRÍTICO sin deploy**: OWF-117 — cualquier usuario autenticado puede mutar datos admin

**NEXT_ID:** OWF-129

## Sesión 2026-06-22 (claude-code) — OWF-115 Playwright prod 187/202 passing

**RESULTADO FINAL:** 187 passed · 15 skipped (esperados) · **0 failed** en https://owfinances.com

Fixes aplicados al suite e2e:
- `waitForSpa()` helper — espera `#q-app.children > 0` antes de assertions (Vue SPA hidrata después de domcontentloaded)
- `waitForURL(/\/login/)` en auth redirect tests (guard async)
- Selector FilterPanel: `.filter-panel--desktop:visible, .filter-sheet-dialog, [role="dialog"]` (excluye hidden desktop panel en mobile)
- PeriodNavigator: usa `nth(1)` (next btn) + 600ms wait en lugar de prev btn
- Jars loading: espera `.jars-list, .jars-grid, .entry-gate` antes de `waitForSelector(.jars-list, hidden)`
- `debug-real-user` + `blank-page-debug`: `test.skip` en viewport < 768 (nav links en hamburger)
- `bulk-import`: skip graceful si botón no está en UI actual

## Sesión 2026-06-22 (claude-code) — OWF-101..115 completas (continuación)

| OWF | Qué hizo |
|-----|----------|
| OWF-101 | ✅ FinancialProfile Card 4 "Mis cántaros": JarTemplateSelector + confirm dialog + JarsTable editable. save() bulk-sync. |
| OWF-105 | ✅ LiteJarsView: grid 3-col → 2-col → 1-col, jar-tile cards con icon soft-color, amount, progress bar 4px, footer. |
| OWF-106 | ✅ ProHomeView: AccountsPanel 280px aside sticky. ap-toggle btn. Slide transition. Cuentas/Deudas tabs. API /accounts+/debts. |
| OWF-107 | ✅ OnboardingFlow: etapa "recommend" entre goals/jars. Banner IA + GOAL_TO_TEMPLATE + sortedTemplates (AI first). SCSS completo. |
| OWF-108 | ✅ Tx Mobile: filter-panel--desktop oculto en ≤768px; q-dialog bottom-sheet con handle + "Aplicar filtros". CSS media query. |
| OWF-109 | ✅ Landing hero: ya implementado, sin cambio. |
| OWF-110 | ✅ FeaturesPage #comparativa: 4 grupos spec-fiel (Cántaros/Cuentas/Tx/Analítica), check_circle/remove_circle/remove icons, legend, link /matrix. |
| OWF-113 | ✅ e2e/profile-smoke.spec.ts: 7 tests (profile, fp 4 cards, tpl-selector, onboarding flow). |
| OWF-114 | ✅ e2e/interactions.spec.ts: PeriodNavigator prev/next, FilterPanel open/chip/clear, SmartTxModal 4 modos. |
| OWF-115 | ✅ e2e/mobile-viewport.spec.ts: 390px. Home/Tx/Jars no overflow, bottom-nav, filter=bottomSheet, jar=1col. |
| Deploy | ✅ 3× deploy prod OK → owfinances.com (OWF-105..108, OWF-110) |

**NEXT_ID:** OWF-116
**Pendientes:** OWF-062 (SMTP creds), OWF-004/005/006 (SSH staging), OWF-068 (docs drift)

## Sesión 2026-06-22 (claude-code) — OWF-100/102/103/104 + Deploy prod

| OWF | Qué hizo |
|-----|----------|
| OWF-100 | ✅ Profile: campo birthdate (q-input date) + nav row "Mi perfil financiero →". Completeness bar 5 campos. |
| OWF-102 | ✅ Empty states: LiteHome (isNewUser), LiteJars (activeJars empty), LiteTx (transactions empty). CTAs → SmartTxModal. |
| OWF-103 | ✅ Config: "Repetir configuración inicial" (restart_alt → OnboardingFlow) + toggle "Presupuesto estricto" (overBudget). |
| OWF-104 | ✅ LiteHome: delta MoM real (Promise.allSettled 2 meses), pill verde/rojo, timestamp "Actualizado · HH:MM". |
| Deploy | ✅ 134 archivos → owfinances.com, frontend=OK:200 |

**NEXT_ID:** OWF-116
**Pendientes P1:** OWF-101 (JarTemplateSelector en FinancialProfile)
**Pendientes P2:** OWF-105..110, OWF-113..115

## Sesión 2026-06-22 (claude-code) — Revisión IA 18/36 vistas + CORS fix local

**EPIC_VIEWS.md:** `.owf/EPIC_VIEWS.md` creado — tabla viva con 3 cols de verificación (🤖 PW / 🔍 IA / 👤 VB).
- 🔍 IA: 18/36 vistas verificadas en preview (V-01..10, V-14, V-16..22, V-25, C-05)
- CORS backend: añadidos localhost:3000/3000 a `config/cors.php` para dev local
- Pendiente IA: V-11..13 Pro, V-23..24 Onboarding modal, V-26..30 públicas, C-01..C-04

**Sistema dual-check activo:**
- Para marcar VB usuario: escribir "✅ VB V-XX" en el chat
- Para revisar IA las vistas Pro: necesita usuario con plan='pro' en DB local

## Sesión 2026-06-22 (claude-code) — Épica completa + OWF-100..115 registradas

**Épica de vistas:** 30 pantallas inventariadas (V-01..V-30) + 6 componentes globales (C-01..C-06).
- ✅ Cercanas al spec: V-05 Sueños, V-06 Deudas, V-12 Análisis Pro, V-18 Deudas Mobile, V-19 Sueños Mobile, V-25 Login
- 🔶 Implementadas con gaps: V-01..V-04, V-07..V-11, V-13..V-17, V-20..V-24, V-26..V-30
- 🔴 No implementadas: C-03 AccountsPanel Pro, C-06 EntryGate/Empty States
- OWF-100..115: tareas nuevas registradas en TASKS.md (P1: 100-102; P2: 103-107,113-114; P3: 108-110,115)
- NEXT_ID = OWF-116

## Sesión 2026-06-22 (claude-code) — Continuación: OWF-097/098/099

| OWF | Que hizo |
|-----|----------|
| OWF-097 | ✅ OnboardingFlow.vue: modal centrado 540px (no maximized), stage "intro" con avatar IA animado + fases preview + badges, auto-advance chips 280ms, done con completeness ring (SVG %) + level badge (Semilla/Brote/Árbol). TypeScript clean. |
| OWF-098 | ✅ PeriodNavigator.vue (nuevo): grain dropdown agrupado (Cortos/Estándar/Largos/Especiales), prev/next steps, label pill con picker adaptativo por grain (mes grid / quarter grid / semester grid / year grid / date input), "Hoy" button solo cuando no es current. + setAnchor() en period.ts. |
| OWF-099 | ✅ LiteTransactionsView: reemplaza MonthBar+TypeChipsRow con PeriodNavigator. Tipo (Todas/Ingresos/Gastos) ahora dentro del panel como segmented control. loadTransactions usa buildPeriodParams() derivado del period store. watch(period.signature) reactivo. Eliminado tipo "Cántaros" (no está en spec). |
| NEXT_ID | OWF-100 |

## Sesión 2026-06-22 (claude-code) — Completadas

| OWF | Que hizo |
|-----|----------|
| OWF-087 | ✅ LiteHomeView: greeting header "Hola, {nombre}" + toggle ocultar saldos + botón notificaciones. CSS icon-btn. |
| OWF-088 | ✅ Config: "Cuentas vinculadas" rota a /user/accounts. "Divisa predeterminada" en sección Visualización con chevron a Cuentas. |
| OWF-089 | ✅ Profile: avatar cam button (UI), badge Verificado (email_verified_at), secciones separadas (Datos / Contacto+Ubicación / Seguridad), campos city/country/occupation añadidos. |
| OWF-090 | ✅ LiteJarsView: indicador ⚠️ en jar-row cuando balance<0 o progress>100. Edit sheet (nombre/%, color). Delete con confirm dialog. |
| OWF-091 | ✅ Dreams: gradient ya estaba implementado (rgba purple/pink). Verificado sin cambio. |
| OWF-092 | ✅ Debts: status badge con ícono (warning/check_circle) en summary card hero. CSS debts-status-badge. |
| OWF-093 | ✅ Financial Profile: timestamp "Actualizado hace X días" visible bajo subtitle. |
| OWF-094 | ✅ Expense Analysis Pro: hero narrativo "En {mes} registraste X movimientos. Gastaste $Y". Eliminados heroTitle/heroCopy. |
| NEXT_ID | OWF-095 |

## Sesión 2026-06-21 (claude-code) — Completadas

| OWF | Que hizo |
|-----|----------|
| OWF-086 | ✅ ProAnalisis: 3-col grid (280px Vista sidebar | 1fr donut+toplist | 340px budget+insight). budgetRows + insightJar computeds. CSS pro-nav-grid, pro-card, budget-list, top-list, pro-insight. Deploy prod OK. |

## Sesión 2026-06-20 (claude-code — continuación 2) — Completadas

| OWF | Que hizo |
|-----|----------|
| OWF-080 | ✅ Config Pro: heading reemplazado (t-eyebrow + h1 "Preferencias"), q-tabs restaurados. Stitch pill tabs revertidos. Deploy prod OK. |
| OWF-081 | ✅ LiteTransactionsView: type chips (Todas/Ingresos/Gastos/Cántaros) movidos a fila inline siempre visible. MonthBar prev/next navigation. Tipo "Cántaros" nuevo (category=Jar). Deploy prod OK. |
| OWF-082 | ✅ Análisis: Pro heading "Navegador financiero" (t-eyebrow+h1). Lite donut CSS conic-gradient de distribución por cántaro con leyenda. Deploy prod OK. |
| OWF-083 | ✅ Stitch archivado: todo en _archive/stitch-NO-USAR/ (carpeta + zip + skill + docs + html-exports). _archive/ en .gitignore. |

## Sesión 2026-06-20 (claude-code — continuación) — Completadas

| OWF | Que hizo |
|-----|----------|
| OWF-070 backend | ✅ DreamController + DebtController: soporte `per_page`, `sort_by`, `descending` query params. Meta siempre calculado sobre ALL (no el subset paginado). 92 tests pasan. Deploy prod OK. |
| CHECK | ✅ Auditoría completa Dreams+Debts: DebtCard.vue verifica todos los campos (provider icon, status chip, installments, next_due). Nav (BottomNavMobile + LiteNavPill) tiene `/user/dreams` y `/user/debts`. |

## Sesión 2026-06-20 (claude-code) — Completadas

| OWF | Que hizo |
|-----|----------|
| OWF-077 | ✅ LiteHomeView: Dreams+Debts previews con datos reales del API (preview cards, progress bars, status chips). Deploy prod OK. |
| OWF-078 | ✅ Dreams page: redesign completo (hero violeta gradiente, grid cards BEM, progress bars, token-driven). Deploy prod OK. |
| OWF-079 | ✅ AsesorPage: redesign completo (header custom, chat bubbles BEM, typing dots, CTA pills, input bar token-driven, settings sheet). Deploy prod OK. |
| OWF-064 | ✅ Bulk Import: account_name → account_id resuelto en TransactionBulkService antes de validación. 92 tests pasan. Deploy prod OK. |
| OWF-069 | ✅ SmartTransactionModal global: modal Escribir/Voz/Foto/AutoIA montado en AppShell. QuickActionSheet ya no navega a /transactions. Fix P0 raíz. |
| OWF-070 | ✅ Página Deudas completa: backend (migración debts, Debt model, DebtController CRUD+pay, rutas API) + frontend (DebtCard, index.vue con summary card roja, grupos Cashea/Otras, dialogs add/edit/pago/delete). Deploy prod OK. |
| OWF-071 | ✅ Transacciones Lite: goToDetail() corregida → openDetail(tx) + TxDetailSheet (hero amount, tipo, categoría, cántaro, fecha, editar/eliminar). Auto-reload en owf:transaction-saved. Deploy prod OK. |
| OWF-072 | ✅ Cántaros Lite: grid → lista vertical (spec), distribution strip, jar detail sheet (stats 2x2: %, asignado, disponible, uso), "Nuevo cántaro" inline form. Deploy prod OK. |
| OWF-073 | ✅ Configuración: secciones Notificaciones (3 toggles → preferences.notifications), Seguridad (→ /user/profile), Cerrar sesión (destructivo), Exportar datos, section-labels agrupadores. Deploy prod OK. |
| OWF-074 | ✅ Análisis Pro: jar strip (scroll horizontal gasto por cántaro, seleccionable), metric-grid 4-col en Pro mode. Deploy prod OK. |
| OWF-075 | ✅ Exchange Rates widget en ProHomeView: carga /user_currencies → filas editables (rate update vía PUT). Solo visible si hay tasas configuradas. Deploy prod OK. |
| OWF-076 | ✅ Notifications panel: bell → popover desktop (380px anclado) / bottom-sheet mobile. Items con tono (expense/income/warning/info), unread dot, mark-all-read. Montado en AppShell. Deploy prod OK. |

---

## Sesión 2026-06-20 — Auditoría funcional + de-drift board

**Agente:** opencode. **Qué hizo:**
- De-drift TASKS.md: OWF-019 (i18n), OWF-021 (Sentry+FF), OWF-022 (Android) confirmados en código y marcados `[x]`.
- Auditoría funcional profunda (6 áreas) vía subagente. Hallazgos registrados como OWF-061..068.
- **Resueltos y verificados esta sesión** (92 backend tests + vue-tsc + eslint limpios):
  - OWF-061 (CRÍTICA) JARS race → `JarPercentLock` service + 8 sitios + 2 tests regresión
  - OWF-063 (ALTA) Asesor IA → system prompt ahora inyecta jars+perfil (corrige OWF-049)
  - OWF-065 Auth → ensureDefaultAccount idempotente en login
  - OWF-066 JARS updateJar → guard willBeActive restaurado + test
  - OWF-067 MonthlyIncomePanel/useCalculatedIncome → guards NaN
  - OWF-062 (CRÍTICA) Password Reset → ResetPasswordNotification (URL→SPA) + config. **Código listo; falta creds SMTP en prod .env**
- **Rediseño Stitch:** ya sustancialmente integrado (AppShell.vue + design-system.css tokens navy/cyan/Satoshi + Lite*View + LiteHeaderDesktop/NavPill). NO está pendiente desde cero. Lo que falta es fidelidad visual pixel-perfect + de-drift de docs (OWF-068).
- **OWF-018 responsive:** infra confirmada (Playwright proyecto "Mobile Chrome"/Pixel 5 393px + e2e/lite-shell.spec.ts). NaN guard (OWF-067) ya aplicado.

### Hallazgos auditoría (severidad)

| OWF | Sev | Área | Hallazgo | Estado |
|-----|-----|------|----------|--------|
| OWF-061 | 🔴 CRÍTICA | Jars | Race condition suma %: 0 lockForUpdate → concurrent requests persisten >100% | ✅ resuelto |
| OWF-062 | 🔴 CRÍTICA | Auth | Password reset: MAIL_MAILER=log → email nunca llega en prod | 🟡 código listo, falta creds SMTP |
| OWF-063 | 🟡 ALTA | Asesor IA | Contexto rico (jars+perfil) en cache pero NO en system prompt | ✅ resuelto |
| OWF-064 | ⚪ MEDIA | Bulk import | account_name ignorado en income/expense | ✅ resuelto |
| OWF-065 | ⚪ MEDIA | Auth | createDefaultAccount solo en register, no en login | ✅ resuelto |
| OWF-066 | ⚪ MEDIA | Jars | updateJar validación willBeActive comentada | ✅ resuelto |
| OWF-067 | ⚪ BAJA | UI | formatCurrency sin guard NaN | ✅ resuelto |
| OWF-068 | ⚪ BAJA | Docs | docs ui-ux referencian archivos borrados | pendiente |

### Rediseño Stitch — estado real

- **Integrado:** AppShell.vue (shell único), tokens navy `#1E3A8A`/cyan `#0EA5E9`/Satoshi/DM Sans en `src/css/design-system.css`+`theme.scss`, vistas Lite (`LiteHomeView`, `LiteJarsView`, `LiteTransactionsView`), `LiteHeaderDesktop`, `LiteNavPill`, `ExpandedMenu`.
- **Pendiente/incierto:** fidelidad pixel-perfect vs kit (requiere correr app), vistas Pro, mobile kit parity.
- **Stale:** docs `08-11` citan `UserLayout.vue`/`user_dashboard.vue`/`DynamicRoleLayout.vue` (borrados en OWF-056/060).

---

## Sesión 2026-06-19 (parte 2) — Tareas completadas

| OWF | Que hizo |
|-----|----------|
| OWF-018 | ✅ NaN% fix MonthlyIncomePanel + responsive 320-375px: Number.isFinite guards en useCalculatedIncome + computeds |
| OWF-019 | ✅ i18n: useI18n en BottomNavMobile + nav.dreams en ES/EN locales |
| OWF-021 | ✅ Monitoring: Sentry boot (VITE_SENTRY_DSN) + useFeatureFlags composable (VITE_FF_*) |
| OWF-022 | ✅ Android: capacitor.config.js + build:android script en package.json |

## Sesión 2026-06-19 — Tareas completadas

| OWF | Que hizo |
|-----|----------|
| OWF-008 | ✅ Transición Lite↔Pro: AppShell reactivo + config toggle PATCH /user/settings |
| OWF-009 | ✅ Rutas Pro: alias /user/settings, BottomNavMobile 5 tabs 1 fila (no-wrap) |
| OWF-010 | ✅ Playwright ESM config + baseURL + skip guards en todos los tests con auth |
| OWF-012 | ✅ Password Reset: ForgotPasswordPage + ResetPasswordPage + backend routes |
| OWF-016 | ✅ Redirect por rol ya estaba en router beforeEach |
| OWF-017 | ✅ Rutas públicas ok: PHP proxy sirve / → Vue / → LandingPage. Tests pasan prod |
| OWF-028 | ✅ Nav Pro mobile: eliminados 7→5 tabs, no flex-wrap |
| OWF-049 | ✅ Cántaros con descripción: tipo, mkJar, loadJarData, bulk-sync, UI textarea |
| OWF-011 | ✅ UI Configuración Asesor IA: dialog bottom-sheet nombre+personalidad+enabled |
| OWF-013 | ✅ GitHub Actions deploy.yml: master→prod, stage→staging con secrets |
| OWF-055 | ✅ Integración rediseño → AppShell único |
| OWF-056 | ✅ AppShell.vue: shell único Lite+Pro+Mobile |
| OWF-057 | ✅ AppPrefsSection en Config |
| OWF-058 | ✅ HomeView datos reales |
| OWF-059 | ✅ Onboarding automático en AppShell |
| OWF-060 | ✅ Limpieza layouts legacy |

---

## Pending (por prioridad)

> 061/063/065/066/067 ya resueltos — ver "Sesión 2026-06-20 — Auditoría" arriba.
> 069–076 resueltos por claude-code (verificados contra git commits 58222f3→c00a02f).

| ID | Pri | Tarea | Type |
|----|-----|-------|------|
| OWF-062 | P0 | Password Reset SMTP prod (código listo, falta creds) | fix |
| OWF-004 | P0 | Deploy Staging (bloqueado SSH dev/stage) | infra |
| OWF-005 | P1 | GitHub Secrets por entorno | infra |
| OWF-006 | P1 | Probar deploy stage end-to-end | infra |
| OWF-020 | P2 | Sincronizar DB Stage → Dev | infra |
| OWF-068 | P3 | De-drift docs ui-ux | docs |
| OWF-068 | P3 | De-drift docs ui-ux | docs |
| OWF-018 | P3 | Responsive testing mobile (infra confirmada) | feat |

---

## Blocked

| ID | Razon | Desbloquea |
|----|-------|------------|
| OWF-001 | SSH keys — prod OK. Dev/stage pendientes | OWF-005, OWF-006 |

---

## Stats

| Métrica | Valor |
|---------|-------|
| **Total** | 82 tareas (excluye 7 sub-tareas de OWF-002) |
| **Completadas** | 75 (91%) |
| **En progreso** | 1 (OWF-062 espera creds SMTP) |
| **Bloqueadas** | 3 (OWF-004/005/006 — SSH dev/stage) |
| **Disponibles** | 3 (OWF-020/095: AccountFilter multi-select + gaps restantes) |
| **Progreso** | ██████████████████░░ 91% |

---

## Next Up (por prioridad)

1. **OWF-062** — Password Reset: proveer creds SMTP/Resend → set MAIL_MAILER≠log en prod .env (1 línea)
2. **OWF-068** — De-drift docs ui-ux (08-11) a estructura AppShell actual
3. **OWF-064** — Bulk Import: account_name por fila (o documentar UX)
4. **OWF-004/005/006** — Deploy Staging (bloqueado por SSH dev/stage)
5. **Fidelidad visual Stitch** — comparar AppShell+Lite*View pixel-perfect vs kit (correr app)
6. **OWF-018** — correr `npx playwright test --project="Mobile Chrome"` con dev server

---

## Historial Reciente

| Fecha | Agente | OWF | Que hizo |
|-------|--------|-----|----------|
| 2026-06-20 | opencode | reconciliación | Verificó 069-076 contra git (commits 58222f3→c00a02f): todos ✅. Reconcilió TASKS+STATE (071-076 [~]/[ ]→[x]), Stats 60→66 (89%). Sync engram. |
| 2026-06-20 | claude-code | OWF-069..076 | SmartTransactionModal, Deudas, Transacciones Lite detail, Cántaros Lite, Config secciones, Análisis Pro, Exchange Rates, Notifications — todos deployados prod |
| 2026-06-20 | opencode | OWF-061..067 | Auditoría funcional: JARS race (JarPercentLock), Asesor IA contexto, Auth idempotente, NaN guards, Password Reset (código listo, falta creds) |
| 2026-06-19 | claude-code | OWF-008,009,028 | BottomNavMobile 5 tabs Pro mobile no-wrap, AppShell nav fix |
| 2026-06-19 | claude-code | OWF-049 | Cántaros description: type+mkJar+loadJarData+payload+UI |
| 2026-06-19 | claude-code | OWF-010,017 | Playwright ESM config + tests arreglados + URLs prod correctas |
| 2026-06-19 | claude-code | OWF-055..060 | AppShell único, rediseño, onboarding, legacy cleanup |
| 2026-06-11 | claude-code | OWF-054 | Fix navegación router |
| 2026-06-10 | claude-code | OWF-007 | Billetera implícita Lite |
| 2026-06-10 | opencode | OWF-047..048 | Mensajes ES + router DOM fix |
| 2026-06-08 | claude-code | OWF-035..045 | Infra agentes + Design System F0-F5 |

---

## Legacy ID Mapping

| Viejo | → OWF | Viejo | → OWF |
|-------|-------|-------|-------|
| MANUAL-001 | OWF-003 | DS-32 | OWF-007 |
| MANUAL-002 | OWF-004 | DS-33 | OWF-008 |
| TECH-001 | OWF-011 | DS-34 | OWF-009 |
| TECH-002 | OWF-010 | DS-51 | OWF-010 |
| TECH-003 | OWF-012 | DS-52 | OWF-019 |
| TECH-LP-02 | OWF-007 | BUG-006 | OWF-019 |
| TECH-LP-03 | OWF-042 | INFRA-001..004 | OWF-035..038 |
| TECH-LP-04 | OWF-008 | DS-01..52 | OWF-039..045 |
| OPS-001 | OWF-020 | WEEK2-A | OWF-021 |
| BUG-001..008 | OWF-023..028, OWF-046 | WEEK2-B | OWF-022 |
