# Panorama 360 — OWFINANCE 2026

> **Punto único para ver y entender TODO el proyecto**: qué es, la experiencia de usuario,
> todas las pantallas y funciones, y dónde vive cada detalle. Si solo vas a leer un documento,
> es este; los enlaces te llevan al detalle.
> Última actualización: 2026-06-02.

---

## 1. Qué es OWFINANCE 2026

App de **finanzas personales premium** que funciona como un **coach/asesor financiero
inteligente**. Su método central es el de **Cántaros (Jars)**: cada cántaro es una categoría de
presupuesto que recibe un % del ingreso; el usuario reparte el **100%** de su ingreso ("cada
dólar tiene un trabajo").

- **Doble audiencia / dos modos**: **LITE** (simple, mobile, foco en facilidad) y **PRO**
  (control total, desktop denso). Mismo design system, distinta densidad y profundidad.
- **Stack**: Laravel 12 + Sanctum (API `/api/v1`) · Quasar 2 + Vue 3 + TS · Capacitor (móvil).
- **IA integrada**: asesor por chat, registro por voz, OCR de facturas, extracción
  multi-proveedor.

Detalle: `MODELO_CANTAROS.md` · `MODOS_LITE_VS_PRO.md`.

---

## 2. Propuesta de valor / para quién

| Perfil | Necesidad | Modo |
|--------|-----------|------|
| Quiere ordenarse sin fricción | Registrar rápido, ver cuánto le queda por cántaro | **LITE** |
| Quiere control total | Trackear cuentas, multimoneda, deudas, analítica, bulk | **PRO** |

El onboarding detecta el perfil y adapta categorías, cántaros y complejidad de la interfaz.

---

## 3. Experiencia de usuario (resumen)

> Descripción exhaustiva (micro-interacciones incluidas): `../ui-ux/04-current-state-human-describe.md`.

**Constantes en toda la app:**
- **Selector multimoneda** en el header (chips de divisas; editar tasa al vuelo y reconvierte todo).
- **Barra de período global**: `Todo | Anual | Semestral | Trimestral | Mensual | Quincenal |
  Semanal | Diario | Personalizado`, con `←/→` y swipe en móvil. Filtra **toda** la pantalla.
- **Barra de cántaros flotante**: disponible de cada cántaro siempre visible.
- **Smart Add (super botón)**: Gasto / Ingreso / Transferencia / Deuda + inputs IA (voz, OCR,
  texto plano).
- **Chat IA flotante**: estatus de cántaros, anomalías de gasto, registrar dictando.
- **Navegación**: sidebar (PRO, con drag&drop para reordenar) / bottom nav (LITE).

**Recorrido típico (LITE):** abrir → ver cántaros con saldo → Smart Add → monto + cántaro →
listo. **(PRO):** dashboard → período → cuenta → transacción avanzada (split/items/tasa) →
analítica.

---

## 4. Mapa de pantallas (rutas reales)

### Usuario (`/user/*`, layout dinámico LITE/PRO/Legacy)
| Pantalla | Ruta | Función |
|----------|------|---------|
| Home / Dashboard | `/user/home` | Resumen, cántaros, accesos rápidos (LiteHomeView; ProHomeView ⬜) |
| Transacciones | `/user/transactions` | Historial, filtros, alta/edición, bulk |
| Análisis de gastos | `/user/expense-analysis` | Gráficas y reportes (ECharts) |
| Cántaros | `/user/jars` | Ver/editar cántaros, metas, transferencias, leverage |
| Cuentas | `/user/accounts` | Cuentas, carpetas, saldos (PRO) |
| Categorías | `/user/categories` | Gestión de categorías |
| Impuestos | `/user/taxes` | Impuestos del usuario |
| Configuración | `/user/config` | Perfil, modo, preferencias |
| Asesor IA | `/user/asesor` | Chat con el asesor financiero |

### Admin (`/admin/*`, power users)
Transacciones, currencies, clients, users, account_type, accounts, taxes, item_categories,
items, jars, categories, rates, providers. (CRUD maestro vía `CrudPage.vue`.)

### Auth / públicas
Login (`/login`), 404 (`ErrorNotFound.vue`).

> Inventario UI completo: `../ui-ux/02-current-ui-inventory-and-architecture.md`.

---

## 5. Catálogo de funciones (qué hace el sistema)

### 5.1 Cántaros
Reparto por % o monto fijo · base all-income o por categorías · meta de ahorro
(`target_amount`) · ajustes manuales · retiros · transferencias entre cántaros · apalancamiento
(leverage) · ciclos mensuales con arrastre (carry-over) y déficit · plantillas (55/10/10/10/10).
→ `MODELO_CANTAROS.md`

### 5.2 Cuentas
Tipos: banco, tarjeta de crédito, efectivo, cashea (+ inversión/pasivos) · carpetas
(líquido / patrimonio / deuda) · multimoneda (USD/EUR/VES) · saldo cacheado · cuentas
compartidas · impuestos por cuenta. → `CUENTAS_Y_TRANSACCIONES.md`

### 5.3 Transacciones (modelo unificado `payments[]` + `items[]`)
Ingreso · gasto · transferencia (incl. cross-currency con tasa) · pago múltiple (split en varias
cuentas) · factura con ítems (cantidad + impuestos por línea) · ajuste · carga masiva (bulk con
dry-run) · deudas/cuotas (wizard). → `FLUJOS_TRANSACCIONES.md`

### 5.4 Impuestos y tasas
IGTF 3% · comisión pago móvil · impuestos por ítem/cuenta · tasa actual/oficial · conversión a
moneda del usuario. → (pendiente doc dedicado `IMPUESTOS.md`, `MONEDAS_Y_TASAS.md`)

### 5.5 IA
Asesor por chat · registro por voz · OCR de facturas · extracción multi-proveedor (anthropic /
gemini / openai / groq) · presupuesto de tokens y rate limiting. → (pendiente `IA_FEATURES.md`)

### 5.6 Analítica y período
Filtro temporal global · análisis de gastos · reportes · resumen por cántaro/cuenta.

### 5.7 Plataforma
Auth Sanctum (login/register con throttle, biometría móvil) · roles (admin/user) · modo
LITE/PRO/Legacy · i18n (hoy solo en-US) · modo oscuro/temas (a afinar, TECH-004) · móvil
(Capacitor: cámara, push, biometría).

---

## 6. Variaciones del sistema (lo que cambia entre versiones)

| Eje | Variación |
|-----|-----------|
| Modo | **LITE** (subconjunto, billetera única implícita) vs **PRO** (full) → `MODOS_LITE_VS_PRO.md` |
| Rol | Usuario final vs Admin (CRUD maestro) |
| Plataforma | Web (SPA/PWA) vs Móvil (Capacitor) |
| Tema | Claro / Oscuro / Sistema (TECH-004) |
| Densidad de layout | Legacy / Pro / Lite → `../ui-ux/06-version-matrix-differences.md` |

---

## 7. Índice — dónde vive cada detalle

| Quiero entender… | Leo… |
|------------------|------|
| El negocio y los cántaros | `MODELO_CANTAROS.md` |
| Cuentas y transacciones | `CUENTAS_Y_TRANSACCIONES.md` |
| Cómo se registra (todos los caminos) | `FLUJOS_TRANSACCIONES.md` |
| Diferencias LITE vs PRO | `MODOS_LITE_VS_PRO.md` |
| La experiencia de usuario al detalle | `../ui-ux/04-current-state-human-describe.md` |
| Inventario de pantallas/componentes | `../ui-ux/02-current-ui-inventory-and-architecture.md` |
| Design system | `../ui-ux/DESIGN_MAP.md`, `MASTER_DESIGN_PROMPT.md` |
| El código (ruta de lectura) | `../00-sistema/GUIA_DE_LECTURA_CODIGO.md` |
| Arquitectura técnica | `../ARQUITECTURA_PROYECTO.md` |
| Tareas y estado | `../../TASKS_LEDGER.md`, `../../START_HERE.md` |

---

## 8. Huecos conocidos (para tener el 100%)
Docs pendientes: `GLOSARIO`, `MATRIZ_FUNCIONALIDADES`, `CASOS_DE_USO`, `MONEDAS_Y_TASAS`,
`IMPUESTOS`, `CATEGORIAS_E_ITEMS`, `IA_FEATURES`, `ROADMAP_OPTIMIZACIONES` (P1–P9),
`MODELO_DATOS_ERD`, `SEGURIDAD_Y_PERMISOS`. Producto inacabado: `ProHomeView`, gating funcional
LITE, modo oscuro.
