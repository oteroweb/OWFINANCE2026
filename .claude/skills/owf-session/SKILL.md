---
name: owf-session
description: Centraliza el arranque y cierre de sesión OWFinance. Recupera estado, tareas, memoria Engram. Al cerrar: actualiza STATE/TASKS, sincroniza Engram, verifica deploy.
user-invocable: true
argument-hint: "start | end"
---

# Skill: owf-session

Punto de entrada y salida de cada sesión de trabajo en OWFinance.
**Siempre invocar `/owf-session start` al inicio y `/owf-session end` al terminar.**

---

## `/owf-session start`

### Propósito
Recuperar todo el contexto antes de tocar cualquier código. Sin este paso, el agente trabaja a ciegas.

### Pasos (en orden, todos obligatorios)

**1. Leer los 3 archivos de estado del workspace**
```
.owf/STATE.md    — qué se hizo, qué sigue, qué está bloqueado
.owf/TASKS.md    — board de tareas OWF-NNN
.owf/CONTEXT.md  — decisiones, archivos críticos, gotchas
```

**2. Recuperar memoria Engram**
- `mem_context(project: 'owfinance2026')` → últimas sesiones y observaciones recientes
- `mem_search(query: '<tema actual>', project: 'owfinance2026')` → si hay algo específico que buscar

**3. Mostrar al usuario el resumen de sesión**

Formato estándar del resumen:
```
## Sesión OWFinance — [fecha]

### Estado actual
- Último trabajo: [qué se completó]
- Branch: [branch actual]
- Prod: [OK/pendiente deploy]

### Tareas activas (OWF-NNN in_progress o pending P0/P1)
- OWF-NNN [~] descripción
- OWF-NNN [ ] descripción

### Bloqueados
- OWF-NNN [!] razón

### Siguiente paso recomendado
[una línea concreta]
```

**4. Confirmar con el usuario** qué quiere atacar esta sesión antes de escribir código.

---

## `/owf-session end`

### Propósito
Cerrar limpiamente: estado persistido, memoria guardada, prod actualizado. Sin este paso, la siguiente sesión empieza a ciegas.

### Pasos (en orden, todos obligatorios)

**1. Actualizar `.owf/TASKS.md`**
- Marcar `[x]` con fecha las tareas completadas esta sesión
- Marcar `[!]` con razón las que quedaron bloqueadas
- Actualizar `NEXT_ID` si se crearon tareas nuevas

**2. Actualizar `.owf/STATE.md`**
```markdown
**Updated:** [timestamp ISO]
**By:** claude-code

## Último trabajo ([fecha])
- **OWF-NNN** ✅ descripción de lo completado
- **OWF-NNN** 🔲 descripción de lo pendiente

## Bloqueados
- OWF-NNN: razón
```

**3. Guardar memoria Engram**
- `mem_session_summary(...)` — goal, discoveries, accomplished, next steps, relevant files
- `mem_save(...)` para cualquier decisión técnica, bug fix o patrón nuevo descubierto

**4. Sincronizar `.owf/` → Engram**
```bash
cd /Users/otero/OW_Ecosystem/apps/owfinance/central
.owf/sync-engram.sh push
```

**5. Verificar deploy**
- ¿Hay cambios de código sin deployar? → Correr `./deploy-frontend.sh prod` y/o `./deploy-backend.sh prod`
- Confirmar `frontend=OK:200` antes de declarar sesión cerrada
- Si el deploy falla por lint: corregir, commitear, re-deployar (ver `owf-deploy` skill)

**6. Commit del repo central** (si `.owf/` o `CLAUDE.md` cambió)
```bash
git add .owf/STATE.md .owf/TASKS.md
git commit -m "chore(state): sesión [fecha] — OWF-NNN done, next: OWF-NNN"
```

**7. Confirmar al usuario**
```
✅ Sesión cerrada:
- [N] tareas completadas: OWF-NNN, OWF-NNN
- Prod: https://owfinances.com/app/ OK
- Engram: guardado
- Siguiente: OWF-NNN — descripción
```

---

## Reglas críticas

- **start SIEMPRE antes de cualquier código** — nunca saltar este paso
- **end SIEMPRE antes de responder "listo" al usuario** — no terminar sin cerrar
- Si la sesión se interrumpe, correr `/owf-session end` de todas formas con el estado parcial
- Los archivos `.owf/` son la fuente de verdad local; Engram es la copia persistente cross-sesión

---

## Referencia rápida de comandos

```bash
# Ver estado actual
cat .owf/STATE.md

# Ver tareas pendientes
grep -E "\[ \]|\[~\]|\[!\]" .owf/TASKS.md | head -20

# Sync Engram
.owf/sync-engram.sh push    # local → Engram
.owf/sync-engram.sh pull    # Engram → local (máquina nueva)
.owf/sync-engram.sh status  # comparar timestamps

# Deploy
./deploy-frontend.sh prod "OWF-NNN: descripción"
./deploy-backend.sh prod "OWF-NNN: descripción"

# Verificar prod
curl -s -o /dev/null -w "%{http_code}" https://owfinances.com/up
```

---

## Skills relacionados

- `owf-deploy` — proceso completo de deploy frontend/backend
- `owf-qa-production` — verificar vistas en el browser real de prod
- `engram:memory` — guardar/buscar memoria entre sesiones
