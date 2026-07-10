# Skill: owf-design-sync

## Propósito
Sincronización bidireccional entre el design system (`rediseno/`) y la implementación Vue.
Dos ciclos posibles — el agente detecta cuál aplica y ejecuta el protocolo correspondiente.

---

## Trigger (cuándo invocar esta skill)

- El usuario dice "hice cambios en rediseno", "actualicé el diseño", "hay cambios en el html", "ve las modificaciones"
- El usuario pide un feature nuevo sin mencionar que ya está diseñado
- El usuario dice "necesito que [X] tenga [Y] en la UI"
- Después de implementar en Vue y detectar gaps visuales que requieren ajuste de diseño

---

## Cómo ver el diseño real (IMPORTANTE)

`rediseno/` es React JSX compilado **en el navegador** por Babel Standalone
(`<script type="text/babel" src="organisms/....jsx">`, cargado por fetch). Dos consecuencias:

1. **Leer el `.jsx` crudo con `Read` no muestra cómo se ve** — es código fuente sin transpilar, no HTML renderizado. Sirve para ver estructura/lógica/tokens CSS, pero NO para verificar aspecto visual real.
2. **No abre como `file://`** — el navegador bloquea por CORS el fetch de esos `.jsx`. Requiere sí o sí un servidor HTTP.

Para ver el resultado real:
```
preview_start({name: "rediseno-static"})   → sirve rediseno/ en http://localhost:4173
preview_eval navegar a la URL del index.html relevante (ej. /ui_kits/lite-desktop/index.html)
preview_screenshot / preview_inspect       → ver el render real, colores, spacing
```
(config ya registrada en `.claude/launch.json` como `rediseno-static`, puerto 4173)

Usar `Read` sobre el `.jsx` para el Paso 1/2 (análisis de estructura y delta) SIEMPRE, y además
`preview_start` + screenshot cuando haga falta confirmar el resultado visual real antes de portar a Vue.

---

## Canal directo con Claude Design (MCP DesignSync) — reemplaza el copy-paste manual

El proyecto `rediseno` en claude.ai (design-system, `projectId: 5fd9e16d-4e55-4813-8714-3dd0f0a35c48`)
es un espejo del árbol local `OWFinanceFrontend2025/rediseno/`. Con el tool `DesignSync` disponible,
**no hace falta que el usuario copie/pegue JSX entre chats**: Claude Code puede bajar y subir
archivos directamente contra ese proyecto.

> Nota: existe además un proyecto huérfano `Design System` (`6fc08e8c-988c-4474-b035-e8ec8256c38e`,
> vacío) — no usarlo, es legacy pendiente de borrado manual por el usuario.

### PULL — bajar una iteración que el diseñador hizo en Claude Design

Trigger: el usuario dice "ya lo cambié en Claude Design", "revisa lo que ajustó el diseñador",
"jala la última versión de [componente]" — en vez de pedirle que pegue el JSX a mano.

```
1. DesignSync.get_file(projectId: "5fd9e16d-4e55-4813-8714-3dd0f0a35c48", path: <ruta del .jsx>)
2. Escribir ese contenido al mismo path en rediseno/ local (Write)
3. git diff en OWFinanceFrontend2025/rediseno/ para confirmar qué cambió realmente
4. Si hay cambios locales sin commitear en ese mismo path → avisar antes de sobreescribir
   (git stash si hace falta preservarlos)
5. Continuar con Ciclo 1 desde Paso 1 (leer cambios → analizar delta → portar a Vue)
```

Para no adivinar qué componente cambió: si el usuario no especifica el path, preguntar cuál
(no hacer diff de los ~200 archivos del proyecto — `list_files` no expone hash/mtime, así que
un diff completo implicaría un `get_file` por archivo; es caro y lento comparado con pedir el
nombre del componente).

### PUSH — subir un fix o componente nuevo que Claude Code hizo en rediseno/ local

Trigger: después de que Code edite/cree un `.jsx` en `rediseno/` (ej. Paso 2b resuelto localmente,
o un ajuste menor durante el port), o cuando el usuario pida "sube esto a Claude Design".

```
1. git status en OWFinanceFrontend2025/rediseno/ → listar archivos modificados/nuevos
2. DesignSync.finalize_plan(projectId: "5fd9e16d-4e55-4813-8714-3dd0f0a35c48",
     writes: [paths modificados], localDir: "OWFinanceFrontend2025/rediseno")
3. DesignSync.write_files(planId, files: [{path, localPath}, ...])
4. Confirmar al usuario que el proyecto "rediseno" en claude.ai quedó actualizado
```

### Los "prompts para Claude Design" (Paso 4 / Paso 2b) siguen vigentes — pero el retorno cambia

Generar el prompt sigue teniendo valor (Code no puede invocar generación de diseño por sí mismo;
eso ocurre en una sesión de Claude Design aparte, humana o dirigida por el usuario). Lo que cambia
es el cierre del ciclo: en vez de "el usuario pega el JSX resultante", el usuario dice **"listo,
ya está en Claude Design"** y Code hace **PULL** del path correspondiente — sin copy-paste.

