# OWFINANCE 2026 — Ledger Maestro de Tareas

> Fuente única de verdad para todo el trabajo pendiente.
> Consolida `.pending/`, `BUGS/`, `TAREA_*`, `MANUAL-*` e infraestructura de agentes.
> Última actualización: 2026-06-08 (sesión activa)

## Leyenda de estado
- `todo` — pendiente
- `in-progress` — en trabajo
- `blocked` — depende de otra tarea o de acción humana
- `done` — resuelto y validado

## Leyenda de tipo
- `MANUAL` — requiere acción humana (la IA no puede)
- `TECH` — trabajo técnico ejecutable por IA
- `BUG` — defecto a corregir
- `INFRA` — infraestructura de agentes/herramientas/memoria
- `DESIGN` — rediseño UI/UX

---

## ORDEN DE EJECUCIÓN GLOBAL

| # | ID | Tipo | Tarea | Estado | Bloquea a | Detalle |
|---|----|------|-------|--------|-----------|---------|
| 1 | INFRA-001 | INFRA | Reparar `skill-registry.md` (paths rotos) | **done** | toda delegación | `.atl/skill-registry.md` — 41/41 paths OK (verificado 2026-06-08) |
| 2 | INFRA-002 | INFRA | Instalar engram (backend de memoria) | **done** | persistencia SDD | `/opt/homebrew/Cellar/engram/1.16.1/bin/engram` + MCP activo; mem_save/mem_search funcionando |
| 3 | INFRA-003 | INFRA | Instalar PASEO (handoff multi-agente) | **done** | — | v0.1.90, daemon corriendo en `127.0.0.1:6767`. Providers: Claude ✓, OpenCode ✓. App en `/Applications/Paseo.app`, CLI en `/opt/homebrew/bin/paseo` |
| 4 | INFRA-004 | INFRA | Auto-reparación de registry al cambiar de máquina | **done** | robustez del registry | Cubierto por `checkpoint-steward` skill (`.agents/skills/checkpoint-steward/SKILL.md`) + skill-registry skill puede regenerar `.atl/` en cualquier máquina |
| 5 | MANUAL-001 | MANUAL | Activar Backend AI (API key en `.env`) | **todo (bloqueante)** | todo el módulo AI | `.pending/MANUAL-001-activar-backend.md` |
| 6 | MANUAL-002 | MANUAL | Deploy a Staging | blocked (← MANUAL-001) | WEEK2-* | `.pending/MANUAL-002-deploy-staging.md` |
| 7 | OPS-001 | TECH | Sincronizar DB Stage → Dev | todo | testing real en dev | `TAREA_sync_stage_to_dev.md` + `sync_stage_to_dev.sh` (script listo) |
| 8 | TECH-001 | TECH | UI Configuración del Asesor IA (+ endpoints CRUD) | todo | — | `.pending/TECH-001-settings-asesor-ui.md` |
| 9 | TECH-002 | TECH | Tests Frontend (Vitest + Playwright) | **in-progress** | staging prod-ready | Playwright instalado + config creado + tests shell Lite escritos. Falta: tests de rutas y componentes. |
| 10 | TECH-003 | TECH | Flujo de Password Reset | todo | abrir a usuarios reales | `.pending/TECH-003-password-reset.md` |
| 11 | WEEK2-A | TECH | Días 11-15: monitoring, Sentry, feature flags | blocked (← MANUAL-002) | — | `.pending/WEEK2-dias-11-15.md` |
| 12 | WEEK2-B | TECH | Días 16-20: Android build, PRO pages, bulk import | blocked (← MANUAL-002) | — | `.pending/WEEK2-dias-16-20.md` |
| 13 | DESIGN-001 | DESIGN | Rediseño con kit Claude Design (lite-desktop) | **done** | — | DS-01..DS-52 completados. Lite+Pro, tokens DS, i18n ES/EN, tests e2e, billetera implícita, transición sin pérdida |

---

## MODO DUAL LITE/PRO (producto, 2026-06-02)

> Especificación: `docs/producto/MODOS_LITE_VS_PRO.md` · Cántaros: `docs/producto/MODELO_CANTAROS.md` · Cuentas/transacciones: `docs/producto/CUENTAS_Y_TRANSACCIONES.md`

| # | ID | Tipo | Tarea | Estado | Detalle |
|---|----|------|-------|--------|---------|
| 14 | TECH-LP-01 | TECH | Gating funcional por `layout_mode` | **done** | Absorbido en DS-31 — HomeView.vue enruta LiteHomeView vs ProHomeView |
| 15 | TECH-LP-02 | TECH | Billetera implícita Lite | **done** | Absorbido en DS-32 — useTransactionForm + TransactionCreateDialog |
| 16 | TECH-LP-03 | TECH | Construir `ProHomeView` | **done** | Absorbido en DS-30 — ProHomeView.vue con KPIs + breakdown + AI strip |
| 17 | TECH-LP-04 | TECH | Transición LITE↔PRO sin pérdida de datos | **done** | Absorbido en DS-33 — config page con api.put('/user/settings') |
| 18 | TECH-004 | DESIGN | Afinar modo oscuro y temas | **done** | Absorbido en DS-40 — tokens CSS dark mode via body.body--dark |

---

## INTEGRACIÓN DESIGN SYSTEM (2026-06-08) — ejecuta DESIGN-001

> Plan completo: `OWFinanceFrontend2025/DESIGN_SYSTEM_INTEGRATION_PLAN.md`
> Alcance: Lite + Pro (sistema completo). Cada fase es un lote verificable en browser.

