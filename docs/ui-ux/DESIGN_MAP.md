# OWFinance 2026 — Mapa Completo de Diseño
> Generado: 2026-05-26 | Consolidación de 13 docs ui-ux + 23 pantallas Stitch + código frontend

---

## 1. JERARQUÍA DE AUTORIDAD (cuándo hay conflicto)

1. **`08-frozen-canonical-design-system-brief.md`** ← MANDA sobre todo
2. **`09-freeze-stitch-flujo-core-matrix.md`** ← Rutas y flujos canónicos
3. **`03-unified-design-rules.md`** ← Intención de diseño primaria
4. **`07-master-prompt-generator.md`** ← Prompts para generar con Stitch
5. **`10-layout-refactor-legacy-pro-lite-mini-spec.md`** ← Arquitectura de refactor
6. **`11-stitch-lite-desktop-generation-prompt.md`** ← Prompt Stitch para Lite Desktop
7. **`06-version-matrix-differences.md`** ← Filosofía Lite vs Pro (referencia histórica)
8. **`00-master-design-system-raw.md`** ← Origen, SUBORDINADO a #1

---

## 2. DESIGN SYSTEM CANÓNICO (congelado)

### Paleta
| Rol | Token | Hex |
|---|---|---|
| Background | `bg-app` | `#F8FAFC` |
| Cards | `surface-card` | `#FFFFFF` |
| Secondary | `surface-soft` | `#F1F5F9` |
| Brand Primary | `brand-primary` | `#1E3A8A` (Navy) |
| Brand Hover | `brand-primary-hover` | `#1D4ED8` |
| Brand Soft | `brand-soft` | `#DBEAFE` |
| Text Strong | `text-strong` | `#0F172A` |
| Text Muted | `text-muted` | `#64748B` |
| Border Soft | `border-soft` | `#E2E8F0` |
| Success | `state-success` | `#10B981` |
| Danger | `state-danger` | `#EF4444` |
| Warning | `state-warning` | `#F59E0B` |
| Info | `state-info` | `#0EA5E9` |

**Regla clave:** Brand primary es NAVY `#1E3A8A`, NO cyan. Cyan solo como acento secundario.

### Tipografía
- **Primaria:** Satoshi (Bold para headings/montos)
- **Fallback:** DM Sans
- **NO usar:** Manrope ni Inter como baseline para pantallas migradas

### Formas
- Cards hero: 24-32px radius
- Cards estándar: 24px (Lite), 20-24px (Pro)
- Desktop denso: 16-20px
- Botones: Pill (`rounded-full`)
- **Prohibido:** esquinas cuadradas duras

### Modo Dark (variante secundaria)
- Background: `#0F172A`
- Surface: `#131B2E` / `#1A1A2E` / `#222A3D`
- Text: `#E2E8F0` / `#94A3B8`
- Glassmorphism: blur 16-24px, sin bordes duros

---

## 3. FILOSOFÍA Lite vs Pro

**NO son marcas diferentes.** Mismo sistema, diferente densidad.

| Aspecto | Lite | Pro |
|---|---|---|
| Prioridad | Mobile-first, touch | Desktop-first, productividad |
| Navegación | Bottom nav flotante (4 tabs) | Sidebar + top utility bar |
| Balance | Hero card gigante (40% pantalla) | Distribuido en widgets |
| Transacciones | Lista simple 3-5 items | Super-Grid con inline editing |
| Cántaros | Donut + progreso visual | Tabla densa + drag & drop monetario |
| Forms | Wizard 1 toque (monto → categoría) | Múltiples campos simultáneos |
| Cuentas | Suma consolidada | Árbol jerárquico con D&D |

---

## 4. RUTAS CANÓNICAS (congeladas)

| Ruta | Vista | Lite Source Stitch | Pro Source Stitch |
|---|---|---|---|
| `/user/home` | Dashboard | OW Finance Dashboard Lite - Home | Desktop Pro Dashboard - Light Mode |
| `/user/transactions` | Transacciones | Transactions - Mobile Lite | Transactions Pro Super-Grid |
| `/user/jars` | Cántaros | Cántaros - Mobile Lite | Desktop Pro Jars Management |
| `/user/config` | Configuración | Simplificado de Desktop Pro Settings | Desktop Pro Settings |
| `/user/asesor` | AI Coach | AI Coach Chat | AI Coach Chat (deferred) |

---

## 5. PANTALLAS STITCH DISPONIBLES (23 total)

