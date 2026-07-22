# OWFinance — Lista Maestra de Funcionalidades (Pro + Lite)

<!-- Generado: 2026-07-19, vía auditoría de 8 agentes leyendo el código fuente completo de OWFinanceFrontend2025/src. -->
<!-- Propósito: prompt de referencia para que NINGUNA funcionalidad existente se pierda en el rediseño. -->
<!-- Complementa a `.owf/EPIC_VIEWS.md` (que trackea estado pass/fail por vista) con el detalle campo-por-campo/acción-por-acción. -->
<!-- Actualizado: 2026-07-19 (mismo día, sesión posterior) — incorpora commits afbb8bd (OWF-320), 470d9fc y 87b912c (OWF-319 capa 2) a las secciones 1 (Home) y 2 (Transacciones). Jars/Cántaros (sección 3) verificado sin cambios en ese rango. -->

## Cómo usar este documento

Para cada módulo se lista: KPIs/datos mostrados, acciones disponibles, diferencias Pro vs Lite, validaciones, estados vacíos/loaders. Al final hay una sección **"Deuda técnica y hallazgos críticos"** con componentes huérfanos, features a medias, y flujos triplicados — léela ANTES de decidir qué portar al rediseño, para no reconstruir código muerto ni "bugs congelados" como si fueran spec.

---

## 0. Arquitectura del toggle Pro/Lite

- **No hay rutas separadas.** Un único árbol de rutas `/user/*`; cada página raíz decide render vía `layout_mode` (`stores/auth.ts`, valores `'pro' | 'lite' | 'legacy' | null`).
- **3 modos reales, no 2**: `pro`, `lite`, y `legacy` (código heredado que persiste en `transactions/index.vue` y `expense-analysis/index.vue`). `SmartTransactionModal.vue` solo distingue 2 (trata `legacy` como `lite`).
- `layout_mode` es una **preferencia de usuario**, no un plan de pago — no hay feature-gating por suscripción en el código (el único badge "PRO" visible es cosmético).
- Única excepción de router explícito: `/user/accounts` redirige a `/user/config` si `layout_mode === 'lite'`.
- Selección inicial obligatoria: `OnboardingModal.vue` (elegir Lite/Pro, no saltable, dispara `window.location.reload()`), separado de `OnboardingFlow.vue` (perfil financiero + IA, sí saltable, repetible desde Config en Lite).

---

## 1. Home (`/user/home`)

### Mecanismo
`HomeView.vue` → `ProHomeView.vue` (isPro) o `LiteHomeView.vue` (resto). Ambos son monolíticos (todo el template inline, no usan los componentes `components/home/*` — ver huérfanos).

### Pro (`ProHomeView.vue`)
- Saludo "Hola, {nombre}" + botón notificaciones.
- Balance hero (solo mobile): disponible, badge PRO, 3 stats (ingresos/gastos/neto).
- **KPI strip (4 cards)**: Disponible (+ delta MoM), Ingresos·mes (+ delta), Gastos·mes (+ delta, color invertido), **Tasa de ahorro** (fórmula `(ingreso-gasto)/ingreso*100`, meta fija "40%" hardcodeada — único badge de meta fija del sistema).
- Timestamp "Actualizado {hora}".
- Fila media: **Gastos por categoría** (top 5, barra proporcional) + **Cántaros** (lista con % + barra).
- Movimientos recientes (hasta 6, **excluye transferencias**, clasificación robusta por `transaction_type_id`/slug).
- Widget `ExchangeRatesTable` embebido.
- Sueños (preview hasta 3, ordenados por progreso).
- Strip "Asesor Financiero IA" (hint fijo, no dinámico pese al nombre).
- **Panel de Cuentas (Pro-only)**: toggle flotante → panel lateral con tabs Cuentas (patrimonio neto + lista) / Deudas (deuda total + lista con estado). Oculto en mobile ≤768px (sin spec mobile aún, OWF-173-GAP2).
  - **(OWF-320, 2026-07-19)** Cada cuenta en moneda distinta a USD ahora muestra su **equivalente en USD** junto al saldo nativo (`≈ $X USD`, texto secundario debajo del monto+código de moneda), calculado con la tasa paralela guardada por el usuario (`useUserRates`, misma fuente que el picker de `SmartTransactionModal`). Se oculta junto con el resto si `ui.hideValues` está activo; no se muestra si la cuenta ya es USD o no hay tasa registrada para esa moneda.
