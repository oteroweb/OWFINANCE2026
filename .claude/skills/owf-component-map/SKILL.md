# Skill: owf-component-map — Mapa de Componentes OWFinance Frontend

**Referencia rápida de todos los componentes Vue, páginas, stores y sus interconexiones.**
Última actualización: 2026-07-08

---

## Regla de uso

Leer este skill ANTES de tocar cualquier componente de UI. Evita duplicar lógica que ya existe
y permite saber qué se rompe si cambias algo.

---

## Arquitectura general

```
src/
├── layouts/          ← Shells globales (AppShell, Main, Public, Admin)
├── components/       ← Componentes reutilizables (~60 archivos)
│   ├── (raíz)        ← Diálogos y widgets principales
│   ├── ai/           ← Modales de IA (Voz, OCR, AutoIA)
│   ├── home/         ← Secciones del home (Hero, Jars, Transactions, Periods)
│   ├── liquid/       ← Kit design system Liquid (nav, cards, FAB, sheets)
│   ├── lite/         ← Nav y header del modo Lite
│   ├── transactions/ ← Palette de etiquetas de transacciones
│   └── ui/           ← Primitivas UI (glass card, spring button, swipeable sheet)
├── pages/            ← 57 vistas
│   ├── user/         ← App principal
│   ├── admin/        ← Panel administración (18 CRUDs)
│   └── public/       ← Landing, features, precios
└── stores/           ← 7 stores Pinia
```

---

## Stores Pinia (7)

| Store | Archivo | Usado por |
|-------|---------|-----------|
| `useAuthStore` | `stores/auth.ts` | Layout, AppShell, LiteHomeView, ProHomeView, config, profile |
| `useUiStore` | `stores/ui.ts` | AppShell, SmartTransactionModal, QuickActionSheet, LiquidFAB, transacciones, jars |
| `useTransactionsStore` | `stores/transactions.ts` | transactions/index, TxDetailModal, SmartTransactionModal, FormDialog |
| `useTransactionTypesStore` | `stores/transactionTypes.ts` | SmartTransactionModal, transactions/index |
| `useTagsStore` | `stores/tags.ts` | SmartTransactionModal |
| `useJarsStore` | `stores/jars.ts` | jars/index, LiteJarsView |
| `usePeriodStore` | `stores/period.ts` | PeriodNavigator, expense-analysis, transactions/index |

**Señal global de apertura del modal principal:** `ui.showSmartModal = true` (+ `ui.smartModalTab`, `ui.smartModalType`)

---

## Componentes — Raíz (`src/components/`)

### Transacciones

| Componente | Rol | Props clave | Emits | Usado por |
|-----------|-----|------------|-------|-----------|
| **SmartTransactionModal** | Modal global para CREAR transacciones — tabs Escribir/Voz/Foto/AutoIA/Carga masiva | (ninguno — controlado por `useUiStore`) | `@saved` | AppShell (único lugar, global) |
| **TxDetailModal** | Modal para VER + EDITAR + ELIMINAR una transacción existente. Rediseñado. | `txId: number\|null`, `layoutMode: 'lite'\|'pro'` | `@saved`, `@deleted` | ProHomeView, LiteHomeView |
| **TransactionFormDialog** | Dialog viejo de edición (legacy — a deprecar). Usa q-dialog maximized. | `id?: number\|null`, `v-model: boolean` | (cierra via ui store) | transactions/index (en tabla), components/index barrel |
| **TransactionForm** | Sub-form embebido ligero (60 líneas) | `modelValue`, varios props | `update:modelValue` | TransactionFormDialog |
| **TransactionBulkImportDialog** | Dialog importación masiva CSV | `v-if` show | `@close`, `@imported` | transactions/index |
| **TfReviewCard** | Tarjeta de revisión dentro de SmartTransactionModal | varios computed del padre | — | SmartTransactionModal (inline) |
| **AnchoredJarChip** | Muestra el cántaro derivado de una categoría (solo lectura, nunca editable) | `categoryId: number\|null`, `compact?: boolean` | — | SmartTransactionModal, TxDetailModal, TransactionFormDialog, transactions/index |
| **CategorySelector** | Dropdown de categorías agrupadas por cántaro | `modelValue: number\|null`, `allowNull`, `placeholder` | `update:modelValue` | SmartTransactionModal, TxDetailModal, TransactionFormDialog |

