# QA — Matriz de casos de prueba: Formulario de Transacciones

<!-- Generado 2026-07-13. Cobertura: SmartTransactionModal.vue (creación), TxDetailModal.vue
     (ver/editar), TransactionFormDialog.vue (edición legacy Pro). Basado en inventario de
     código OWF-301/302/303. Actualizar este documento si el formulario cambia. -->

**Cómo usar:** cada fila es un caso de prueba independiente. Marcar `[x]` al pasar,
`[!]` + nota si falla. Agrupado por bloque para poder correr subconjuntos (ej. solo Lite,
solo Pro, solo edición).

---

## RONDA 1 — 2026-07-13 (ejecutada por Claude, usuario Test Pro / prod real)

Metodología: interacción real en browser (click + type, no solo `.focus()`/scripted) contra
la API de producción, verificando cada guardado con una consulta directa a
`GET /transactions/{id}` (o `/accounts/{id}` para Ajuste) — no solo inspección visual del
formulario. Cobertura: Sección 1 (Gasto) casi completa, Sección 3 (Transferir) foco en
cruce de moneda + comisión, Sección 4 (Ajuste) happy path. Pro panels (5–8), Lite (12),
edición (10–11) y navegación (13) **quedan pendientes para la Ronda 2**. Sección 9
(voz/OCR/IA) excluida a pedido del usuario — no configurada aún.

### 🐛 Bugs confirmados

1. **[8.6] Comisión no se aplica en Transferir.** El panel "Cobrar comisión" calcula y
   muestra "Comisión ≈ $0.03 · Total $10.03" con tipo "Pago móvil" (0.30% BCV), pero el
   preview final dice "Transfieres $10.00" y el registro guardado en la API confirma
   `amount: "10.00"` — la comisión calculada nunca se incorpora al monto real transferido.
   Repro: Transferir, cruce de moneda USD→VES, activar "Cobrar comisión" (cualquier tipo),
   guardar, comparar `payment_transactions[0].amount` contra el "Total" mostrado en pantalla.
   Candidato: OWF-304.
2. **[hallazgo colateral, no en la matriz original] Cántaro no se muestra pese a que el
   picker de categoría agrupa bajo un cántaro.** Categoría "Supermercado" aparece en el
   picker bajo el grupo "Necesidades básicas" (usa `jar_slug` legado para agrupar), pero al
   seleccionarla el campo Cántaro del formulario dice "Esta categoría no aporta a ningún
   cántaro". Causa raíz probable: la categoría tiene `jar_slug: "necesidades"` pero
   `assigned_jar_id: null` (columna real que `AnchoredJarChip` necesita) — el picker usa un
   fallback por slug que el chip del formulario no replica. Afecta a cualquier categoría con
   `jar_slug` pero sin `assigned_jar_id` poblado (dato legado, mismo patrón de columna
   nullable-sin-backfill que OWF-303). Candidato: revisar `AnchoredJarChip` para que también
   caiga al fallback por `jar_slug` cuando `assigned_jar_id` es null, igual que el picker.

### ✅ Confirmado funcionando correctamente (verificado contra API, no solo UI)

- **1.1–1.18** (Gasto happy path): cuenta, monto, concepto, categoría con búsqueda en vivo
  (sin robo de foco — regresión OWF-303 no reprodujo), proveedor precargado al abrir vacío
  (regresión OWF-302 no reprodujo), creación de proveedor inline con auto-selección, fecha,
  etiquetas del sistema, creación de etiqueta nueva con color aleatorio, toggle "Afecta el
  saldo". Payload real (vía `GET /transactions/{id}`) confirma `provider_id`, `category_id`,
  `transaction_type_id` (fix OWF-303 funcionando para usuario no-admin), `tags[]` y balance de
  cuenta actualizado correctamente (325.00→299.50 tras gasto de 25.50).
