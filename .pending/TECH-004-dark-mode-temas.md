# TECH-004 — Afinar modo oscuro y temas

**Tipo:** TECH · **Prioridad:** media · **Estado:** todo · **Creada:** 2026-06-02

## Objetivo
Dejar el **modo oscuro** consistente en toda la app y montar una base de **temas** limpia,
reutilizando los tokens y variables que ya existen (no reinventar).

## Estado actual (código)
- `src/css/tokens.css` — variables de marca (`--brand-primary #1E3A8A`, `--brand-soft`, etc.).
- `src/css/quasar.variables.scss` — `$dark: #0f172a`, `$dark-page: #08111f`.
- `src/css/app.scss` — estilos `.body--dark` y `body.body--dark .glass-panel` (glassmorphism).
- Quasar Dark plugin disponible (`Dark.set(...)`), pero el toggle/persistencia no está unificado.

## Alcance
1. **Toggle de tema** unificado (claro / oscuro / sistema) con persistencia en
   `user_settings` (junto a `layout_mode`) y aplicación al boot.
2. **Auditoría de contraste** en modo oscuro de los componentes clave:
   - Cántaros (`jars/index.vue`), diálogo de transacciones (`TransactionCreateDialog.vue`),
     análisis de gastos, layouts LITE/PRO.
   - Revisar glassmorphism: legibilidad de texto sobre paneles translúcidos en dark.
3. **Tokens de color** como única fuente: migrar colores hardcodeados a variables de
   `tokens.css` para que un cambio de tema sea de un solo lugar.
4. **Coherencia con LITE/PRO**: ambos modos deben verse correctos en claro y oscuro.
5. Charts (ECharts) con paleta que respete el tema activo.

## Criterios de aceptación
- [ ] Toggle claro/oscuro/sistema persiste por usuario y se aplica al recargar.
- [ ] 0 problemas de contraste WCAG AA en pantallas clave (dark).
- [ ] Sin colores hardcodeados nuevos fuera de `tokens.css` en componentes tocados.
- [ ] Charts legibles en ambos temas.
- [ ] LITE y PRO verificados en claro y oscuro.

## Referencias
- `docs/producto/MODOS_LITE_VS_PRO.md`
- `docs/ui-ux/` (design system congelado)
