# OWFINANCE 2026 — Ledger Maestro de Tareas

> Fuente única de verdad para todo el trabajo pendiente.
> Consolida `.pending/`, `BUGS/`, `TAREA_*`, `MANUAL-*` e infraestructura de agentes.
> Última actualización: 2026-06-10

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
| 1 | INFRA-001 | INFRA | Reparar `skill-registry.md` (paths rotos) | **done** | toda delegación | `.atl/skill-registry.md` — 40/40 paths OK |
| 2 | INFRA-002 | INFRA | Elegir e instalar backend de memoria (engram recomendado) | blocked | persistencia SDD | Requiere aprobación instalación |
| 3 | INFRA-003 | INFRA | Instalar PASEO (handoff multi-agente) | blocked | handoff Codex/Antigravity | `npx skills add getpaseo/paseo` — requiere aprobación |
| 4 | INFRA-004 | INFRA | Skill de procesado intermedio + auto-reparación de registry | todo | robustez del registry | Evita que los paths se rompan al mover de máquina |
| 5 | MANUAL-001 | MANUAL | Activar Backend AI (API key en `.env`) | **todo (bloqueante)** | todo el módulo AI | `.pending/MANUAL-001-activar-backend.md` |
| 6 | MANUAL-002 | MANUAL | Configurar DNS owfinances.com + deploy inicial | blocked (← MANUAL-001) | WEEK2-* | Apuntar dominio `owfinances.com` a servidor; configurar subdomains `dev.owfinances.com`, `stage.owfinances.com`, `app.owfinances.com`; deploy inicial a cada branch. Ver `.pending/MANUAL-002-deploy-staging.md` |
| 7 | OPS-001 | TECH | Sincronizar DB Stage → Dev | todo | testing real en dev | `TAREA_sync_stage_to_dev.md` + `sync_stage_to_dev.sh` (script listo) |
| 8 | TECH-001 | TECH | UI Configuración del Asesor IA (+ endpoints CRUD) | todo | — | `.pending/TECH-001-settings-asesor-ui.md` |
| 9 | TECH-002 | TECH | Tests Frontend (Vitest + Playwright) | todo | staging prod-ready | `.pending/TECH-002-tests-frontend.md` — ver también TECH-005 |
| 10 | TECH-003 | TECH | Flujo de Password Reset | todo | abrir a usuarios reales | `.pending/TECH-003-password-reset.md` |
| 11 | WEEK2-A | TECH | Días 11-15: monitoring, Sentry, feature flags | blocked (← MANUAL-002) | — | `.pending/WEEK2-dias-11-15.md` |
| 12 | WEEK2-B | TECH | Días 16-20: Android build, PRO pages, bulk import | blocked (← MANUAL-002) | — | `.pending/WEEK2-dias-16-20.md` |
| 13 | DESIGN-001 | DESIGN | Rediseño con kit Claude Design (lite-desktop) | blocked | — | Acceso vía navegador en PC del usuario (pendiente) |

---

## MODO DUAL LITE/PRO (producto, 2026-06-02)

> Especificación: `docs/producto/MODOS_LITE_VS_PRO.md` · Cántaros: `docs/producto/MODELO_CANTAROS.md` · Cuentas/transacciones: `docs/producto/CUENTAS_Y_TRANSACCIONES.md`

| # | ID | Tipo | Tarea | Estado | Detalle |
|---|----|------|-------|--------|---------|
| 14 | TECH-LP-01 | TECH | Gating funcional por `layout_mode` (no solo visual) en transacciones y menú | todo | Hoy LITE solo cambia densidad; debe limitar funciones |
| 15 | TECH-LP-02 | TECH | Modelo de gasto LITE: billetera implícita única (auto-crear/seleccionar, account_id NOT NULL) | todo | Decidido 2026-06-02 (opción A); migración a PRO sin pérdida |
| 16 | TECH-LP-03 | TECH | Construir `ProHomeView` | todo | Hoy comentado en `DynamicHomePage.vue` |
| 17 | TECH-LP-04 | TECH | Transición LITE↔PRO sin pérdida de datos | todo | Reversible, ocultar no borrar |
| 18 | TECH-004 | DESIGN | Afinar modo oscuro y temas | todo | `.pending/TECH-004-dark-mode-temas.md` |

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
| BUG-008 | Layout LITE: vistas vacías | Layout LITE | todo | media |

Detalle por bug en `BUGS/BUG-*.md`.

---

## Notas
- **Ruta vieja en docs:** `WEEK2-dias-16-20.md` y `BUGS-diferidos.md` referencian `/Users/joseluisoterolopez/...` — corregir al tocarlos.
- **Cadena bloqueante crítica:** MANUAL-001 → MANUAL-002 → WEEK2-*. Sin la API key de AI nada del módulo IA arranca.
- Este ledger es la fuente de verdad; los archivos individuales en `.pending/` y `BUGS/` mantienen el detalle.