- **1.x nota de proceso**: el botón **"Ver payload"** del formulario (debug UI) es un objeto
  simplificado escrito a mano (`debugPayloadPreview` en SmartTransactionModal.vue) — NO
  incluye `provider_id`, `jar_id`, `split`, `items`, `shared`, comisión ni adjuntos. No sirve
  para verificar esos campos; hay que confirmar contra `GET /transactions/{id}` después de
  guardar.
- **3.1, 3.3, 3.5** (Transferir cross-currency): selector de cuenta origen/destino searchable
  funcional, panel "Cruce de moneda" aparece correctamente al mezclar USD/VES, cálculo de
  preview "Envías X / Llega Y" correcto (10×150=1500), `payment_transactions` con `rate_value`
  y montos correctos en ambas cuentas, balances actualizados en ambas monedas.
- **4.1, 4.6** (Ajuste): endpoint dedicado `POST /accounts/{id}/adjust-balance` (no pasa por
  `/transactions`) confirmado — balance de cuenta pasó de $325.00 a $400.00 tras ajuste de
  +75.00. Confirmado que Categoría, Proveedor, paneles Pro y adjunto NO aparecen en este tipo.

## RONDA 2 — 2026-07-13 (regresión post-fix OWF-304, mismo día)

Objetivo: confirmar que los 2 bugs de la Ronda 1 quedaron corregidos y que no se rompió nada
del resto del flujo. Metodología idéntica (interacción real + verificación vía API).

### 🐛 Bugs de Ronda 1 — RE-VERIFICADOS, AMBOS CORREGIDOS ✅

1. **Comisión en Transferir**: repetido dos veces en Ronda 1 (fix) y Ronda 2 (regresión).
   `payment_transactions` origen `-10.03` (monto + comisión), destino `+1500.00` (10×150, sin
   inflar). Preview "Vas a registrar" también corregido: "Transfieres $10.03 ... llegan
   Bs. 1,500.00".
2. **Cántaro por jar_slug legado**: re-confirmado dos veces en esta ronda — categoría
   "Supermercado" muestra el chip "Necesidades básicas" (ícono+color) en vez de "no aporta a
   ningún cántaro", tanto en una transacción nueva como al repetir el flujo completo.

### ✅ Cadena de transacciones de regresión (verificada por aritmética de balance, no solo
### inspección individual — el saldo final es la prueba de que TODAS se aplicaron en orden y
### con el monto correcto)

Cuenta USD partiendo de $325.00:
1. Ajuste → $400.00 (+75.00) — Ronda 1
2. Transferir $10.00 + comisión $0.03 (USD→VES, tasa 150) → $389.97 (-10.03) — Ronda 1
3. Gasto $15.00 (RONDA2 gasto regresion) → $374.97 (-15.00) — Ronda 2
4. Ajuste a $350.00 → $350.00 confirmado — Ronda 2

El balance final ($350.00) coincide exactamente con la suma esperada de las 4 operaciones,
confirmando que ninguna quedó con un monto incorrecto silencioso.

### Hallazgo menor (no bloqueante, no relacionado a los fixes)

- El selector "Cuenta a ajustar" (y probablemente los demás selectores de cuenta) muestra el
  **saldo cacheado de sesión** (`auth.user.accounts`, cargado una vez al iniciar sesión), no
  el saldo real actualizado tras transacciones hechas en la misma sesión — ej. mostró "$325.00"
  cuando el saldo real ya era $374.97. El backend usa el saldo real igual (confirmado: el
  ajuste a $350.00 fue exacto), así que es solo un problema de UI/caché, no de datos. Candidato
  para una tarea separada si molesta en el uso real (recargar accounts tras cada save, o usar
  el store de accounts en vez de auth.user.accounts).

### ⚠️ Notas de proceso para la Ronda 2

- Los selectores de cuenta (Quasar `q-select` con `use-input`) comparten una única variable
  `accountNeedle` global entre TODOS los selects de cuenta del formulario (comentario en
  código: "la needle es compartida... se resetea sola al cambiar de selector"). En pruebas
  automatizadas hay que limpiar el campo de búsqueda explícitamente antes de escribir en un
  select distinto — no asumir que Quasar dispara `@filter('')` automáticamente al abrir.