- Ocultar valores (`ui.hideValues`) aplica a todos los montos.

### Lite (`LiteHomeView.vue`)
- Saludo + botón ocultar saldos (propio, no vive en topbar como en Pro) + notificaciones.
- Hero de balance **siempre visible** (no solo mobile) con delta MoM prominente junto al monto, fecha, botón "Agregar", timestamp, 3 KPIs inline (sin tasa de ahorro).
- Botón "Configurar ingreso mensual" (dialog simple, PUT `/user`).
- **Sección "Ingreso esperado"** (exclusiva Lite): monto + edición inline (PUT `/user/profile` — nota: dato duplicado con el dialog anterior, dos endpoints distintos para el mismo campo).
- Cántaros (preview hasta 4, solo barra visual, **sin %** numérico a diferencia de Pro).
- Sueños (preview hasta 3, con CTA "Crear sueño" en vacío — Pro no lo tiene).
- **Deudas en el home feed principal** (Pro solo las muestra dentro del panel lateral) — 4 estados (Al día/Por vencer/Atrasada/Pagada) vs 3 en Pro.
- Recientes (hasta 4 mobile / 5 desktop, **no excluye transferencias** — clasificación más simple solo por signo, inconsistente con Pro).
- Efecto lateral: publica `ui.setJarStatus(...)` al store global (Pro no lo hace).

### Navegación (AppShell.vue — compartido)
- Sidebar Pro (9 items: Inicio, Transacciones, Análisis, Cántaros, Perfil financiero, Sueños, Deudas, Asesor IA, Configuración) + topbar con Agregar/ocultar saldos/tema/notificaciones/admin(si rol)/panel-cuentas/avatar.
- Bottom nav Lite (`LiteFloatingBottomNav`: Home/Movs/Análisis/Cántaros/Sueños/Deudas/Ajustes + FAB) vs bottom nav Pro-mobile (`BottomNavMobile`, default solo Home/Transacciones/Cántaros/Sueños/Configuración — **no incluye Análisis ni Deudas** por defecto).
- `ExpandedNavigationMenuLight` (menú de cuenta compartido): Perfil, Perfil financiero, Cuentas, Exportar datos (placeholder no implementado), Asesor IA, Configuración, Privacidad (placeholder), Cerrar sesión.
- `QuickActionSheet` (mobile, FAB): Gasto/Ingreso/Transferir/Voz/Escanear/Auto IA/Personalizado (placeholder "próximamente") + botón "Hablar con Asesor IA".
- `ImpersonationBanner` (admin impersonando usuario) + `VersionBadge`.
- Selectores de periodo compartidos (`PeriodFilterBar`, `PeriodNavigator`): granularidades día/semana/quincena/mes/trimestre/semestre/año/todo/custom.

---

## 2. Transacciones (`/user/transactions`)

### Pro (dentro de `index.vue`)
- Header + `PeriodNavigator`.
- `AccountFilterWidget` (multi-cuenta con folders), buscador, contador+neto, exportar CSV, eliminar selección.
- 3 pools de filtro: Filtros activos (mes/tipo/categoría/cántaro/búsqueda/monto con presets), Categorías (agrupadas por cántaro), Cántaros.
- Feed agrupado por fecha, con modo multi-selección (doble-click) y acciones en lote.
- **AccountsPanel** lateral: Cuentas (ajustar/recalcular saldo, individual o en lote) / Deudas.
- Modal de detalle propio "OWF-138" (ver/editar/duplicar/eliminar) — **independiente** de `TxDetailModal.vue`.
- Ajustar/Recalcular saldo de cuenta única seleccionada, balance corrido (`running_balance`) si 1 cuenta + orden por fecha.
- Deep-link `?editTx=<id>` desde Home.

### Legacy (tercer layout dentro del mismo archivo)
- 2 columnas: `AccountsSidebarWidget` + hero de stats + filtros avanzados vía `dictionary.forms_filter` + `q-table` server-side + selector de columnas visibles.

### Lite (`LiteTransactionsView.vue`)
- Filtro inteligente en una tarjeta (buscador + panel de filtros: tipo/cántaro/categoría/día/monto).
- Lista simple con chips de etiquetas, cántaro, monto (oculto con `hideValues`).
- Detalle en bottom-sheet (solo lectura) con Eliminar/Duplicar/Cerrar/Editar (abre `SmartTransactionModal`).
- Transferencias se clasifican como "expense" (inconsistente con Pro que las distingue).