> **REGLA**: El cántaro NUNCA se selecciona manualmente. Siempre viene anclado vía `AnchoredJarChip` derivado de `categoryId`.

### Cuentas

| Componente | Rol | Props clave | Usado por |
|-----------|-----|------------|-----------|
| **AccountDialog** | CRUD de cuentas (crear/editar) | `v-model`, `accountId?` | accounts/index |
| **AccountViewerDialog** | Ver detalle de una cuenta | `accountId`, `v-model` | accounts/index, transactions/index |
| **AccountFilterWidget** | Filtro de cuentas para tabla de transacciones | `modelValue`, varios | transactions/index |
| **AccountsSidebarWidget** | Panel lateral de cuentas — listado, balance, deudas (750 líneas, heavyweight) | `v-model:show` | transactions/index |
| **AccountsTree** | Árbol drag-and-drop de cuentas (844 líneas) | — | accounts/index |
| **AdjustmentModal** | Modal de ajuste de saldo por cuenta | `v-model`, `accountId` | accounts/index |

### Cántaros

| Componente | Rol | Usado por |
|-----------|-----|-----------|
| **JarCard** | Tarjeta de cántaro con progreso | LiteJarsView, jars/index |
| **JarsBalanceBar** | Barra de progreso multi-cántaro | jars/index |
| **JarPercentSplitInfo** | Info de porcentaje de distribución | jars/index |
| **BigJarSidebar** | Panel lateral detalle de cántaro | jars/index |
| **ExchangeRatesWidget** | Widget editable de tasas de cambio | ProHomeView |
| **ExchangeRatesTable** | Tabla CRUD de tasas (bloque unificado config Pro) | user/config/index |
| **MonthlyIncomePanel** | Panel de ingreso mensual esperado | user/config/index |

### Categorías

| Componente | Rol | Usado por |
|-----------|-----|-----------|
| **CategoryDialog** | CRUD categorías | user/categories/index |
| **CategoriesTree** | Árbol de categorías | user/categories/index |

### Análisis / Charts

| Componente | Rol | Usado por |
|-----------|-----|-----------|
| **ExpenseDistributionChart** | Gráfica distribución de gastos por categoría | expense-analysis/index |
| **ui/simple-css-chart** | Barra CSS pura (sin deps) | varios |

### Notificaciones / Onboarding

| Componente | Rol | Usado por |
|-----------|-----|-----------|
| **NotificationsPanel** | Panel popover de notificaciones con API real | AppShell |
| **OnboardingFlow** | Flujo de onboarding multi-paso | AppShell (post-registro) |
| **OnboardingModal** | Modal legacy de onboarding | (verificar si activo) |
| **ImpersonationBanner** | Banner de modo impersonation (admin) | AppShell/Admin |
| **VersionBadge** | Badge de versión de app | (huérfano — verificar) |

### Periodo

| Componente | Rol | Usado por |
|-----------|-----|-----------|
| **PeriodNavigator** | Navegación de periodo (mes anterior/siguiente) | transactions/index, expense-analysis |
| **PeriodFilterBar** | Barra de filtro de periodo | (verificar uso) |

### CrudPage

| Componente | Rol | Usado por |
|-----------|-----|-----------|
| **CrudPage** | Base genérica para todas las vistas CRUD admin (17 importaciones) | 18 páginas admin |

---

## Subcarpetas de componentes

### `/ai/`

| Componente | Rol | Abierto desde |
|-----------|-----|--------------|
| **AutoIaDialog** | Dialog de entrada de texto libre → AI categoriza | SmartTransactionModal (tab autoai) |
| **OcrTransactionDialog** | Dialog foto/OCR de factura | SmartTransactionModal (tab photo) |
| **VoiceTransactionDialog** | Dialog grabación de voz → transcripción IA | SmartTransactionModal (tab voice) |

