# Stitch MCP Operational Setup

Estado documental: `vigente`

Este documento fija como usar Stitch en OWFINANCE sin confundir diseño, implementacion y backlog.

## 1. Rol de Stitch en OWFINANCE

Stitch es la referencia visual cuando existe una pantalla o proyecto canonico.

No reemplaza:
- el router real;
- los contratos de producto;
- la documentacion tecnica vigente;
- el criterio de implementacion del repo.

## 2. IDs canonicos actuales

Fuente base:
- `docs/ui-ux/MASTER_UI_SOURCES.md`

Proyecto principal documentado:
- `OW Finance 2026 — Master UI [Definitivo]`
- Project ID: `5968657237763273187`

Los screen IDs oficiales deben mantenerse en `MASTER_UI_SOURCES.md`, no dispersos en tickets sueltos.

## 3. Como referenciar Stitch en Notion

Para cualquier ticket UI, usar:
- `Stitch Ref`: URL, screen ID o project ID verificable
- `Source of Truth`: `Stitch` cuando la referencia visual sea parte del alcance
- `Canonical Doc`: link al doc tecnico o al handoff si existe

## 4. Cuando es obligatorio

En esta fase actual:
- es obligatorio documentar la referencia Stitch cuando exista material canonico para la pantalla;
- todavia no bloquea todos los tickets UI;
- si no existe Stitch para una pantalla, el ticket puede avanzar con doc tecnica y decision de UX bien documentada.

## 5. Si MCP o Stitch no estan disponibles

Fallback aceptado:
1. usar el proyecto y screen IDs ya documentados;
2. usar docs UI del repo como traduccion tecnica;
3. dejar nota en el ticket de que falta reconfirmar con Stitch activo.

No aceptado:
- inventar screen IDs;
- tratar una spec vieja como si fuera fuente visual viva;
- bloquear una correccion urgente solo por falta temporal del MCP.

## 6. Runtime local que debe quedar sano

Para que Stitch y otros MCP funcionen bien en OpenCode:
- `c:\\Users\\pc\\.config\\opencode\\opencode.json` debe ser JSON valido;
- la configuracion debe documentar los MCP esperados;
- los secretos deben vivir fuera del repo.

Si el runtime local se corrompe o queda incompleto:
- repararlo primero;
- luego actualizar esta guia si cambia el metodo de conexion.
