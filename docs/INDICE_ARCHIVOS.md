# Índice de Archivos y Documentación — OWFINANCE 2026

> Listado completo de toda la documentación y archivos pertinentes de los 3 repos.
> ⭐ = núcleo (lo más importante para entender el sistema).
> Para entender el producto de un vistazo, empieza por [`producto/PANORAMA_360.md`](./producto/PANORAMA_360.md).
> Última actualización: 2026-06-02.

---

## 📁 CENTRAL (orquestador) — branch `master`

### Raíz — canónicos (fuente única de la verdad)
| Archivo | Rol |
|---------|-----|
| `START_HERE.md` ⭐ | Entrada / onboarding |
| `TASKS_LEDGER.md` ⭐ | Lista única de tareas |
| `AGENTS.md` | Reglas técnicas para agentes |
| `CLAUDE.md` | Reglas de orquestación |
| `README.md` | Visión técnica raíz |
| `.state/CHECKPOINT.md` | Cursor de trabajo (RESUME POINTER) |

### Raíz — operación / estrategia
`DEPLOYMENT-STRATEGY.md` · `ENV_STRATEGY.md` · `MOBILE_DEPLOYMENT_GUIDE.md` ·
`NOTION_BACKLOG.md` · `COMPONENT_USAGE.md` · `VERIFICATION_CHECKLIST.md` ·
`set-herramientas.md` · `TAREA_sync_stage_to_dev.md`

### `docs/producto/` — negocio + UX ⭐
| Archivo | |
|---------|--|
| `PANORAMA_360.md` ⭐ | Punto único para entender todo |
| `README.md` | Comienza aquí (producto) |
| `MODELO_CANTAROS.md` | Dinámica de cántaros |
| `CUENTAS_Y_TRANSACCIONES.md` | Tipos de cuenta y transacción |
| `FLUJOS_TRANSACCIONES.md` | Caminos de registro + diagramas + P1–P9 |
| `MODOS_LITE_VS_PRO.md` | Variación LITE vs PRO |

### `docs/00-sistema/`
`GUIA_DE_LECTURA_CODIGO.md` ⭐ · `DEVELOPMENT_HANDBOOK.md` · `FLUJO_OPERATIVO_UNIFICADO.md` ·
`GIT_HYGIENE_AND_SAFE_UPDATE.md` · `ANALISIS_E_INSTRUCCIONES_CARGA_MASIVA_TRANSACCIONES.md` · `README.md`

### `docs/01-configuracion/`
`AI_AGENT_TOOLING.md` · `SAAS_ROLE_SYSTEM.md` · `ENV_STRATEGY.md` · `NOTION_TICKET_WORKFLOW.md` ·
`TELEGRAM_NOTIFICATIONS.md` · `GOOGLE_WORKSPACE_MCP_SETUP.md` · `OPENCODE_RUNTIME_SETUP.md` ·
`STITCH_MCP_OPERATIONAL_SETUP.md` · `DOCUMENTATION_CLEANUP_POLICY.md` · `README.md`

### `docs/02-backend/`
`README.md` · `arquitectura/`: `jar-balance-system.md`, `jar-system-architecture.md`,
`before-after-architecture.md` · `endpoints/`: `accounts-endpoints.md`, `jar-quick-reference.md`,
`transaction-payloads.md`, `user-currencies.md` · `bugfixes/BULK_TRANSFERS_GUARDRAILS.md`

### `docs/03-frontend/`
`SISTEMA_LAYOUTS_DINAMICOS.md` · `RUTAS.md` · `README.md`

### `docs/ui-ux/` — design system + UX ⭐
`04-current-state-human-describe.md` ⭐ (UX exhaustiva) ·
`02-current-ui-inventory-and-architecture.md` · `06-version-matrix-differences.md` ·
`10-layout-refactor-legacy-pro-lite-mini-spec.md` · `DESIGN_MAP.md` · `MASTER_DESIGN_PROMPT.md` ·
`MASTER_UI_SOURCES.md` · `01-happy-jar-reference.md` ·
`00/03/05/07/08/09/11` (raw, reglas, freeze, prompts, generación)

### `docs/` (raíz docs) + otros
`INDICE_MAESTRO_PROYECTO.md` · `ARQUITECTURA_PROYECTO.md` · `CONSULTAS_OPERATIVAS.md` ·
`ANALISIS_CAMPOS_CARGA_MASIVA.md` · `STITCH_QUICK_START.md` · `STITCH_RESOURCES.md` · `README.md` ·
`devops/GHA_TESTING_ROUTINE.md` · `tickets/` (3) ·
`04-mobile/`, `05-referencias/`, `06-recursos-especiales/` (solo README) ·
`archive/` (histórico — NO fuente de verdad)

---

## ⚙️ BACKEND — `OWFINANCEBackend2025` (branch `dev`)

### Docs (raíz del submódulo)
`README.md` · `API_TESTING_EXAMPLES.md` · `ANALISIS_LOGICA_PORCENTAJE_CANTAROS.md` ·
`FRONTEND_INTEGRATION_GUIDE.md` · `FRONTEND_QUICK_REFERENCE.md` · `DEPLOY_STAGING.md` ·
`BUGFIX_SQL_AMBIGUITY.md` · `CORRECCION_ERROR_404_JARROS.md` ·
`IMPLEMENTATION_COMPLETE.md` / `IMPLEMENTATION_SUMMARY.md` · `SOLICITUD_*`
### `docs/` (submódulo)
jar-balance (system/management/visual/guide/summary) · `jar-system-architecture` ·
`transaction-payloads` · `accounts-endpoints` · `user-currencies` · `frontend-*` ·
`FRONTEND-INDEX` / `FRONTEND-SUMMARY`

