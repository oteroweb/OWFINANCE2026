# OW Finance 2026: Master StitchMCP Prompt & Unified Palette

Este documento es la **Fuente Única de Verdad (Single Source of Truth)** para generar, recrear o actualizar cualquier vista de OW Finance 2026 utilizando StitchMCP o programando componentes en Quasar/Vue.

---

## 🎨 1. LA ÚNICA PALETA DE COLORES (Liquid Glass Unified)

No uses colores genéricos ni valores hardcodeados. Utiliza siempre este sistema semántico.

### Colores Semánticos Principales (Constantes en ambos modos)
*   **Primary (Brand):** `#0EA5E9` (Cyan Sky) — *Se usa para acciones clave, botones principales, barra de carga.*
*   **Income (Success):** `#10B981` (Emerald) — *Se usa para ingresos, cántaros en positivo, metas cumplidas.*
*   **Expense (Danger):** `#EF4444` (Red) — *Se usa para gastos, deudas, cántaros excedidos, acciones destructivas.*
*   **Warning (Alert):** `#FBBF24` (Gold) — *Se usa para alertas (ej. dinero ocioso), o ícono de Escanear/OCR.*
*   **Voice/AI Action:** `#8B5CF6` (Purple) — *Se usa exclusivamente para transferencias o funciones del coach IA.*

### Dark Mode (Modo Oscuro Predeterminado)
*   **Background Base:** `#0F172A` (Slate 900)
*   **Card / Surface 1:** `#131B2E`
*   **Card / Surface 2:** `#1A1A2E` (Uso principal para contenedores)
*   **Card / Surface 3:** `#222A3D` (Uso para elementos flotantes o hover)
*   **Text Primary:** `#E2E8F0` (Casi blanco)
*   **Text Secondary:** `#94A3B8` (Gris claro)
*   **Efectos:** Glassmorphism (blur 16-24px), sin bordes duros (`0px border`), sombras tenues con color Primary (`rgba(14,165,233, 0.15)`).

### Light Mode (Modo Claro Alternativo)
*   **Background Base:** `#F8FAFC` (Titanium White/Gris ultra claro)
*   **Card / Surface 1:** `#FFFFFF` (Blanco puro para las tarjetas)
*   **Card / Surface 2:** `#F1F4F6` (Para elementos secundarios)
*   **Text Primary:** `#0F172A` (Slate 900 oscuro)
*   **Text Secondary:** `#64748B` (Slate 500 gris medio)
*   **Efectos:** Sombras suaves (`box-shadow: 0 4px 24px rgba(0,0,0,0.06)`), tarjetas blancas prístinas sobre el fondo *F8FAFC*. Cero glassmorphism oscuro.

---

## 🔠 2. TIPOGRAFÍA Y ESPACIADOS

*   **Fuentes:** 
    *   `Manrope` (Bold) para Encabezados (H1, H2, Montos de dinero gigantes).
    *   `Inter` (Regular/Medium) para Párrafos, tablas y metadata.
*   **Formas:** 
    *   Tarjetas gigantes (Modales/Hero): `rounded-t-3xl` o `24px-32px radius`.
    *   Paneles Desktop: `16px-24px radius`.
    *   Botones: Píldora (`rounded-full` o `999px radius`).

---

## 📋 3. MASTER PROMPT GENERATOR (Copiar y Pegar a los AI Agents o StitchMCP)

Cuando necesites generar una nueva vista (o recrearla), copia el esqueleto de abajo y reemplaza las variables `[CORCHETES]`:

```text
Design a [DEVICE TYPE: Mobile/Desktop] [VIEW NAME] screen for OW Finance — a premium personal finance app using the "Liquid Glass Unified" design system.

CRITICAL DESIGN RULES ([DARK/LIGHT] MODE):
- Mode: [DARK | LIGHT]
- Background Base: [#0F172A | #F8FAFC]
- Card Surfaces: [#1A1A2E no borders, glassmorphism | #FFFFFF with 0 4px 24px rgba(0,0,0,0.06) soft shadow]
- Semantic Colors: Primary #0EA5E9, Income/Success #10B981, Expense/Danger #EF4444, Warning #FBBF24.
- Typography: Manrope Bold for all headings/money amounts, Inter for body/labels.
- Shape: Extreme rounding (24-32px for cards, pill-shaped buttons). Zero 1px borders.

LAYOUT & STRUCTURE:
1. HEADER: [Describe header elements, title, navigation icons]
2. HERO SECTION: [Describe the primary focus element, usually a massive financial amount or KPI]
3. MAIN CONTENT: [Describe lists, grids, inputs or charts]
4. BOTTOM NAV (Mobile Only): Fixed bottom floating bar with 4 tabs (Home, Transactions, Jars, Settings) and a center Action button. Floating AI Brain icon just above the center button.

SPECIFIC COMPONENTS FOR THIS VIEW:
[Detalla aquí la funcionalidad específica que quieres en la pantalla, ej. "Formulario de nueva transferencia," "Gráfico mensual," etc.]

AESTHETIC FEEL:
Premium, clutter-free, high-end fintech. Similar to Apple Wallet meets Bloomberg Terminal. Clean typography and generous whitespace.
```

## 🤖 4. DIRECCIÓN PARA AGENTES UI/UX (OW-Finance-UX-Expert)
Cualquier agente que trabaje en esta base de código:
1. **DEBE LEER ESTE ARCHIVO SIEMPRE** antes de escribir CSS o generar vistas.
2. Si el usuario pide un modo `Light`, usar exclusivamente `GEMINI_3_PRO` y aplicar las reglas de Light Mode aquí descritas.
3. Si el usuario pide modificar Quasar/Vue layouts, usar los CSS variables o clases Tailwind equivalentes a los HEX detallados aquí.
