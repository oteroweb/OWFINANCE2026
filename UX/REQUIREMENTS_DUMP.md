# OWFinance 2026 — Vaciado Completo de Requerimientos
> Generado: 2026-05-26 | Fuente: Backend API + Frontend Quasar + Stitch Designs + Notion Backlog

---

## 1. FUNCIONES DEL SISTEMA (Features)

### 1.1 Autenticación y Usuarios
- **F-AUTH-01** Login email/password con Sanctum token
- **F-AUTH-02** Registro de usuario (nombre, email, contraseña)
- **F-AUTH-03** Login biométrico (Capacitor NativeBiometric — fingerprint/face)
- **F-AUTH-04** Roles: admin / user / guest con middleware CheckRole
- **F-AUTH-05** Perfil editable (nombre, email, avatar, contraseña)
- **F-AUTH-06** Logout (revoca token)
- **F-AUTH-07** Onboarding modal para usuarios nuevos
- **F-AUTH-08** Redirección por rol post-login (admin→/admin, user→/user/home)

### 1.2 Dashboard / Home
- **F-DASH-01** Balance global en tiempo real (todas las cuentas, todas las monedas)
- **F-DASH-02** Ingreso mensual esperado vs calculado (real)
- **F-DASH-03** Gasto mensual total
- **F-DASH-04** Selector de período (diario/semanal/quincenal/mensual/trimestral/semestral/anual/personalizado)
- **F-DASH-05** Tarjetas de cántaros con barra de progreso visual (asignado/gastado)
- **F-DASH-06** Últimas transacciones (scrollable, paginado)
- **F-DASH-07** Toggle ocultar/mostrar valores (botón ojo)
- **F-DASH-08** Selector de moneda secundaria con tasa de cambio
- **F-DASH-09** Modo dual: Lite (mobile-first) / Pro (desktop) / Legacy
- **F-DASH-10** Panel de estado óptimo (desktop)

### 1.3 Cántaros (Jars) — Núcleo del Sistema
- **F-JAR-01** Crear/editar/eliminar cántaros con nombre, porcentaje/fijo, color
- **F-JAR-02** Asignación porcentual: suma ≤ 100% validada por backend
- **F-JAR-03** Asignación fija: monto absoluto por cántaro
- **F-JAR-04** Modos de refresh: reset (mensual) / acumulativo
- **F-JAR-05** Categorías destino por cántaro (N:M, exclusividad: 1 categoría = max 1 jar)
- **F-JAR-06** Categorías base de ingreso (para cántaros con base_scope=categories)
- **F-JAR-07** Sincronización masiva (bulk-sync): crear/actualizar/eliminar en transacción
- **F-JAR-08** Balance detallado: asignado - gastado + ajustes - retiros ± transferencias
- **F-JAR-09** Ajuste manual de balance (valor objetivo)
- **F-JAR-10** Historial de ajustes por mes
- **F-JAR-11** Reset de ajustes al nuevo período
- **F-JAR-12** Retiros de cántaro con descripción
- **F-JAR-13** Transferencias entre cántaros (from_jar → to_jar)
- **F-JAR-14** Apalancamiento (leverage): tomar prestado de otro cántaro
- **F-JAR-15** Balance negativo configurable (allow_negative_balance + negative_limit)
- **F-JAR-16** Overrides mensuales: cambiar % o monto fijo para un mes específico
- **F-JAR-17** Configuración global: fecha inicio, negativos default, ciclo reset, apalancamiento
- **F-JAR-18** Plantillas de cántaros (JarTemplate): presets predefinidos
- **F-JAR-19** Ahorro teórico: dinero no gastado en jars reset + cuentas de ahorro
- **F-JAR-20** Ahorro acumulado mes a mes (máx 24 meses)
- **F-JAR-21** Resumen de ingresos: esperado vs calculado, desglose por categoría
- **F-JAR-22** Ingreso mensual histórico (UserMonthlyIncomeHistory con lookup fallback)
- **F-JAR-23** Ciclos de cántaro (JarCycle): snapshot mensual para evitar cálculo recursivo
- **F-JAR-24** Configuración mensual: apalancamiento por mes, usar ingreso real

