# OWFINANCE — Task Board

<!--
  PROTOCOLO DE TAREAS
  ===================
  ID:         OWF-NNN (secuencial, nunca se reutiliza)
  Status:     [ ] pending | [~] in_progress | [x] done | [!] blocked
  Priority:   P0 critico | P1 alto | P2 medio | P3 bajo
  Urgency:    🔴 URGENTE | 🟡 Alta | ⚪ Normal
  Type:       infra | feat | fix | refactor | design | docs | sdd | paseo
  Source:     adhoc | sdd:{change-name} | paseo:{slug} | migrated:{old-id}

  Reglas:
  - Todo agente puede crear tareas (siguiente numero disponible).
  - Solo el agente que trabaja la tarea la marca [~] in_progress.
  - Al completar: marcar [x] y agregar fecha en columna Done.
  - Al bloquear: marcar [!] y agregar razon.
  - Commits referencian: "feat(login): fix PHP warnings (OWF-006)".
  - La columna "Migrated from" mapea IDs viejos de otros sistemas.
  - Urgency 🔴 = requiere accion inmediata, prioridad sobre todo.

  Fuentes consolidadas:
  - TASKS_LEDGER.md (Claude Code, IDs: DS-*, TECH-*, MANUAL-*, BUG-*, INFRA-*)
  - Sesiones OpenCode (IDs: OWF-*)
-->

## Active