### Reglas para no perder sincronía

- `rediseno/` local (git-tracked) sigue siendo la fuente de verdad canónica — todo PUSH sale de ahí.
- Antes de un PUSH: `git status` para no subir cambios a medio hacer.
- Antes de un PULL: verificar que no haya cambios locales sin commitear en esos paths.
- El `projectId` de `rediseno` es fijo (`5fd9e16d-4e55-4813-8714-3dd0f0a35c48`) — no listar
  proyectos cada vez, usarlo directo.

---

## Rutas clave del design system

```
OWFinanceFrontend2025/rediseno/
├── INSTRUCTIVO.md                          ← reglas y mapeo rediseno→Vue
├── colors_and_type.css                     ← tokens CSS (--brand-primary, --surface-1, etc.)
├── tx-catalog.js                           ← categorías + jars canónicos
├── ui_kits/lite-desktop/
│   ├── index.html                          ← demo completa desktop (abrir en browser)
│   ├── organisms/                          ← componentes principales
│   │   ├── RecentTransactions.jsx          → lista de transacciones desktop
│   │   ├── TransactionForm.jsx             → form alta tx desktop
│   │   ├── TransactionDetailModal.jsx      → detalle/edición desktop
│   │   └── SmartTransactionModal.jsx       → quick add global
│   └── templates/
│       ├── TransactionsRoute.jsx           → vista tx Pro/Lite
│       ├── HomeRoute.jsx / ProHomeRoute.jsx
│       └── DebtsRoute.jsx
├── ui_kits/mobile/
│   ├── index.html                          ← demo completa mobile
│   ├── components/
│   │   ├── TransactionComponents.jsx       → lista tx mobile
│   │   ├── TransactionFormSheet.jsx        → form alta mobile
│   │   └── TransactionDetailSheet.jsx      → detalle mobile
│   └── screens/
│       ├── TransactionsScreen.jsx
│       ├── HomeScreenLite.jsx / HomeScreenPro.jsx
│       └── DebtsScreen.jsx
└── redesign/audit/
    ├── harness.html                        ← vista rápida tx desktop
    ├── harness-mobile.html                 ← vista rápida tx mobile
    └── ev-*.png                            ← 13 capturas de referencia visual
```

## Mapeo rediseno → Vue

| Archivo rediseño | Componente Vue |
|---|---|
| `organisms/TransactionForm.jsx` | `src/components/SmartTransactionModal.vue` |
| `organisms/TransactionDetailModal.jsx` | `src/components/TransactionEditDialog.vue` |
| `organisms/RecentTransactions.jsx` | listas en `LiteTransactionsView.vue` + `ProTransactionsView.vue` |
| `components/TransactionFormSheet.jsx` | `src/components/TransactionForm.vue` |
| `components/TransactionComponents.jsx` | listas en vistas mobile de transacciones |
| `templates/TransactionsRoute.jsx` | `src/pages/user/transactions/LiteTransactionsView.vue` |
| `screens/TransactionsScreen.jsx` | vista mobile de transacciones |

---

## CICLO 1 — El usuario hizo cambios en rediseno/, pide implementar en Vue

### Paso 1: Leer los cambios

```
1. Leer el/los archivos .jsx modificados en rediseno/ (estructura, props, lógica)
2. Si hay capturas .png relevantes → leerlas con Read (son imágenes, Claude las ve)
3. Si hay un index.html o harness.html que los monta → preview_start({name:"rediseno-static"}),
   navegar a esa ruta y preview_screenshot para ver el render REAL (el .jsx crudo no basta,
   ver sección "Cómo ver el diseño real" arriba)
```

### Paso 2: Analizar delta

Identificar exactamente:
- Qué elementos nuevos hay (campos, componentes, comportamientos)
- Qué tokens CSS usa (buscar `var(--)` en el JSX)
- Qué lógica de datos necesita (props nuevas, computed, stores)

### Paso 2.5: Comparar contra la app real (auditorías de paridad)

Cuando la tarea es "dejar igual al diseño" (no solo portar un cambio puntual), no alcanza con
comparar código fuente — hay que ver ambos renders lado a lado:

```
1. preview_start({name: "rediseno-static"}) → navegar al harness/index.html del componente,
   preview_screenshot (render real del diseño)
2. preview_start({name: "frontend-quasar"}) → login (sesión suele persistir), navegar a la
   vista real, abrir el componente (modal/dialog), preview_resize a desktop si aplica,
   preview_screenshot (render real de Vue en prod/dev)
3. Comparar ambas capturas campo por campo: orden, textos, iconos, condiciones de visibilidad
4. Para archivos grandes (>500 líneas), delegar la lectura + diff estructural a un Agent en vez
   de leer todo inline — pasarle el resumen del JSX ya leído + pedir comparación exhaustiva
   con líneas exactas del Vue
5. Registrar cada gap como sub-tarea OWF-NNN de una épica (mismo patrón que config-audit/
   home-audit), priorizada P1 (funcional) / P2 (orden/cosmético) / P3 (detalle menor)
```

