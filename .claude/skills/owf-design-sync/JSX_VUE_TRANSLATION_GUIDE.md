# Guía de traducción JSX → Vue3/Quasar (OWFinance)

Extraída de auditar 4 pares ya portados y en producción:

| JSX de referencia (`rediseno/`) | Vue real (`src/`) |
|---|---|
| `ui_kits/lite-desktop/organisms/TransactionForm.jsx` | `components/SmartTransactionModal.vue` |
| `ui_kits/lite-desktop/organisms/TransactionDetailModal.jsx` | `pages/user/transactions/LiteTransactionsView.vue` (bottom-sheet inline, no componente separado) |
| `ui_kits/lite-desktop/organisms/RecentTransactions.jsx` | `pages/user/transactions/LiteTransactionsView.vue` (lista completa) |
| `ui_kits/lite-desktop/organisms/DesktopQuickModal.jsx` | `components/liquid/DesktopQuickModal.vue` |

No es una guía genérica de React→Vue — son las convenciones reales que ya se repiten en este código.

---

## A) Eventos

- `onClick` de botón de acción secundaria/ghost → `@click` sobre un `<button>` **nativo** con clases BEM propias (`stm-btn`, `tx-detail-btn`, `dqm-*`). **No se usa `q-btn` salvo el CTA primario final** (`q-btn unelevated color="primary"`).
- `onClick` de fondo/scrim de modal custom → `@click` manual en el `div.*-scrim`; si el modal usa `q-dialog` real, el cierre por backdrop/ESC ya viene gratis — no se replica el listener.
- `onClick={e => e.stopPropagation()}` → `@click.stop` (modificador nativo Vue, no función).
- `Picker onChange={setX}` → `q-select v-model="form.x" emit-value map-options dense outlined` (a veces `clearable`).
- `Switch onChange={setX}` → `q-toggle :model-value="..." @update:model-value="..."`. Si el JSX tenía dos booleans independientes, en Vue suelen colapsarse a un solo enum (`proPanel: 'split'|'invoice'|'shared'|null`).
- `TextInput`/`MoneyInput onChange` → `v-model` / `v-model.number` nativo. **Ojo**: no siempre se sube a `q-input` — hay formularios reales (`LiteTransactionsView` detail edit) que quedaron con `<input>` plano por deuda técnica, no por regla.
- `document.addEventListener('keydown', ...)` dentro de `useEffect` → se mantiene **igual de imperativo** en Vue: `watch()` + `document.addEventListener` + cleanup en el `else` del watch y en `onBeforeUnmount`. Además, usar `onCleanup` (tercer parámetro del callback: `watch(fuente, (val, old, onCleanup) => {...})`) para remover el listener anterior cuando la condición del watch cambia — evita listeners duplicados y fugas de memoria si el watch se re-dispara. No se declara con `@keydown` en el template.
- `onMouseEnter/onMouseLeave` para hover state → **eliminado**, reemplazado 100% por `:hover` en SCSS con CSS custom properties (`--dqm-accent`, `--dqm-tint`) inyectadas vía `:style`.

## B) Hooks React → Composition API

- Muchos `useState` sueltos de un mismo formulario → **un solo `ref({...})` objeto**, no un ref por campo (`const form = ref({...})`, ver `SmartTransactionModal.vue`).
- `useState` de flags simples (modal abierto, confirm dialog) → `ref()` individuales.
- `useMemo` → `computed()` 1:1, sin cambios de intención.
- `useEffect` con deps que sincroniza un draft cuando cambia una prop → en Vue esto se resuelve de dos formas distintas, según el caso:
  - `watch(() => props.algo, (v) => {...})` cuando de verdad hay que reaccionar a cambios externos continuos.
  - **Función explícita invocada en el evento** (`openDetail(tx)`, `enterEditMode()`) en vez de watcher, cuando el "efecto" solo necesitaba correr una vez al abrir — más simple y más común en los 4 pares auditados.
- Custom hooks del kit de diseño (`useViewportMobile()`, `useTxdState()`) → **no se portan como composables**. Se resuelven con CSS media queries puras, o se pierden directamente (ver sección E, gaps mobile).
- Listener de teclado con cleanup (`return () => removeEventListener`) → replicado con `onBeforeUnmount()` explícito, no delegado a un composable reusable.

## C) HTML genérico → componentes Quasar

Reglas consistentes en los 4 pares:

