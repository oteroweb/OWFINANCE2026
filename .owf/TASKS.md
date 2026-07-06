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

| **OWF-117** | [x] | P0 | 🔴 | fix | adhoc | — | **Security: Add CheckRole:admin middleware to all admin CRUD routes** — auditado: todas las rutas /admin/* ya están en grupo con middleware CheckRole:admin. Rutas de catálogos de usuario (accounts/jars/categories) son del usuario, no admin. | claude-code | 2026-06-28 |
| **OWF-118** | [x] | P1 | 🟡 | feat | adhoc | — | Admin: CRUD page Transaction Types — verificado: pages/admin/transaction_types/ + routes en admin.php + sidebar link ya existían. Deploy OK. | claude-code | 2026-06-28 |
| **OWF-119** | [x] | P1 | 🟡 | feat | adhoc | — | Admin Dashboard: métricas reales — DashboardController devuelve total_users/active_accounts/transactions_this_month/top_categories. Vue stat cards implementadas. Deploy prod OK. | claude-code | 2026-06-28 |
| **OWF-120** | [x] | P1 | ⚪ | feat | adhoc | — | Admin Users: añadido campo password (id:3) + role_id (id:7) en forms_save/forms_update. Deploy prod OK. | claude-code | 2026-06-28 |
| **OWF-121** | [x] | P2 | ⚪ | fix | adhoc | — | Fix Currencies dictionary: vmodel_api ya es 'align'. Dup id:3 ya corregido. Sin cambio necesario. | claude-code | 2026-06-28 |
| **OWF-122** | [x] | P2 | ⚪ | fix | adhoc | — | Fix Jars admin: active/is_active ya normalizado en dictionary.ts. Sin cambio necesario. | claude-code | 2026-06-28 |
| **OWF-123** | [x] | P2 | ⚪ | fix | adhoc | — | Fix AdminLayout sidebar: duplicado ya eliminado en sesión anterior. Sin cambio necesario. | claude-code | 2026-06-28 |
| **OWF-124** | [x] | P2 | ⚪ | feat | adhoc | — | Admin Accounts: user_id ya en forms_save/forms_update (verificado). Sin cambio necesario. | claude-code | 2026-06-28 |
| **OWF-125** | [x] | P2 | ⚪ | feat | adhoc | — | Admin Roles CRUD: RoleController.php creado, rutas en admin.php (GET/POST/PUT/DELETE /admin/roles), dictionary url_api→admin/roles, roles/index.vue con CrudPage. Deploy prod OK. | claude-code | 2026-06-28 |
| **OWF-126** | [x] | P3 | ⚪ | chore | adhoc | — | Admin: transactionsDictionary.ts ya eliminado en sesión anterior. Sin cambio. | claude-code | 2026-06-28 |
| **OWF-127** | [x] | P3 | ⚪ | feat | adhoc | — | Admin System health: SystemController.php (table_counts, last_logins, deploy info). Ruta GET /admin/system. Vue system/index.vue con stat cards + login list + env chips. Deploy prod OK. | claude-code | 2026-06-28 |
| **OWF-128a** | [x] | P0 | 🔴 | fix | adhoc | — | Fix ap-panel account filter: rows solo filtraban en apSelectMode=true (nunca activo). Ahora siempre llaman toggleApAcct(). cursor:pointer. Checkbox visible si seleccionado aunque no sea selectMode. Deploy prod OK. | claude-code | 2026-06-27 |
| **OWF-128b** | [x] | P2 | ⚪ | feat | adhoc | — | V-11 ProHomeView: AI advisor strip — renombrado `.ai-strip` → `.pro-advisor-strip` BEM, `goToAsesor()` router.push, gradiente morado/cyan spec-fiel, CTA pill "Hablar con mi asesor". vue-tsc limpio. | claude-code | 2026-06-23 |
| **OWF-129** | [x] | P0 | 🔴 | feat | adhoc | — | Registro de transacciones con IA: conectar extracción (voz/OCR/texto) → prefill SmartTransactionModal → confirm. Fix: applyAiResult() ahora resuelve category_suggestion → category_id real del usuario (fuzzy match). | claude-code | 2026-06-29 |
| **OWF-130** | [x] | P1 | 🟡 | infra | adhoc | — | 6 AI providers configurados en prod con fallback chain: opencode-go→groq→openrouter→gemini→xai→openai. AiProviderChain runtime fallback. OpenRouterProvider + XaiProvider nuevos. Admin monitor /admin/ai. Deploy OK. | claude-code | 2026-06-27 |
| **OWF-131** | [ ] | P1 | 🟡 | fix | adhoc | — | Validar key Gemini en prod: prefijo AQ. inusual (estándar es AIza). Si falla, regenerar en aistudio.google.com. También verificar OpenCode Zen key contra chat.opencode.ai panel. | — | — |
| **OWF-132** | [x] | P2 | ⚪ | feat | adhoc | — | Admin AI Monitor: link añadido en sidebar de AdminLayout (smart_toy icon → /admin/ai). Deploy prod OK. | claude-code | 2026-06-28 |
| **OWF-133** | [x] | P1 | 🟡 | feat | adhoc | — | TxPoolsHeader 3-pool Pro: Pool-1 Filtros activos (mes locked + tipo segmented + chips removibles), Pool-2 Categorías (multi-select PickChip por conteo), Pool-3 Cántaros (PickChip + dot color). Reemplaza el filter card popover. proSelCats/proSelJars multi-select. Deploy prod OK. Playwright 77/77 pasan. | claude-code | 2026-06-28 |
| **OWF-134** | [x] | P1 | 🟡 | feat | adhoc | — | TxLedger v2 Pro: checkbox hover/selectMode, dblclick=enterSelectMode+marca, single-click=220ms debounce→edit, cat-chip dblclick=toggleProCat, bottom sticky multibar (count+sum+Todas+Listo slide-up), day totals en headers. Deploy prod OK. | claude-code | 2026-06-28 |
| **OWF-135** | [x] | P2 | ⚪ | feat | adhoc | — | Asesor IA: añadido a AppShell NAV_ITEMS + currentTab computed, y a ExpandedNavigationMenuLight MENU_GROUPS. Deploy prod OK. | claude-code | 2026-06-28 |
| **OWF-136** | [x] | P2 | ⚪ | fix | adhoc | — | LiteHomeView: Dreams ahora aparece ANTES que Debts. Swap corregido. Deploy prod OK. | claude-code | 2026-06-28 |
| **OWF-137** | [x] | P2 | ⚪ | feat | adhoc | — | Cántaros Mobile v2: LiteJarsView mejorado según spec. Period selector (Mensual/Semestral/Anual), drag-to-reorder, toggle activo/inactivo por jar, carry tags (Acumula/Reset), dim para jars inactivos, JarItem ampliado (active/carry/mode/fixed). | claude-code | 2026-06-29 |
| **OWF-138** | [x] | P3 | ⚪ | feat | adhoc | — | Transaction Detail Modal v2 (Pro): AnchoredJarChip en VIEW, CategorySelector+chip en EDIT, category_id+jar_id en payload save/duplicate. | claude-code | 2026-06-30 |
| **OWF-139** | [x] | P0 | 🔴 | fix | adhoc | — | Fix SystemController 500: columna `last_login_at` no existe en prod. Wrapped query en try/catch; fallback usa `updated_at`. Deploy prod OK. `/admin/system` responde 200 con data completa. | claude-code | 2026-06-28 |
| **OWF-140** | [x] | P0 | 🟡 | feat | OWF-140-admin-users | — | [ÉPICA] Admin: Gestión completa de usuarios. COMPLETA — Backend OWF-141..144 + Frontend OWF-145..148 + Tests OWF-151..152. | claude-code | 2026-06-29 |
| **OWF-141** | [x] | P1 | 🟡 | feat | OWF-140-admin-users | — | Backend: `GET /admin/users/:id/detail` — UserAdminController::detail(), carga user+settings+accounts+jars+recent_tx(20)+tokens_count+currencies. | claude-code | 2026-06-29 |
| **OWF-142** | [x] | P1 | 🟡 | feat | OWF-140-admin-users | — | Backend: `PUT /admin/users/:id/password` — UserAdminController::changePassword(), valida min:8+confirmed, revoca tokens existentes. | claude-code | 2026-06-29 |
| **OWF-143** | [x] | P1 | 🟡 | feat | OWF-140-admin-users | — | Backend: `DELETE /admin/users/:id/tokens` — UserAdminController::revokeTokens(), retorna revoked_count. | claude-code | 2026-06-29 |
| **OWF-144** | [x] | P1 | 🟡 | feat | OWF-140-admin-users | — | Backend: `POST /admin/users/:id/reset-password-email` — UserAdminController::sendResetEmail(), Password::createToken + ResetPasswordNotification. | claude-code | 2026-06-29 |
| **OWF-145** | [x] | P1 | 🟡 | feat | OWF-140-admin-users | — | Frontend: `admin/users/index.vue` reescrita — KPI row 4 chips, filtros (search/rol/active), q-table avatar+badges+toggle+acciones (detalle/impersonar/eliminar), paginación. | claude-code | 2026-06-29 |
| **OWF-146** | [x] | P1 | 🟡 | feat | OWF-140-admin-users | — | Frontend: `admin/users/detail.vue` nueva — 6 tabs (Perfil/Cuentas/Cántaros/Transacciones/Seguridad/Ajustes), modals inline pwd/revocar/reset/impersonar. Ruta `/admin/users/:id` en admin.routes.ts. | claude-code | 2026-06-29 |
| **OWF-147** | [x] | P0 | 🔴 | feat | OWF-140-admin-users | — | Frontend: auth.ts startImpersonation()/stopImpersonation() con sessionStorage. ImpersonationBanner.vue fixed top rojo. Montado en AppShell.vue. | claude-code | 2026-06-29 |
| **OWF-148** | [x] | P2 | ⚪ | feat | OWF-140-admin-users | — | Frontend: AdminLayout.vue sidebar v2 — 4 secciones, iconos Material, badge usuarios, logo+avatar admin, logout rojo al fondo. | claude-code | 2026-06-29 |
| **OWF-149** | [x] | P2 | ⚪ | feat | OWF-140-admin-users | — | Frontend: ChangePassword integrado inline en detail.vue (tab Seguridad). No se creó como componente separado — no es necesario. | claude-code | 2026-06-29 |
| **OWF-150** | [x] | P2 | ⚪ | feat | OWF-140-admin-users | — | Frontend: Revoke tokens confirm integrado inline en detail.vue (tab Seguridad + $q.dialog). | claude-code | 2026-06-29 |
| **OWF-151** | [x] | P2 | ⚪ | tests | OWF-140-admin-users | — | Feature tests PHP: AdminUserManagementTest.php — 15 tests, 44 assertions. Cubre detail/impersonate/changePassword/revokeTokens/sendResetEmail. 15/15 PASSING. | claude-code | 2026-06-29 |
| **OWF-152** | [x] | P3 | ⚪ | tests | OWF-140-admin-users | — | E2E Playwright: e2e/admin-user-management.spec.ts — 8 tests. Sidebar, lista KPIs, búsqueda, detalle, tabs Seguridad, confirm dialog impersonar, volver. Skip guard PLAYWRIGHT_ADMIN_EMAIL. | claude-code | 2026-06-29 |
| **OWF-153** | [x] | P1 | ⚪ | feat | rediseno-tx | — | `src/utils/txCatalog.ts`: loadCategoriesWithJars, loadUserJars, jarForCategory, getCachedJars, resetTxCatalog. Slug-based (jar_slug desde API). TypeScript limpio. | claude-code | 2026-06-29 |
| **OWF-154** | [x] | P1 | ⚪ | feat | rediseno-tx | — | `src/components/AnchoredJarChip.vue`: 3 estados (sin-cat / sin-jar / jar anclado). Auto-load de categorías+jars en onMounted. Colores dinámicos via color-mix. TypeScript limpio. | claude-code | 2026-06-29 |
| **OWF-155** | [x] | P1 | ⚪ | feat | rediseno-tx | — | SmartTransactionModal: AnchoredJarChip bajo selector categoría, jar_id derivado en save() incluido en payload POST. Imports txCatalog. | claude-code | 2026-06-29 |
| **OWF-156** | [x] | P2 | ⚪ | feat | rediseno-tx | — | LiteTransactionsView: detail sheet con AnchoredJarChip, modo edición inline (concepto/monto/fecha/categoría+chip), Duplicar, confirm-eliminar inline. category_id+jar_slug en TxItem. | claude-code | 2026-06-29 |
| **OWF-157** | [x] | P2 | ⚪ | feat | rediseno-tx | — | SmartTransactionModal Pro toggles: comisión (fija/% /BCV 0.30%), split N cuentas, items/factura. Solo isProMode. Payload incluye items[] y amount+comisión. | claude-code | 2026-06-29 |
| **OWF-158** | [x] | P3 | ⚪ | feat | rediseno-tx | — | Commit frontend (060d4fc) + backend (35c9923). 15 archivos frontend, 4 backend. TypeScript 0 errores. | claude-code | 2026-06-29 |
| **OWF-159** | [x] | P0 | 🟡 | feat | rediseno-tx | — | Backend: jar_slug en GET /categories via formatCategories()+jarSlugForCategory() en CategoryController. Category.php añade jars(). CategoryRepo filtra global+user. | claude-code | 2026-06-29 |
| **OWF-160** | [x] | P0 | 🟡 | feat | rediseno-tx | — | CanonicalCategorySeeder.php: 15 categorías canónicas user_id=null. Ejecutado en local (warnings esperados: jars con nombres distintos en dev). | claude-code | 2026-06-29 |
| **OWF-161** | [x] | P2 | ⚪ | feat | rediseno-tx | — | TransactionFormDialog + TransactionEditDialog + useTransactionForm: category_id en FormState, selector+AnchoredJarChip en ambos dialogs, jar_id derivado en saveCreate/saveUpdate/persist. | claude-code | 2026-06-29 |
| **OWF-162** | [x] | P1 | ⚪ | feat | rediseno-tx | — | Transaction interface extendida (category_id, jar_id, category, jar). Category model: $appends=['jar_slug'] + getJarSlugAttribute() — jar_slug aparece en todos los endpoints automáticamente. | claude-code | 2026-06-29 |
| **OWF-163** | [x] | P1 | ⚪ | feat | redesign-delta | — | CategorySelector.vue: picker avanzado con búsqueda, grid agrupada por cántaro (frío) y lista plana filtrada (caliente). Teleport a body. Reemplaza q-select en STM/FormDialog/EditDialog. | claude-code | 2026-06-30 |
| **OWF-164** | [x] | P2 | ⚪ | feat | redesign-delta | — | SmartTransactionModal: tipo Ajuste añadido (ámbar, icon tune). Amount sign neutral en payload ajuste. | claude-code | 2026-06-30 |
| **OWF-165** | [x] | P2 | ⚪ | design | redesign-delta | — | SmartTransactionModal: monto 17px → 32px font-weight 700 (auditoría 1A). | claude-code | 2026-06-30 |
| **OWF-166** | [x] | P2 | ⚪ | fix | redesign-delta | — | LiteTransactionsView hero collision: amount+label con overflow ellipsis, max-width, gap reducido. Label color fg-2. (auditoría mobile). | claude-code | 2026-06-30 |
| **OWF-167** | [x] | P3 | ⚪ | chore | redesign-delta | — | Merge rediseno/rediseno/ → rediseno/ (unificación carpetas). redesign/ nuevo: auditoría TX HTML + 14 screenshots. ui_kits actualizados: CategorySelector.jsx, TransactionForm.jsx, TransactionFormSheet.jsx, tx-summary.js. | claude-code | 2026-06-30 |
| **OWF-168** | [x] | P2 | ⚪ | fix | deploy | — | Fix lint build errors: no-base-to-string en txCatalog.ts (String cast via as unknown), no-misused-promises en admin/users/index.vue (void IIFE pattern). | claude-code | 2026-06-30 |
| **OWF-169** | [x] | P1 | ⚪ | feat | tags | — | Backend: sistema de etiquetas completo. Tabla tags + pivots transaction_tags + item_transaction_tags + is_fee/fee_type en item_transactions. TagSeeder 6 tags sistema. TagController GET/POST/DELETE. TransactionController acepta tags[]. Deployado prod commit aadd9d6. | claude-code | 2026-07-02 |
| **OWF-170** | [x] | P1 | 🟡 | feat | tags | — | Frontend: store tags.ts + SmartTransactionModal (chips etiquetas multi-select + autocomplete proveedor) + admin/transactions/dictionary.ts (columna tags, filtro, multiselect form). CrudPage soporte type=tags y multiselect. Commit 3551e33. | claude-code | 2026-07-02 |
| **OWF-171** | [ ] | P2 | ⚪ | feat | tags | — | Frontend: mostrar tags en lista de transacciones (chips debajo del nombre) y en detalle de transacción (sección Etiquetas modo vista). Mobile + desktop. | — | — |
| **OWF-172** | [ ] | P2 | ⚪ | fix | views | — | V-13 Transacciones Pro gaps: amount-presets filter (<$50/$50-200/>$200); neto en tiempo real en filter bar; pill dropdowns vs q-expansion-item. | — | — |
| **OWF-173** | [ ] | P2 | ⚪ | fix | views | — | V-15 Home Mobile Pro gaps: KPI 1-col en ≤640px (spec dice 2×2); AccountsPanel sin overlay mobile. | — | — |
| **OWF-174** | [ ] | P2 | ⚪ | fix | views | — | V-18 Deudas Mobile gaps: form .df-row-2 sin breakpoint 390px (2-col cramped); DebtCard ribbon/progress bar Venezuela. | — | — |
| **OWF-175** | [ ] | P3 | ⚪ | fix | views | — | V-24 Onboarding Desktop: modal mismo tamaño en todos los viewports — necesita layout 2-col desktop (540px+ diferente). | — | — |
| **OWF-176** | [ ] | P3 | ⚪ | fix | views | — | V-27 Forgot/Reset PW: emoji ✉️ → Material Icon; strength indicator en reset PW. Bloqueado por OWF-062 (SMTP). | — | — |
| **OWF-177** | [ ] | P2 | ⚪ | feat | views | — | C-02 NotificationsPanel: datos reales desde API (no hardcoded SEED); "Ver todas" navega a vista de notificaciones. | — | — |
| **OWF-178** | [ ] | P2 | ⚪ | feat | views | — | C-04 BulkImportPanel gaps: rate heuristic frágil (solo excluye USD/ARS); modo fullscreen en desktop. | — | — |
| **OWF-179** | [x] | P1 | 🟡 | design | rediseno | — | PRO form — Cross-currency preview (TfRateBreakdown): cuando currency≠USD debajo del MoneyInput, mostrar caja con 2 filas: Paralelo (tasa actual) + BCV (tasa oficial), cada una con el equivalente en USD. Archivo: SmartTransactionModal.vue. | claude-code | 2026-07-05 |
| **OWF-180** | [x] | P1 | 🟡 | design | rediseno | — | PRO form — Cuenta a su propia fila full-width. Nota: side-by-side Categoría+Cántaro NO implementado (no existe jar_id estable en frontend); pendiente decisión de producto. | claude-code | 2026-07-05 |
| **OWF-181** | [x] | P2 | ⚪ | design | rediseno | — | PRO form — Proveedor + Fecha side by side: ambos campos en la misma fila (stm-row-2), actualmente están apilados. | claude-code | 2026-07-05 |
| **OWF-182** | [x] | P1 | 🟡 | feat | rediseno | — | PRO form — Switch toggles en lugar de botones: reemplazar stm-pro-toggles (3 botones Comisión/Split/Artículos) con 3 Switch components inline: "Pago múltiple" (splitOn) substituye Cuenta con TfPaymentsEditor completo; "Detalle/factura" (itemsOn) sustituye amount con total de items; "Cobrar comisión" ya es card, solo necesita Switch activador. | claude-code | 2026-07-05 |
| **OWF-183** | [x] | P2 | ⚪ | feat | rediseno | — | PRO form — "Afecta el saldo" Switch: toggle include_in_balance (default true) al final del formulario antes del footer; incluir en payload al guardar. | claude-code | 2026-07-05 |
| **OWF-184** | [x] | P1 | 🟡 | feat | rediseno | — | PRO form — TfReview card: reemplazar footer simple (Cancel/Guardar) con: (1) preview card lenguaje natural "VAS A REGISTRAR Registras un gasto de $X desde [Cuenta]…"; (2) mensajes de validación (cuando inválido: "Ingresa un monto…", "Elige una categoría"); (3) link "Ver payload · POST /api/v1/transactions" colapsado; (4) botón 3 estados: idle→spinner Guardando…→check_circle Registrado (verde, luego cierra). Toast de confirmación con "Deshacer". | claude-code | 2026-07-05 |
| **OWF-185** | [x] | P2 | ⚪ | feat | rediseno | — | PRO form — Transfer type UI dedicada: para type=transfer mostrar Desde (origen) + flecha → + Hacia (destino) con q-select accounts en cada uno, + panel cruce de moneda cuando currencies difieren (Envías/Llega con tasa). Actualmente usa el split panel que es incorrecto. | claude-code | 2026-07-05 |
| **OWF-186** | [x] | P2 | ⚪ | feat | rediseno | — | PRO form — Ajuste type section: para type=ajuste mostrar: (1) Cuenta a ajustar (q-select); (2) Saldo objetivo MoneyInput; (3) diff box (trending_up/down con texto "Se creará un ajuste de ±$X"); (4) Motivo text field. Enviar target_balance al backend. | claude-code | 2026-07-05 |
| **OWF-187** | [x] | P2 | ⚪ | feat | rediseno | — | LITE form — Income "Se reparte automáticamente": cuando type=income en modo LITE, reemplazar CategorySelector con info box que muestre distribución por cántaro (Necesidades X% · Diversión X% · etc.), usando SAMPLE_JARS/jarOpts. | claude-code | 2026-07-05 |
| **OWF-188** | [x] | P3 | ⚪ | feat | rediseno | — | LITE form — Income Categoría opcional: cuando type=income en modo LITE, mostrar Categoría (opcional) en la misma fila que Fecha (stm-row-2). Actualmente Fecha va sola. | claude-code | 2026-07-05 |
| **OWF-194** | [x] | P0 | 🔴 | fix | rediseno | — | OWF-179..188 se habían implementado en TransactionCreateDialog.vue, componente huérfano nunca montado en ningún template — cero impacto real en usuarios pese a build/tests OK. Se portaron las 10 tareas a SmartTransactionModal.vue (el formulario real, montado en AppShell). Verificado con 115/115 E2E prod + capturas visuales. | claude-code | 2026-07-05 |
| **OWF-195** | [x] | P1 | 🟡 | fix | transactions | — | 4 puntos de entrada más llamaban a ui.openNewTransactionDialog() (acción muerta, sin listener real): botón "Nueva transaccion" en expense-analysis, "+ Registrar ingreso" y quick actions en jars/LiteJarsView (Lite), hero CTA + botones rápidos + FAB en legacy layout de transactions/index.vue. Todos re-wireados a ui.openSmartModal(). Watcher de refresco de tabla también estaba muerto (escuchaba flag sin consumidor) — reemplazado por listener del evento global 'owf:transaction-saved'. | claude-code | 2026-07-05 |
| **OWF-196** | [x] | P3 | ⚪ | chore | cleanup | — | Eliminados TransactionCreateDialog.vue y TransactionEditDialog.vue (código muerto, nunca montados, solo referenciados por barrel export sin consumidores). Limpiado components/index.ts. | claude-code | 2026-07-05 |
| **OWF-189** | [x] | P3 | ⚪ | chore | dx | — | Skill owf-deploy: proceso estandarizado de deploy frontend/backend prod. ESLint gotchas documentados. CLAUDE.md actualizado. | claude-code | 2026-07-05 |
| **OWF-190** | [x] | P3 | ⚪ | chore | dx | — | Skill owf-session: protocolo centralizado start/end. Arranque: lee STATE+TASKS+CONTEXT+Engram. Cierre: STATE+TASKS+Engram+sync+deploy. CLAUDE.md con 2 reglas al tope. | claude-code | 2026-07-05 |
| **OWF-062** | [!] | P0 | 🔴 | fix | adhoc | — | Password Reset: código listo. BLOQUEADO: credenciales SMTP/Resend reales en .env prod. Usuario debe proveer. | opencode | — |
| **OWF-131** | [ ] | P1 | 🟡 | fix | adhoc | — | Gemini key prod prefijo AQ. inusual (estándar AIza). Regenerar en aistudio.google.com y actualizar .env prod. | — | — |
| **OWF-191** | [x] | P1 | 🟡 | fix | adhoc | — | Backend: `Category::getJarSlugAttribute()` usaba mapa hardcodeado de 12 nombres → cántaro, ignorando la relación real `jar_category`. Categorías personalizadas (ej. "Familia") devolvían jar_slug=null. Ahora consulta primero la relación real, cae al mapa legado si no hay asignación. Eager-load en CategoryRepo. Deploy prod OK. | claude-code | 2026-07-05 |
| **OWF-192** | [x] | P2 | ⚪ | fix | adhoc | — | Frontend Pro: botón "Editar" del detalle de transacción abría el modal vacío (no llamaba a `txDetailFillForm()`). Agregado `txDetailStartEdit()` en index.vue, igual que ya hacía Duplicar. Deploy prod OK. | claude-code | 2026-07-05 |
| **OWF-193** | [x] | P2 | ⚪ | fix | adhoc | — | SmartTransactionModal: "Nuevo movimiento" siempre preseleccionaba la primera cuenta de la lista en vez de la cuenta filtrada/seleccionada (`txStore.selectedAccountIds`). Además la moneda del monto era un selector independiente que podía no coincidir con la cuenta — ahora queda fija a la moneda de la cuenta elegida. Deploy prod OK. | claude-code | 2026-07-05 |

<!--
  NEXT_ID: OWF-197
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