Esto confirma o descarta gaps que un diff de código por sí solo no detecta (layouts que se ven
distinto aunque el JSX "diga" lo mismo, campos que en la práctica quedan apilados en vez de
lado a lado, etc.).

### Paso 3: Implementar en Vue

Seguir el mapeo rediseno→Vue de arriba.

**Para la traducción sintáctica JSX→Vue/Quasar** (eventos, hooks→Composition API, HTML→componentes q-*,
dónde entra Pinia), no improvisar componente por componente — seguir
[`JSX_VUE_TRANSLATION_GUIDE.md`](./JSX_VUE_TRANSLATION_GUIDE.md), extraída de auditar los 4 ports reales
ya en producción. Incluye además qué patrones NUNCA se traducen mecánicamente (sección E) y por qué
NO conviene automatizar el primer paso con un script (evaluado y descartado, ver el final del documento).

Principios de negocio del INSTRUCTIVO.md (no sintácticos, siempre requieren criterio — ver también
sección E de la guía):
1. Cántaro anclado a categoría — nunca selector independiente
2. `jarForCategory()` resuelve jar automáticamente
3. Ingresos (kind='income') → jarId null → chip "Sin cántaro"
4. Lite NO tiene comisiones, split, ni items (solo Pro)

### Paso 4: Detectar gaps y generar prompt de retorno

Si al implementar detectas que algo en el diseño es ambiguo, incompleto, o necesita ajuste:

**Devolver al usuario un prompt listo para Claude Design:**

```
== PROMPT PARA CLAUDE DESIGN ==

Contexto: OWFinance, app de finanzas personales. Design system React JSX en rediseno/.
Componente: [ruta exacta del .jsx]
Situación actual: [describe qué tiene el JSX hoy]
Ajuste necesario: [describe exactamente qué falta o está mal]
Restricciones:
  - Tokens CSS de colors_and_type.css: [lista los relevantes]
  - [Principio del INSTRUCTIVO.md si aplica]
Referencia visual: [mencionar ev-*.png si es relevante]

Devuelve el bloque JSX modificado listo para reemplazar en el archivo.
```

Cuando el usuario confirme que el ajuste ya está hecho en Claude Design, **no pedir que pegue el
JSX** — hacer PULL directo (ver sección "Canal directo con Claude Design" arriba) del path exacto
del componente.

---

## CICLO 2 — El usuario pide un feature nuevo

### Paso 1: Buscar en rediseno/

```
1. Buscar en los .jsx de organisms/ y components/ si ya existe algo relacionado
2. Buscar en las capturas ev-*.png del audit
3. Revisar INSTRUCTIVO.md sección 3 (tabla de componentes)
```

### Paso 2a: Si el diseño YA EXISTE en rediseno/

→ Indicar al usuario qué archivo tiene el diseño de referencia
→ Leerlo y proceder directamente a implementar en Vue (Ciclo 1 desde Paso 3)

### Paso 2b: Si el diseño NO EXISTE en rediseno/

→ Generar prompt para Claude Design:

```
== PROMPT PARA CLAUDE DESIGN ==

Contexto: OWFinance, app de finanzas personales (Quasar 2 + Vue 3 en prod).
Design system: React JSX en OWFinanceFrontend2025/rediseno/ (sin build, browser directo).
Componente base: [ruta del .jsx más cercano que se debe modificar]

Feature a diseñar: [descripción clara y concreta del feature]

Restricciones de diseño:
  - Tokens de color: var(--brand-primary), var(--surface-1), var(--surface-2),
    var(--fg-1), var(--fg-2), var(--border-hairline), var(--radius-pill)
  - Tipografía: var(--font-body), var(--font-display)
  - [Agregar restricciones específicas del feature]

Contexto técnico:
  - Los datos de tx tienen: { id, label, meta, amount, jar, jarColor, tags[], category }
  - El kit Lite NO tiene: comisiones, split, items (solo Pro)
  - [Agregar contexto de datos relevante]

Referencia visual: [ev-*.png si aplica, o "no hay referencia existente"]

Devuelve:
1. El JSX modificado del componente completo, listo para reemplazar en [ruta del archivo]
2. Si necesitas un componente nuevo, devuelve también su JSX como archivo separado
```

→ Cuando el usuario confirme que ya está en Claude Design, hacer **PULL** directo del/los
  archivo(s) nuevos (ver sección "Canal directo con Claude Design" arriba) — no pedir copy-paste
→ Luego proceder con Ciclo 1

---

## Checklist de cierre

Después de implementar en Vue, seguir el post-tarea de `owf-session` (verificar → `owf-deploy` → marcar `[x]` en `.owf/TASKS.md`).
Adicional específico de este skill:
- [ ] Si hubo gaps de diseño → devolver prompt para Claude Design al usuario (ver Paso 4 arriba)
