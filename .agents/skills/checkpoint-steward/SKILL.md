---
name: checkpoint-steward
description: Resumable step-level task tracking and intermediate handoff processing for OWFINANCE. Use when the user says "continúa"/"continue", "retoma"/"resume", "en qué quedamos", reports a step done, hands work between agents, or when starting a session and you need to know where to pick up. Also self-repairs the skill-registry when paths are broken.
version: 1.0.0
user-invocable: true
tags: [owfinance, checkpoint, resume, handoff, registry, state]
---

# Checkpoint Steward

Mantiene el estado reanudable de tareas a nivel de **paso**, procesa handoffs intermedios entre agentes (Claude Code / Codex / Antigravity), y auto-repara el `skill-registry`. Es la capa que permite: *"voy en la tarea B paso 3 → retoma ahí y dime que A ya está listo"*.

**Argumentos del usuario:** $ARGUMENTS

## Archivos que gobierna

| Archivo | Rol |
|---------|-----|
| `.state/CHECKPOINT.md` | Estado reanudable: RESUME POINTER + tareas con pasos `[x]`/`[>]`/`[ ]` |
| `TASKS_LEDGER.md` | Ledger maestro priorizado (vista estática) |
| `.atl/skill-registry.md` | Registro de paths de skills (a verificar/reparar) |

## Marcadores de paso (en CHECKPOINT.md)
- `[x]` paso terminado (con fecha)
- `[>]` paso activo — DEBE coincidir con `ACTIVE_STEP` del RESUME POINTER
- `[ ]` paso pendiente

## Operaciones

### 1. RESUME — "continúa" / "retoma" / "en qué quedamos"
1. Lee `.state/CHECKPOINT.md` → bloque `RESUME POINTER` (`ACTIVE_TASK`, `ACTIVE_STEP`).
2. Si engram MCP está disponible, `mem_search` el último checkpoint para recuperar contexto fino tras compaction.
3. Localiza la tarea/paso `[>]` y lee sus `NOTAS`.
4. Reporta al usuario: *"Retomo {ACTIVE_TASK} en {ACTIVE_STEP}. Pasos completados: …"* y continúa el trabajo.

### 2. COMPLETE STEP — el usuario o el agente termina un paso
1. Marca el paso como `[x]` con fecha.
2. Avanza el cursor: el siguiente `[ ]` pasa a `[>]` y actualiza `ACTIVE_STEP`.
3. Si era el último paso, marca `ESTADO: done` y limpia el RESUME POINTER (`ACTIVE_TASK: (ninguna)`).
4. Reporta: *"Paso {N} de {TASK} listo."* (esto cumple el requisito de "indicar que A está listo").
5. Si engram disponible: `mem_save` un checkpoint con el nuevo cursor.

### 3. NEW MULTI-STEP TASK — el usuario dicta "tarea A, B, C"
1. Crea bloques `### TASK-A/B/C` en CHECKPOINT.md con sus pasos.
2. Pon el primer paso de la primera tarea como `[>]` y fija el RESUME POINTER.
3. Refleja las tareas en `TASKS_LEDGER.md` si son trabajo de proyecto.

### 4. HANDOFF intermedio — pasar trabajo a otro agente
1. Asegura que CHECKPOINT.md tiene el cursor y NOTAS actualizadas (contexto autocontenido).
2. Si PASEO está instalado, usa la skill `paseo-handoff` y embebe en el prompt: tarea activa, paso, NOTAS, archivos tocados.
3. El agente receptor arranca leyendo CHECKPOINT.md → continuidad sin pérdida.

### 5. REGISTRY SELF-REPAIR — al iniciar sesión o si una skill no resuelve
1. Para cada path en `.atl/skill-registry.md`, verifica que el archivo exista.
2. Si hay paths rotos con un prefijo común obsoleto, calcula el prefijo correcto a partir de la raíz real del repo (cwd) y reemplaza el prefijo viejo.
3. Verifica de nuevo (todos deben resolver) y reporta cuántos se repararon.
4. Regla: nunca inventar paths; solo reescribir prefijos cuando el sufijo relativo existe en disco.

## Integración con memoria
- **Sin engram:** todo vive en `.state/CHECKPOINT.md` (file-based, versionado en git). Funciona dentro de Claude Code.
- **Con engram MCP:** además `mem_save`/`mem_search` para memoria COMPARTIDA entre agentes y recuperación tras compaction. Topic key sugerido: `checkpoint/{repo}/state`.

## Invariantes
- Solo UN paso `[>]` activo a la vez (el del RESUME POINTER).
- CHECKPOINT.md es la fuente de verdad operativa; TASKS_LEDGER.md es la vista priorizada.
- No marcar un paso `[x]` si quedó incompleto o con errores.