### Creación/edición — `SmartTransactionModal.vue` (formulario "maestro")
- **Métodos de entrada**: Escribir / Voz / Foto / Auto IA / Carga masiva (dialog aparte).
- **Tipos**: Gasto, Ingreso, Transferir, Ajuste (oculto en edición — usa endpoint dedicado).
- Campos por tipo: cuenta define moneda, monto, tasas duales (paralelo + BCV oficial) si no-USD, categoría+cántaro anclado (solo lectura), proveedor (con creación inline), fecha, etiquetas (Pro: todas; Lite: 3 fijas por slug).
- **4 features Pro-only** (toggles tipo tarjeta): Pago múltiple/split, Detalle/factura por ítems, Gasto compartido (⚠️ incompleta, ver hallazgos), Cobrar comisión (Pago móvil % / % / monto fijo).
  - **(OWF-320, 2026-07-19)** Comisión "Pago móvil" ahora aplica un **piso mínimo de Bs 2** (antes solo calculaba el 0.30% sin piso, lo que daba comisiones irrealmente bajas o de $0 en montos pequeños) — el resultado mostrado es `max(monto*0.30%, Bs 2 convertido a la moneda de la cuenta)`.
- Toggle "Afecta el saldo".
- Foto/adjunto: ⚠️ solo UI, no sube al backend (OWF-283 pendiente).
- `TfReviewCard`: preview en lenguaje natural antes de guardar.
- Tabs IA: Voz (MediaRecorder + Whisper/Groq), Foto (OCR), Auto IA (texto libre) — todas comparten `applyAiResult()` con fuzzy-match de categoría/proveedor.
  - **(OWF-319, 2026-07-19)** Fix: el guardado de una transacción proveniente de un resultado de IA (voz/foto/auto-IA) fallaba con error de backend *"date field must be a valid date"* en ciertos casos — corregido el formateo de fecha antes de enviar el payload.
  - **(OWF-319 capa 2, 2026-07-19, nuevo — parcial 1/2)** Cuando el flujo de Voz no logra determinar la cuenta automáticamente y necesita preguntarle al usuario, el asistente ahora puede **leer la pregunta en voz alta** vía un composable nuevo (`useSpeechSynthesis.ts`, TTS nativo del navegador `speechSynthesis`, no requiere backend). Se eligió TTS nativo (en vez de servidor) específicamente porque tiene soporte amplio en iOS Safari, a diferencia de `SpeechRecognition` (que sí tuvo que migrarse a server-side en OWF-311 por falta de soporte). Es **no-op silencioso** si el navegador no soporta la API — nunca bloquea el flujo, y el selector visual de chips para elegir cuenta sigue funcionando igual con o sin audio. Nota: es la "capa 2 (1/2)" — queda una segunda mitad de este trabajo pendiente de implementar/documentar.

### Carga masiva — `TransactionBulkImportDialog.vue`
- 3 modos: Tabla manual, Excel (.xlsx/.xls), Texto (delimitador configurable).
- Cuenta única obligatoria, mapeo de columnas con concatenación múltiple, reglas de tipo por texto, vista previa editable, asignación de categorías no encontradas, tasa por defecto con advertencia, dry-run + import real, reporte de errores por fila.

### Otros componentes de transacción
- `CategorySelector.vue`: popover con Teleport, agrupación por cántaro, búsqueda, filtro por kind income/expense.
- `AnchoredJarChip.vue`: muestra cántaro anclado a una categoría (3 estados: sin categoría / sin jar / jar anclado con candado informativo — el candado NO es interactivo ni tiene relación con `JarPercentLock` backend).

---

## 3. Cántaros / Jars (`/user/jars`)

