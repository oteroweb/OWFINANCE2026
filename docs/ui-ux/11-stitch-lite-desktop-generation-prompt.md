# Stitch Prompt: Lite Desktop Light/Dark

## Objetivo

Generar en Stitch una variante **Lite Desktop** real para OW Finance 2026 en **Light Mode** y **Dark Mode**, porque hoy el frontend en `layout_mode = lite` sigue renderizando la shell de [LiteMobileLayout.vue](/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025/src/layouts/LiteMobileLayout.vue) incluso en escritorio.

Eso produce tres problemas concretos:

1. No existe una shell Lite desktop propia en el proyecto Stitch.
2. En dev se están heredando patrones móviles o piezas de otras variantes.
3. Hay problemas de iconos porque el frontend usa Quasar con `material-icons` y algunas propuestas recientes usan nombres `o_*` que no son un baseline confiable para este entorno.

## Fuentes de verdad usadas

- `docs/ui-ux/08-frozen-canonical-design-system-brief.md`
- `docs/ui-ux/09-freeze-stitch-flujo-core-matrix.md`
- `docs/ui-ux/10-layout-refactor-legacy-pro-lite-mini-spec.md`
- `docs/ui-ux/MASTER_UI_SOURCES.md`
- Stitch project `5968657237763273187`

## Hallazgos técnicos del frontend actual

- `DynamicRoleLayout` envía cualquier usuario `lite` a `LiteMobileLayout`, sin diferenciar desktop.
- `LiteHeaderDesktop.vue`, `LiteBottomNavDesktop.vue` y `ExpandedNavigationMenuLight.vue` existen en código, pero no están integrados a una shell desktop Lite real.
- La shell móvil actual usa `LiquidHeader`, `LiquidBottomNavNew` y `QuickActionSheet`.
- El proyecto Quasar está configurado con `material-icons`, no con Material Symbols como set oficial por defecto.

## Restricciones de diseño canónicas

- **Lite y Pro comparten una sola identidad visual.** No crear una marca distinta para Lite desktop.
- **Light mode es el baseline canónico.** Dark mode debe ser la variante secundaria equivalente.
- **Lite no usa sidebar persistente** como patrón principal. En desktop puede usar drawer opcional o menú expandido contextual, pero no una navegación densa tipo Pro.
- **Sin bordes duros de 1px** como recurso dominante.
- **Dinero primero:** balance, disponible, jars y movimientos recientes deben tener jerarquía dominante.
- **Sin emojis nativos como iconografía del sistema.** Solo SVG/material icons.

## Restricciones de implementación reales

- Los iconos deben ser compatibles con Quasar + `material-icons`.
- Usar nombres seguros como: `home`, `receipt_long`, `savings`, `settings`, `notifications`, `person`, `menu`, `add`, `visibility`.
- Evitar depender de iconos `o_home`, `o_receipt_long`, `o_savings`, `o_settings` como pieza central del diseño final.

## Componentes visuales que sí deben existir en la propuesta

1. **Lite Header Desktop**
   - saludo breve
   - avatar
   - notifications
   - visibility toggle opcional para montos
   - chip o selector corto de divisa activa

2. **Lite Navigation Desktop**
   - 4 destinos canónicos: Home, Transactions, Jars, Settings
   - sin sidebar pesada estilo Pro
   - puede resolverse como nav pill horizontal flotante, nav rail compacta o top segmented nav
   - estado activo muy claro con `brand-primary`

3. **Expanded Navigation Menu**
   - versión contextual para desktop Lite
   - activada desde avatar o botón de menú
   - no debe convertirse en una shell de admin

4. **Primary Financial Hero**
   - balance total dominante
   - CTA principal único
   - resumen calmado, no dashboard saturado

5. **Jars Preview + Recent Transactions**
   - densidad Lite: menos columnas y menos ruido que Pro
   - visible y útil en desktop, pero sin caer en super-grid

## Prompt listo para Stitch

```text
Design two new OW Finance 2026 screens for the Stitch project `5968657237763273187`:

1. OW Finance Lite Desktop - Light
2. OW Finance Lite Desktop - Dark

These are not Pro screens. They are a true Lite desktop shell and route experience for the canonical user flows.

CRITICAL PRODUCT CONTEXT:
- The current frontend incorrectly renders the Lite mobile layout on desktop.
- We need a real Lite desktop version that preserves the Lite philosophy: simpler, calmer, lower density, progressive disclosure, and premium fintech trust.
- Lite and Pro are the same product and same design system. They differ by density and layout posture, not by brand.

CANONICAL ROUTES:
- /user/home
- /user/transactions
- /user/jars
- /user/config

DESIGN SYSTEM RULES:
- Light mode is the canonical baseline.
- Dark mode must mirror the exact same structure and component language.
- Use a premium financial UI with white cards on `#F8FAFC` for light mode.
- Use deep navy surfaces for dark mode.
- Brand primary is deep navy `#1E3A8A`.
- Supporting info accent may use `#0EA5E9`.
- Success `#10B981`, danger `#EF4444`, warning `#F59E0B`.
- Use Satoshi as primary typeface, DM Sans as fallback.
- No hard 1px dark borders as dominant framing.
- Use soft elevation, large radius, pill controls, subtle glass only where appropriate.

LITE DESKTOP UX RULES:
- Do NOT create a Pro-style persistent sidebar.
- Do NOT create an admin shell.
- Keep only 4 global destinations.
- Keep one obvious primary action at a time.
- Reduce simultaneous controls compared with Pro.
- Preserve large money hierarchy and calm whitespace.

REQUIRED UI PARTS:
1. Desktop Lite header with avatar, greeting, notifications, optional balance visibility toggle, active currency chip.
2. Desktop Lite navigation using one of these patterns:
   - floating horizontal nav pill
   - compact top segmented nav
   - slim contextual nav rail
   But never a heavy Pro sidebar.
3. Expanded contextual navigation menu launched from avatar or menu button.
4. Hero balance card.
5. Jars preview area.
6. Recent transactions preview area.
7. Primary CTA for quick add.

ICONOGRAPHY RULES:
- Use only implementation-safe material icons.
- Use these safe names when possible: `home`, `receipt_long`, `savings`, `settings`, `notifications`, `person`, `menu`, `add`, `visibility`.
- Avoid outlined icon variants that depend on unsupported icon prefixes.
- No emoji-based system icons.

VISUAL REFERENCES TO PRESERVE:
- Keep the editorial calm of OW Finance Lite.
- Keep strong financial hierarchy.
- Keep rounded premium cards and trust-first spacing.
- Keep the expanded navigation menu as a contextual element, not as a route.

WHAT TO AVOID:
- Pro dashboard density
- admin chrome
- cyan-first CTA hierarchy
- AI / QR / voice as primary navigation destinations
- spreadsheet tables for Lite desktop
- duplicated Home labels or decorative premium badges

OUTPUT GOAL:
- Deliver two polished Stitch screens named exactly:
  - `OW Finance Lite Desktop - Light`
  - `OW Finance Lite Desktop - Dark`
- They must be implementation-ready references for a future `LiteDesktopLayout.vue` in Quasar.
```

## Nota de uso

Si Stitch propone una sidebar persistente o una densidad similar a Pro, rechazarla. La variante correcta debe sentirse como **Lite en escritorio**, no como **Pro simplificado** ni como **mobile estirado**.