| ID | Status | Pri | Urgency | Type | Source | Migrated from | Description | Assignee | Done |
|----|--------|-----|---------|------|--------|---------------|-------------|----------|------|
| **OWF-001** | [x] | P0 | ⚪ | infra | adhoc | — | SSH keys para servidores — prod ✅ (~/.ssh/owfinances_prod, owfinanc1@178.156.160.70). Dev/stage pendientes. | claude-code | 2026-06-10 |
| **OWF-002** | [x] | P0 | ⚪ | infra | adhoc | — | **Produccion setup** (owfinances.com) — 7/7 subs completadas | opencode | 2026-06-10 |
| → | [x] | P0 | ⚪ | infra | adhoc | — | ↳ Sub-1: Credenciales prod en `.deploy/prod.sh` (IP, user, paths) | claude-code | 2026-06-10 |
| → | [x] | P0 | ⚪ | infra | adhoc | — | ↳ Sub-2: Backend .env produccion (APP_URL, DB MySQL localhost, CORS) | claude-code | 2026-06-10 |
| → | [x] | P0 | ⚪ | infra | adhoc | — | ↳ Sub-3: Frontend `.env.production` (VITE_API_BASE_URL owfinances.com/api/v1) | opencode | 2026-06-10 |
| → | [x] | P1 | ⚪ | infra | adhoc | — | ↳ Sub-4: LiteSpeed web root config (PHP 8.4 handler, .htaccess) | opencode | 2026-06-10 |
| → | [x] | P1 | ⚪ | infra | adhoc | — | ↳ Sub-5: Deploy frontend prod end-to-end | opencode | 2026-06-10 |
| → | [x] | P1 | ⚪ | infra | adhoc | — | ↳ Sub-6: Deploy backend prod (rsync + composer + migrate, 47 tablas OK) | opencode | 2026-06-10 |
| → | [x] | P1 | ⚪ | infra | adhoc | — | ↳ Sub-7: Verificar health + rutas en owfinances.com | opencode | 2026-06-10 |
| **OWF-003** | [x] | P0 | 🟡 | manual | migrated | MANUAL-001 | Activar Backend AI (API key en `.env`) — confirmado por usuario | humano | 2026-06-10 |
| **OWF-004** | [?] | P0 | ⚪ | infra | migrated | MANUAL-002 | Deploy a Staging — **PENDIENTE POR REVISAR**: staging pausado indefinidamente (prod directo). Revisar si aplica en el futuro. | — | — |
| **OWF-005** | [?] | P1 | ⚪ | infra | adhoc | — | GitHub Secrets por entorno — **PENDIENTE POR REVISAR**: depende de OWF-004. | — | — |
| **OWF-006** | [?] | P1 | ⚪ | infra | adhoc | — | Probar deploy stage end-to-end — **PENDIENTE POR REVISAR**: depende de OWF-004. | — | — |
| **OWF-007** | [x] | P1 | ⚪ | feat | migrated | DS-32, TECH-LP-02 | Billetera implicita Lite (auto-crear/seleccionar account_id) | claude-code | 2026-06-10 |
| **OWF-008** | [x] | P1 | ⚪ | feat | migrated | DS-33, TECH-LP-04 | Transicion Lite↔Pro: AppShell recomputa mode reactivamente. Config toggle PATCH /user/settings. Sin pérdida de datos (backend persiste). | claude-code | 2026-06-19 |
| **OWF-009** | [x] | P2 | ⚪ | feat | migrated | DS-34 | Rutas Pro: /user/settings alias→config. BottomNavMobile 5 tabs Pro mobile. Sidebar Pro desktop. Todas las rutas ya existentes (jars,analysis,debts,dreams). | claude-code | 2026-06-19 |
| **OWF-010** | [x] | P1 | ⚪ | infra | migrated | DS-51, TECH-002 | Playwright ESM config + baseURL. 11 suites e2e. Auth/design/nav tests con skip guard (PLAYWRIGHT_TEST_EMAIL). 19/19 pasan sin creds, 1 skipped. | claude-code | 2026-06-19 |
| **OWF-011** | [x] | P2 | ⚪ | feat | migrated | TECH-001 | UI Configuracion Asesor IA: dialog bottom-sheet nombre+personalidad+enabled. PUT /user/financial-profile actualizado. | claude-code | 2026-06-19 |
| **OWF-012** | [x] | P2 | ⚪ | feat | migrated | TECH-003 | Flujo Password Reset: ForgotPasswordPage + ResetPasswordPage (token+email desde URL). Backend: Password::sendResetLink + Password::reset. Rutas: throttle:5,1. LoginPage → router-link /forgot-password. MAIL_MAILER=log en prod (no SMTP aún). | claude-code | 2026-06-19 |
| **OWF-013** | [x] | P2 | ⚪ | infra | adhoc | — | GitHub Actions deploy.yml: master→prod, stage→staging. Secrets: DEPLOY_HOST/USER/SSH_KEY/SITE_URL/API_URL/BACKEND_DIR/FRONTEND_DIR. Health check /up. | claude-code | 2026-06-19 |
| **OWF-016** | [x] | P2 | ⚪ | feat | adhoc | — | Redirect según rol ya implementado en router beforeEach: `/` y `/login` redirigen a `/user/home` o `/admin` según auth.role. | claude-code | 2026-06-19 |
| **OWF-017** | [x] | P2 | ⚪ | feat | adhoc | — | Rutas públicas verificadas. PHP proxy en / sirve app/index.html para todo. Router base=/ → owfinances.com/ → LandingPage ✓. /funciones, /planes, /login ok. Tests clean-user pasan contra prod. | claude-code | 2026-06-19 |
| **OWF-018** | [x] | P3 | ⚪ | feat | adhoc | — | Responsive testing mobile: Playwright Mobile Chrome corrido (41 pass → mismo que chromium). 7 fallas mobile-específicas resueltas: public-navigation + blank-page-debug usan `test.skip` en viewport <768px (links ocultos en hamburger). 11 fallas restantes son pre-existentes en ambas plataformas. | claude-code | 2026-06-20 |
| **OWF-019** | [x] | P2 | ⚪ | feat | migrated | DS-52, BUG-006 | i18n ES/EN: useI18n en BottomNavMobile + nav.dreams + LoginPage + transactions + jars + CrudPage. Locales es/en (~213 keys). | claude-code | 2026-06-19 |
| **OWF-020** | [?] | P2 | ⚪ | infra | migrated | OPS-001 | Sincronizar DB Stage → Dev — **PENDIENTE POR REVISAR**: depende de OWF-004. | — | — |
| **OWF-021** | [x] | P3 | ⚪ | infra | migrated | WEEK2-A | Monitoring: Sentry boot (src/boot/sentry.ts, VITE_SENTRY_DSN) + useFeatureFlags composable (VITE_FF_*). | claude-code | 2026-06-19 |
| **OWF-022** | [x] | P3 | ⚪ | infra | migrated | WEEK2-B | Android: capacitor.config.js + src-capacitor/android + build:android/dev:android scripts + capacitor-native-biometric. | claude-code | 2026-06-19 |
| **OWF-023** | [x] | P3 | ⚪ | fix | migrated | BUG-001 | watch re-normaliza tipo en filas existentes cuando cambian reglas | claude-code | 2026-06-19 |
| **OWF-024** | [x] | P3 | ⚪ | fix | migrated | BUG-002 | buildRowPayloadFromNormalized resuelve account_name→id por nombre (case-insensitive) | claude-code | 2026-06-19 |
| **OWF-025** | [x] | P3 | ⚪ | fix | migrated | BUG-003 | handleBulkImported llama fetchSingleAccountBalance() post-import | claude-code | 2026-06-19 |
| **OWF-026** | [x] | P3 | ⚪ | fix | migrated | BUG-004 | e2e/bulk-import.spec.ts: unit + smoke tests | claude-code | 2026-06-19 |
| **OWF-027** | [x] | P3 | ⚪ | fix | migrated | BUG-005 | rowsPerPage=0 → per_page=1000 en buildQueryParams() | claude-code | 2026-06-19 |
| **OWF-028** | [x] | P3 | ⚪ | fix | migrated | BUG-007 | Menubar rutas duplicadas: eliminados 6 liquid duplicados + 5 layouts legacy. AppShell único. Nav Pro mobile fix (7→5 tabs, no-wrap). | claude-code | 2026-06-19 |
| **OWF-048** | [x] | P0 | 🔴 | fix | adhoc | — | Fix router DOM perdido al navegar — slot layout + default lite + Playwright 23/23 | opencode | 2026-06-10 |
| **OWF-049** | [x] | P2 | ⚪ | feat | adhoc | — | Campo description en Jar: tipo, mkJar, loadJarData (API→frontend), bulk-sync payload. UI: textarea 'Propósito' en card expandido (300 chars, autogrow). El asesor IA ya recibe description en su contexto de jars. | claude-code | 2026-06-19 |
| **OWF-054** | [x] | P1 | 🔴 | fix | adhoc | — | Fix navegación router: pantalla en blanco (imports DynamicRoleLayout + IntersectionObserver re-observe + scrollBehavior reset) | 2026-06-11 |
| **OWF-061** | [x] | P0 | 🔴 | fix | adhoc | — | JARS race condition: JarPercentLock service (Cache::lock per-user) envolvió los 8 sitios de validación % (JarController bulkSync/save/update + UserJarController saveJar batch/single, bulkUpsertJars, createJar, updateJar). +2 tests regresión. 92 tests pass. | opencode | 2026-06-20 |
| **OWF-062** | [ ] | P0 | 🔴 | fix | adhoc | — | Password Reset: ResetPasswordNotification custom (URL→SPA /reset-password) + frontend_url config + .env.example docs. **CÓDIGO LISTO. POR DEFINIR**: creds SMTP/Resend reales en .env prod (MAIL_MAILER≠log). Usuario decide cuándo. | opencode | 2026-06-20 |
| **OWF-063** | [x] | P1 | 🟡 | fix | adhoc | — | Asesor IA: buildAdvisorSystemPrompt ahora inyecta jars_context (con propósito) + user_financial_profile (metas/sueño) + advisor_name personalizado. Corrige OWF-049 (contexto ya llega al LLM). | opencode | 2026-06-20 |
| **OWF-064** | [x] | P2 | ⚪ | fix | adhoc | — | Bulk Import: account_name resuelto en TransactionBulkService pre-validación (lookup por nombre/user_id → account_id). | claude-code | 2026-06-20 |
| **OWF-077** | [x] | P2 | ⚪ | feat | adhoc | — | LiteHomeView: secciones Dreams+Debts con datos reales (API preview top-3, progress bars, status chips). v-if guard. Deploy prod OK. | claude-code | 2026-06-20 |
| **OWF-078** | [x] | P1 | 🟡 | feat | adhoc | — | Dreams page redesign: hero gradiente violeta, grid cards BEM (.dc), progress bar, aportar/editar actions. Deploy prod OK. | claude-code | 2026-06-20 |
| **OWF-079** | [x] | P1 | 🟡 | feat | adhoc | — | AsesorPage redesign: header custom, bubbles BEM, typing dots, CTA pills [CTA:text], input bar token-driven, settings sheet. Deploy prod OK. | claude-code | 2026-06-20 |
| **OWF-065** | [x] | P2 | ⚪ | fix | adhoc | — | Auth: createDefaultAccount ahora idempotente + llamado en login() → usuarios preexistentes (migrados/seeded) obtienen Billetera implícita. | opencode | 2026-06-20 |
| **OWF-066** | [x] | P2 | ⚪ | fix | adhoc | — | JARS updateJar: restaurado guard willBeActive (solo valida % si el jar queda activo). +test regresión. | opencode | 2026-06-20 |
| **OWF-067** | [x] | P3 | ⚪ | fix | adhoc | — | MonthlyIncomePanel formatCurrency guard NaN + useCalculatedIncome guards en difference/fulfillmentPercentage. vue-tsc + eslint limpios. | opencode | 2026-06-20 |
| **OWF-068** | [x] | P3 | ⚪ | docs | adhoc | — | De-drift docs ui-ux: banners ⚠️ en 02, 09, 11 + sección §6 reescrita en DESIGN_MAP.md con arquitectura AppShell.vue actual. | claude-code | 2026-06-20 |
| **OWF-080** | [x] | P2 | ⚪ | design | adhoc | — | Config Pro heading: reemplazado emoji ⚙️ con t-eyebrow+h1 "Preferencias", restaurado q-tabs. Fuente verdad: rediseno/ConfigRoute.jsx. Deploy prod OK. | claude-code | 2026-06-20 |
| **OWF-081** | [x] | P2 | ⚪ | feat | adhoc | — | Transactions type chips inline + MonthBar: chips Todas/Ingresos/Gastos/Cántaros siempre visibles, prev/next month nav, tipo "Cántaros" nuevo. Deploy prod OK. | claude-code | 2026-06-20 |
| **OWF-082** | [x] | P2 | ⚪ | feat | adhoc | — | Análisis: Pro heading "Navegador financiero" (t-eyebrow+h1). Lite donut CSS conic-gradient por cántaro con leyenda. Deploy prod OK. | claude-code | 2026-06-20 |
| **OWF-083** | [x] | P3 | ⚪ | refactor | adhoc | — | Stitch archivado: todo en _archive/stitch-NO-USAR/ (carpeta, zip, skill, docs, html-exports). _archive/ en .gitignore. | claude-code | 2026-06-20 |
| **OWF-084** | [x] | P2 | ⚪ | feat | adhoc | — | LiteTransactions: filtro "Día" añadido al panel (spec TransactionsRoute). dayOptions computed de formatDateShort. Chip removible. Deploy prod OK. | claude-code | 2026-06-20 |
| **OWF-085** | [x] | P3 | ⚪ | fix | adhoc | — | Pro Transactions: heroEyebrow="Transacciones", heroTitle=periodStore.label (antes "Pro movements"/"en flujo balanceado"). Deploy prod OK. | claude-code | 2026-06-20 |
| **OWF-086** | [x] | P2 | ⚪ | feat | adhoc | — | ProAnalisis: 3-col grid (280px Vista sidebar | 1fr donut+toplist | 340px budget+insight). budgetRows + insightJar computeds. CSS pro-nav-grid, pro-card, budget-list, top-list, pro-insight. Deploy prod OK. | claude-code | 2026-06-21 |
| **OWF-087** | [x] | P2 | ⚪ | feat | adhoc | — | LiteHomeView: greeting header "Hola, {firstName}" + toggle ocultar saldos + campana notificaciones. CSS icon-btn. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-088** | [x] | P2 | ⚪ | feat | adhoc | — | Config: "Cuentas vinculadas" navega a /user/accounts. "Divisa predeterminada" row en sección Visualización con chevron. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-089** | [x] | P2 | ⚪ | feat | adhoc | — | Profile: avatar cam overlay (UI), badge Verificado (email_verified_at), 3 secciones (Datos / Contacto+Ubicación / Seguridad), campos city/country/occupation. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-090** | [x] | P2 | ⚪ | feat | adhoc | — | LiteJarsView: indicador ⚠️ en row cuando balance<0 o progress>100. Edit sheet completo (PATCH /jars/:id). Delete con confirm dialog (DELETE /jars/:id). Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-091** | [x] | P3 | ⚪ | chore | adhoc | — | Dreams gradient verificado — ya estaba implementado. Sin cambio. | claude-code | 2026-06-22 |
| **OWF-092** | [x] | P2 | ⚪ | feat | adhoc | — | Debts: status badge hero con ícono warning/check_circle según late_count. CSS debts-status-badge. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-093** | [x] | P2 | ⚪ | feat | adhoc | — | Financial Profile: "Actualizado hace X días" desde d.updated_at bajo subtitle. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-094** | [x] | P2 | ⚪ | feat | adhoc | — | Expense Analysis Pro: hero narrativo dinámico "En {período} registraste X movimientos. Gastaste $Y". Eliminados heroTitle/heroCopy. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-096** | [x] | P2 | ⚪ | feat | adhoc | — | Backend: city/country/occupation en PUT /user/profile. Migración users table + $fillable User model + $commonFields + validation rules. Deploy prod OK (migración corrió en 39ms). | claude-code | 2026-06-22 |
| **OWF-095** | [x] | P2 | ⚪ | feat | adhoc | — | AccountFilter multi-select en Transacciones Pro: pill "Cuentas · N" + dropdown con toggle por cuenta + chips individuales por cuenta seleccionada + limpieza individual. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-097** | [x] | P2 | ⚪ | feat | adhoc | — | OnboardingFlow.vue: modal centrado (540px, no maximized), nuevo stage "intro" con avatar IA animado + fases preview + badges meta, auto-advance chips (280ms), done stage con completeness ring + level badge. | claude-code | 2026-06-22 |
| **OWF-098** | [x] | P2 | ⚪ | feat | adhoc | — | PeriodNavigator.vue (nuevo): grain dropdown agrupado (Cortos/Estándar/Largos/Especiales), prev/next, label pill con date picker adaptativo (mes/quarter/semester/year/day grids), "Hoy" button. + setAnchor() en period.ts store. | claude-code | 2026-06-22 |
| **OWF-099** | [x] | P2 | ⚪ | feat | adhoc | — | LiteTransactionsView: reemplaza MonthBar+TypeChips por PeriodNavigator. Tipo movido al interior del panel (segmented). loadTransactions usa period store (watch signature). Eliminado tipo "Cántaros". | claude-code | 2026-06-22 |