### Pro/Legacy (`jars/index.vue`)
- Bloque `MonthlyIncomePanel`: Ingreso Esperado/Real, Total Asignado, Disponible, toggle "usar ingreso real", alerta de meta.
- Card "Resumen del mes": Total gastado, Total ajustes, No usado este mes, Ahorro teórico total (+ "Ocioso acumulado" solo en legacy) + tabla desglose mensual por cántaro.
- Card "Configuración global": inicio de contabilidad, permitir negativos/límite, ciclo por defecto + día, **cántaro de apalancamiento** (global y override mensual), auto-apalancamiento (toggle).
- Barra horizontal de % por cántaro + alerta si no suma 100% (salvo jar fijo activo o único jar al 100%).
- Por cántaro (draggable): nombre, activo, Reset/Acumulativo, %/Monto fijo, color (picker + sugeridos + aleatorio), eliminar, expandir. Expandido: slider %/monto, Propósito (contexto para IA), `JarCard` de balance (ver abajo), Opciones avanzadas (fecha inicio, ciclo, negativo, meta/objetivo, apalancamiento desde), dropzone de categorías (drag&drop con anti-duplicado).
- Panel lateral de categorías (árbol readonly, filtra ya-asignadas).
- Diálogo "Aplicar plantilla" (reemplaza toda la config actual, con confirmación).
- `AdjustmentModal`: balance objetivo absoluto, split Usado/Restante sincronizado, confirmación si reduce balance.
- Diálogo "Registrar uso" (retiro): monto, descripción, fecha.
- Guardado: `POST /jars/bulk-sync` (protegido por `JarPercentLock` backend contra condiciones de carrera, OWF-061).

### `JarCard.vue` (balance individual expandido)
- Hero disponible + barra (usada % **sin cap**, puede superar 100% mostrando "excedido").
- Chips: carry-over, gastado, ajuste, retiros.
- Preview en vivo de cambios de % no guardados aún.
- Sugerencia de ingreso real vs esperado.
- Desglose completo: saldo anterior, asignado, gastado, retiros, ajuste, transferencias in/out, **apalancamiento in/out**, balance final.
- Acciones: Ajustar, Registrar uso, Apalancar (si aplica), Resetear ajuste.

### Lite (`LiteJarsView.vue`) — vista totalmente distinta, mobile-first
- Card resumen: total en cántaros, barra de distribución, stats (activos/asignado/uso global %).
- Selector de periodo (Mensual/Semestral/Anual) — ⚠️ presente pero **no conectado a recarga de datos**.
- Lista de cántaros con drag **solo visual** (no persiste), toggle activo inline, barra de progreso (con cap a 100%, a diferencia de Pro).
- Bottom-sheets: Detalle (con Agregar/Retirar → abre smart modal genérico, no un formulario dedicado), Editar (solo nombre+%+color de paleta fija de 8), Nuevo cántaro.
- **Sin**: tipo fijo/%, acumulativo editable, categorías vinculadas, apalancamiento, meta/objetivo, ajuste manual dedicado, plantillas, tabla mensual, ahorro teórico.

### Componentes de soporte
- `BigJarSidebar.vue`: jarra XL apilada, solo lectura.
- `JarsBalanceBar.vue`: chips horizontales de disponible por cántaro (1 sola llamada bulk `GET /jars/all-balances`), colores ok/warn/neg.
- `JarPercentSplitInfo.vue`: banner "se reparte automáticamente" (usado en formularios de ingreso).

---

## 4. Cuentas, Categorías, Impuestos

### Cuentas (`/user/accounts`, **Pro-only** — Lite redirige a `/user/config`)
- CRUD genérico (`CrudPage` + `dictionary.ts`): Nombre, Inicial, Moneda, Tipo, Activo.
- `AccountsSidebarWidget`: agrupado por carpetas, selección múltiple, totales con conversión a USD, menú ⋮ (Ajustar saldo con opción "generar transacción de ajuste" / Recalcular saldo).
- `AccountsTree`: gestión completa con drag&drop (mover dentro de carpeta, reordenar, reglas anti-loop), toggle incluir/excluir del balance global por cuenta, crear/renombrar/eliminar carpetas.
- `AccountFilterWidget`: pill + panel flotante, segmentos rápidos (Todas/USD/VES/Con deuda), ajuste/recalculo inline.
- `AccountViewerDialog` / `AccountDialog`: vista detalle + form standalone (no integrado al CrudPage genérico).

### Lite — "billetera implícita" (confirmado en código, no solo copy de marketing)
- Router redirige `/user/accounts` → `/user/config`.
- Item "Cuentas vinculadas" **excluido** del nav de Config en Lite.
- `useTransactionForm.ts`: auto-asigna la cuenta `is_default=true` sin intervención del usuario.
- Conclusión: en Lite no hay gestión de cuentas de ningún tipo — todo vive en una única cuenta "Billetera".

### Categorías (`/user/categories`, compartida)
- Árbol completo (`CategoriesTree`): crear categoría/carpeta, mover (drag&drop con conversión automática carpeta↔categoría), eliminar (con confirmación), filtro por nombre + toggles carpetas/categorías, badge de cántaro vinculado, multi-columna.
- `CategoryDialog.vue` (versión más completa, usada desde otro flujo): tipo transacción (gasto/ingreso/ambas), toggle incluir en balance, selector de icono (catálogo ~30 iconos Material).
- El `index.vue` de usuario tiene su propio diálogo simplificado (solo nombre/fecha/activo) — inconsistente con `CategoryDialog.vue`.

