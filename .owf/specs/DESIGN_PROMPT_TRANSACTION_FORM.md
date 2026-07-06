# Prompt para Claude Design — Formulario de Transacciones OWFINANCE 2026
> **Para:** Claude Design (diseñador IA)
> **Proyecto:** OWFINANCE 2026 — Formulario de Transacciones: Verificación + Piezas Faltantes
> **Fecha:** 2026-06-29

---

## Contexto del producto

OWFINANCE es una app de finanzas personales (modo **Lite** para usuarios finales y modo **Pro** avanzado).
El formulario de transacciones es el punto más crítico de la app: el usuario lo abre docenas de veces por semana.

**Stack visual:** Quasar 2 + Vue 3. Paleta navy/cyan. Dos contextos: desktop modal y mobile bottom sheet.

---

## Lo que ya existe (NO rediseñar, solo VERIFICAR)

El sistema ya tiene especificado y parcialmente implementado:

### Desktop — `TransactionForm.jsx`
Formulario en modal. Cubre 8 modos:

| Modo | Se activa con |
|---|---|
| Gasto simple | tab por defecto |
| Ingreso simple | tab Ingreso |
| Transferencia | tab Transferir |
| Ajuste de saldo | tab Ajuste |
| Pago compuesto (split) | toggle "Pago múltiple" — una operación, varias cuentas |
| Detalle / Factura | toggle "Detalle / factura" — ítems con nombre × cantidad × precio + impuesto + categoría por ítem |
| Cruce de moneda | preview automático cuando cuenta origen ≠ moneda del monto |
| Comisión VE | switch opcional — pago móvil (0.30% BCV) / monto fijo / porcentaje |

**Regla de cántaro:** el cántaro NO se elige manualmente. Se muestra como lectura derivada de la categoría seleccionada. Si la categoría no tiene cántaro → mensaje "Esta categoría no aporta a ningún cántaro". Si no hay categoría → "El cántaro entra con la categoría". El ícono del cántaro muestra un candado (`lock`) indicando que es de solo lectura.

### Desktop — `TransactionDetailModal.jsx`
Modal de detalle al hacer clic en una transacción. Tiene:
- Vista (view mode): monto hero + fila por campo (tipo, categoría, cántaro, cuenta, comisión, fecha)
- Edición inline (edit mode): segmentado de tipo + monto + concepto + categoría + cántaro + cuenta
- Eliminación con confirmación inline (fondo rojo suave)

### Mobile — `TransactionFormSheet.jsx` (bottom sheet Pro)
Bottom sheet con la misma lógica que desktop pero adaptada a móvil. Incluye:
- Tipos: Gasto / Ingreso / Transferir (3 tabs, falta Ajuste)
- Toggle "Pago compuesto" (varias cuentas)
- Toggle "Monto compuesto" (ítems factura)
- Comisión
- Selector inline de categoría + cántaro (lado a lado en móvil)

### Mobile — `TransactionDetailSheet.jsx`
Bottom sheet de detalle de transacción en móvil. Similar al modal desktop pero en sheet.

### Modales de entrada rápida (SmartTx)
- `SmartTransactionModal.jsx` (desktop) y `SmartTransactionSheet.jsx` (mobile): Entrada AI/voz que pre-rellena el form. No requieren verificación de diseño ahora.

---

## PARTE 1 — VERIFICACIÓN: Checklist de lo que el diseñador debe auditar

El diseñador debe revisar las siguientes piezas del formulario y confirmar que el diseño actual es correcto, consistente y sin gaps. Para cada punto: ✅ aprobado / ⚠️ problema / ❌ rediseñar.