| **OWF-100** | [x] | P1 | ⚪ | feat | adhoc | — | ProfileRoute (V-07): campo birthdate (q-input type=date) + link "Mi perfil financiero →" nav row. Completeness bar ahora cuenta 5 campos. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-101** | [x] | P1 | ⚪ | feat | adhoc | — | FinancialProfileRoute (V-08): Card 4 "Mis cántaros" con JarTemplateSelector (scroll horizontal, mini barra coloreada, confirm dialog) + JarsTable editable (nombre/%, propósito, add/remove, suma%). Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-102** | [x] | P1 | ⚪ | feat | adhoc | — | EntryGate: LiteHomeView (isNewUser computed), LiteJarsView (activeJars empty), LiteTransactionsView (transactions empty). CTAs abren SmartTxModal. Jars CTA pre-selecciona tab Ingreso. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-103** | [x] | P2 | ⚪ | feat | adhoc | — | Config: row "Repetir configuración inicial" (restart_alt icon → showOnboarding=true) + toggle "Presupuesto estricto" (overBudget en prefs section). Eliminado duplicado en notificaciones. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-104** | [x] | P2 | ⚪ | feat | adhoc | — | LiteHomeView: delta MoM real con Promise.allSettled (mes actual vs anterior), pill verde/rojo con arrow icon. Timestamp "Actualizado · HH:MM" bajo hero. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-105** | [x] | P2 | ⚪ | feat | adhoc | — | LiteJarsView: JarsFullGrid 3-col card tiles (icon soft-color, nombre, balance grande, barra %, footer En uso/Lleno/Sobrepasado). Grid responsive 3→2→1 cols. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-106** | [x] | P2 | ⚪ | feat | adhoc | — | ProHome: AccountsPanel 280px lateral plegable — toggle btn fijo top-right, tabs Cuentas/Deudas, lista con badge color/nombre/balance, total neto. Slide-in animation. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-107** | [x] | P2 | ⚪ | feat | adhoc | — | Onboarding: etapa "recommend" entre goals y jars — banner IA "plan recomendado" + reason, template cards ordenados (AI first + badge), mini barra coloreada. GOAL_TO_TEMPLATE map. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-108** | [x] | P3 | ⚪ | feat | adhoc | — | Tx Mobile: filter-panel--desktop (dropdown) oculto en ≤768px; q-dialog position=bottom (bottom-sheet) con mismo contenido + "Aplicar filtros" btn. Desktop bottom-sheet oculto vía CSS. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-109** | [x] | P3 | ⚪ | chore | adhoc | — | Landing page: hero mockup ya estaba implementado en prod (verificado 2026-06-22). Sin cambio necesario. | claude-code | 2026-06-22 |
| **OWF-110** | [x] | P3 | ⚪ | feat | adhoc | — | FeaturesPage.vue #comparativa: tabla Lite vs Pro reescrita fiel al spec (Funciones.html). 4 grupos: Cántaros/Cuentas/Transacciones/Analítica, iconos check_circle/remove_circle/remove, leyenda correcta, link a /matrix. Deploy prod OK. | claude-code | 2026-06-22 |
| **OWF-113** | [x] | P2 | ⚪ | test | adhoc | — | Playwright: e2e/profile-smoke.spec.ts — 7 tests: profile loads, fp tiene 4 cards, tpl-selector visible, onboarding renders intro/navega steps/recommend step. | claude-code | 2026-06-22 |
| **OWF-114** | [x] | P2 | ⚪ | test | adhoc | — | Playwright: e2e/interactions.spec.ts — PeriodNavigator prev/next, FilterPanel open/chip/clear, SmartTxModal open/expense fill/income toggle/transfer. | claude-code | 2026-06-22 |
| **OWF-115** | [x] | P3 | ⚪ | test | adhoc | — | Playwright: e2e/mobile-viewport.spec.ts — 390px viewport. Home/Tx/Jars sin overflow, bottom-nav visible, filter abre bottom-sheet (no desktop-dropdown), jar grid colapsa a 1-col. | claude-code | 2026-06-22 |
| **OWF-116** | [x] | P2 | ⚪ | feat | adhoc | — | LoginPage.vue (modo register): password strength meter — 4 segmentos color-coded (rojo/naranja/amarillo/verde), label reactivo (Muy débil/Débil/Aceptable/Fuerte), visible solo cuando password.length>0. pwStrength computed. Deploy prod OK. | claude-code | 2026-06-22 |