### 1.4 Transacciones
- **F-TXN-01** CRUD completo de transacciones (crear, listar, editar, eliminar)
- **F-TXN-02** Tipos: ingreso / egreso / transferencia
- **F-TXN-03** Asignación a cuenta, categoría, proveedor, tipo
- **F-TXN-04** Balance corrido por cuenta (running balance)
- **F-TXN-05** Filtros avanzados: cuenta, categoría, tipo, período, texto
- **F-TXN-06** Paginación con selector de records por página
- **F-TXN-07** Importación masiva (tabla/excel/texto) con preview
- **F-TXN-08** Líneas de transacción (ItemTransaction): items con cantidad, precio, tax, jar
- **F-TXN-09** Conversión a moneda secundaria
- **F-TXN-10** Soft-delete con restauración
- **F-TXN-11** Toggle activo/inactivo
- **F-TXN-12** Tasa de cambio por transacción (rate_id)
- **F-TXN-13** Split payment: una transacción desde múltiples cuentas (PaymentTransaction)
- **F-TXN-14** Impuestos en líneas de pago (PaymentTransactionTax)
- **F-TXN-15** Impuesto en transacción (amount_tax)
- **F-TXN-16** Flag include_in_balance por transacción

### 1.5 Cuentas
- **F-ACC-01** CRUD de cuentas con nombre, moneda, tipo, balance inicial
- **F-ACC-02** Tipos de cuenta (AccountType): efectivo, banco, tarjeta, etc.
- **F-ACC-03** Carpetas jerárquicas (AccountFolder) con drag-and-drop
- **F-ACC-04** Árbol de cuentas (tree view)
- **F-ACC-05** Balance global (todas las cuentas, conversión a moneda base)
- **F-ACC-06** Recálculo de balance desde inicial + transacciones
- **F-ACC-07** Ajuste manual de balance
- **F-ACC-08** Reordenar cuentas (batch sort)
- **F-ACC-09** Mover cuenta entre carpetas
- **F-ACC-10** Flag include_in_global_balance
- **F-ACC-11** Multi-moneda: cada cuenta tiene su moneda + conversión

### 1.6 Categorías
- **F-CAT-01** CRUD con nombre, icono, tipo (ingreso/egreso)
- **F-CAT-02** Árbol jerárquico con parent/children
- **F-CAT-03** Drag-and-drop para reordenar/mover
- **F-CAT-04** Asignación a cántaro (exclusiva)
- **F-CAT-05** Reset de categorías del usuario
- **F-CAT-06** Flag include_in_balance

### 1.7 Monedas y Tasas
- **F-CUR-01** CRUD de monedas (nombre, símbolo, código, alineación)
- **F-CUR-02** Tasas de cambio globales (Rate)
- **F-CUR-03** Tasas de cambio por usuario (UserCurrency)
- **F-CUR-04** Marcar tasa actual y tasa oficial
- **F-CUR-05** Sincronización tasa BCV automática 2x/día (CRON pendiente)
- **F-CUR-06** Sistema dual BCV + Binance P2P

### 1.8 Análisis y Reportes
- **F-RPT-01** Análisis de gastos por jar/categoría/cuenta/tipo
- **F-RPT-02** Gráfico de distribución donut
- **F-RPT-03** Filtros múltiples con chips seleccionables
- **F-RPT-04** Conversión a moneda base automática
- **F-RPT-05** Tasa de ahorro
- **F-RPT-06** Stacked bar chart: meta vs real por categoría

### 1.9 Inteligencia Artificial
- **F-AI-01** Chat con asesor financiero (SSE streaming)
- **F-AI-02** Extracción de transacción desde texto (NLP)
- **F-AI-03** Extracción desde voz (Whisper → NLP)
- **F-AI-04** Extracción desde imagen/OCR (recibo/factura)
- **F-AI-05** Auto-detección inteligente de transacción
- **F-AI-06** Contexto financiero del usuario inyectado en system prompt
- **F-AI-07** Historial de conversaciones (AiConversation + Messages)
- **F-AI-08** Budget mensual de tokens IA (500K input, middleware con 429)
- **F-AI-09** Log de uso IA por feature/provider/modelo
- **F-AI-10** Configuración IA: nombre asesor, personalidad, voz/OCR/auto activos