### `/home/`

| Componente | Rol | Usado por |
|-----------|-----|-----------|
| **HomeHeroCard** | Card principal del home Lite (balance + periodo) | LiteHomeView |
| **HomeJarsSection** | Sección de cántaros en home Lite | LiteHomeView |
| **HomeTransactionsSection** | Sección de movimientos recientes en home Lite | LiteHomeView |
| **HomePeriodSelectorChips** | Chips de selección de periodo | LiteHomeView |
| **HomePeriodSelectorCompact** | Versión compacta del selector | LiteHomeView |
| **HomePeriodSelectorTabs** | Tabs de periodo | LiteHomeView |

### `/liquid/` — Design System "Liquid"

| Componente | Rol | Usado por |
|-----------|-----|-----------|
| **BottomNavMobile** | Nav inferior mobile (Lite) | layouts |
| **LiteFloatingBottomNav** | FAB + nav flotante (Lite mobile) | LiteHomeView |
| **LiteHeaderDesktop** | Header desktop del modo Lite | AppShell |
| **LiquidBalanceCard** | Card de balance estilo "liquid" | LiteHomeView |
| **LiquidCategoryChip** | Chip de categoría estilo liquid | LiteTransactionsView |
| **LiquidFAB** | Floating Action Button (abre SmartTransactionModal) | layouts/AppShell |
| **LiquidJarCard** | Tarjeta de cántaro estilo liquid | LiteHomeView, LiteJarsView |
| **LiquidTransactionItem** | Item de transacción estilo liquid | LiteTransactionsView |
| **QuickActionSheet** | Bottom sheet de acción rápida (Paso 1 de crear tx) — abre SmartTransactionModal | AppShell, LiquidFAB |
| **ExpandedNavigationMenuLight** | Menú lateral expandido (desktop, Lite) | AppShell |
| **DesktopEstadoOptimoPanel** | Panel "Estado óptimo" sidebar desktop | ProHomeView (desktop) |

### `/lite/`

| Componente | Rol | Usado por |
|-----------|-----|-----------|
| **LiteHeader** | Header mobile del modo Lite | layouts |
| **LiteNavPill** | Pill nav inferior del modo Lite | layouts |
| **ExpandedMenu** | Menú expandido del modo Lite | layouts |

### `/transactions/`

| Componente | Rol | Usado por |
|-----------|-----|-----------|
| **TransactionPalette** | Palette de etiquetas/tags (Comisión, Planificado, etc.) | SmartTransactionModal |

### `/ui/`
Primitivas puras sin lógica de negocio: `glass-fab`, `glass-fluid-card`, `simple-css-chart`, `spring-button`, `swipeable-bottom-sheet`.

---

## Páginas principales (`src/pages/user/`)

| Vista | Ruta | Componentes clave usados |
|------|------|--------------------------|
| **HomeView** | `/user/home` | Enruta a LiteHomeView o ProHomeView según `layout_mode` |
| **LiteHomeView** | (cargada por HomeView) | HomeHeroCard, HomeJarsSection, HomeTransactionsSection, TxDetailModal |
| **ProHomeView** | (cargada por HomeView) | ExchangeRatesWidget, TxDetailModal, DesktopEstadoOptimoPanel |
| **transactions/index** | `/user/transactions` | AccountFilterWidget, AccountsSidebarWidget, TransactionFormDialog, PeriodNavigator, CategorySelector, AnchoredJarChip |
| **LiteTransactionsView** | (embed en transactions) | LiquidTransactionItem, LiquidCategoryChip |
| **jars/index** | `/user/jars` | JarCard, JarsBalanceBar, BigJarSidebar |
| **LiteJarsView** | (embed en jars) | LiquidJarCard |
| **accounts/index** | `/user/accounts` | AccountDialog, AccountViewerDialog, AccountsTree, AdjustmentModal |
| **config/index** | `/user/config` | ExchangeRatesTable, MonthlyIncomePanel + bloque inline masivo |
| **expense-analysis/index** | `/user/expense-analysis` | ExpenseDistributionChart, PeriodNavigator |
| **financial-profile/index** | `/user/financial-profile` | JarPercentSplitInfo |
| **notifications/index** | `/user/notifications` | (standalone, API directa) |
| **AsesorPage** | `/user/asesor` | (standalone, AI chat) |