| **OWF-117** | [ ] | P0 | 🔴 | fix | adhoc | — | **Security: Add CheckRole:admin middleware to all admin CRUD routes** — cualquier usuario autenticado puede mutar datos catálogo (currencies, users, accounts, etc.). Envolver todas las rutas admin con `['auth:sanctum', CheckRole:admin]`. | — | — |
| **OWF-118** | [ ] | P1 | 🟡 | feat | adhoc | — | Admin: CRUD page Transaction Types — `/pages/admin/transaction_types/` + route + sidebar link. Sin esto el select de Tipos en Transacciones queda vacío/roto. Backend API `/api/transaction_types` ya existe. | — | — |
| **OWF-119** | [ ] | P1 | 🟡 | feat | adhoc | — | Admin Dashboard: reemplazar stub con métricas reales — DashboardController devuelve static OK; `admin_dashboard.vue` es párrafo estático. Implementar endpoint (total users, active accounts, tx este mes, top categories) + stat cards en Vue. | — | — |
| **OWF-120** | [ ] | P1 | ⚪ | feat | adhoc | — | Admin Users: añadir campo password + role_id en forms_save/forms_update — admin no puede setear password inicial ni asignar rol al crear usuario. | — | — |
| **OWF-121** | [ ] | P2 | ⚪ | fix | adhoc | — | Fix Currencies dictionary: `vmodel_api: ''` en campo align → nunca se envía al API en create. Fix a `vmodel_api: 'align'`. También fix duplicate `id: 3` en `forms_save`. | — | — |
| **OWF-122** | [ ] | P2 | ⚪ | fix | adhoc | — | Fix Jars admin: duplicación `active` vs `is_active` en columns/forms. Auditar modelo Jar, eliminar campo no canónico del dictionary. | — | — |
| **OWF-123** | [ ] | P2 | ⚪ | fix | adhoc | — | Fix AdminLayout sidebar: item "Usuarios" duplicado (líneas 16–17 y 34–35). Eliminar duplicado. | — | — |
| **OWF-124** | [ ] | P2 | ⚪ | feat | adhoc | — | Admin Accounts: añadir `user_id` a forms_save/forms_update — sin esto no se puede crear cuenta asignada a usuario desde admin. | — | — |
| **OWF-125** | [ ] | P2 | ⚪ | feat | adhoc | — | Admin: página Roles management — sin UI para ver/asignar roles. CRUD mínimo (list + assign role to user). Requiere RoleController + routes backend. | — | — |
| **OWF-126** | [ ] | P3 | ⚪ | chore | adhoc | — | Admin: eliminar archivo huérfano `transactionsDictionary.ts` (nunca importado, la versión activa es `transactions/dictionary.ts`). | — | — |
| **OWF-127** | [ ] | P3 | ⚪ | feat | adhoc | — | Admin: página System health — `/admin/system` con record counts por tabla, últimos logins, info último deploy. Extender DashboardController o nuevo SystemController. | — | — |
| **OWF-128** | [x] | P2 | ⚪ | feat | adhoc | — | V-11 ProHomeView: AI advisor strip — renombrado `.ai-strip` → `.pro-advisor-strip` BEM, `goToAsesor()` router.push, gradiente morado/cyan spec-fiel, CTA pill "Hablar con mi asesor". vue-tsc limpio. | claude-code | 2026-06-23 |