### Impuestos (`/user/taxes`, compartida)
- CRUD genérico: Nombre, Porcentaje, Fecha, Activo. Sin confirmación antes de eliminar (a diferencia de categorías).

---

## 5. Deudas, Sueños, Perfil (sin diferencias Pro/Lite — renderizado idéntico en ambos modos)

### Deudas (`/user/debts`)
- Card resumen: total pendiente, próximas cuotas 30d, estado (N atrasadas / al día).
- Agrupación: Planes Cashea (0% interés) / Otras deudas.
- `DebtCard`: proveedor con icono/color, saldo, estado (4: al día/próximo/atrasado/pagado), progreso %, cuota X/Y.
- Acciones: Nuevo plan, Pagar cuota (genérico o por card), Editar, Eliminar (confirmación).
- Form: nombre*, tipo/proveedor, comercio, monto original*, saldo, cuotas totales/pagadas, próxima cuota, fecha, tasa/interés, estado, notas.
- Sin proyección de "cuándo se pagará" — solo progreso actual.

### Sueños (`/user/dreams`)
- Hero: total acumulado, N activos, meta combinada, % del camino.
- Cards con emoji/color custom, % progreso, saved/target, barra.
- Sección "Completados" separada (opacidad reducida, check verde).
- Acciones: Nuevo sueño, Aportar (con celebración si completa), Editar, Marcar completado/Reabrir, Eliminar.
- Sin proyección de fecha estimada de meta.

### Perfil Financiero (`/user/financial-profile`)
- Chips de "Quién soy" (ocupación/ingresos/vivienda), "Situación financiera" (deudas/fondo emergencia/relación con dinero), "Metas y sueños" (meta principal/sueño largo plazo/cómo quiero sentirme).
- **Cántaros**: selector de plantilla (carrusel, recomendada/popular) + tabla editable de cántaros con validación de suma ≤100%.
- Guarda perfil + `POST /jars/bulk-sync` en paralelo.

### Perfil (`/user/profile`)
- Avatar (subida ⚠️ no funcional, placeholder), barra de completitud (8 campos), datos personales, contacto, ubicación (país/ciudad), `ChangePasswordCard` embebido (indicador de fortaleza de contraseña).

---

## 6. Análisis de Gastos y Tasas (`/user/expense-analysis`)

Dos specs de diseño distintas confirmadas en comentarios: `ProAnalisisRoute` ("Navegador financiero") vs `AnalisisRoute`/Lite ("En qué se fue").

| Aspecto | Pro | Lite | Legacy |
|---|---|---|---|
| Layout | 3 columnas | 2 columnas | 2 columnas |
| Donut | En panel central, leyenda clickeable filtra | Card independiente sin filtro | — |
| Budget pulse (conic-gradient %) | No | Sí | No |
| Insight en lenguaje natural | Solo sobregasto (rojo) | Insight violeta + comparación MoM | — |
| Top cántaros / Asignado vs gastado | Sí | No | No |
| Agrupar por "cántaro" | Disponible | Oculto | Disponible |
| Métricas | 4 (Trans/Gastos/Ingresos/Balance) | 3 (Trans/Balance/Filtros activos) | 4 |

- `ExpenseDistributionChart.vue`: donut (asignado esperado) + barras horizontales (Asignado/Gastado/Balance) vía ECharts.
- **Corrección (2026-07-20, verificado por grep de imports reales en `src/`): la edición de Tasas de Cambio NO vive dentro de `expense-analysis/index.vue`** — esta vista solo consume tasas (`useUserRates`) para convertir montos, no las muestra ni las edita. Los lugares reales donde el usuario ve/edita tasas son `ProHomeView.vue` (Home Pro, widget embebido) y `config/index.vue` (tab Finanzas, Pro) — ambos usan `ExchangeRatesTable.vue`. **`ExchangeRatesWidget.vue` es huérfano** (no importado en ningún lado — las 2 menciones a su nombre en `transactions/index.vue` son comentarios/variables de una UI de tasas construida ad-hoc ahí, que no usa el archivo real del componente). Monedas: **EUR, VES, COP, CLP, PEN** + USD base. Origen confirmado: **BCV oficial** vs "tasa actual" (no hay "paralelo" textual), ambas editables en `ExchangeRatesTable`. **Sin historial temporal**, solo snapshot + delta %. Detalle completo en `rediseno/PROMPT_REDISENO_ANALISIS.md` §5.
- `MonthlyIncomePanel`: esperado vs real vs asignado vs disponible, con alertas condicionales (esperado=0, sobre-asignado, cumplimiento crítico/warning/excelente, disponible>10% sin asignar).