### 1.10 Configuración
- **F-CFG-01** Perfil de usuario
- **F-CFG-02** Modo layout: Lite / Pro / Legacy
- **F-CFG-03** Moneda default
- **F-CFG-04** Tasas de cambio personalizadas
- **F-CFG-05** Ingreso mensual esperado
- **F-CFG-06** Gestión de categorías (tab integrado)
- **F-CFG-07** Gestión de cuentas (tab integrado)
- **F-CFG-08** Gestión de impuestos (tab integrado)

### 1.11 Proveedores y Clientes
- **F-PRO-01** CRUD de proveedores (nombre, dirección, email, teléfono, web)
- **F-PRO-02** CRUD de clientes

### 1.12 Items y Productos
- **F-ITM-01** CRUD de items (nombre, último precio, categoría, tax)
- **F-ITM-02** Categorías de items jerárquicas
- **F-ITM-03** Impuestos configurables por item

### 1.13 Administración (Admin)
- **F-ADM-01** CRUD completo de todas las entidades (modo admin)
- **F-ADM-02** Gestión de usuarios (crear, editar, toggle status, soft-delete)
- **F-ADM-03** Panel admin placeholder
- **F-ADM-04** Dictionary-driven pages (CRUD configurable)

### 1.14 Mobile (Capacitor)
- **F-MOB-01** Build Android APK
- **F-MOB-02** Login biométrico nativo
- **F-MOB-03** PWA installable

---

## 2. ELEMENTOS DEL SISTEMA (Componentes UI)

### 2.1 Navegación
- **E-NAV-01** Bottom Navigation (5 tabs: Home, Cántaros, +, Transacciones, Perfil)
- **E-NAV-02** Sidebar (modo Pro, desktop)
- **E-NAV-03** Top Bar (balance, avatar, selector moneda)
- **E-NAV-04** Header Liquid (balance principal, toggle visibilidad)
- **E-NAV-05** FAB (+) — Botón flotante acción rápida
- **E-NAV-06** Menú expandido de navegación
- **E-NAV-07** Essential links (menú lateral)

### 2.2 Cards y Displays
- **E-CRD-01** Hero Card (balance global, ingreso, gasto)
- **E-CRD-02** Jar Card (barra progreso, nombre, monto asignado/gastado)
- **E-CRD-03** Balance Card (balance de un cántaro con color)
- **E-CRD-04** Transaction Item (ícono categoría, concepto, monto coloreado)
- **E-CRD-05** Monthly Income Panel (esperado vs real)
- **E-CRD-06** Glass Card (glassmorphism fluido)
- **E-CRD-07** Version Badge

### 2.3 Formularios y Dialogs
- **E-FRM-01** Transaction Form (concepto, monto, fecha, cuenta, categoría, tipo)
- **E-FRM-02** Transaction Create/Edit Dialog
- **E-FRM-03** Bulk Import Dialog (tabla editable, preview)
- **E-FRM-04** Adjustment Modal (valor objetivo para cántaro)
- **E-FRM-05** Account Dialog (crear/editar cuenta)
- **E-FRM-06** Category Dialog (crear/editar categoría)
- **E-FRM-07** OCR Dialog (captura → extracción → prefill)
- **E-FRM-08** Voice Dialog (grabar → transcripción → prefill)
- **E-FRM-09** Quick Action Sheet (bottom sheet de acciones rápidas)
- **E-FRM-10** Onboarding Modal
- **E-FRM-11** Account Viewer Dialog

### 2.4 Visualizaciones
- **E-VIS-01** Expense Distribution Chart (donut)
- **E-VIS-02** Balance Bar (barra de balance jars)
- **E-VIS-03** Period Filter Bar
- **E-VIS-04** Simple CSS Chart
- **E-VIS-05** Stacked Bar Chart (meta vs real) — *pendiente implementar*

