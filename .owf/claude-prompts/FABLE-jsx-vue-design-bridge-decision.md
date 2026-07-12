# Contexto completo para segunda opinión (Fable) — puente Diseño (Claude Design/JSX) ↔ Código real (Vue/Quasar)

Este documento es autocontenido: asume que quien lo lee no tiene memoria de conversaciones previas.
Es un reporte de estado + una pregunta de decisión abierta, no una tarea a ejecutar.

---

## 1. Qué es OWFinance

App de finanzas personales, dos capas:

- **Backend**: Laravel 12 + Sanctum, API REST prefijo `/api/v1`, MySQL en prod / SQLite local.
- **Frontend**: Quasar 2 + Vue 3, Composition API (`<script setup>`), Pinia para estado global, TypeScript.
- **Modo dual Lite/Pro**: mismo dominio de datos, dos experiencias de usuario. Lite es simplificado (sin comisiones, split de gastos, ítems de factura); Pro tiene todo el detalle. Es un eje ortogonal a Desktop/Mobile (hay 4 combinaciones posibles: Lite-desktop, Lite-mobile, Pro-desktop, Pro-mobile).
- **Entidades núcleo**: transacciones, cuentas, categorías, "cántaros" (jars — sobres de presupuesto tipo cántaro), deudas, sueños (metas de ahorro), y un asesor de IA con fallback chain de 6 proveedores.
- **Regla de negocio #1 del dominio**: el cántaro (jar) siempre se resuelve automáticamente a partir de la categoría (`jarForCategory()`) — nunca es un selector independiente que el usuario elija a mano. Aparece repetida en absolutamente todo el código y todo el diseño.

## 2. Qué es `rediseno/` (el design system)

Carpeta `OWFinanceFrontend2025/rediseno/` — es la exportación completa de un proyecto de **Claude Design** (`https://claude.ai/design/p/5fd9e16d-4e55-4813-8714-3dd0f0a35c48`), confirmado porque `rediseno/_ds_manifest.json` tiene `"namespace":"OWFinanceDesignSystem_5fd9e1"`, coincidiendo exactamente con ese ID de proyecto.

Características clave:

- Es **React JSX puro, sin paso de build**. Se transpila **en el navegador** con Babel Standalone: cada `.jsx` se carga vía `<script type="text/babel" src="organisms/Componente.jsx">`. Esto significa que ni siquiera corre con `file://` — requiere servidor HTTP (CORS bloquea el fetch de los `.jsx` si no).
- **No tiene persistencia real**: usa fixtures en memoria (`window.SAMPLE_TX`, `window.SAMPLE_ACCOUNTS`, `window.SAMPLE_JARS`, `window.SAMPLE_CATEGORIES`, `window.SAMPLE_TAGS`, `window.SAMPLE_PROVIDERS`). Las "mutaciones" (crear/editar/borrar) hacen `.splice()`/`.push()` directo sobre esos arrays globales — se pierden al recargar la página. No hay red, no hay backend, no hay store.
- Contiene: tokens de diseño (`colors_and_type.css` — variables CSS planas, `var(--brand-primary)`, `var(--surface-1)`, etc., con tema claro y oscuro `[data-theme="dark"]`), ~30+ pantallas HTML navegables, componentes organizados en `organisms/` y `components/`, dos "kits" (`ui_kits/lite-desktop/` y `ui_kits/mobile/`), y un `INSTRUCTIVO.md` con las reglas de negocio (cántaro-categoría, Lite sin comisiones, etc).
- Ya existe un **canal directo bidireccional** (tool `DesignSync` vía MCP) entre Claude Code y ese proyecto de Claude Design — `get_file`/`write_files` contra el `projectId` fijo. Esto ya elimina el copy-paste manual de JSX entre sesiones humano↔IA. Esta parte del problema (canal de transporte de archivos) está resuelta.

## 3. Cuál es el problema real (no es de canal, es de idioma)

El código de producción real es **Vue 3 + Quasar**, un framework de componentes con paradigma distinto:

| Concepto | JSX (diseño) | Vue real (producción) |
|---|---|---|
| Eventos | `onClick`, `onChange` (callback prop) | `@click`, `v-model` (binding declarativo) |
| Estado local | `useState` por variable | `ref()`/`reactive()`, a veces consolidado en un solo objeto |
| Efectos | `useEffect(fn, [deps])` | `watch()`, `watchEffect()`, `onMounted()`, o simplemente una función invocada en el evento |
| Derivados | `useMemo`/`useCallback` | `computed()` |
| Listas | `.map()` con `key` | `v-for` con `:key` |
| Componentes de UI | genéricos (`<button>`, `Picker`, `Switch`, `TextInput` — propios del kit) | mezcla de HTML nativo + componentes Quasar (`q-select`, `q-toggle`, `q-icon`, `q-dialog`, `q-btn`) |
| Estado global/persistencia | `window.SAMPLE_*` mutado en memoria | Pinia stores + llamadas API reales a Laravel |