- `<span className="material-icons">` → `<q-icon name="..." size="Npx" />` (nombre estático sin `:`; `:name="..."` solo cuando el icono es dinámico). **100% consistente, sin excepciones.**
- Botones → **se quedan `<button>` nativo + BEM** salvo el submit primario del formulario (`q-btn`). No asumir que todo botón se traduce a `q-btn`.
- Selects/pickers estructurados → `q-select` con `emit-value map-options dense outlined` casi siempre.
- Toggles/switches → `q-toggle`.
- Modales reales con backdrop/ESC nativo → `q-dialog`. Modales/popovers custom del design system (`DesktopQuickModal`) → `div` con clases propias + transición Vue manual (`<Transition name="dqm-fade">`), no `q-dialog`.
- `.map()` de listas → `v-for` con `:key` = id real cuando existe (`tag.id`, `tx.id`), índice (`:key="i"`) solo para ítems efímeros de un draft sin id todavía.
- Estilos inline del JSX (`style={{...}}`) → SCSS `scoped` con las mismas CSS vars de `colors_and_type.css`, nunca objetos de estilo en JS.

## D) Dónde entra Pinia (y dónde NO)

- Estado 100% local del componente (un formulario, un toggle de UI) → se queda en `ref()`/`reactive()` local, **no** sube a un store.
- Pinia entra específicamente para:
  - `useAuthStore()` — usuario, moneda base, permisos.
  - `useUiStore()` — visibilidad de modales globales (`showSmartModal`, `smartModalTab`), flag de privacidad (`hideValues`). Acceso de lectura vía `computed(() => ui.campo)`, acciones vía llamada directa (`ui.openSmartModal(...)`) — **no siempre se usa `storeToRefs`**, es más común el `computed` manual.
  - `usePeriodStore()` — rango de fechas activo, fuera del control del componente.
- Catálogos de dominio (categorías, cántaros) **NO son un store Pinia clásico** — son un módulo cache-first (`src/utils/txCatalog.ts`: `loadCategoriesWithJars`, `getCachedCategories`, `getCachedJars`, `jarForCategory`). Si el JSX tenía `window.SAMPLE_CATEGORIES`/`SAMPLE_JARS`, el reemplazo real es este módulo, no un store nuevo.
- Mutaciones directas de arrays fixture (`window.SAMPLE_TX.splice(...)`) → siempre se convierten en llamada real a `api.*` (Laravel) seguida de refresco (`loadTransactions()`), nunca mutación local persistente.

## E) Lo que NUNCA se traduce mecánicamente (juicio de negocio)

Estas son señales de que la tarea necesita un agente con criterio, no un script:

1. **Cántaro anclado a categoría** — la regla #1 del proyecto. Si el JSX trata `jar`/`jarColor` como campo independiente y editable, en Vue SIEMPRE se reemplaza por `jarForCategory(category_id)` vía `AnchoredJarChip`. Aparece en los 4 pares auditados sin excepción.
2. **Lite vs Pro** — el JSX casi siempre modela esto con una prop `mode` y un `if/return` duplicado dentro del mismo componente. El Vue real casi nunca hace esto: o el componente termina siendo Lite-only/Pro-only (archivos separados), o se fusiona en un único template con `v-if` puntuales — es un refactor arquitectónico, no una traducción de sintaxis.
3. **"Planes especiales" (debt/dream/jar) cambian de semántica** — en JSX suelen emitir una acción genérica hacia el padre (`onSelectAction`); en Vue terminan navegando a una página/módulo dedicado en vez de abrir un modal de transacción. Confirmar con el usuario/negocio antes de asumir cuál es la correcta.
4. **Gaps mobile silenciosos** — layouts "bottom sheet" descritos en el JSX (`isMobile`, grab handle, animación `dqmSheet`) frecuentemente **no se portan** al componente Vue real (queda desktop-only). Esto es deuda/gap real, no una decisión de diseño — señalarlo como hallazgo, no darlo por sentado.
5. **Animaciones/keyframes se simplifican o se pierden** — el JSX suele definir 2-3 `@keyframes`; el Vue real normalmente implementa solo una transición (el fade del overlay), sin el "rise" de la card ni la animación de sheet.
6. **Endpoints dedicados reemplazan payloads genéricos** — ej. "Ajuste de saldo" en JSX arma un payload genérico de transacción; Vue usa `POST /accounts/{id}/adjust-balance`, un endpoint específico del dominio.