### 2.5 Layouts
- **E-LAY-01** Main Layout (auth)
- **E-LAY-02** Admin Layout (sidebar + header)
- **E-LAY-03** Dynamic Role Layout (selector Lite/Pro/Legacy)
- **E-LAY-04** Lite Mobile Layout (header + bottom nav)
- **E-LAY-05** Lite Desktop Layout (header + bottom nav desktop)
- **E-LAY-06** Pro Layout (sidebar amplio + topbar)

### 2.6 Elementos UI Base
- **E-UI-01** Spring Button (animación spring)
- **E-UI-02** Glass FAB (glassmorphism)
- **E-UI-03** Swipeable Bottom Sheet
- **E-UI-04** Category Chip
- **E-UI-05** Period Selector Chips/Tabs/Compact
- **E-UI-06** Transaction Palette (toggle ingreso/egreso/transferencia)
- **E-UI-07** Accounts Sidebar Widget

---

## 3. VISTAS DEL SISTEMA (Screens)

### 3.1 Autenticación
- **V-AUTH-01** Login (email + password + bio)
- **V-AUTH-02** Register (nombre + email + contraseña)

### 3.2 Home / Dashboard
- **V-HOME-01** Dashboard Lite Mobile (Hero + Jars + Transacciones recientes)
- **V-HOME-02** Dashboard Lite Desktop (similar con más espacio)
- **V-HOME-03** Dashboard Pro Desktop (sidebar, grids densos, métricas)
- **V-HOME-04** Dashboard Pro Light Mode
- **V-HOME-05** Home Components Showcase

### 3.3 Cántaros
- **V-JAR-01** Lista de Cántaros (cards con progreso, totales)
- **V-JAR-02** Detalle de Cántaro (balance exacto, historial, ajustes)
- **V-JAR-03** Configuración Global de Jars (fecha inicio, negativos, ciclo)
- **V-JAR-04** Ajuste de Balance (modal valor objetivo)
- **V-JAR-05** Apalancamiento (desde/hacia, monto)
- **V-JAR-06** Overrides Mensuales (tabla editable)
- **V-JAR-07** Transferencia entre Jars

### 3.4 Transacciones
- **V-TXN-01** Lista de Transacciones (tabla paginada, filtros, balance corrido)
- **V-TXN-02** Crear/Editar Transacción (dialog completo)
- **V-TXN-03** Importar Masivo (tabla editable + preview)
- **V-TXN-04** Transacciones Mobile Lite (cards anchas con monto coloreado)
- **V-TXN-05** Transacciones Pro Super Grid

### 3.5 Análisis
- **V-ANL-01** Análisis de Gastos (donut, filtros chips, desglose)
- **V-ANL-02** Reportes Pro (stacked bars, tasa ahorro, meta vs real)

### 3.6 Cuentas
- **V-ACC-01** Árbol de Cuentas (folders + cuentas, drag-and-drop)
- **V-ACC-02** Crear/Editar Cuenta (dialog)
- **V-ACC-03** Detalle de Cuenta (balance, transacciones)

### 3.7 Categorías
- **V-CAT-01** Árbol de Categorías (jerárquico, drag-and-drop, mapeo jar)
- **V-CAT-02** Crear/Editar Categoría (dialog)

### 3.8 IA / Asesor
- **V-AI-01** Chat Asesor IA (streaming, sugerencias predefinidas)
- **V-AI-02** Extracción OCR (cámara → análisis → prefill)
- **V-AI-03** Extracción Voz (micrófono → transcripción → prefill)
- **V-AI-04** Auto-detección IA

### 3.9 Configuración
- **V-CFG-01** Perfil (nombre, email, avatar, contraseña)
- **V-CFG-02** Finanzas (moneda, tasas, ingreso mensual)
- **V-CFG-03** Layout Mode (selector Lite/Pro/Legacy)
- **V-CFG-04** Impuestos
- **V-CFG-05** Settings Pro Desktop