- Al rellenar campos numéricos por script, `document.querySelectorAll('input[type="number"]')`
  puede devolver 10+ inputs ocultos con `placeholder: "—"` (de los paneles Pro Split/Items/
  Shared, aunque estén cerrados/no montados visualmente) antes del input real — filtrar por
  `placeholder` visible o por posición en el DOM visible, no por índice `[0]`.
- El modal tarda en transicionar (animación de entrada) — esperas de 400ms fueron
  insuficientes en varias ocasiones bajo carga; usar ≥600-800ms tras cada apertura antes de
  interactuar.

---

## 0. Setup previo

- [ ] Tener un usuario **Lite** y un usuario **Pro** de prueba (o un mismo usuario alternable).
- [ ] El usuario de prueba debe tener: ≥2 cuentas en la misma moneda, ≥2 cuentas en monedas
      distintas (para casos de cross-currency), ≥1 proveedor existente, ≥1 categoría de
      gasto y ≥1 de ingreso con cántaro asignado, ≥1 categoría **sin** cántaro asignado,
      y si es posible una categoría **legada sin `transaction_type_id`** (dato viejo).

---

## 1. Tipo de movimiento — Gasto (`expense`)

| # | Caso | Esperado |
|---|---|---|
| 1.1 | Crear gasto mínimo: solo Cuenta + Monto + Concepto | Guarda OK, saldo de la cuenta baja |
| 1.2 | Crear gasto con Categoría con cántaro asignado | Chip de Cántaro se auto-completa, solo lectura |
| 1.3 | Crear gasto con Categoría **sin** cántaro | No se rompe, cántaro queda vacío/"sin cántaro" |
| 1.4 | Crear gasto sin categoría ("Sin categoría") | Guarda OK |
| 1.5 | Buscar categoría escribiendo en el buscador (ej. "gas") | Filtra en vivo, sin perder foco (regresión OWF-303) |
| 1.6 | Seleccionar proveedor existente | Se guarda `provider_id` |
| 1.7 | Crear proveedor nuevo inline ("+ Nuevo proveedor") | Se crea, se auto-selecciona, aparece en el picker sin recargar |
| 1.8 | Abrir picker de proveedor sin escribir nada | Muestra la lista precargada, no vacío (regresión OWF-302) |
| 1.9 | Dejar "Sin proveedor" | Guarda OK, `provider_id: null` |
| 1.10 | Fecha = Hoy (default) | Guarda con fecha actual |
| 1.11 | Fecha = Ayer | Guarda con fecha de ayer |
| 1.12 | Fecha = "Otra fecha…" (pasada y futura) | Selector datetime-local aparece, guarda con la fecha elegida |
| 1.13 | Agregar 1 etiqueta del sistema | Se guarda asociada |
| 1.14 | Agregar 2+ etiquetas | Todas se guardan |
| 1.15 | Crear etiqueta nueva ("+ Nueva etiqueta") con color de paleta | Se crea, se auto-selecciona |
| 1.16 | Crear etiqueta nueva con color "al azar" (dado) | Color aleatorio aplicado |
| 1.17 | Crear etiqueta nueva con color picker libre (`<input type=color>`) | Color custom aplicado |
| 1.18 | Crear etiqueta con nombre duplicado (colisión de slug) | Backend resuelve colisión (-2, -3…) sin error |
| 1.19 | Adjuntar foto/soporte | ⚠️ Confirmar si persiste tras guardar (marcado como UI-only en código, ticket OWF-283) |
| 1.20 | Toggle "Afecta el saldo" = OFF | Transacción se crea pero NO mueve el saldo de la cuenta |
| 1.21 | Monto = 0 o vacío | Bloquea guardado, mensaje de validación |
| 1.22 | Concepto vacío | Bloquea guardado |
| 1.23 | Sin cuenta seleccionada (Pro) | Bloquea guardado |
| 1.24 | Cuenta en moneda ≠ USD | Aparece campo de tasa paralelo/oficial, cálculo correcto |
| 1.25 | Revisar TfReviewCard antes de guardar | Resumen en lenguaje natural coincide con lo ingresado |
| 1.26 | Cerrar el modal a mitad de llenado (botón X / click fuera) | Pide confirmación o descarta sin guardar, sin error en consola |

