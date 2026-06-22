# Skill: OWFinance QA en Producción

## Propósito

Revisar vistas de owfinances.com en el browser real del usuario y actualizar
la columna 🔍 IA de `.owf/EPIC_VIEWS.md`.

**URL base prod:** `https://owfinances.com`

---

## Cuándo usar este skill

- Cuando el usuario dice "revisa en prod", "verifica en producción", "chequea owfinances.com"
- Para poblar la columna 🔍 IA del EPIC_VIEWS.md con evidencia real de prod
- Antes de marcar cualquier vista como lista para VB del usuario

---

## Herramientas requeridas

Usar **Claude in Chrome MCP** (`mcp__Claude_in_Chrome__*`) — NO el preview tool local.
El usuario tiene su sesión activa en el browser; no se necesita credenciales.

```
mcp__Claude_in_Chrome__navigate      — ir a una URL
mcp__Claude_in_Chrome__read_page     — obtener snapshot accesible
mcp__Claude_in_Chrome__get_page_text — texto plano de la página
mcp__Claude_in_Chrome__find          — buscar elementos
mcp__Claude_in_Chrome__computer      — screenshot del estado actual
```

---

## Protocolo de revisión

### Paso 1 — Conectar al browser

```
list_connected_browsers → seleccionar tab owfinances.com activo
```
Si no hay tab activo, navegar a `https://owfinances.com/login`.

### Paso 2 — Verificar sesión

```
navigate('https://owfinances.com/user/home')
read_page() → si redirige a /login, sesión caducada → avisar al usuario
```

### Paso 3 — Recorrer vistas

Para cada vista del EPIC_VIEWS.md:
1. `navigate(url)`
2. `computer()` → screenshot
3. Comparar visualmente contra spec en `rediseno/`
4. Anotar gaps encontrados

### Paso 4 — Actualizar EPIC_VIEWS.md

Para cada vista revisada:
- Columna 🔍 IA: `✅` si OK o `❌` con nota del gap
- Añadir fila en "Log de verificaciones"
- Actualizar el bloque de Resumen

---

## Orden de revisión (prioridad)

### Ronda 1 — Vistas core Lite (mobile-first)
| Ruta | ID |
|------|----|
| `/user/home` | V-01 / V-14 |
| `/user/transactions` | V-03 / V-16 |
| `/user/jars` | V-02 / V-17 |
| `/user/dreams` | V-05 / V-19 |
| `/user/debts` | V-06 / V-18 |
| `/user/expense-analysis` | V-04 |
| `/user/asesor` | V-10 / V-20 |

### Ronda 2 — Auth & Config
| Ruta | ID |
|------|----|
| `/login` | V-25 |
| `/register` | V-26 |
| `/user/profile` | V-07 |
| `/user/financial-profile` | V-08 |
| `/user/config` | V-09 / V-21 |

### Ronda 3 — Público & Onboarding
| Ruta | ID |
|------|----|
| `/` | V-28 |
| `/planes` | V-29 |

### Ronda 4 — Pro (si usuario tiene plan Pro)
| Ruta | ID |
|------|----|
| `/user/home` (Pro mode) | V-11 |
| `/user/expense-analysis` (Pro) | V-12 |
| `/user/transactions` (Pro) | V-13 |

---

## Criterios de aprobación por vista

### Criterios globales (aplica a todas)
- [ ] La vista carga sin errores de consola visibles
- [ ] El header/navbar está presente y correcto
- [ ] No hay texto roto, placeholders sin reemplazar (`{{var}}`, `undefined`)
- [ ] El dark mode no rompe la vista (si aplica)
- [ ] En mobile (≤390px): no hay overflow horizontal

### Criterios específicos por vista
Ver gaps documentados en cada fila del EPIC_VIEWS.md.

---

## Qué hacer si hay un gap nuevo

1. Anotar en EPIC_VIEWS.md con `❌` + descripción corta
2. Si es P1/P2, crear tarea OWF-NNN en TASKS.md
3. Si es cosmético menor, marcar `✅` con nota

---

## Cómo marcar VB del usuario

El usuario Jose Luis marca sus VB escribiendo `✅ VB V-XX` en el chat.
Claude entonces actualiza la columna 👤 VB en EPIC_VIEWS.md.

---

## Archivos clave

- Épica: `.owf/EPIC_VIEWS.md`
- Tareas: `.owf/TASKS.md`
- Estado: `.owf/STATE.md`
- Spec desktop: `OWFinanceFrontend2025/rediseno/ui_kits/lite-desktop/templates/`
- Spec mobile: `OWFinanceFrontend2025/rediseno/ui_kits/cantaros-mobile-lite/`
