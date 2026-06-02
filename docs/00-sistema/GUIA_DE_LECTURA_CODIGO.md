# Guía de lectura del código — OWFINANCE 2026

> Ruta ordenada de archivos a leer para entender **todo** el sistema (backend + frontend).
> Pensada para onboarding de personas y agentes. Lee de arriba abajo dentro de cada bloque.
> Última actualización: 2026-06-02.

## Cómo usar esta guía
- 🥇 = imprescindible (el núcleo) · 🥈 = importante · 🥉 = complementario.
- Antes del código, lee la documentación de producto: `docs/producto/README.md`.

---

## A) BACKEND — `OWFINANCEBackend2025` (Laravel 12 + Sanctum)

### A1. Punto de entrada y contratos 🥇
| Orden | Archivo | Qué entiendes |
|-------|---------|---------------|
| 1 | `bootstrap/app.php` | Routing (`/api/v1`, auto-glob de `routes/api/*.php`), health `/up`, scheduler (`jars:materialize-cycles`), manejo unificado de errores 401/403 |
| 2 | `routes/api/auth.php` | Login/register (con throttle) y logout |
| 3 | `routes/api/transactions.php` | Endpoints de transacciones (`save`, `bulk`, listados) |
| 4 | `routes/api/health.php` | Health versionado `/api/v1/health` |

### A2. El corazón: transacciones 🥇
| Orden | Archivo | Qué entiendes |
|-------|---------|---------------|
| 5 | `app/Http/Controllers/Api/TransactionController.php` (1161 líneas) | **El flujo central.** `save()` (modelo unificado payments[]+items[], inferencia de tipo, ownership, conversión), `bulkSave()`, `update`, `all` |
| 6 | `app/Observers/TransactionObserver.php` | Cómo una transacción dispara recálculo de saldos |
| 7 | `app/Services/BalanceService.php` | Saldo de cuentas |
| 8 | `app/Services/TransactionBulkService.php` | Lógica de carga masiva (relacionada con BUG-001..005) |
| 9 | `app/Services/UserRateService.php` | Tasas y multimoneda |

### A3. Cántaros (jars) 🥇
| Orden | Archivo | Qué entiendes |
|-------|---------|---------------|
| 10 | `app/Models/Entities/Jar.php` | Campos y comportamiento del cántaro (%/fijo, base, ciclo, leverage) |
| 11 | `app/Services/JarBalanceService.php` | **Cómo se calcula el disponible de cada cántaro** |
| 12 | `app/Http/Controllers/Api/JarController.php` (839) y `UserJarController.php` (692) | CRUD y operaciones de cántaros |
| 13 | Familia Jar: `JarSetting`, `JarCycle`, `JarWithdrawal`, `JarTransfer`, `JarAdjustment`, `JarLeverageSetting`, `JarTemplate` | Ajustes, ciclos, retiros, transferencias, apalancamiento, plantillas |

### A4. Cuentas, tipos y modelos de soporte 🥈
| Orden | Archivo | Qué entiendes |
|-------|---------|---------------|
| 14 | `app/Models/Entities/Account.php`, `AccountType.php`, `AccountFolder.php`, `AccountTax.php` | Cuentas, tipos, carpetas, impuestos |
| 15 | `Transaction.php`, `PaymentTransaction.php`, `ItemTransaction.php`, `TransactionType.php` | Estructura de datos de un movimiento |
| 16 | `User.php`, `UserSetting.php` (`layout_mode`), `UserCurrency.php` | Usuario, modo LITE/PRO, moneda |
| 17 | `app/Http/Controllers/Api/AccountController.php` (706), `CategoryController.php` (503) | CRUD cuentas y categorías |

### A5. Seguridad y autorización 🥈
| Orden | Archivo | Qué entiendes |
|-------|---------|---------------|
| 18 | `app/Policies/` (`TransactionPolicy`, `JarPolicy`, `AccountFolderPolicy`, `Concerns/`) | Quién puede operar qué (ownership) |

### A6. IA 🥈
| Orden | Archivo | Qué entiendes |
|-------|---------|---------------|
| 19 | `app/Services/AI/` + `routes/api/ai.php` | Extracción multi-proveedor, asesor, rate limiting (`throttle:ai`, `ai.budget`) |
| 20 | `app/Http/Middleware/AiTokenBudgetMiddleware.php` | Control de presupuesto de tokens |

### A7. Datos de arranque 🥉
| Orden | Archivo | Qué entiendes |
|-------|---------|---------------|
| 21 | `database/seeders/`: `TransactionTypeSeeder`, `AccountTypeSeeder`, `JarTemplateSeeder`, `CategoryTemplateSeeder`, `PaymentTransactionTaxSeeder` | Tipos, plantilla 55/10/10/10/10, impuestos (IGTF, pago móvil) |
| 22 | `database/migrations/` (84) | Esquema completo (leer en orden cronológico) |