## 2. Tipo de movimiento — Ingreso (`income`)

| # | Caso | Esperado |
|---|---|---|
| 2.1 | Crear ingreso mínimo | Guarda OK, saldo sube |
| 2.2 | Categoría filtra correctamente por `kind=income` | Solo aparecen categorías de ingreso + legadas sin tipo (no debe mostrar categorías de gasto puras) |
| 2.3 | (Lite únicamente) Banner de reparto automático por cántaros porcentuales | Aparece solo en Lite+Ingreso, cálculo de reparto correcto |
| 2.4 | (Lite únicamente) Fila Fecha comparte espacio con Categoría/Cántaro | Layout compacto correcto |
| 2.5 | Proveedor/etiquetas/fecha | Mismos casos que 1.6–1.18 aplicados a ingreso |
| 2.6 | Monto negativo tecleado | Se fuerza positivo al guardar (signo forzado por tipo) |

## 3. Tipo de movimiento — Transferir (`transfer`)

| # | Caso | Esperado |
|---|---|---|
| 3.1 | Transferencia simple, misma moneda | Guarda OK, 2 `payments` (origen -, destino +) |
| 3.2 | Seleccionar la misma cuenta en Origen y Destino | Bloquea o limpia destino automáticamente (watcher) |
| 3.3 | Cuentas en monedas distintas | Aparece panel "Cruce de moneda" con campo Tasa obligatorio |
| 3.4 | Cruce de moneda sin tasa ingresada | Bloquea guardado |
| 3.5 | Cruce de moneda con tasa válida | Preview "Envías X / Llega Y" correcto, guarda con `rate` |
| 3.6 | No hay Categoría ni Proveedor visibles | Confirmar que estos campos NO aparecen en este tipo |
| 3.7 | Panel Pro "Comisión" en Transferir | ⚠️ Verificar si el monto final realmente incluye la comisión (posible gap, ver 6.4) |
| 3.8 | Panel Pro Split/Items/Shared intentar activarlos | Deben estar deshabilitados/ocultos al cambiar a Transferir (watcher los limpia) |
| 3.9 | Concepto vacío en Transferir | Debe permitir guardar (opcional en este tipo) |
| 3.10 | Etiquetas en Transferir | Se pueden agregar igual que en Gasto/Ingreso |
| 3.11 | Selector de cuenta origen/destino searchable | Filtra en vivo sin perder foco |
| 3.12 | Buscar cuenta y presionar Enter | Selecciona la primera opción filtrada |

## 4. Tipo de movimiento — Ajuste (`ajuste`)

| # | Caso | Esperado |
|---|---|---|
| 4.1 | Ajustar saldo hacia arriba (saldo objetivo > actual) | Preview "+X", guarda vía `POST /accounts/{id}/adjust-balance` (endpoint distinto, no `/transactions`) |
| 4.2 | Ajustar saldo hacia abajo (objetivo < actual) | Preview "-X" |
| 4.3 | Saldo objetivo = saldo actual | Ajuste de 0, ¿bloquea o permite guardar vacío? |
| 4.4 | Motivo vacío | Bloquea guardado |
| 4.5 | Sin cuenta seleccionada | Bloquea guardado |
| 4.6 | Confirmar que NO aparecen: Categoría, Proveedor, paneles Pro, adjunto de foto | Ninguno de estos campos debe estar visible en Ajuste |
| 4.7 | Toggle "Afecta el saldo" en Ajuste | Confirmar comportamiento (¿tiene sentido en este tipo?) |

## 5. Paneles Pro — Split ("Pago múltiple")

