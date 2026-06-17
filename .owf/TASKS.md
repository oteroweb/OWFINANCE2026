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
| **OWF-004** | [ ] | P0 | ⚪ | infra | migrated | MANUAL-002 | Deploy a Staging — desbloqueado (OWF-003 done) | — | — |
| **OWF-005** | [ ] | P1 | ⚪ | infra | adhoc | — | GitHub Secrets configurados por entorno | — | — |
| **OWF-006** | [ ] | P1 | ⚪ | infra | adhoc | — | Probar deploy stage end-to-end | — | — |
| **OWF-007** | [x] | P1 | ⚪ | feat | migrated | DS-32, TECH-LP-02 | Billetera implicita Lite (auto-crear/seleccionar account_id) | claude-code | 2026-06-10 |
| **OWF-008** | [ ] | P1 | ⚪ | feat | migrated | DS-33, TECH-LP-04 | Transicion Lite↔Pro sin perdida de datos | — | — |
| **OWF-009** | [ ] | P2 | ⚪ | feat | migrated | DS-34 | Rutas Pro restantes (super-grid, jars mgmt, settings, analisis) | — | — |
| **OWF-010** | [~] | P1 | ⚪ | infra | migrated | DS-51, TECH-002 | Tests Frontend (Vitest + Playwright) | claude-code | — |
| **OWF-011** | [ ] | P2 | ⚪ | feat | migrated | TECH-001 | UI Configuracion Asesor IA (+ endpoints CRUD) | — | — |
| **OWF-012** | [ ] | P2 | ⚪ | feat | migrated | TECH-003 | Flujo Password Reset | — | — |
| **OWF-013** | [ ] | P2 | ⚪ | infra | adhoc | — | GitHub Actions deploy.yml multi-environment | — | — |
| **OWF-016** | [ ] | P2 | ⚪ | feat | adhoc | — | Redirect segun rol (logueados en `/` → `/user/home` o `/admin`) | — | — |
| **OWF-017** | [ ] | P2 | ⚪ | feat | adhoc | — | Verificar rutas publicas desde LAN | — | — |
| **OWF-018** | [ ] | P3 | ⚪ | feat | adhoc | — | Responsive testing en mobile | — | — |
| **OWF-019** | [ ] | P2 | ⚪ | feat | migrated | DS-52, BUG-006 | i18n ES/EN del copy nuevo | — | — |
| **OWF-020** | [ ] | P2 | ⚪ | infra | migrated | OPS-001 | Sincronizar DB Stage → Dev | — | — |
| **OWF-021** | [ ] | P3 | ⚪ | infra | migrated | WEEK2-A | Dias 11-15: monitoring, Sentry, feature flags | — | — |
| **OWF-022** | [ ] | P3 | ⚪ | infra | migrated | WEEK2-B | Dias 16-20: Android build, PRO pages, bulk import | — | — |
| **OWF-023** | [ ] | P3 | ⚪ | fix | migrated | BUG-001 | Reglas opcionales tipo no aplican en vista previa (bulk import) | — | — |
| **OWF-024** | [ ] | P3 | ⚪ | fix | migrated | BUG-002 | Transferencia falla en dry-run (bulk import) | — | — |
| **OWF-025** | [ ] | P3 | ⚪ | fix | migrated | BUG-003 | Saldo post-import no refleja movimientos | — | — |
| **OWF-026** | [ ] | P3 | ⚪ | fix | migrated | BUG-004 | Falta suite pruebas mixtas bulk | — | — |
| **OWF-027** | [ ] | P3 | ⚪ | fix | migrated | BUG-005 | "Records per page: All" ignora filtro | — | — |
| **OWF-028** | [ ] | P3 | ⚪ | fix | migrated | BUG-007 | Menubar rutas duplicadas en dev | — | — |
| **OWF-048** | [x] | P0 | 🔴 | fix | adhoc | — | Fix router DOM perdido al navegar — slot layout + default lite + Playwright 23/23 | opencode | 2026-06-10 |
| **OWF-049** | [ ] | P2 | ⚪ | feat | adhoc | — | Cántaros con contexto rico: descripción, propósito, metadata ligada al perfil de usuario | — | — |
| **OWF-054** | [x] | P1 | 🔴 | fix | adhoc | — | Fix navegación router: pantalla en blanco (imports DynamicRoleLayout + IntersectionObserver re-observe + scrollBehavior reset) | 2026-06-11 |

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

<!--
  NEXT_ID: OWF-056
  Proximo agente: usar OWF-055 para la primera tarea nueva.
  Incrementar NEXT_ID al final.
-->