### Código pertinente
- **Entrada**: `bootstrap/app.php` ⭐ (routing `/api/v1`, scheduler, errores)
- **Rutas** (`routes/api/`, 25): `transactions` ⭐, `jars`, `accounts`, `auth`, `ai`, `health`,
  `payment_transactions`, `item_transactions`, `categories`, `taxes`, `account-folders`,
  `transaction_types`, `account_types`, `items`, `item_categories`, `providers`, `clients`,
  `currencies`, `rates`, `jar_templates`, `user`, `users`, `admin`, …
- **Controllers** (`app/Http/Controllers/Api/`, 31): `TransactionController` ⭐, `JarController`,
  `UserJarController`, `AccountController`, `CategoryController`, familia Jar
  (Adjustment/Balance/Income/Savings/Setting/Transfer/Withdrawal/Template/MonthlyOverride),
  `Payment*`, `Item*`, `AuthController`, `UserSettingController`, `Admin/`
- **Services** (`app/Services/`): `JarBalanceService` ⭐, `BalanceService`,
  `TransactionBulkService`, `UserRateService`, `CategoryTreeInitializer`,
  `ItemCategoryClassifier`, `AI/`
- **Observers**: `TransactionObserver` ⭐, `UserObserver`
- **Policies**: `TransactionPolicy`, `JarPolicy`, `AccountFolderPolicy`, `CategoryPolicy`,
  `ProviderPolicy`, `ItemTransactionPolicy`, `Concerns/`
- **Middleware**: `AiTokenBudgetMiddleware`
- **Models** (`app/Models/Entities/`): `Jar` + familia
  (Setting/Cycle/Withdrawal/Transfer/Adjustment/LeverageSetting/Template/MonthlyOverride),
  `Account` + `AccountType/Folder/Tax`, `Transaction`/`PaymentTransaction`/`ItemTransaction`/
  `TransactionType`, `User`/`UserSetting`/`UserCurrency`/`AiUserSetting`
- **Datos**: `database/migrations/` (84) · `database/seeders/` (TransactionType, AccountType,
  JarTemplate, CategoryTemplate, PaymentTransactionTax)
- **Config**: `composer.json`, `.env.example`, `.github/workflows/` (CI/CD)

---

## 🖥️ FRONTEND — `OWFinanceFrontend2025` (branch `dev`)

### Docs (raíz del submódulo)
`README.md` · `QUICK_START.md` · `BACKEND_SPECIFICATIONS.md` · `ANALISIS_LOGICA_ACTUAL.md` ·
`GUIA_INGRESO_MENSUAL.md` · `PLAN_INTEGRACION_AJUSTES.md` · `CHECKLIST_IMPLEMENTACION.md` ·
`RESUMEN_EJECUTIVO_HIBRIDO.md` · `RESUMEN_IMPLEMENTACION.md` ·
`docs/STITCH_INTEGRATION_PIPELINE.md` · `docs/transaction-payloads.md`

### Código pertinente
- **Boot**: `src/boot/axios.ts` ⭐, `i18n.ts`
- **Router**: `src/router/routes.ts`, `index.ts`
- **Stores** (`src/stores/`): `auth` ⭐, `jars`, `transactions`, `transactionTypes`, `period`,
  `ui`, `index`
- **Utils**: `src/utils/layoutMode.ts` ⭐
- **Layouts** (`src/layouts/`): `DynamicRoleLayout` ⭐, `ProLayout`, `LiteMobileLayout`,
  `LiteDesktopLayout`, `LegacyLayout`, `AdminLayout`, `MainLayout`
- **Composables** (`src/composables/`): `useTransactionForm` ⭐, `useJarBalance`,
  `useCalculatedIncome`, `useUserRates`, `useAiChat`, `useAiExtraction`, `useVoiceInput`,
  `useImageCompressor`, `useBiometric`
- **Pages** (`src/pages/User/`): `DynamicHomePage`, `transactions/`, `jars/`, `accounts/`,
  `categories/`, `taxes/`, `config/`, `settings/`, `expense-analysis/` (+ `Admin/`, `auth/`)
- **Components clave** (`src/components/`): `TransactionCreateDialog` ⭐, `TransactionEditDialog`,
  `TransactionForm`, `TransactionBulkImportDialog`, `CrudPage`, `OnboardingModal`, `JarCard`,
  `JarsBalanceBar`, `BigJarSidebar`, `AccountDialog`, `AccountsTree`, `views/LiteHomeView`
- **Estilos/temas**: `src/css/tokens.css`, `quasar.variables.scss`, `app.scss`
- **i18n**: `src/i18n/` (solo `en-US`)
- **Config**: `quasar.config.ts`, `package.json`, `src-capacitor/` (móvil)

---

## 🔧 Scripts raíz (operación)
`dev-start.sh` / `dev-stop.sh` · `deploy-backend.sh` / `deploy-frontend.sh` /
`deploy-mobile.sh` · `ops-status.sh` / `status.sh` · `sync-submodule-pointers.sh` ·
`switch-env.sh` / `env-config.sh` · `build-*.sh` · `telegram-*.sh`

---

## 🧭 Por dónde empezar
1. `docs/producto/PANORAMA_360.md` — entender el sistema completo
2. `docs/00-sistema/GUIA_DE_LECTURA_CODIGO.md` — ruta de lectura del código
3. `docs/ui-ux/04-current-state-human-describe.md` — experiencia de usuario al detalle
4. `START_HERE.md` + `TASKS_LEDGER.md` — estado y tareas