| # | Caso | Esperado |
|---|---|---|
| 5.1 | Activar Split, repartir monto en 2 cuentas exacto | Suma = monto total, guarda OK |
| 5.2 | Repartir en 3+ cuentas | Todas las filas se envían como `payments[]` |
| 5.3 | Suma de filas ≠ monto total | Bloquea guardado, mensaje en rojo visible |
| 5.4 | Cuenta de una fila en moneda ≠ USD | Aparece campo Tasa por fila, equivalente correcto |
| 5.5 | Quitar una fila (mínimo 2) | No permite bajar de 2 filas |
| 5.6 | Repetir la misma cuenta en 2 filas del split | Confirmar si se permite o bloquea |
| 5.7 | Split + cambiar tipo a Transferir | Panel Split se desactiva automáticamente |
| 5.8 | Split + cambiar a Ajuste | Panel Split desaparece (Ajuste no tiene paneles Pro) |

## 6. Paneles Pro — Items/Factura ("Detalle / factura")

| # | Caso | Esperado |
|---|---|---|
| 6.1 | Activar Items, agregar 1 ítem con Qty/Precio/IVA | Monto total = qty×precio×(1+iva/100) |
| 6.2 | Agregar 2+ ítems con categorías distintas por línea | Cada ítem guarda su propia `category_id`/`jar_id` |
| 6.3 | Monto hero queda oculto/reemplazado por total de ítems | Confirmar que el campo Monto no es editable directo mientras Items está activo |
| 6.4 | Quitar un ítem | Recalcula el total |
| 6.5 | IVA en 0% y en 100% (límites) | Cálculo correcto en ambos extremos |
| 6.6 | Categoría/Cántaro global ocultos mientras Items activo | Confirmado — se gestionan por línea |
| 6.7 | Tasas paralelo/oficial mientras Items activo | Confirmar que NO aparecen (según inventario, no aplican en este modo) |
| 6.8 | Items + Categoría del artículo sin asignar en alguna línea | ¿Bloquea guardado o permite ítem sin categoría? |

## 7. Paneles Pro — Shared ("Gasto compartido")

| # | Caso | Esperado |
|---|---|---|
| 7.1 | Activar Shared, repartir monto en 2 categorías exacto | Validación visual de suma OK |
| 7.2 | Suma de filas ≠ monto total | Bloquea guardado visualmente |
| 7.3 | **Verificar si el reparto por categoría realmente llega al backend** | ⚠️ Gap detectado en inventario: el payload de `save()` no parece incluir `sharedCats`. Confirmar consultando la transacción creada vía API/admin — si NO llega, es un bug a reportar (posible OWF-304) |
| 7.4 | Shared + cambiar a Transferir | Panel se desactiva automáticamente |

## 8. Panel Pro — Comisión

| # | Caso | Esperado |
|---|---|---|
| 8.1 | Tipo "Pago móvil" (fijo 0.30% BCV, mín. Bs 2) | Comisión no editable, se calcula sola |
| 8.2 | Tipo "Porcentaje", ingresar % | Comisión = monto × % |
| 8.3 | Tipo "Monto fijo" | Comisión = valor ingresado |
| 8.4 | Comisión en Gasto | `finalAmount = monto + comisión` se refleja en el monto final guardado |
| 8.5 | Comisión en Ingreso | Confirmar mismo comportamiento que Gasto |
| 8.6 | **Comisión en Transferir** | ⚠️ Gap detectado: el cálculo de `finalAmount` con comisión parece estar solo en la rama Gasto/Ingreso del código. Verificar si al combinar Transferir+Comisión el monto final realmente la incluye |

## 9. Métodos de entrada alternativos