---

## 7. Asesor IA, Configuración, Notificaciones, Onboarding

### Asesor IA (`/user/asesor`)
- Chat con streaming SSE (`POST /ai/chat`), 4 sugerencias predefinidas, CTAs embebidas (`[CTA: texto]`), copiar mensaje, reintentar en error, rate-limit (429) manejado.
- Configuración del asesor: nombre custom, personalidad (Amigable/Formal/Coach), toggle activado.
- Backend soporta historial de conversaciones (`conversation_id`, `loadConversation`, `getConversations`) — **sin UI que lo exponga todavía**.
- Proveedores (Gemini/OpenCode/Groq) son 100% server-side — solo visibles en `admin/ai_monitor.vue`.

### Configuración (`/user/config`) — bifurca completamente el template Pro/Lite
**Pro**: cards (Aplicación, Seguridad, Notificaciones, Perfil financiero, Tasas de Cambio) + tabs (Perfil, Finanzas, Categorías, **Cuentas**, Impuestos).
**Lite**: filas de lista simplificadas; nav sin "Cuentas"; agrega "Repetir configuración inicial" (reabre `OnboardingFlow`) y "Exportar datos" (⚠️ placeholder no funcional); cambio de contraseña redirige a `/user/profile` en vez de inline; **sin** bloque de Tasas de Cambio.
**Compartido**: modo Lite/Pro, idioma (es/en), ocultar saldos, tema, presupuesto estricto, divisa predeterminada (enlace), pantalla de inicio (enlace), resumen semanal + alertas dinero ocioso, "pedir confirmación para ver saldos" (privacy lock), PIN de acceso (config/cambiar/eliminar), cerrar sesión.

### Notificaciones
- Página completa (`/user/notifications`) + panel dropdown/bottom-sheet (`NotificationsPanel`, campana del header) — **estados independientes, no comparten store**.
- Tonos: expense/income/warning/info. Marcar leído: ⚠️ **solo local/optimista, no persiste al backend** en ninguno de los dos.
- Panel tiene "Marcar todas"; la página completa no.

### Onboarding (dos flujos independientes)
1. **`OnboardingModal.vue`**: elegir Lite/Pro, obligatorio (no saltable), primera vez (`has_seen_onboarding`), recarga completa al elegir.
2. **`OnboardingFlow.vue`**: perfil financiero + recomendación de plantilla de cántaros por IA (heurística `GOAL_TO_TEMPLATE`), 7 pasos, gamificación (badges 🌱/🌿/🌳 por % completitud), auto-avance en chips, panel lateral "tu plan se forma" (desktop), saltable, repetible desde Config (solo Lite tiene el botón, Pro no).

---

## 8. Panel Admin (`/admin/*`) — 18+ vistas

- **15 CRUDs genéricos** (mismo motor `CrudPage.vue` + `dictionary.ts`): currencies, clients, account_type, taxes, item_categories, items, jars, categories, rates, providers, transaction_types, roles, transactions, (accounts existe en disco también).
- **4 vistas custom**: `users` (index con KPIs+impersonación + detail.vue con 6 tabs: Perfil/Cuentas/Cántaros/Transacciones/Seguridad/Ajustes), `admin_dashboard` (6 KPIs), `ai_monitor` (estado de proveedores IA, costos, tokens, por-feature, últimas llamadas), `system` (conteos de tablas, últimas sesiones).
- Nota de diseño: rediseñar `CrudPage.vue` impacta automáticamente a los 15 CRUDs genéricos.

---

## 9. Auth y Público/Marketing

### Auth
- `LoginPage.vue`/`LoginMobileView.vue`: tabs login/registro, medidor de fuerza de contraseña, biometría (mobile), botones sociales decorativos (sin función real).
- `RegisterPage.vue`: solo redirect a `/login?tab=register`.
- `ForgotPasswordPage.vue` / `ResetPasswordPage.vue`: flujo estándar con banners de éxito/error.