| # | ID | Fase | Tarea | Estado | Absorbe |
|---|----|------|-------|--------|---------|
| F0 | DS-01 | 0 Fundaciones | Portar tokens completos (`colors_and_type.css` → `src/css/design-system.css`), `tokens.css` huérfano eliminado | **done** | verificado navy en browser |
| F0 | DS-02 | 0 Fundaciones | Self-host Satoshi + DM Sans (`src/css/fonts/`), capa de tema con switch `$font-preset: ds\|outfit` | **done** | font-family DM Sans confirmado |
| F0 | DS-03 | 0 Fundaciones | `quasar.variables.scss` → capa `theme.scss` (`$brand-preset: navy\|cyan`); `$primary` = `#1E3A8A` | **done** | inspect = rgb(30,58,138) |
| F0 | DS-04 | 0 Fundaciones | `app.scss` realineado (fondo plano, re-mapeo `--ow-*`→tokens DS, glass solo en overlays) | **done** | — |
| F1 | DS-10 | 1 Shell Lite Desktop | Reskin `LiteDesktopLayout.vue` (nav pill flotante, max-1200) — arregla nav solapado | **done** | — |
| F1 | DS-11 | 1 Shell Lite Desktop | Componentes shell (Header, NavPill, ExpandedMenu) | **done** | — |
| F1 | DS-12 | 1 Shell Lite Desktop | Empty states Lite | **done** | **BUG-008** resuelto previamente; LiteHomeView incluye empty states nativos |
| F2 | DS-20..25 | 2 Rutas Lite | Home/Transactions/Jars/Config + QuickAdd + Lite Mobile | **done** | LiteHomeView.vue, LiteTransactionsView.vue (filtro inteligente), LiteJarsView.vue, Config calm list |
| F3 | DS-30 | 3 Pro | Construir `ProHomeView` (desbloquea "Elegir Pro") | **done** | **TECH-LP-03** — KPI strip + spending breakdown + dense transactions + AI advisor strip |
| F3 | DS-31 | 3 Pro | Gating funcional por `layout_mode` | **done** | **TECH-LP-01** — HomeView.vue enruta LiteHomeView vs ProHomeView según auth.settings.layout_mode |
| F3 | DS-32 | 3 Pro | Billetera implícita Lite | **done** | **TECH-LP-02** — auto-asigna primer account; selector oculto en Lite |
| F3 | DS-33 | 3 Pro | Transición Lite↔Pro sin pérdida | **done** | **TECH-LP-04** — config page usa api.put('/user/settings'); datos nunca se borran |
| F3 | DS-34 | 3 Pro | Rutas Pro restantes (super-grid, jars mgmt, settings, análisis) | **done** | Rutas: transactions, jars, config, expense-analysis ya existen |
| F4 | DS-40 | 4 Dark + pulido | Dark mode ramp ink | **done** | **TECH-004** — Todas las vistas usan tokens CSS con modo oscuro definido |
| F4 | DS-41 | 4 Dark + pulido | Iconografía safe-set, sin emoji | **done** | Ningún archivo nuevo usa `o_*`; solo Material Icons filled |
| F4 | DS-42 | 4 Dark + pulido | Microinteracciones + focus states | **done** | Transiciones 150-220ms en hover/active de botones, nav, cards, chips |
| F5 | DS-50 | 5 Higiene | Normalizar casing git `User`/`user`/`Admin` → reactivar overlay | **done** | Renombrado en Git; `vue-tsc` sin errores de casing |
| F5 | DS-51 | 5 Higiene | Tests Vitest + Playwright | **done** | 4 spec files: auth, lite-routes, design-system, helpers/auth — cobertura e2e rutas + tokens DS |
| F5 | DS-52 | 5 Higiene | i18n ES/EN del copy nuevo | **done** | **BUG-006** — i18n/es + i18n/en-US completos (auth/nav/home/transactions/jars/pro/config/form) |

---

## BUGS (diferidos post-MVP)

| ID | Título | Módulo | Estado | Prioridad |
|----|--------|--------|--------|-----------|
| BUG-001 | Reglas opcionales de tipo no aplican en vista previa | Bulk import | todo | alta |
| BUG-002 | Transferencia falla en dry-run, vista previa desincronizada | Bulk import + API | todo | alta |
| BUG-003 | Saldo post-import no refleja movimientos | Transacciones + balance | todo | alta |
| BUG-004 | Falta suite de pruebas mixtas bulk | Bulk import + validación | todo | alta |
| BUG-005 | "Records per page: All" ignora filtro de marzo | Paginación/filtros | todo | alta |
| BUG-006 | Inconsistencia idioma ES/EN en UI | i18n transversal | todo | media |
| BUG-007 | Menubar rutas duplicadas en dev | Routing | revisar (tiene fix-report) | media |
| BUG-008 | Layout LITE: vistas vacías | Layout LITE | **done** | media | Resuelto: router-view duplicado en DynamicRoleLayout eliminado previamente. Revalidado 2026-06-08. |

Detalle por bug en `BUGS/BUG-*.md`.

---

## Notas
- **Ruta vieja en docs:** `WEEK2-dias-16-20.md` y `BUGS-diferidos.md` referencian `/Users/joseluisoterolopez/...` — corregir al tocarlos.
- **Cadena bloqueante crítica:** MANUAL-001 → MANUAL-002 → WEEK2-*. Sin la API key de AI nada del módulo IA arranca.
- Este ledger es la fuente de verdad; los archivos individuales en `.pending/` y `BUGS/` mantienen el detalle.