| # | Caso | Esperado |
|---|---|---|
| 9.1 | Tab "Voz" — grabar y transcribir un gasto simple | Reconocimiento funciona (navegador con soporte), transcript correcto |
| 9.2 | Voz en navegador sin soporte (`SpeechRecognition` no disponible) | Mensaje "Tu dispositivo no soporta reconocimiento de voz" |
| 9.3 | Voz con resultado exitoso → "Editar y guardar" | Precarga tab "Escribir" con banner "Pre-rellenado desde voz", NO autoguarda |
| 9.4 | Voz con error de red | Reintenta automáticamente 1 vez |
| 9.5 | Voz con error 429 (límite de uso) | Mensaje "Límite de uso alcanzado" |
| 9.6 | Voz con error 503 | Mensaje "Servicio no disponible" |
| 9.7 | Tab "Foto" — subir imagen de factura (drag&drop) | Extrae Monto/Comercio/IVA/Fecha en chips informativos |
| 9.8 | Tab "Foto" — subir PDF | Acepta `application/pdf`, procesa igual |
| 9.9 | Tab "Foto" — file picker manual (sin drag&drop) | Mismo resultado que 9.7 |
| 9.10 | Foto con resultado exitoso → "Editar y guardar" | Precarga tab "Escribir", requiere confirmación manual |
| 9.11 | Foto con imagen ilegible/corrupta | Manejo de error sin crashear el modal |
| 9.12 | Tab "Auto IA" (Beta) — texto libre describiendo un gasto | Botón "Analizar con IA" habilitado solo con texto no vacío |
| 9.13 | Auto IA con texto ambiguo/vacío | Botón deshabilitado o error claro |
| 9.14 | Auto IA resultado con `category_suggestion` que coincide por nombre | Se resuelve a `category_id` real automáticamente |
| 9.15 | Auto IA resultado con `category_suggestion` que NO coincide con ninguna categoría del usuario | Categoría queda vacía, no crashea |
| 9.16 | "Carga masiva" — abrir desde el modal | Cierra `SmartTransactionModal` y abre `TransactionBulkImportDialog` por separado; confirmar que no quedan ambos modales superpuestos |
| 9.17 | "Carga masiva" — botón X para cerrar | ⚠️ Comentario en código indica que el cierre no es 100% confiable desde ese botón — verificar |

## 10. Ver / Editar transacción existente (`TxDetailModal.vue`)

| # | Caso | Esperado |
|---|---|---|
| 10.1 | Abrir una transacción de Gasto en modo "ver" | Muestra Tipo, Categoría, Cántaro, Cuenta (si aplica), Fecha larga, solo lectura |
| 10.2 | Botón "Editar" → cambia a modo edición | Campos editables: Tipo, Monto, Concepto, Categoría+Cántaro, Cuenta (solo Pro) |
| 10.3 | Cambiar Tipo de Gasto→Ingreso en edición | Confirmar que SÍ lo permite (comportamiento no obvio detectado) y que el signo del monto se ajusta |
| 10.4 | Editar en modo Lite | Selector de Cuenta NO debe aparecer (oculto por `layoutMode` en este modal) |
| 10.5 | Guardar edición | `PATCH /transactions/{id}` — confirmar que NO se pierden tags/proveedor/fecha existentes (este modal no los reenvía, según inventario) |
| 10.6 | Intentar abrir una Transferencia en este modal | Confirmar comportamiento — el modal solo maneja income/expense según inventario |
| 10.7 | Intentar abrir un Ajuste en este modal | Igual, confirmar que no rompe |
| 10.8 | Botón "Eliminar" | Confirmación inline "¿Eliminar este movimiento? No se puede deshacer", luego `DELETE` |
| 10.9 | Botón "Duplicar" | Crea copia con sufijo " (copia)", fecha = ahora (no la original) |
| 10.10 | Cancelar edición sin guardar | Descarta cambios, vuelve a modo ver con datos originales |

## 11. Edición legacy vía tabla Pro (`TransactionFormDialog.vue` / `useTransactionForm.ts`)

| # | Caso | Esperado |
|---|---|---|
| 11.1 | Editar una fila desde la tabla de Transacciones (Pro) | Abre este diálogo, no SmartTransactionModal |
| 11.2 | Cambiar el signo del Monto (de - a +) | El tipo (`transaction_type_id`) cambia automáticamente Ingreso↔Gasto (watcher por signo — comportamiento DISTINTO al picker explícito de SmartTransactionModal) |
| 11.3 | Editar una transferencia (detectada por slug/name del tipo) | Requiere cuenta origen y destino |
| 11.4 | Guardar sin cambiar nada | No debe romper ni duplicar |
| 11.5 | Confirmar que este diálogo NO tiene split/items/shared/tags | Ausentes por diseño (composable legacy más simple) |