### 3.10 Quick Actions
- **V-QCK-01** Quick Add Modal (acción rápida FAB)
- **V-QCK-02** Bottom Sheet de Acciones Rápidas

### 3.11 Admin
- **V-ADM-01** Panel Admin (placeholder)
- **V-ADM-02→14** CRUD Admin (users, accounts, currencies, categories, jars, transactions, rates, providers, items, taxes, clients, item_categories, account_types)

---

## 4. ENTIDADES DEL SISTEMA (Data Model)

### 4.1 Core
- User, Role, UserSetting
- Account, AccountType, AccountFolder, AccountTax
- Currency, Rate, UserCurrency
- Category, TransactionType
- Transaction, ItemTransaction, PaymentTransaction, PaymentTransactionTax
- Tax, Item, ItemCategory, ItemTax
- Provider, Client

### 4.2 Jars (Dominio Principal)
- Jar, JarSetting, JarAdjustment, JarWithdrawal, JarTransfer
- JarCycle, JarMonthlyOverride, JarLeverageSetting
- JarTemplate, JarTemplateJar

### 4.3 IA
- AiConversation, AiConversationMessage
- AiExtraction, AiUsageLog, AiUserSetting

### 4.4 Historial
- UserMonthlyIncomeHistory

---

## 5. ESTADO ACTUAL vs PENDIENTE

### ✅ Implementado
- Auth completo (login, register, bio, roles)
- CRUD completo de 23 entidades
- Sistema de Cántaros con 24 sub-funciones
- 3 modos de layout (Lite/Pro/Legacy)
- Chat IA con streaming
- Dashboard con balance global
- Transacciones con filtros avanzados e importación masiva
- Análisis de gastos con donut chart
- Mobile Capacitor (Android)
- Deploy CI/CD (GitHub Actions)

### ❌ Crítico Pendiente
- **OFB-58** Securizar rutas API (14 endpoints sin auth:sanctum)
- **OFB-51** Git hygiene inicial
- **OFB-37** Cron tasa BCV 2x/día
- **OFB-60** Tests E2E (0 tests frontend)

### 🔄 En Progreso
- **OFB-46** FAB Bottom Sheet Lite
- **OFB-35** Integración ProLayout

### 📋 Backlog Diseño/UI
- Rediseño completo con herramienta de diseño (Stitch vs Claude Design vs OpenDesign)
- Pantallas de deuda bidireccional
- Pantallas crypto (interés compuesto)
- Pantallas Cashea/BNPL
- Pantalla de sueños/metas en perfil
- Pantalla de obstáculos/fricciones en perfil
- Detección de patrones de gasto
- Evaluación de Theme Factory

---

## 6. DESIGN SYSTEM ACTUAL (Stitch — Liquid Glass Unified)

**Paleta:**
- Primary: `#006591` (azul profundo)
- Container: `#0EA5E9` (azul cielo)
- Accent: `#DE8712` (gold/ámbar)
- Gastos: `#EF4444` (rojo)
- Ingresos: `#10B981` (verde)
- Fondo: `#0F172A` (dark mode)
- Glass: `rgba(15,23,42,0.8)` + `backdrop-filter: blur(16px)`

**Tipografía:** Manrope (headings) + Inter (body)

**Estilo:** Glassmorphism con bordes redondeados 24-32px, botones pill-shaped

**17 pantallas Stitch disponibles en:** `stitch_ow_finance_2026_master_ui_definitivo/`

---

## 7. PRÓXIMOS PASOS — RECOMENDACIÓN

1. **Evaluar Claude Design y OpenDesign** contra Stitch actual
2. **Generar pantallas nuevas** con la herramienta ganadora:
   - Deuda bidireccional
   - Crypto/BNPL
   - Sueños/Metas
   - Patrones de gasto
3. **Unificar design system** en tokens exportables (colores, tipografía, spacing)
4. **Priorizar bugs críticos** antes del rediseño visual
5. **Integrar MCPs** (Stitch + Notion) para flujo automatizado diseño→implementación

> *Este documento es la base para la sesión de diseño. Cada sección puede refinarse independientemente.*