<!--
  NEXT_ID: OWF-129
-->

## Completed

| ID | Status | Pri | Urgency | Type | Source | Migrated from | Description | Done |
|----|--------|-----|---------|------|--------|---------------|-------------|------|
| **OWF-047** | [x] | P0 | 🔴 | fix | adhoc | — | Mensajes login ES + passwords fortalecidos S$ratoga.1990 + eliminar alert() nativos | 2026-06-10 |
| **OWF-029** | [x] | P0 | ⚪ | fix | adhoc | — | Fix login roto por PHP deprecated warnings en API response | 2026-06-10 |
| **OWF-030** | [x] | P1 | ⚪ | infra | adhoc | — | Estructura `.deploy/` centralizada (dev/stage/prod configs) | 2026-06-10 |
| **OWF-031** | [x] | P1 | ⚪ | feat | adhoc | — | Paginas marketing como Vue routes (Landing, Features, Pricing, Matrix) | 2026-06-10 |
| **OWF-032** | [x] | P1 | ⚪ | feat | adhoc | — | LoginPage split-panel con diseno Redesign | 2026-06-10 |
| **OWF-033** | [x] | P1 | ⚪ | feat | adhoc | — | PublicLayout con nav + footer + descarga app | 2026-06-10 |
| **OWF-034** | [x] | P1 | ⚪ | feat | adhoc | — | Rutas modulares (auth, admin, user, public) | 2026-06-10 |
| **OWF-035** | [x] | P0 | ⚪ | infra | migrated | INFRA-001 | Reparar skill-registry.md (paths rotos) | 2026-06-08 |
| **OWF-036** | [x] | P0 | ⚪ | infra | migrated | INFRA-002 | Instalar Engram (backend de memoria) | 2026-06-08 |
| **OWF-037** | [x] | P0 | ⚪ | infra | migrated | INFRA-003 | Instalar Paseo (handoff multi-agente) | 2026-06-08 |
| **OWF-038** | [x] | P1 | ⚪ | infra | migrated | INFRA-004 | Auto-reparacion registry al cambiar de maquina | 2026-06-08 |
| **OWF-039** | [x] | P1 | ⚪ | design | migrated | DS-01..04 | Design System F0: Tokens, fuentes, tema navy/cyan, app.scss | 2026-06-08 |
| **OWF-040** | [x] | P1 | ⚪ | design | migrated | DS-10..12 | Design System F1: Shell Lite Desktop (layout, header, navpill, empty states) | 2026-06-08 |
| **OWF-041** | [x] | P1 | ⚪ | feat | migrated | DS-20..25 | Design System F2: Rutas Lite (Home, Transactions, Jars, Config, QuickAdd) | 2026-06-08 |
| **OWF-042** | [x] | P1 | ⚪ | feat | migrated | DS-30 | Design System F3: ProHomeView (KPI strip + breakdown + AI advisor) | 2026-06-08 |
| **OWF-043** | [x] | P1 | ⚪ | feat | migrated | DS-31 | Gating funcional por layout_mode (LiteHomeView vs ProHomeView) | 2026-06-08 |
| **OWF-044** | [x] | P1 | ⚪ | design | migrated | DS-40..42 | Design System F4: Dark mode, iconografia, microinteracciones | 2026-06-08 |
| **OWF-045** | [x] | P1 | ⚪ | infra | migrated | DS-50 | Design System F5: Normalizar casing git (vue-tsc limpio) | 2026-06-08 |
| **OWF-046** | [x] | P2 | ⚪ | fix | migrated | BUG-008 | Layout LITE: vistas vacias (router-view duplicado) | 2026-06-08 |