## 12. Diferencias Lite vs Pro (transversal)

| # | Caso | Esperado |
|---|---|---|
| 12.1 | Header del modal dice "· Lite" en cuenta Lite, "· Pro" en cuenta Pro | Correcto en ambos |
| 12.2 | Etiquetas visibles en Lite | Solo 3: Compra Impulsiva, Planificado, Recurrente |
| 12.3 | Etiqueta custom creada por el usuario en cuenta Lite | Normalmente NO visible en Lite salvo que su slug coincida con uno de los 3 fijos — confirmar este edge case |
| 12.4 | Paneles Pro (split/items/shared/comisión) en Lite | Deben estar completamente ausentes, no solo deshabilitados |
| 12.5 | Auto-asignación de cuenta default en Lite si no hay ninguna seleccionada | Confirmar que ocurre (`ensureAccountsLoaded`) |
| 12.6 | Cambiar `layout_mode` de un usuario Lite→Pro (o viceversa) y volver a abrir el modal | Refleja el modo correcto sin caché stale |

## 13. Movimientos especiales (fuera de SmartTransactionModal — navegación)

| # | Caso | Esperado |
|---|---|---|
| 13.1 | Botón "Pago de deuda" en acción rápida (desktop) | Navega a `/user/debts?quickAction=pay`, abre diálogo de pago de cuota |
| 13.2 | Botón "Aporte a sueño" | Navega a `/user/dreams?quickAction=contribute` |
| 13.3 | Botón "Aporte a jar" | Navega a `/user/jars?quickAction=deposit` |
| 13.4 | Cancelar navegación a mitad (botón atrás del navegador) | No deja el query param colgado causando reapertura accidental del diálogo |

<!-- Nota: 13.x son flujos con su propia lógica de negocio (cuotas Cashea, metas, cántaros de
     corto plazo) — si se requiere matriz detallada de estos 3, es un documento aparte. -->

## 14. Regresiones específicas de esta sesión (OWF-301/302/303) — no re-romper

| # | Caso | Esperado |
|---|---|---|
| 14.1 | Abrir selector de Proveedor sin escribir nada | Muestra lista precargada de proveedores del usuario, NO vacío |
| 14.2 | Abrir selector de Categoría con el campo cerca del borde superior del modal (scroll hasta abajo del form) | El popover NO se corta / no queda detrás del header, input de búsqueda accesible |
| 14.3 | Escribir en el buscador de Categoría | Filtra en vivo SIN que el foco salte a otro campo (regresión del focus-trap de QDialog) |
| 14.4 | Cuenta con categorías legadas (sin `transaction_type_id`) | Esas categorías siguen apareciendo en el selector, no desaparecen |
| 14.5 | Crear una transacción como usuario NO-admin | El payload debe incluir `transaction_type_id` correcto (antes quedaba `null` por bug de permisos en `/transaction_types`) |

---

## Resumen de gaps a confirmar con el equipo (no son bugs confirmados, son hallazgos de inventario)

1. **Shared (7.3)**: el reparto por categoría podría no llegar al backend — validar con una prueba real y revisar la transacción creada.
2. **Comisión + Transferir (8.6)**: el cálculo de comisión podría no aplicarse en este tipo.
3. **Adjunto de foto (1.19)**: marcado como UI-only en el código (OWF-283) — probablemente no persiste.
4. **Tags custom en Lite (12.3)**: pueden "desaparecer" visualmente si el slug no coincide con los 3 fijos.
5. **Inconsistencia de comportamiento entre editores**: `TxDetailModal` permite cambiar tipo Gasto↔Ingreso explícitamente; `TransactionFormDialog`/`useTransactionForm` lo cambia automáticamente por el signo del monto; `SmartTransactionModal` (creación) usa un picker explícito. Tres reglas distintas para "cuál es el tipo" según dónde se edite.
