# OWFINANCE — Estado del Workspace
<!-- PROTOCOLO: Todo agente LEE este archivo al iniciar sesion. -->
<!-- Solo un agente escribe a la vez. Updated = timestamp del ultimo escritor. -->
<!-- Tareas se referencian por ID (OWF-NNN) → ver .owf/TASKS.md -->

**Updated:** 2026-06-11T00:00:00Z
**By:** claude-code

---

## En Progreso RIGHT NOW

| ID | Tarea | Agente | Progreso | Detalle |
|----|-------|--------|----------|---------|
| — | — | — | — | Sin tareas activas |

### OWF-054 — Fix navegación router (COMPLETADA 2026-06-11)

3 fixes deployados a prod (owfinances.com, commit main 35c0a89):
- `DynamicRoleLayout.vue` — imports explícitos de sub-layouts (Vue 3 script setup)
- `PublicLayout.vue` — watcher route.path re-observa .reveal elements en navegación
- `src/router/index.ts` — scrollBehavior: reset scroll al top en cada navegación pública

### SDD Change: (none)

### Paseo Epic: (none)

### Sin asignar — disponible para cualquier agente

| ID | Pri | Tarea | Type |
|----|-----|-------|------|
| OWF-004 | P0 | Deploy Staging (desbloqueado) | infra |
| OWF-008 | P1 | Transicion Lite↔Pro sin perdida | feat |
| OWF-009 | P2 | Rutas Pro restantes | feat |
| OWF-012 | P2 | Flujo Password Reset | feat |
| OWF-016 | P2 | Redirect segun rol | feat |
| OWF-017 | P2 | Verificar rutas publicas desde LAN | feat |

---

## Blocked (requieren accion humana)

| ID | Razon | Desbloquea |
|----|-------|------------|
| OWF-001 | SSH keys — prod OK. Dev/stage pendientes | OWF-005, OWF-006 |

---

## Stats

| Metrica | Valor |
|---------|-------|
| **Total** | 56 tareas |
| **Completadas** | 28 (50%) |
| **En progreso** | 0 |
| **Bloqueadas** | 1 (OWF-001 parcial) |
| **Disponibles** | 27 |
| **Progreso** | ██████████░░░░░░░░░░ 50% |

---

## Next Up (por prioridad)

1. **OWF-004** — Deploy Staging
2. **OWF-008** — Transicion Lite↔Pro sin perdida de datos
3. **OWF-010** — Tests Frontend (Vitest + Playwright) — continuar
4. **OWF-009** — Rutas Pro restantes
5. **OWF-012** — Flujo Password Reset
6. **OWF-049** — Cantaros con contexto rico

---

## Uncommitted Changes (working directory)

Ninguno. Frontend main limpio — todos los fixes commitados y deployados a prod.

---

## Historial Reciente

| Fecha | Agente | OWF | Que hizo |
|-------|--------|-----|----------|
| 2026-06-11 | claude-code | OWF-054 | Fix navegación router: DynamicRoleLayout imports + IntersectionObserver re-observe + scrollBehavior reset. Deployado prod. |
| 2026-06-10 | claude-code | — | Asesor IA: OpenCode Go integrado como provider. OpenCodeGoProvider creado, factory registrado, .env configurado. Test OK — respuesta con contexto financiero real, streaming funcionando. |
| 2026-06-10 | opencode | OWF-048 | Fix router DOM perdido: slot layout + default lite + Playwright 23/23 |
| 2026-06-10 | opencode | OWF-047 | Mensajes ES + passwords + alert() eliminados + i18n notify |
| 2026-06-10 | claude-code | OWF-007 | Billetera implicita Lite: banner setup + auto-create backend |
| 2026-06-10 | claude-code | OWF-053 | Seed datos base prod (roles, account types, currencies, transaction types) |
| 2026-06-10 | claude-code | OWF-050..052 | CORS fix, merge dev→main, arquitectura prod evaluada |
| 2026-06-10 | opencode | OWF-029..034 | Fix PHP deprecated, .deploy/, marketing pages, login split-panel |
| 2026-06-08 | claude-code | OWF-039..045 | Design System F0-F5 completo |
| 2026-06-08 | claude-code | OWF-035..038 | Infra agentes (engram, paseo, registry) |

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