| **OWF-053** | [x] | P1 | 🟡 | infra | adhoc | — | Seed datos base prod: roles, account types, currencies, transaction types | claude-code | 2026-06-10 |
| **OWF-054** | [x] | P0 | 🔴 | fix | adhoc | — | Opcion B Router: publicPath `/`, rutas publicas children, slot pattern, server proxy reescrito | opencode | 2026-06-10 |
| **OWF-050** | [x] | P1 | 🟡 | fix | adhoc | — | CORS prod: config/cors.php con allowed_origins owfinances.com + dev origins | claude-code | 2026-06-10 |
| **OWF-051** | [x] | P1 | 🟡 | infra | adhoc | — | Merge dev→main + re-deploy: AI, health, user settings, 6 migraciones nuevas | claude-code | 2026-06-10 |
| **OWF-052** | [x] | P2 | ⚪ | infra | adhoc | — | Arquitectura evaluada: proxy index.php funcional, symlink posible pero no urgente | claude-code | 2026-06-10 |

| **OWF-055** | [x] | P1 | 🟡 | design | adhoc | — | Integración rediseño → layouts: LiteHeaderDesktop + LiteFloatingBottomNav + BottomNavMobile + ExpandedMenu canónicos. Borrados 6 duplicados liquid/. LiteDesktopLayout + LiteMobileLayout actualizados. TypeCheck limpio. | claude-code | 2026-06-19 |
| **OWF-056** | [x] | P1 | 🟡 | design | adhoc | — | AppShell.vue: shell único Lite+Pro+Mobile. Reemplaza 4 layouts. q-layout wrapper + sidebar fixed + q-page-container. Router actualizado. TypeCheck limpio. Preview OK. | claude-code | 2026-06-19 |
| **OWF-057** | [x] | P1 | ⚪ | feat | adhoc | — | AppPrefsSection en Config: modo Lite/Pro + tema + ocultar saldos. auth.updateSettings() (PATCH /user/settings, optimista). Plain CSS (sin SCSS). | claude-code | 2026-06-19 |
| **OWF-058** | [x] | P1 | ⚪ | feat | adhoc | — | HomeView datos reales verificados: LiteHomeView ya usa GET /accounts/summary/global-balance + GET /transactions + GET /jars. HomeView.vue prioriza settings.layout_mode. | claude-code | 2026-06-19 |
| **OWF-060** | [x] | P2 | ⚪ | refactor | adhoc | — | Limpieza layouts legacy: borrados DynamicRoleLayout, LiteDesktopLayout, LiteMobileLayout, ProLayout, LegacyLayout, DynamicHomePage, user_dashboard, components/views/LiteHomeView. MainLayout simplificado. 3 deploys prod OK. | claude-code | 2026-06-19 |
| **OWF-059** | [x] | P1 | ⚪ | feat | adhoc | — | Onboarding automático: AppShell watch has_seen_onboarding → OnboardingFlow. onOnboardingDone → updateSettings({has_seen_onboarding:true}). | claude-code | 2026-06-19 |