---

## Layouts y AppShell

| Layout | Monta |
|--------|-------|
| **AppShell** | Header Pro/Lite, SmartTransactionModal (GLOBAL — 1 sola instancia), NotificationsPanel, QuickActionSheet, OnboardingFlow, ImpersonationBanner, LiquidFAB |
| **MainLayout** | Wrap básico para páginas user con AppShell |
| **PublicLayout** | Header público + footer |
| **AdminLayout** | Sidebar admin + rutas /admin/* |

> **IMPORTANTE**: `SmartTransactionModal` está montado UNA SOLA VEZ en AppShell.
> Para abrir: `useUiStore().openSmartModal(tab, type)` desde cualquier página.
> Para editar una tx existente: usar `TxDetailModal` localmente en la página.

---

## Flujo de creación de transacción

```
Usuario pulsa FAB / botón +
        ↓
QuickActionSheet (Paso 1)
  "¿Qué quieres registrar?" → tipo (Gasto/Ingreso/Transferir)
  "¿Cómo lo querés ingresar?" → método (Escribir/Voz/Foto/AutoIA)
        ↓
ui.openSmartModal(tab, type)
        ↓
SmartTransactionModal (Paso 2) — global en AppShell
  • Escribir → form inline (monto, cuenta, categoría → AnchoredJarChip, proveedor, fecha, etiquetas, toggles)
  • Voz → VoiceTransactionDialog
  • Foto → OcrTransactionDialog
  • AutoIA → AutoIaDialog
  • Carga masiva → TransactionBulkImportDialog
        ↓
POST /api/v1/transactions → emite @saved → páginas recargan
```

## Flujo de edición de transacción

```
Click en tx (ProHomeView / LiteHomeView "Movimientos recientes")
        ↓
TxDetailModal (local en la página)
  Modo vista → detalle completo
  Click "Editar" → modo edición (CategorySelector + AnchoredJarChip)
  Click "Eliminar" → confirm inline
        ↓
PATCH / DELETE /api/v1/transactions/:id → emite @saved/@deleted → lista recarga
```

---

## Barrel de exports (`components/index.ts`)

Solo 4 componentes exportados globalmente (disponibles vía `import { X } from 'components'`):
- `AccountsSidebarWidget`
- `ExpenseDistributionChart`
- `TransactionFormDialog`
- `TxDetailModal`

El resto se importa con ruta relativa directa.

---

## Hub nodes (componentes más usados)

1. **CrudPage** — 18 páginas admin
2. **AnchoredJarChip** — 5 lugares (SmartTransactionModal, TxDetailModal, TransactionFormDialog, transactions/index, CategorySelector)
3. **CategorySelector** — 4 lugares
4. **TxDetailModal** — ProHomeView, LiteHomeView (y potencialmente más)

## Componentes posiblemente huérfanos (verificar)

- `VersionBadge` — no aparece importado en ninguna página activa
- `EssentialLink` — componente de template Quasar, no usado
- `PeriodFilterBar` — uso no confirmado
- `OnboardingModal` — duplicado con OnboardingFlow?
- `ProSidebar` — legado? reemplazado por DesktopEstadoOptimoPanel

---

## Gotchas críticos

1. **TransactionFormDialog es legacy** — tiene UI vieja (q-bar azul, campos en columnas). Se mantiene en transactions/index para la tabla. Usar `TxDetailModal` para UX nueva.
2. **SmartTransactionModal controla su propio estado via useUiStore** — NO recibe props de visibilidad.
3. **AppShell monta SmartTransactionModal una sola vez** — cualquier otra instancia causa conflicto de store.
4. **El cántaro NUNCA se selecciona manual** — siempre `AnchoredJarChip` derivado de `category_id`.
5. **txCatalog.ts** debe cargarse antes de cualquier lookup de jar/categoria: `loadCategoriesWithJars()` + `loadUserJars()`.