Cada vez que el diseño cambia (o se pide un componente nuevo a Claude Design), alguien tiene que traducir esto **a mano**, componente por componente, sin una convención escrita hasta ahora — cada agente/sesión decidía sobre la marcha.

## 4. Trabajo ya hecho: auditoría de 4 traducciones reales

Se auditaron 4 pares ya portados y funcionando en producción (no hipotéticos), leyendo AMBOS archivos completos línea por línea:

1. `rediseno/ui_kits/lite-desktop/organisms/TransactionForm.jsx` → `src/components/SmartTransactionModal.vue`
2. `rediseno/ui_kits/lite-desktop/organisms/TransactionDetailModal.jsx` → `src/pages/user/transactions/LiteTransactionsView.vue` (bottom-sheet inline, no un componente separado — el componente `TransactionEditDialog.vue` que originalmente iba a recibir esto fue **borrado como código muerto**, nunca llegó a montarse en ningún template real)
3. `rediseno/ui_kits/lite-desktop/organisms/RecentTransactions.jsx` → `src/pages/user/transactions/LiteTransactionsView.vue` (la lista completa)
4. `rediseno/ui_kits/lite-desktop/organisms/DesktopQuickModal.jsx` → `src/components/liquid/DesktopQuickModal.vue`

### Patrones consistentes encontrados (repetidos en los 4 pares, sin excepción)

- **Botones**: NO se traduce todo `<button>` a `q-btn`. Se mantiene `<button>` nativo + clases BEM propias del proyecto (`stm-btn`, `tx-detail-btn`, `dqm-*`), salvo el CTA primario final del formulario.
- **Consolidación de estado**: muchos `useState` sueltos de un mismo formulario en JSX se convierten en **un solo `ref({...})` objeto** en Vue, no un ref por campo.
- **`useEffect` con deps**: no siempre se traduce a `watch()`. Con frecuencia se reemplaza por una **función explícita invocada en el evento de usuario** (ej. `openDetail(tx)`, `enterEditMode()`) en vez de un watcher reactivo — más simple, y de hecho el patrón más común encontrado.
- **`q-icon`** reemplaza `<span className="material-icons">` con 100% de consistencia, sin ninguna excepción en los 4 pares.
- **Pinia entra solo para**: `useAuthStore()` (usuario/moneda base), `useUiStore()` (visibilidad de modales globales, flag de privacidad `hideValues`), `usePeriodStore()` (rango de fechas activo). Los catálogos de dominio (categorías, cántaros) **no son un store Pinia** — son un módulo cache-first plano (`src/utils/txCatalog.ts`: `loadCategoriesWithJars`, `getCachedCategories`, `getCachedJars`, `jarForCategory`).
- **Custom hooks del kit** (`useViewportMobile()`, `useTxdState()`) no se portan como composables Vue — se resuelven con media queries CSS puras, o simplemente se pierden (ver más abajo).

### Lo que nunca se traduce mecánicamente (requiere juicio de negocio)

1. **Cántaro anclado a categoría** — si el JSX trata `jar`/`jarColor` como campo independiente editable, en Vue SIEMPRE se reemplaza por `jarForCategory(category_id)` vía un componente dedicado `AnchoredJarChip`. Presente en los 4 pares sin excepción.
2. **Lite vs Pro**: el JSX modela esto casi siempre con una prop `mode` y un `if/return` duplicado dentro del mismo componente. El Vue real casi nunca preserva esa estructura — o el componente termina siendo Lite-only/Pro-only (archivos separados), o se fusiona con `v-if` puntuales. Es un refactor arquitectónico real, no una traducción de sintaxis.
3. **"Planes especiales" (deuda/sueño/cántaro) cambian de semántica**: en JSX emiten una acción genérica hacia el componente padre (`onSelectAction`); en Vue real terminan **navegando a una página/módulo dedicado** en vez de abrir un modal de transacción rápida.
4. **Gaps mobile silenciosos**: layouts tipo "bottom sheet" descritos en el JSX (con `isMobile`, grab handle, animación de entrada) frecuentemente **no se portan** — el componente Vue real queda desktop-only. Esto es deuda técnica real, no una decisión consciente documentada en ningún lado.
5. **Animaciones se simplifican o se pierden**: el JSX suele definir 2-3 `@keyframes` (fade, rise, sheet); el Vue real normalmente implementa solo un fade del overlay.
6. **Endpoints dedicados reemplazan payloads genéricos**: ej. "Ajuste de saldo" en JSX arma un payload genérico de transacción; Vue usa un endpoint específico del dominio (`POST /accounts/{id}/adjust-balance`).