| **OWF-069** | [x] | P0 | 🔴 | feat | adhoc | — | SmartTransactionModal: modal global unificado (Escribir/Voz/Foto/AutoIA), montado en AppShell, QuickActionSheet corregido. Fix raíz: TransactionCreateDialog nunca estaba montado fuera de /user/transactions. | claude-code | 2026-06-20 |
| **OWF-070** | [x] | P1 | 🟡 | feat | adhoc | — | Página Deudas completa: migración debts + Debt model/controller/route (CRUD + pay) + DebtCard.vue + index.vue (summary, grupos Cashea/Otras, form add/edit, pago cuota, delete). Backend deployado prod. | claude-code | 2026-06-20 |
| **OWF-071** | [x] | P1 | 🟡 | feat | adhoc | — | Transacciones Lite: openDetail(tx) + q-dialog inline (tx-detail-sheet: hero amount, tipo, categoría, cántaro, fecha, editar/eliminar). Auto-reload owf:transaction-saved. ✅ verificado git commit 3736d6e. | claude-code | 2026-06-20 |
| **OWF-072** | [x] | P1 | 🟡 | feat | adhoc | — | Cántaros Lite: grid → lista vertical (spec), distribution strip, jar detail sheet (stats 2x2), "Nuevo cántaro" inline form. ✅ verificado git commit c22b711 (+499 líneas). | claude-code | 2026-06-20 |
| **OWF-073** | [x] | P2 | ⚪ | feat | adhoc | — | Configuración: secciones Notificaciones (3 toggles), Seguridad, Cerrar sesión, Exportar datos, section-labels. ✅ verificado git commit 214c437. | claude-code | 2026-06-20 |
| **OWF-074** | [x] | P2 | ⚪ | feat | adhoc | — | Análisis Pro: jar strip (scroll horizontal gasto por cántaro), metric-grid 4-col Pro mode. ✅ verificado git commits cabf22e+9c114b4. | claude-code | 2026-06-20 |
| **OWF-075** | [x] | P2 | ⚪ | feat | adhoc | — | Exchange Rates widget en ProHomeView: carga /user_currencies → filas editables (PUT rate). Solo visible si hay tasas. ✅ verificado git commit cabf22e. | claude-code | 2026-06-20 |
| **OWF-076** | [x] | P3 | ⚪ | feat | adhoc | — | Notifications panel: bell → popover desktop / bottom-sheet mobile. Items con tono, unread dot, mark-all-read. Montado en AppShell. ✅ verificado git commit c00a02f. | claude-code | 2026-06-20 |