---

## B) FRONTEND — `OWFinanceFrontend2025` (Quasar 2 + Vue 3 + TS)

### B1. Arranque y estado 🥇
| Orden | Archivo | Qué entiendes |
|-------|---------|---------------|
| 1 | `src/boot/axios.ts` | Cliente API, interceptores (auth, errores, base `/api/v1`) |
| 2 | `src/router/routes.ts` + `router/index.ts` | Rutas y guards por rol |
| 3 | `src/stores/auth.ts` | Sesión, rol y **`layout_mode` (lite/pro/legacy)** |
| 4 | `src/stores/` (`jars`, `transactions`, `transactionTypes`, `period`, `ui`) | Estado del dominio |
| 5 | `src/utils/layoutMode.ts` | Enum y normalización del modo |

### B2. Layouts y modo dual 🥇
| Orden | Archivo | Qué entiendes |
|-------|---------|---------------|
| 6 | `src/layouts/DynamicRoleLayout.vue` | **Enrutador de layout** según modo |
| 7 | `src/layouts/ProLayout.vue`, `LiteMobileLayout.vue`, `LiteDesktopLayout.vue`, `LegacyLayout.vue` | Las shells de cada modo |
| 8 | `src/components/OnboardingModal.vue` | Elección LITE/PRO al entrar |
| 9 | `src/pages/User/DynamicHomePage.vue` + `src/components/views/LiteHomeView.vue` | Home por modo (ProHomeView **pendiente**) |

### B3. El corazón: transacciones 🥇
| Orden | Archivo | Qué entiendes |
|-------|---------|---------------|
| 10 | `src/composables/useTransactionForm.ts` | Lógica del formulario de transacción |
| 11 | `src/components/TransactionCreateDialog.vue` (3614) | **Todos los modos de registro** (simple, transfer, split, items, cross-currency) |
| 12 | `src/components/TransactionBulkImportDialog.vue` | Carga masiva (BUG-001..005) |
| 13 | `src/pages/User/transactions/index.vue` (3172) | Listado, filtros, paginación |
| 14 | `src/components/CrudPage.vue` | Componente CRUD genérico reutilizable |

### B4. Cántaros y cuentas 🥈
| Orden | Archivo | Qué entiendes |
|-------|---------|---------------|
| 15 | `src/pages/User/jars/index.vue` (4144) + `components/JarCard.vue`, `JarsBalanceBar.vue` | UI de cántaros |
| 16 | `src/composables/useJarBalance.ts`, `useCalculatedIncome.ts` | Cálculo de saldos/ingreso en el front |
| 17 | `src/pages/User/accounts/` + `components/AccountDialog.vue`, `AccountsTree.vue` | UI de cuentas |
| 18 | `src/pages/User/config/index.vue` (1634), `expense-analysis/index.vue` | Configuración y analítica |

### B5. IA, móvil y temas 🥈
| Orden | Archivo | Qué entiendes |
|-------|---------|---------------|
| 19 | `src/composables/useAiChat.ts`, `useAiExtraction.ts`, `useVoiceInput.ts`, `useImageCompressor.ts` | Funciones IA (asesor, OCR, voz) |
| 20 | `src/composables/useBiometric.ts` | Biometría (Capacitor) |
| 21 | `src/css/tokens.css`, `quasar.variables.scss`, `app.scss` | Tokens, `$dark`, modo oscuro (liga TECH-004) |
| 22 | `src/boot/i18n.ts` + `src/i18n/` | i18n (solo en-US hoy → BUG-006) |

---

## C) Orquestación / raíz (central)
| Archivo | Qué entiendes |
|---------|---------------|
| `START_HERE.md`, `AGENTS.md`, `TASKS_LEDGER.md` | Onboarding, reglas, tareas (fuente única) |
| `docs/producto/` | Modelo de negocio y variaciones LITE/PRO |
| `dev-start.sh`, `deploy-*.sh`, `ops-status.sh` | Levantar y desplegar |

---

## Ruta mínima (si solo tienes 1 hora)
1. `docs/producto/README.md` → 2. `bootstrap/app.php` → 3. `TransactionController::save()` →
4. `JarBalanceService.php` → 5. `stores/auth.ts` + `layoutMode.ts` →
6. `DynamicRoleLayout.vue` → 7. `TransactionCreateDialog.vue`.
Con eso entiendes el modelo unificado de transacciones, los cántaros y el modo dual.