### 1A — Jerarquía visual del formulario (desktop + mobile)
- [ ] ¿El selector de tipo (Segmented: Gasto/Ingreso/Transferir/Ajuste) es el primer elemento y es visualmente dominante?
- [ ] ¿El campo de monto (`MoneyInput`) es claramente el elemento más grande del form, con tipografía de al menos 28–32px?
- [ ] ¿Hay suficiente separación visual entre las secciones (monto / cuenta / categoría-cántaro / avanzado)?
- [ ] ¿Los toggles de "Pago compuesto" / "Monto compuesto" tienen suficiente contraste para ser descubiertos sin ser ruidosos?

### 1B — Cántaro anclado a categoría
- [ ] Cuando no hay categoría: ¿el placeholder "El cántaro entra con la categoría" es legible pero secundario?
- [ ] Cuando la categoría tiene cántaro: ¿el chip del cántaro (color de fondo, ícono del jar, texto con nombre + %) se distingue bien del selector de categoría de al lado?
- [ ] El ícono `lock` en el cántaro: ¿comunica bien que es solo lectura sin confundir?
- [ ] Cuando la categoría no tiene cántaro asignado: ¿el estado "Sin cántaro para esta categoría" (ícono `block`) es claro?

### 1C — Editor de pago compuesto (split)
- [ ] Cada fila de pago: cuenta + monto en su moneda + (si no es USD) tasa editable + resultado en USD. ¿Las 3 columnas son legibles en pantalla de 375px?
- [ ] El total acumulado (Σ ≈ $ X) en el header del bloque: ¿está bien posicionado?
- [ ] Botón "Añadir cuenta": ¿es suficientemente visible pero no distrae del contenido principal?

### 1D — Editor de factura / monto compuesto
- [ ] Fila de ítem: [nombre] [qty] × [precio] [cerrar]. ¿Son accesibles los 4 campos en mobile?
- [ ] Bajo cada ítem: selector de categoría + selector de impuesto + línea "cántaro derivado". ¿Es demasiada información por ítem en mobile? Evaluar si colapsar a acordeón.
- [ ] Cuando hay solo 1 ítem: ¿el botón cerrar (×) debe mostrarse o ocultarse?
- [ ] Total de la factura (suma de ítems): ¿debe reemplazar al campo de monto o mostrarse debajo de él?

### 1E — Comisión Venezuela
- [ ] 3 tipos de comisión en mini-tabs: Pago móvil / Fijo / Porcentaje. ¿Las tabs son suficientemente grandes para tocar en mobile (mínimo 44px de altura)?
- [ ] Estado "Pago móvil" auto-calculado: ¿el chip "0.30% · BCV" comunica suficientemente que es automático?
- [ ] Resumen al pie (Comisión ≈ $X · Total $Y): ¿la tipografía money está bien diferenciada del label body?

### 1F — Cruce de moneda (cross-currency)
- [ ] El bloque de preview (Envías X → Llega Y con tasa): ¿el fondo morado suave (`rgba(139,92,246,0.08)`) contrasta suficiente en dark mode?
- [ ] ¿La tasa de cambio es editable en la preview o solo informativa? (Actualmente solo informativa en transferencia, editable por fila en split)

### 1G — Modo Ajuste de saldo
- [ ] Campo "Saldo objetivo" + preview del delta (↑ o ↓ con colores income/expense): ¿es intuitivo sin explicación adicional?
- [ ] ¿Falta un campo de "Cuenta a ajustar" suficientemente prominente antes del monto?

### 1H — Modal de detalle / edición (TransactionDetailModal)
- [ ] Modo Vista: ¿las filas de detalle (ícono + label + valor) tienen suficiente separación vertical?
- [ ] ¿El hero del monto (28px, fondo suave) comunica bien el tipo de transacción (ingreso vs gasto)?
- [ ] Modo Edición: ¿el Segmented de tipo (Gasto/Ingreso) al comienzo del modo edición es claro que cambia el signo del monto?
- [ ] Confirmación de eliminación inline: ¿el fondo `expense-soft` + texto rojo es suficientemente alarmante sin ser agresivo?

---