### Público
- `LandingPage.vue` (+ `LandingHeroMobile.vue`): hero, trust strip, cántaros, sueños, transacciones IA, análisis, comparación Lite/Pro, features grid, CTA.
- `FeaturesPage.vue`: catálogo de features de marketing (Cántaros/Sueños/Transacciones/Análisis/Cuentas&monedas/Lite vs Pro) — **útil como checklist de lo que se PROMETE** vs lo implementado.
- `PricingPage.vue`: 3 planes (Gratis/Plus/Familiar) — nota: "Lite y Pro son modos, no planes", todos los planes incluyen ambos.
- `MatrixPage.vue`: matriz técnica Disponible/Simplificado/No-disponible por sección.
- ⚠️ Inconsistencia detectada: `FeaturesPage` y `MatrixPage` no siempre coinciden en qué está "simplificado" vs "disponible" en Lite (ej. carga masiva) — vale la pena unificar el mensaje en el rediseño.

---

## 10. Deuda técnica y hallazgos críticos (leer antes de portar código al rediseño)

### Componentes huérfanos (no importados en ningún lado — no reflejan el estado actual en producción)
- `components/home/*` (HomeHeroCard, HomeJarsSection, HomeTransactionsSection, HomePeriodSelectorChips/Compact/Tabs) — solo usados en `home_components_showcase.vue` (dev).
- `components/ProSidebar.vue`, `ProTopbar.vue` — AppShell tiene su propio sidebar/topbar inline.
- `components/lite/LiteHeader.vue`, `LiteNavPill.vue`, `ExpandedMenu.vue` — reemplazados por `components/liquid/*`.
- `components/liquid/LiquidJarCard.vue` — desconectado de la lógica real de jars, solo referencia estética.
- `components/transactions/TransactionPalette.vue` — prototipo MVP incompleto (payload sin `account_id`/`payments[]`).
- `components/ai/AutoIaDialog.vue`, `OcrTransactionDialog.vue`, `VoiceTransactionDialog.vue` — reemplazados por tabs integrados en `SmartTransactionModal`, pero tienen mejor UX en algunos detalles (contador de caracteres, advertencia de baja confianza explícita, límite de grabación visible) que vale la pena rescatar.
- `components/TransactionForm.vue` — scaffold genérico de 3 campos, no conectado a ningún flujo real.
- `src/pages/user/settings/index.vue` — huérfano, ninguna ruta lo importa.
- `components/ExchangeRatesWidget.vue` (hallazgo 2026-07-20) — huérfano confirmado por grep global: no se importa/renderiza en ningún lugar. `transactions/index.vue` tiene comentarios/variables con su nombre pero es una UI de tasas construida ad-hoc ahí, no el componente real. La UI de tasas realmente en producción es `ExchangeRatesTable.vue`, usada en `ProHomeView.vue` y `config/index.vue`.

### Features incompletas / solo-UI (no asumir que funcionan)
- **"Gasto compartido"** en `SmartTransactionModal` — UI completa, pero `sharedCats` nunca se envía en el payload de guardado (se descarta en silencio).
- **Adjuntar foto/comprobante** en `SmartTransactionModal` — solo preview local, sin endpoint de subida real (OWF-283).
- **Subir avatar** en `/user/profile` — botón cámara sin función, notifica "próximamente".
- **Selector de periodo en Lite Jars** (Mensual/Semestral/Anual) — no dispara recarga de datos.
- **"Exportar datos"** en Config Lite y "Exportar datos" en menú de cuenta — ambos placeholders.
- **Marcar notificación como leída** — solo local/optimista, no persiste al backend (ni en la página ni en el panel).
- **Reordenar cántaros en Lite** — drag solo visual, no persiste (sí persiste en Pro vía `sort_order`).
- **TTS del flujo de Voz** (`useSpeechSynthesis.ts`, OWF-319 capa 2, añadido 2026-07-19) — el propio commit lo marca explícitamente como *"capa 2 (1/2)"*: hoy solo lee en voz alta la pregunta de cuenta faltante; queda pendiente la segunda mitad del trabajo (alcance no documentado aún al momento de esta auditoría — verificar en `.owf/TASKS.md`/engram antes de asumir que el flujo de voz completo tiene salida de audio en todos sus pasos).