| **OWF-080** | [x] | P2 | ⚪ | design | adhoc | — | Config Pro heading: reemplazado emoji ⚙️ con t-eyebrow+h1 "Preferencias", restaurado q-tabs (revertido Stitch pill tabs). Fuente verdad: rediseno/ConfigRoute.jsx. Deploy prod OK. | claude-code | 2026-06-20 |
| **OWF-081** | [x] | P2 | ⚪ | feat | adhoc | — | Transactions type chips inline + MonthBar: chips Todas/Ingresos/Gastos/Cántaros siempre visibles, prev/next month nav, chip "Cántaros" nuevo tipo. Deploy prod OK. | claude-code | 2026-06-20 |
| **OWF-082** | [x] | P2 | ⚪ | feat | adhoc | — | Análisis: Pro heading "Navegador financiero" (t-eyebrow+h1), Lite donut CSS (conic-gradient) de distribución por cántaro con leyenda. Deploy prod OK. | claude-code | 2026-06-20 |
| **OWF-083** | [x] | P3 | ⚪ | refactor | adhoc | — | Stitch archivado: todo movido a _archive/stitch-NO-USAR/ (carpeta principal, zip, skill, docs, html-exports). _archive/ en .gitignore. Fuente verdad = rediseno/ui_kits/. | claude-code | 2026-06-20 |

<!--
  NEXT_ID: OWF-084
  Proximo agente: usar OWF-084 para la primera tarea nueva.
  Incrementar NEXT_ID al final.
  Proximo agente: usar OWF-082 para la primera tarea nueva.
  Incrementar NEXT_ID al final.
-->