## PARTE 2 — DISEÑO: Piezas que faltan o necesitan ser creadas

### 2.1 — Selector de categorías (pantalla completa / bottom sheet)

**Problema actual:** El selector de categoría es un `Picker` inline (dropdown). Para ~15–20 categorías esto es insuficiente en mobile. Necesitamos una pantalla dedicada.

**Lo que hay que diseñar:**

**Mobile — CategoryPickerSheet** (bottom sheet al 80% de altura)
- Header: "Seleccionar categoría" + buscador (input con lupa)
- Grid de 3 columnas de chips/cards con: ícono + nombre de la categoría
- Colores de las cards según el cántaro al que pertenece la categoría
  - Ejemplo: categorías de "Vivienda" (25%) → fondo azul suave
  - Categorías de "Necesidades" (55%) → fondo verde suave
  - Categorías sin cántaro → fondo gris neutro
- Al seleccionar: la sheet se cierra y se actualiza el form con la categoría elegida Y el cántaro derivado aparece automáticamente
- Opción "Sin categoría" al inicio (con ícono `block`)

**Desktop — CategoryPickerPopover** (popover 360px wide)
- Misma estructura que mobile pero como popover pegado al field
- Buscador en el top del popover
- Grid de 2 columnas de opciones

**Datos de ejemplo para el diseño:**

| Categoría | Ícono | Cántaro |
|---|---|---|
| Supermercado | `shopping_cart` | Necesidades (55%) — verde |
| Vivienda / Alquiler | `home` | Necesidades (55%) — verde |
| Transporte | `directions_car` | Necesidades (55%) — verde |
| Salud | `favorite` | Necesidades (55%) — verde |
| Entretenimiento | `movie` | Quiero (10%) — morado |
| Ropa | `checkroom` | Quiero (10%) — morado |
| Suscripciones | `subscriptions` | Quiero (10%) — morado |
| Educación | `school` | Ahorro (35%) — azul |
| Inversión | `trending_up` | Ahorro (35%) — azul |
| Salario | `payments` | — (ingreso, sin cántaro) |
| Freelance | `work` | — (ingreso, sin cántaro) |
| Otros gastos | `category` | — (sin asignar) |

---

### 2.2 — Estado vacío del editor de ítems (Factura)

Cuando el usuario activa "Monto compuesto / Factura" y aún no ha añadido ítems, necesita un estado visual de guía.

**Lo que diseñar:**
- Ilustración mínima (línea, no rellena): recibo o documento con líneas
- Texto: "Añade los productos o servicios de esta factura"
- Subtexto: "Cada ítem puede tener su propia categoría e impuesto"
- Botón: "+ Añadir primer ítem" (botón outlined, accent del tipo de tx)

---

### 2.3 — Tipo "Ajuste" en mobile (falta completamente)

El mobile `TransactionFormSheet` tiene 3 tabs (Gasto / Ingreso / Transferir) pero le falta el modo **Ajuste de saldo**.

**Lo que diseñar:**
- 4 tabs en el segmentado: [Gasto] [Ingreso] [Transferir] [Ajuste]
  - En mobile con 4 tabs, evaluar si usar íconos en lugar de texto largo (o íconos + texto corto: "Ajuste" en lugar de "Ajuste de saldo")
- Pantalla del modo Ajuste mobile:
  - Selector "Cuenta a ajustar" (picker full width)
  - Input "Nuevo saldo" (moneyInput grande)
  - Preview delta: chip verde "↑ +$X" o rojo "↓ −$X" según diferencia con saldo actual
  - Input "Motivo / nota" (opcional)

---

### 2.4 — Confirmación antes de guardar (opcional, evaluar)

Cuando el usuario registra una transacción compleja (pago compuesto con múltiples cuentas, o factura con varios ítems, o con comisión), ¿necesita un paso de confirmación visual?