### ✅ Canónicas (usar como referencia)
1. `ow_finance_dashboard_lite_home_1/` — Dashboard Lite Light
2. `transactions_mobile_lite_1/` — Transacciones Lite Dark
3. `c_ntaros_mobile_lite_1/` — Cántaros Lite Light
4. `quick_add_modal_light_mode/` — Quick Add Modal
5. `desktop_pro_dashboard_light_mode_2/` — Pro Dashboard Light (preferido)
6. `desktop_pro_jars_management/` — Pro Jars Dark
7. `desktop_pro_settings_1/` — Pro Settings Dark
8. `transactions_pro_super_grid/` — Pro Transactions Grid
9. `ai_coach_chat_1/` — AI Coach Dark
10. `expanded_navigation_menu/` — Nav Menu Dark
11. `gu_a_de_estilo_y_componentes/` — Style Guide Light

### ⚠️ Duplicadas/Obsoletas (no implementar como ruta separada)
12. `ow_finance_dashboard_lite_home_2/` — Duplicada de #1
13. `ow_finance_dashboard_lite_1/` through `_4/` — Variantes viejas
14. `desktop_pro_dashboard_home_1/` y `_2/` — Dark, usar solo layout cues
15. `desktop_pro_dashboard_light_mode_1/` — Duplicada de #5
16. `desktop_pro_settings_2/` — Duplicada de #7
17. `transactions_mobile_lite_2/` — Duplicada de #2
18. `c_ntaros_mobile_lite_2/` — Duplicada de #3
19. `ai_coach_chat_2/` — Duplicada de #9

### 📐 Design Systems dentro de Stitch
- `precision_vault/DESIGN.md` — Dark elite wealth
- `liquid_glass_unified_1/DESIGN.md` — Dark "Ethereal Vault"
- `liquid_glass_unified_2/DESIGN.md` — Light "Luminous Ledger"

---

## 6. ESTADO DE IMPLEMENTACIÓN FRONTEND

### Componentes Lite que YA EXISTEN
- `LiquidHeader.vue` — Header con balance, toggle visibilidad, moneda
- `LiquidBottomNavNew.vue` — Bottom nav 5 tabs
- `QuickActionSheet.vue` — FAB bottom sheet
- `LiteMobileLayout.vue` — Layout integrador mobile
- `LiquidJarCard.vue` — Card cántaro
- `LiquidBalanceCard.vue` — Card balance
- `LiteHomeView.vue` — Vista home Lite

### Componentes que EXISTEN pero NO INTEGRADOS
- `LiteHeaderDesktop.vue` — Header desktop Lite
- `LiteBottomNavDesktop.vue` — Nav desktop Lite
- `ExpandedNavigationMenuLight.vue` — Menú expandido desktop

### Problema actual: `DynamicRoleLayout` envía Lite desktop a shell mobile

---

## 7. ORDEN DE IMPLEMENTACIÓN (congelado)

1. Shared shell (bottom nav, sidebar, FAB, header slots)
2. Quick-add overlay (Lite sheet, Pro extension)
3. Lite `/user/home`
4. Lite `/user/transactions`
5. Lite `/user/jars`
6. Lite `/user/config`
7. Pro `/user/home`
8. Pro `/user/transactions`
9. Pro `/user/jars`
10. Pro `/user/config`

---

## 8. HERRAMIENTAS DE DISEÑO DISPONIBLES

| Herramienta | Estado | Capacidad |
|---|---|---|
| **Stitch MCP** | ✅ Configurado (GCP `hermes-497105`) | Genera HTML+CSS, 23 pantallas ya creadas, prompt template listo |
| **Claude Design** | 🔍 Por evaluar | Genera HTML/CSS nativo, bueno para diseño moderno, claudetovideo |
| **OpenDesign** | 🔍 Por evaluar | Librería Vue 3 con temas, integración directa con nuestro stack |

### Plan de evaluación
Tomar **V-JAR-01 (Lista de Cántaros)** y generar con cada herramienta, luego comparar:
- Calidad visual
- Coherencia con design system canónico
- Facilidad de migración a Quasar/Vue3

---

## 9. DOCUMENTOS POR LIMPIAR (futura fase)

- `00-master-design-system-raw.md` — Paleta obsoleta (#0F172A, #CA8A04), contradictoria con #08
- `01-happy-jar-reference.md` — Referencia externa, útil pero no autoridad
- `04-current-state-human-describe` (sin extensión) — Archivo huérfano
- `MASTER_UI_SOURCES.md` — IDs Stitch pueden estar desactualizados
- `06-version-matrix-differences.md` — Filosofía ok, pero tabla usa colores viejos
