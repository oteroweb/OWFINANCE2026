# Inventario Actual de UI/UX (OW Finance) y Propuesta Lite vs Pro

Este documento hace un "vaciado" de todas las vistas, componentes y widgets existentes actualmente en el repositorio `OWFinanceFrontend2025`, y sugiere una categorización para la nueva experiencia separada en versiones **Lite** y **Pro**.

## 1. Inventario de Vistas (Páginas y Rutas)

Las vistas principales se dividen según los *Layouts* (Admin, User, Auth):

### Autenticación y Públicas
*   **Login Page** (`/login`): Acceso al sistema.
*   **Error 404** ([ErrorNotFound.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/pages/ErrorNotFound.vue)): Pantalla genérica para rutas inexistentes.

### Vistas de Usuario (End-User)
Ubicadas bajo el layout `UserLayout.vue` (`/user/*`):
*   **User Dashboard / Home** ([user_dashboard.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/pages/user/user_dashboard.vue)): Panel principal.
*   **Transacciones** (`transactions/index.vue`): Historial y gestión de gastos/ingresos.
*   **Análisis de Gastos** (`expense-analysis/index.vue`): Gráficas y reportes.
*   **Jarras / Jars** (`jars/index.vue`): Visualización y control de metas de presupuesto.
*   **Cuentas** (`accounts/index.vue`): Listado de cuentas del usuario.
*   **Categorías** (`categories/index.vue`): Gestión de categorías personales.
*   **Impuestos** (`taxes/index.vue`): Impuestos aplicables al usuario.
*   **Configuración** (`config/index.vue`): Ajustes del perfil de usuario.

### Vistas de Administración (Power Users / Admin)
Ubicadas bajo el layout `AdminLayout.vue` (`/admin/*`):
*   **Admin Dashboard** ([admin_dashboard.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/pages/admin/admin_dashboard.vue))
*   **Gestión de Transacciones** (`transactions` y `transactions-old`)
*   **Catálogos Financieros Básicos:** `currencies` (Monedas), `rates` (Tasas de Cambio), `taxes` (Impuestos).
*   **Catálogo de Negocio:** `clients` (Clientes), `providers` (Proveedores), `items` y `item_categories` (Productos/Servicios).
*   **Gestión Estructural:** `users` (Usuarios), `accounts` (Cuentas Globales), `account_type` (Tipos de Cuenta), `jars` y `categories` (Jarras y Categorías Base).

---

## 2. Inventario de Widgets y Componentes (UI Elements)

Ubicados en `src/components`, son las piezas de bloque (building blocks) de las interfaces.

### Transacciones y Formularios
*   [TransactionCreateDialog.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/TransactionCreateDialog.vue) / [TransactionEditDialog.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/TransactionEditDialog.vue) / [TransactionFormDialog.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/TransactionFormDialog.vue) / [TransactionForm.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/TransactionForm.vue): Suite completa de widgets modales y formularios para crear/editar movimientos.
*   [TransactionBulkImportDialog.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/TransactionBulkImportDialog.vue): Modal avanzado para carga masiva de transacciones.
*   [AdjustmentModal.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/AdjustmentModal.vue): Posible ajuste de balances.

### Jarras y Finanzas Visuales
*   [JarCard.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/JarCard.vue): Tarjeta individual de presupuesto (goal vs current).
*   [JarsBalanceBar.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/JarsBalanceBar.vue): Barra de balance global de las jarras (probablemente de distribución porcentual).
*   [BigJarSidebar.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/BigJarSidebar.vue): Sidebar o widget lateral destacado para una jarra principal.

### Analítica y Filtros
*   [ExpenseDistributionChart.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/ExpenseDistributionChart.vue): Gráfica visual de salida de dinero.
*   [MonthlyIncomePanel.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/MonthlyIncomePanel.vue): Panel de métricas de ingreso mensual.
*   [PeriodFilterBar.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/PeriodFilterBar.vue): Barra de control de tiempo (Mes, Año, Rango).

### Gestión de Árboles (Jerarquías)
*   [AccountsTree.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/AccountsTree.vue) / [AccountsSidebarWidget.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/AccountsSidebarWidget.vue): Visualización anidada y compleja de cuentas bancarias/activos.
*   [CategoriesTree.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/CategoriesTree.vue): Visualización jerárquica de categorías de padre/hijo.
*   [AccountDialog.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/AccountDialog.vue) / [AccountViewerDialog.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/AccountViewerDialog.vue) / [CategoryDialog.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/CategoryDialog.vue): Entidades individuales para gestión de nodos del árbol.

### Contenedores y Base
*   [CrudPage.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/CrudPage.vue): Un layout maestro interno que seguramente estandariza tablas de datos, acciones (crear, editar, eliminar) y paginación.
*   [EssentialLink.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/EssentialLink.vue) / [VersionBadge.vue](file:///Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/components/VersionBadge.vue).

---

## 3. Propuesta de Experiencia: Lite vs Pro

Al analizar todos los bloques que existen, se proponen dos versiones de la interfaz para no abrumar al usuario regular promedio, dejando el poder completo a quien lo necesite.

### Versión LITE: "Simple y Directo al Punto"
**Visión:** Un tracker financiero ultra-rápido diseñado para uso primario desde dispositivos móviles, centrado en el día a día. Sin fricción.
*   **Vistas Clave:** 
    *   Dashboard muy visual (Monto total, Gastos del mes, Jarras principales).
    *   Historial de Transacciones (Básico, fácil de buscar).
    *   Ingreso Rápido (Modal simplificado: Monto, Categoría, Descripción).
    *   Detalle de Jarras (Ver qué me queda por gastar).
*   **Widgets Conservados:** `JarCard`, `JarsBalanceBar`, y una versión extremadamente compacta de `TransactionCreateDialog`.
*   **Elementos Ocultos/Eliminados:** Pantallas de Administración, Importación Masiva (`TransactionBulkImportDialog`), Árboles complejos de cuentas (`AccountsTree`), Impuestos, Divisas, Clientes/Proveedores.

### Versión PRO: "Sistema de Inteligencia Financiera Completo"
**Visión:** Una herramienta web robusta (desktop) pensada para finanzas personales avanzadas, contabilidad de freelancers o pequeños negocios.
*   **Vistas Clave:** 
    *   Todo el entorno LITE, expandido.
    *   Expense Analysis profundo con todas las gráficas (`ExpenseDistributionChart`).
    *   Gestores jerárquicos de múltiples cuentas y balances (`AccountsTree`, `CategoriesTree`).
    *   Carga masiva de la tarjeta de crédito (`TransactionBulkImportDialog`).
    *   Acceso a las herramientas de configuración de flujo de caja (Tipos de cuenta, Impuestos, Monedas múltiples).
*   **Público Objetivo:** Usuarios que auditan cada centavo, manejan múltiples bancos interconectados, y requieren herramientas de "Power User" del actual menú de Configuración / Admin.