**Opción A:** Sin step de confirmación — guardar directamente (como está actualmente)
**Opción B:** Toast de confirmación post-guardado (3 segundos, con "Deshacer")
**Opción C:** Preview card antes del botón "Guardar" que muestra el resumen de lo que se va a registrar

El diseñador debe proponer cuál de las 3 opciones encaja mejor con el flujo mobile y cuál con desktop. Justificar la elección.

---

### 2.5 — Estado de carga y retroalimentación post-submit

**Al guardar:**
- Botón principal: estado de loading (spinner en lugar del ícono `check`)
- Duración estimada: 800ms–1200ms
- Post-éxito: ¿el modal/sheet debe cerrarse automáticamente + notificación toast, o mostrar una pantalla de confirmación?

**En caso de error:**
- Error de validación (monto vacío, cuenta requerida): mostrar qué campo falta sin cerrar el form
  - Diseñar el estado de campo inválido: borde rojo + mensaje debajo
- Error de red: toast de error con "Reintentar"

**Lo que diseñar:**
- Estado del botón: loading / success / error
- Field con error de validación (borde + mensaje)
- Toast de error de red

---

### 2.6 — Preview del payload JSON (existente, mejorar)

En desktop, el form ya tiene un botón "Ver payload · POST /api/v1/transactions" que expande un bloque `<pre>` con el JSON. Es útil para devs pero feo para usuario final.

**Propuesta:** en producción esto se remplazaría por una pantalla de resumen de la operación antes de confirmar (ver 2.4 Opción C).

**Lo que diseñar:** una "Transaction Preview Card" que muestre en lenguaje natural:
- Monto + tipo (Gasto de $125.00 / Ingreso de $3,200.00 / Transferencia de $500.00)
- Cuenta(s) involucrada(s)
- Categoría y cántaro (si aplica)
- Número de ítems (si es factura: "Factura con 3 ítems")
- Comisión (si aplica: "+ $1.50 de comisión pago móvil")
- Fecha

Debe ser un card compacto (no full screen), que aparece encima del botón Guardar.

---

### 2.7 — Comportamiento del cántaro en modo Lite (solo mobile)

En Lite, el gasto pregunta "¿De qué cántaro sale?" con un picker (NO derivado de categoría).
Necesita un diseño más visual porque el usuario Lite no conoce bien los cántaros.

**Lo que diseñar:**
- Un selector de cántaro estilo "card grid" (2 columnas) con:
  - Color del cántaro como fondo suave de la card
  - Ícono del cántaro
  - Nombre del cántaro
  - Porcentaje asignado (ej: "55%")
  - Saldo disponible (ej: "$ 420.00 disponibles")
- Estado "seleccionado": borde accent + check

---

## Design Tokens del proyecto (respetar SIEMPRE)

```css
/* Colores base */
--owf-navy: #1E3A8A;       /* primario oscuro */
--owf-cyan: #0EA5E9;       /* acento bright */
--owf-pro: #7C3AED;        /* plan Pro / transfer */
--owf-warning: #F59E0B;    /* ajuste / advertencia */

/* Semánticos */
--income:       #10B981;   /* verde — ingreso */
--income-soft:  rgba(16,185,129,0.08);
--income-fg:    #059669;
--expense:      #EF4444;   /* rojo — gasto */
--expense-soft: rgba(239,68,68,0.08);
--expense-fg:   #DC2626;
--info:         #3B82F6;   /* azul — info / Pro accent */
--info-soft:    rgba(59,130,246,0.08);
--info-fg:      #2563EB;

/* Superficies (dark mode) */
--surface-1: #0F1629;      /* fondo base */
--surface-2: #161D33;      /* elevación 1 */
--surface-3: #1C2540;      /* elevación 2 */
--fg-1: #F1F5F9;           /* texto principal */
--fg-2: #94A3B8;           /* texto secundario */
--fg-3: #475569;           /* texto terciario / placeholder */
--border-hairline: rgba(255,255,255,0.06);

/* Tipografía */
--font-body:  'Satoshi', 'DM Sans', sans-serif;
--font-money: 'DM Mono', 'Roboto Mono', monospace;

/* Radio */
--radius-sm:   8px;
--radius-md:   12px;
--radius-lg:   16px;
--radius-xl:   20px;
--radius-pill: 999px;
```