---

## F) Checklist de paridad funcional (obligatoria antes de dar un port por terminado)

Un port que "se ve igual" NO está terminado. Las capturas de pantalla solo validan estética;
el comportamiento vive en el código del JSX y solo se verifica interactuando.

**Antes de portar — extraer el inventario de comportamiento del JSX.** Ese inventario ES la spec:

- Todo `useState` del componente y sus molecules (`FormControls.jsx` incluido, no solo el organism).
- Todo handler: `onChange`, `onInput`, `onKeyDown`, `onFocus/onBlur`, funciones `filter`/`pick`/`create`.
- Todo render condicional: estados hover/focus/disabled/empty/loading, textos de vacío ("Sin resultados"),
  qué muestra el control cerrado vs abierto.
- Props de configuración de las molecules (`searchable`, `onCreate`, `clearable`…) — un `<Picker searchable />`
  de una sola palabra en el JSX es un requisito funcional completo (input con autofocus, filtrado por label,
  Enter elige el primero, empty state).

**La verificación de un port tiene 3 columnas — las 3 obligatorias:**

| Columna | Qué se comprueba | Cómo |
|---|---|---|
| **Estética** | Se ve igual (tokens, spacing, orden) | Screenshots lado a lado (Paso 2.5 del SKILL) |
| **Funcional** | Cada interacción del inventario reproducida: búsqueda al tipear, teclado (Enter/flechas), estados, crear inline | Interactuar en el preview: tipear, navegar, seleccionar — no basta mirar |
| **Detalles** | Placeholders, textos de vacío, formatos de número/fecha (tfMoney, NBSP), tooltips/hints | Comparar texto por texto contra el JSX |

**Regla anti-regresión (ports sobre controles existentes):** si el port MODIFICA un control Vue que ya
existía (agregar slots `selected-item`/`option`, `display-value`, cambiar `:options`…), listar primero
los comportamientos que ese control YA tenía (`use-input`, `@filter`, `clearable`, keyboard nav…) y
re-probarlos todos después del cambio. Un slot nuevo puede romper silenciosamente el filtrado o el
display sin que ningún lint ni typecheck lo detecte.

**Caso real de referencia — OWF-296/297:** el selector de cuentas de `SmartTransactionModal.vue` quedó
estéticamente fiel al `Picker` del rediseño (dot de color + saldo a la derecha) pero sin búsqueda: el
`searchable` que el JSX declara en TODOS los pickers de cuenta (`TransactionForm.jsx` líneas 322/347/351/380/749/824)
nunca se portó, y la verificación de OWF-296 fue solo visual, así que no lo detectó. Lo reportó el
usuario, no el proceso. El fix (OWF-297) fue `use-input input-debounce="0" @filter` + needle compartida +
slots preservados, con el input colapsado vía CSS mientras el menú está cerrado para no perder el
saldo alineado a la derecha (`.stm-acct-select`).

---

## ¿Vale la pena automatizar el primer paso (traducción mecánica)?

**No, con el volumen actual.** Evaluado tras esta auditoría:

- Lo verdaderamente mecánico y de bajo riesgo (icon spans → `q-icon`, `.map()` → `v-for`, `onClick` simple → `@click`) es real pero es la parte MÁS RÁPIDA de hacer a mano — no es donde se va el tiempo.
- El tiempo real se va en las secciones D y E: decidir qué sube a Pinia, si el patrón Lite/Pro se colapsa o se separa, y detectar qué NO se debe portar (mobile, animaciones) — todo esto requiere leer el componente Vue existente y el contexto de negocio, un script no lo resuelve y generaría "traducciones" que parecen listas pero omiten lo importante (falsa sensación de completitud).
- El ritmo real de nuevos componentes portados es bajo (4 en producción hasta ahora, cambios de diseño llegan por sesión, no en lote) — el costo de construir y mantener un codemod no se paga con este volumen.

**Revisar esta decisión si**: el ritmo de nuevos componentes a portar supera ~15 en un trimestre, o si aparece un patrón mecánico de alto volumen y bajo riesgo (ej. portar 30 iconos/labels sueltos) que sí justifique un script puntual y desechable — no un pipeline permanente.

Mientras tanto, esta guía + el checklist del Paso 3 de `owf-design-sync/SKILL.md` es el mecanismo correcto.
