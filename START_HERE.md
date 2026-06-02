# START HERE — Onboarding Rápido (Agentes y Humanos)

> Lee este archivo PRIMERO. Te da contexto del sistema en 2 minutos y te apunta al resto.
> Última actualización: 2026-06-01

## Qué es OWFINANCE 2026
App de finanzas personales premium basada en el método de **Cántaros (Jars)**: cada cántaro = categoría con % del ingreso mensual; el usuario reparte 100% del ingreso. Doble audiencia: **LITE** (mobile-first, simple) y **PRO** (desktop denso, analítico). Mismo design system, distinta densidad.

## Arquitectura (monorepo + 2 submódulos git)
| Repo | Stack | Branch | Métricas |
|------|-------|--------|----------|
| **OWFINANCEBackend2025** | Laravel 12 + PHP 8.2 + Sanctum | `dev` | 25 archivos de rutas, 39 controllers, 62 models, 84 migraciones, 26 tests |
| **OWFinanceFrontend2025** | Quasar 2 + Vue 3 + TS + Capacitor | `dev` | 31 pages, 57 components, 7 layouts, 8 stores, 34 rutas |
| central (orquestador) | scripts + docs | `master` | este repo |

- API base versionada: **`/api/v1`** · Auth: **Bearer Sanctum** · Envelope: `{ status, code, message, data }`
- Reglas que NO se rompen: ver `AGENTS.md`.

## Entornos
| Env | Branch | URL |
|-----|--------|-----|
| DEV | `dev` | appfinanzasdev.blockshift.website |
| STAGING | `staging` | appfinanzas-staging.blockshift.website |
| PROD | `master` | appfinanzas.blockshift.website |
Estrategia completa: `DEPLOYMENT-STRATEGY.md`. Scripts: `deploy-frontend.sh`, `deploy-backend.sh`, `deploy-mobile.sh`.

## 🚨 Bloqueante actual
- **MANUAL-001**: API key de AI no configurada (`0/3` en backend `.env`). Sin esto el módulo IA no arranca → bloquea staging y WEEK2-*. Ver `.pending/MANUAL-001-activar-backend.md`.

## 🎯 FUENTE ÚNICA DE LA VERDAD (canónico, 2026-06-01)
> No crear informes nuevos sueltos. Todo el estado vive en estos 4 lugares + engram.

| Capa | Archivo / sistema | Rol |
|------|-------------------|-----|
| **Entrada** | `START_HERE.md` (este) | Orientación en 2 min |
| **Trabajo** | `TASKS_LEDGER.md` | Única lista priorizada de TODAS las tareas |
| **Cursor** | `.state/CHECKPOINT.md` | RESUME POINTER — dónde retomar |
| **Memoria compartida** | engram (`owfinance2026`) | Contexto entre sesiones/agentes (`mem_search`/`mem_save`) |

Reglas técnicas: `AGENTS.md` · Bugs: `BUGS/README.md` · Tareas manuales: `.pending/` · Informes puntuales viejos: `docs/archive/` (histórico, NO fuente de verdad).

## Dónde vive el estado del trabajo
| Para... | Lee... |
|---------|--------|
| Saber dónde retomar (paso activo) | `.state/CHECKPOINT.md` ← **RESUME POINTER** |
| Lista priorizada de todo | `TASKS_LEDGER.md` |
| Bugs | `BUGS/README.md` |
| Tareas manuales/técnicas | `.pending/` |

## Infraestructura de agentes (instalada 2026-06-01)
| Herramienta | Rol | Estado |
|-------------|-----|--------|
| **engram** (1.16.1, MCP) | Memoria compartida Claude/Codex/Antigravity + recuperación tras compaction (`mem_save`/`mem_search`) | Instalado — activa al reiniciar Claude Code |
| **PASEO** (`~/.agents/skills/paseo*`) | Handoff y orquestación multi-agente | Instalado |
| **Context7** (MCP) | Docs de librerías al día | Conectado |
| **checkpoint-steward** (skill) | Tracking reanudable a nivel de paso + auto-repara registry | Creado |
| skill-registry | Resolución de paths de skills (orquestador) | `.atl/skill-registry.md` — reparado, 40 paths OK |

### MCPs
Slack ✓ · Mermaid ✓ · engram ✓ · Context7 ✓ · Google Drive (auth pendiente) · Notion (auth pendiente)

## Sistema de roles / SDD
- 24 skills de rol + UX + frontend en `.agents/skills/` (ver `.atl/skill-registry.md`).
- SDD (spec-driven) en `.claude/skills/sdd-*`. Convenciones en `.claude/skills/_shared/`.
- Orquestación y reglas de delegación: `CLAUDE.md`.

## Docs canónicos
- `AGENTS.md` — reglas técnicas para agentes
- `docs/INDICE_MAESTRO_PROYECTO.md` — índice maestro
- `docs/ui-ux/DESIGN_MAP.md` + `MASTER_DESIGN_PROMPT.md` — design system congelado
- `docs/ARQUITECTURA_PROYECTO.md` — arquitectura

## Flujo recomendado al empezar una sesión
1. Lee `.state/CHECKPOINT.md` → RESUME POINTER (dónde quedaste).
2. Si engram activo: `mem_search` el último checkpoint para contexto fino.
3. Revisa `TASKS_LEDGER.md` para prioridad.
4. Trabaja; al terminar cada paso, marca `[x]` en CHECKPOINT y avanza el cursor.