### Flujos triplicados/duplicados (elegir UNA implementación de referencia para el rediseño, no las 3)
- **Detalle de transacción**: `TxDetailModal.vue` (solo Home), modal `OWF-138` inline en `transactions/index.vue` (Pro/Legacy), bottom-sheet en `LiteTransactionsView.vue` — alcance de campos distinto en cada una.
- **Editar transacción**: mini-editor OWF-138 (sin transferencia/comisión/split/items), `TransactionFormDialog.vue` (legacy, sin IA/split/items/shared/comisión, campo "Archivo" es solo texto libre), `SmartTransactionModal.vue` (el completo, al que todos deberían delegar).
- **Ingreso mensual esperado**: editable desde `LiteHomeView` (PUT `/user`) Y desde la sección "Ingreso esperado" (PUT `/user/profile`) — mismo dato, dos endpoints.

### Otras inconsistencias a resolver, no replicar
- Clasificación de "transferencia" difiere entre vistas (Pro la distingue como tercer tipo; Lite la colapsa en "expense").
- `isProMode`/`isLiteLayout` en `SmartTransactionModal` trata "legacy" como "lite" (pierde funcionalidad Pro sin que el usuario lo note).
- `TxDetailModal.vue` conserva CSS muerto de un modo de edición inline ya removido.
- Toggles de notificaciones/idioma en Config se guardan sin feedback de error visible al usuario.

### Cambios recientes ya incorporados en línea (no repetir como "hallazgo nuevo")
Estos 3 commits (mismo día de la auditoría original, sesión posterior) ya están reflejados inline en las secciones 1 y 2 — se listan aquí solo para trazabilidad/changelog:
- `afbb8bd` — OWF-320: comisión "Pago móvil" con piso Bs 2 (antes sin piso) + equivalente en USD por cuenta en el panel de cuentas del Home Pro (sección 1).
- `470d9fc` — OWF-319: fix de guardado de transacción creada por IA que fallaba con *"date field must be a valid date"* (sección 2).
- `87b912c` — OWF-319 capa 2 (1/2): composable `useSpeechSynthesis.ts` para TTS nativo en el flujo de Voz (sección 2, y ver arriba en "Features incompletas" por el alcance parcial declarado por el propio autor).

---

## 11. Inventario de archivos (referencia rápida)

**Páginas de usuario** (`src/pages/user/`): HomeView, ProHomeView, LiteHomeView, home_components_showcase (dev), accounts/index, categories/index, config/index, debts/{index,DebtCard}, dreams/index, expense-analysis/index, financial-profile/index, jars/{index,LiteJarsView}, notifications/index, profile/index, settings/index (huérfano), taxes/index, transactions/{index,LiteTransactionsView,TxDropdown}.

**Auth/Público**: LoginPage, LoginMobileView, RegisterPage, ForgotPasswordPage, ResetPasswordPage, public/{LandingPage, LandingHeroMobile, FeaturesPage, PricingPage, MatrixPage}.

**Admin** (18): admin_dashboard, ai_monitor, account_type, accounts, categories, clients, currencies, item_categories, items, jars, providers, rates, roles, system, taxes, transaction_types, transactions, users/{index,detail}.

**Componentes raíz clave**: SmartTransactionModal, TxDetailModal, TransactionForm(Dialog), TransactionBulkImportDialog, CategorySelector, CrudPage, AccountDialog/ViewerDialog/SidebarWidget/Tree/FilterWidget, CategoryDialog/CategoriesTree, JarCard, AnchoredJarChip, BigJarSidebar, JarsBalanceBar, JarPercentSplitInfo, AdjustmentModal, ExchangeRatesTable/Widget, ExpenseDistributionChart, MonthlyIncomePanel, ChangePasswordCard, NotificationsPanel, OnboardingFlow/Modal, ImpersonationBanner, VersionBadge, PeriodFilterBar, PeriodNavigator.

**Composables relevantes** (no son vistas, pero alimentan comportamiento documentado arriba): `useUserRates` (tasas paralelas, usado en SmartTransactionModal y en el equivalente USD del panel de cuentas Home Pro, OWF-320), `useSpeechSynthesis.ts` (TTS nativo del flujo de Voz, OWF-319 capa 2, nuevo), `useTransactionForm.ts` (auto-asignación de cuenta implícita en Lite).

**Layouts**: AdminLayout, AppShell, MainLayout, PublicLayout.

**Referencia de diseño** (`OWFinanceFrontend2025/rediseno/`, JSX/HTML — ver `views-registry.json` para estado de sync por vista): incluye conceptos aún no portados a Vue — Onboarding como ruta propia, Gamificación, Mascota, Transacciones Pool Unificado (`redesign/`), SettingsScreen dedicado.