Todo esto quedó documentado en `.claude/skills/owf-design-sync/JSX_VUE_TRANSLATION_GUIDE.md` (archivo completo disponible en el repo si Fable necesita más detalle).

## 5. Decisión ya tomada: NO automatizar con un script

Se evaluó si valía la pena construir un "primer paso" semi-automatizado (parser/codemod) que hiciera la traducción sintáctica mecánica y dejara solo la lógica de negocio para revisión humana/IA.

**Conclusión: no, con el volumen actual.**

- Razón: lo genuinamente mecánico y de bajo riesgo (`<span className="material-icons">` → `q-icon`, `.map()` → `v-for`, `onClick` simple → `@click`) es real, pero es la parte MÁS RÁPIDA de hacer a mano — no es donde se va el tiempo.
- El tiempo real se va en decidir qué sube a Pinia, si el patrón Lite/Pro se colapsa o se separa, y detectar qué NO se debe portar (mobile, animaciones) — todo esto requiere leer el componente Vue existente y el contexto de negocio. Un script generaría "traducciones" que parecen completas pero omiten justo lo importante — falsa sensación de completitud.
- Volumen real: solo 4 componentes portados a producción hasta ahora. Los cambios de diseño llegan por sesión, no en lote.
- Umbral fijado para revisar esta decisión: si el ritmo supera ~15 componentes nuevos por trimestre, o aparece un patrón mecánico de alto volumen y bajo riesgo que sí justifique un script puntual y desechable.

## 6. La pregunta abierta — esto es lo que necesitamos decidir

El usuario (dueño del proyecto) planteó la discordancia de fondo: **`rediseno/` es una plantilla simple, no funcional, sin persistencia — pero el frontend real sí tiene un backend detrás**. La pregunta es cómo hacer que el "lenguaje" entre ambos mundos sea más directo, y qué cambiar concretamente para que la migración diseño→código siga siendo fácil a futuro (no solo hoy, con 4 componentes, sino cuando haya 20-30).

Dos propuestas ya sobre la mesa (NO implementadas todavía, es lo que se busca validar/mejorar/descartar):

**Propuesta A — Contrato de nombres de callback fijo.**
Cualquier componente JSX nuevo pedido a Claude Design debería usar siempre los mismos nombres de prop callback: `onSelectAction`, `onSave`, `onDelete`, `onClose` — nunca inventar uno nuevo por componente. La idea es que esto haga que decidir "dónde entra Pinia" (sección D de la guía) sea casi mecánico en vez de detective work, porque el nombre del callback ya indica qué acción de store/router debe dispararse.

**Propuesta B — Fixtures con forma real (shape parity).**
Cuando se pida un componente nuevo, exigir en el prompt a Claude Design que los datos de muestra (`window.SAMPLE_TX`, etc.) usen los mismos nombres de campo que las interfaces TypeScript reales (`Transaction`, `Account` en `src/stores/*.ts`), en vez de nombres inventados por el diseño. Esto reduciría el mapeo de datos (sección D/E de la guía) a un ejercicio de copiar-pegar en vez de reconciliar shapes distintos cada vez.

**Riesgo ya identificado en ambas propuestas**: si nadie mantiene esto sincronizado cuando las interfaces reales cambian, se pudre exactamente como ya pasó con la tabla de mapeo componente→componente en `owf-design-sync/SKILL.md` (apuntaba a `TransactionEditDialog.vue`, que fue borrado como código muerto hace varias sesiones y nadie actualizó la referencia).

## 7. Lo que se le pide a Fable

Con todo este contexto, dar una segunda opinión honesta sobre:

1. ¿Las propuestas A y B (contrato de callbacks + fixtures con forma real) son el mejor uso del esfuerzo, o hay un enfoque estructuralmente mejor que no se ha considerado? (ejemplos de cosas no evaluadas: generar tipos TS compartidos entre `rediseno/` y `src/` desde un único origen; un linter/CI check que falle si un componente JSX nuevo no sigue el contrato; cambiar el propio prompt de generación en Claude Design para que emita ya patrones Vue-friendly aunque el output siga siendo JSX; abandonar JSX como intermedio y pedir a Claude Design directamente estructuras más neutrales tipo JSON de layout + tokens).
2. ¿Vale la pena invertir en esto AHORA (con solo 4 componentes portados) o es prematuro — mejor esperar a que el volumen justifique la inversión, tal como se decidió para el script de auto-traducción?
3. Si Fable recomienda algo distinto a A/B, ¿cuál sería el primer paso concreto y de bajo riesgo para probarlo sin comprometer el flujo actual (que funciona, aunque manual)?

No se espera que Fable implemente nada — es una consulta de arquitectura/proceso, para que el usuario decida con una segunda perspectiva antes de comprometerse.
