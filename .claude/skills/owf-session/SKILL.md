---
name: owf-session
description: Orquestador central de sesión OWFinance. Todas las skills del proyecto se invocan desde aquí. Ejecutar start al arrancar y end al terminar — nunca invocar otras skills directamente sin pasar por este orquestador.
user-invocable: true
argument-hint: "start | end"
---

# Skill: owf-session — Orquestador Central

**Este skill ES el punto de entrada de todo el trabajo en OWFinance.**
Ninguna otra skill se invoca directamente — todas pasan por aquí.

---

## Mapa de skills del proyecto

| Skill | Cuándo se usa | Invocada desde |
|-------|--------------|----------------|
| `owf-session` | Arranque y cierre de sesión | El usuario o automático |
| `owf-deploy` | Después de cada tarea completada | `owf-session end` + post-tarea |
| `owf-qa-production` | Verificar vistas en prod tras deploy | `owf-session end` si hay cambios UI |
| `engram:memory` | Guardar decisiones y bugs | `owf-session end` + inline al descubrir algo |
| `verification-before-completion` | Antes de marcar cualquier tarea [x] | Post-implementación |
| `paseo-epic` | Features grandes multi-agente (overnight) | Decisión en `owf-session start` |
| `paseo-loop` | Loops iterativos, babysit CI/PR | Decisión en `owf-session start` |
| `sdd-*` | Spec-driven development para features medianas | Decisión en `owf-session start` |

---

## `/owf-session start`

Ejecutar ANTES de cualquier código. Sin esto, el agente trabaja a ciegas.

### Paso 1 — Leer estado del workspace
```
.owf/STATE.md    — qué se hizo, qué sigue, qué está bloqueado
.owf/TASKS.md    — board OWF-NNN
.owf/CONTEXT.md  — decisiones, archivos críticos, gotchas
```

### Paso 2 — Recuperar memoria Engram  *(usa: `engram:memory`)*
```
mem_context(project: 'owfinance2026')     — sesiones recientes
mem_search(query: '<tema>', project: ...)  — si hay algo específico
```

### Paso 3 — Mostrar resumen al usuario

```
## Sesión OWFinance — [fecha]

### Estado
- Último trabajo: [descripción]
- Branch frontend: [branch]
- Prod: OK / pendiente deploy

### Tareas activas
- OWF-NNN [~] descripción
- OWF-NNN [ ] descripción (P1)

### Bloqueados
- OWF-NNN [!] razón

### Skills disponibles para esta sesión
- Feature grande → /paseo-epic
- Feature mediana → /sdd-new <nombre>
- Tarea directa → implementar + owf-deploy al terminar
- QA prod → /owf-qa-production

### Siguiente recomendado
OWF-NNN — descripción concreta
```

### Paso 4 — Confirmar plan con el usuario antes de escribir código

---

## Post-tarea (después de completar cada OWF-NNN)

Inmediatamente después de terminar cualquier tarea:

**1. Verificar** *(usa: `verification-before-completion`)*
- TypeScript: `npx vue-tsc --noEmit` en OWFinanceFrontend2025/
- Si hay errores lint: corregir antes de continuar

**2. Deploy** *(usa: `owf-deploy`)*
```bash
./deploy-frontend.sh prod "OWF-NNN: descripción"   # si hay cambios frontend
./deploy-backend.sh prod  "OWF-NNN: descripción"   # si hay cambios backend
```

**3. Guardar descubrimiento si aplica** *(usa: `engram:memory`)*
```
mem_save(title, type: 'bugfix'|'decision'|'pattern', ...)
```

**4. Marcar tarea en TASKS.md**
```
[x] con fecha → OWF-NNN
```

---

## `/owf-session end`

Ejecutar ANTES de responder "listo" o terminar la sesión.

### Paso 1 — TASKS.md
- `[x]` + fecha en cada tarea completada
- `[!]` + razón en bloqueadas
- Actualizar `NEXT_ID`

### Paso 2 — STATE.md
```markdown
**Updated:** [ISO timestamp]
**By:** claude-code

## Último trabajo ([fecha])
- OWF-NNN ✅ descripción
- OWF-NNN 🔲 pendiente

## Bloqueados
- OWF-NNN: razón

### Siguiente recomendado
OWF-NNN — descripción
```

### Paso 3 — Engram  *(usa: `engram:memory`)*
```
mem_session_summary(goal, discoveries, accomplished, next_steps, relevant_files)
mem_save(...)  ← para cada decisión técnica nueva
```

### Paso 4 — Sync `.owf/` → Engram
```bash
.owf/sync-engram.sh push
```

### Paso 5 — Deploy si hay código sin subir  *(usa: `owf-deploy`)*
```bash
./deploy-frontend.sh prod "sesión [fecha] — OWF-NNN"
./deploy-backend.sh prod  "sesión [fecha] — OWF-NNN"
```

### Paso 6 — QA prod si hubo cambios de UI  *(usa: `owf-qa-production`)*
Verificar en browser real que las vistas afectadas funcionan.

### Paso 7 — Commit central
```bash
git add .owf/STATE.md .owf/TASKS.md
git commit -m "chore(state): sesión [fecha] — OWF-NNN done, next OWF-NNN"
```

### Paso 8 — Confirmar al usuario
```
✅ Sesión cerrada:
- N tareas completadas: OWF-NNN, OWF-NNN
- Prod: https://owfinances.com/app/ OK
- Engram: guardado + .owf/ sincronizado
- Siguiente: OWF-NNN — descripción
```

---

## Decisión de tamaño de tarea (en `start`)

| Tamaño | Criterio | Skill a usar |
|--------|----------|-------------|
| Pequeña (1-2 archivos, < 2h) | Cambio acotado y claro | Implementar directo + `owf-deploy` |
| Mediana (3+ archivos, spec necesaria) | Requiere diseño previo | `/sdd-new <nombre>` |
| Grande (multi-sesión, multi-agente) | Overnight, múltiples fases | `/paseo-epic <tarea>` |
| Loop/babysit | "Sigue hasta que pase X" | `/paseo-loop` |

---

## Comandos de referencia rápida

```bash
# Estado
grep -E "\[ \]|\[~\]|\[!\]" .owf/TASKS.md | grep -v "^#\|^<!--" | head -15

# Deploy
./deploy-frontend.sh prod "OWF-NNN: desc"
./deploy-backend.sh prod  "OWF-NNN: desc"

# Sync Engram
.owf/sync-engram.sh push    # local → Engram
.owf/sync-engram.sh pull    # nueva máquina
.owf/sync-engram.sh status  # comparar

# Verificar prod
curl -s -o /dev/null -w "%{http_code}" https://owfinances.com/up

# TypeScript check
cd OWFinanceFrontend2025 && npx vue-tsc --noEmit
```
