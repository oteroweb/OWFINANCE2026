# 💸 Módulo Transaccional (Unified Data Hub & Input Palette)

**Status**: To Do  
**Priority**: High  
**Role**: Engineering / Product / UI/UX  
**Sprint**: Phase 3  

---

## User Story

> Como usuario diario de OWFinance (modo Lite),  
> quiero tener un acceso rápido (Floating Action Button) persistente,  
> para abrir una paleta que me permita registrar gastos e ingresos en segundos.

---

## Descripción

La "Transacciones Palette" y el "Data Hub" constituyen el núcleo interactivo de la experiencia móvil (Lite). Sustituirán los formularios de transacciones completos por interacciones Bottom-Sheet o Modales que aparecen fluidamente con un teclado pre-adecuado o numérico (a definir), reduciendo la fricción y el número de taps necesarios para loggear un ingreso/gasto.

---

## Criterios de Aceptación

### UI/UX
- [ ] Implementar un botón persistente interactivo (`glass-fab`) en `LiteHomeView`.
- [ ] Implementar un elemento deslizante desde la parte inferior (`swipeable-bottom-sheet`).
- [ ] Construir la tarjeta (form) principal de transacciones (`TransactionPalette`), con transiciones ágiles entre Income/Expense/Transfer.
- [ ] Mantener fidelidad geométrica (border-radius consistentes) y sombras de la librería *Liquid Glass / Emil Kowalski* ya implementada.

### Funcionalidad Lógica Frontend
- [ ] La paleta debe usar los hooks o stores de `transactions` pre-existentes para ejecutar los `api.post('/transactions')`.
- [ ] Una vez enviada una transacción con éxito, cerrar el modal fluidamente y notificar visualmente (Quick Toast).
- [ ] Selecciones visuales (botones como pastillas/chips en lugar de selects dropdown) para elegir la **Categoría**.
- [ ] Refrescar de ser necesario el balance de `LiteHomeView` o Store subyacente de Pinia cuando se ingrese un dato.

---

## Notas Técnicas

- Usaremos componentes `glass-fluid-card.vue` y `spring-button.vue` como primitivas atómicas de UI.
- No instalaremos nuevas librerías para *bottom-sheets* inicialmente para minimizar bundle size; construiremos usando Vue `<Transition>` custom o CSS.
- Si fallan los selectores por defecto se puede considerar Numpad on-sheet en Phase 3 part 2.

*Creado a falta de Autenticación Notion MCP activa (Fallback).*