**Reglas tipográficas:**
- Monto principal: `var(--font-money)` · 28–32px · weight 700 · tabular-nums
- Labels de campo: `var(--font-body)` · 11px · weight 700 · uppercase · letter-spacing 0.06em · color `--fg-3`
- Texto de campo: `var(--font-body)` · 13.5–14px · weight 500 · color `--fg-1`
- Subtexto (hints, sub): `var(--font-body)` · 11.5–12px · color `--fg-2`

---

## Modo oscuro (dark mode)

**Todo el diseño debe ser dark-first.** La app vive en dark mode. Las variables CSS anteriores ya son dark. NO diseñar en light mode salvo para el Admin Panel (que es light).

---

## Restricciones de componentes

- **Mobile:** todo en bottom sheets con `border-radius: 22px 22px 0 0`. Safe area inset en el bottom.
- **Desktop:** modales centrados, `max-width: 560px`, `border-radius: var(--radius-xl)`.
- **Touch targets:** mínimo 44px de alto en mobile para cualquier elemento interactivo.
- **Íconos:** Material Icons (Google) — usar el nombre del ícono tal como aparece en la spec.
- Quasar 2 provee: q-dialog, q-sheet, q-tabs, q-btn — el diseño debe ser compatible.

---

## Deliverables esperados del diseñador

### Verificación (PARTE 1)
1. **Checklist de auditoría** — para cada punto del checklist: ✅ / ⚠️ / ❌ con comentario breve
2. **Pantallas de los problemas encontrados** (marcados ⚠️ ❌) con el problema señalado y la corrección propuesta

### Diseño (PARTE 2)
3. **CategoryPickerSheet (mobile)** — estado vacío, estado con búsqueda, estado con selección
4. **CategoryPickerPopover (desktop)** — estado normal y con hover
5. **Estado vacío del editor de factura** — ilustración + texto + CTA
6. **Modo Ajuste en mobile** — 4 tabs + pantalla del modo Ajuste
7. **Recomendación de paso de confirmación** (2.4) — proponer A/B/C con justificación, mockup de la opción elegida
8. **Estados del botón Guardar** — loading / success / error
9. **Field con error de validación** — mobile y desktop
10. **Toast de error de red** — mobile y desktop
11. **Transaction Preview Card** (resumen pre-confirmación)
12. **Selector de cántaro en modo Lite mobile** — card grid

### Especificaciones para el developer (por cada pieza diseñada)
- Colores exactos usados (hex o referencia a variable CSS)
- Tamaños (px) de elementos clave
- Comportamiento de animación de entrada/salida (si aplica)
- Qué estado es el default y qué dispara cada estado

---

## Referencia visual

El estilo de referencia para el formulario: **Splitwise + Revolut + Linear**
- Splitwise: claridad en división de gastos entre cuentas
- Revolut: jerarquía del monto + feedback instantáneo de tipo de cambio
- Linear: toggles/switches bien diseñados, sin fricciones

**Prioritario:** el usuario promedio del sistema es venezolano. El flujo de comisión de pago móvil es MUY frecuente. Debe ser tan rápido de activar como un toggle, sin obscurecer el flujo principal.

---

## Pantallas fuera de scope (no diseñar ahora)

- SmartTransactionModal / SmartTransactionSheet (entrada AI) — es una pantalla separada
- AdminLayout y vistas del admin panel — tienen su propio prompt en `.owf/specs/OWF-140-admin-users/DESIGN_PROMPT.md`
- Onboarding — tiene spec propia en `rediseno/onboarding/`
