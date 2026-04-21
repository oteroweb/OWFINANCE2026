# OWFINANCE Docs Hub

Estado documental: `vigente`

Este directorio mantiene solo la documentacion tecnica y operativa que el repo necesita para ejecutar trabajo con seguridad.

Reglas base:
- Drive `OWFINANCE` conserva la documentacion canonica de estrategia, planning, ownership y decision logs.
- Notion coordina tickets, estado y handoff operativo.
- El repo conserva playbooks cortos, arquitectura vigente, rutas vigentes y guias reproducibles.
- Los documentos obsoletos o supersedidos se mueven a `docs/archive/legacy-docs/` antes de considerar eliminacion.

## Documentos autoridad

- `docs/00-sistema/DEVELOPMENT_HANDBOOK.md` **[NUEVO 2026-04-06]**
  Handbook completo de desarrollo: 41 skills catalogados, flujos de trabajo, scripts, principios fundamentales y anti-patterns. **Punto de partida para cualquier tarea de desarrollo.**
- `docs/INDICE_MAESTRO_PROYECTO.md`
  Mapa maestro de documentacion activa, legacy y estructura interna de backend/frontend.
- `docs/00-sistema/FLUJO_OPERATIVO_UNIFICADO.md`
  Flujo end-to-end de intake, contexto, implementacion, validacion, release y cleanup.
- `docs/00-sistema/GIT_HYGIENE_AND_SAFE_UPDATE.md`
  Paso 0 obligatorio antes de `pull`, branch switch o trabajo por repo.
- `docs/ARQUITECTURA_PROYECTO.md`
  Arquitectura tecnica vigente del workspace y de los dos repos.
- `docs/CONSULTAS_OPERATIVAS.md`
  Playbook operativo corto para agentes y trabajo diario.
- `docs/03-frontend/SISTEMA_LAYOUTS_DINAMICOS.md` **[NUEVO 2026-04-06]**
  Sistema de layouts dinámicos (Lite, Pro, Legacy): arquitectura, componentes, rutas, responsive behavior, debugging.
- `docs/03-frontend/RUTAS.md`
  Fuente de verdad de rutas reales del frontend.
- `docs/01-configuracion/NOTION_TICKET_WORKFLOW.md`
  Flujo corto de trabajo con tickets y cierre de contexto.
- `docs/01-configuracion/STITCH_MCP_OPERATIONAL_SETUP.md`
  Integracion real de Stitch y como referenciar pantallas en tickets.
- `docs/01-configuracion/DOCUMENTATION_CLEANUP_POLICY.md`
  Politica de archivo, limpieza y consolidacion documental.

## Estados documentales

Usar siempre una de estas etiquetas visibles al inicio del documento:
- `vigente`: referencia activa y operativa.
- `transicional`: vigente por ahora, pero en proceso de reemplazo.
- `congelado`: baseline historico valido para contexto o comparacion.
- `obsoleto`: ya no debe guiar trabajo nuevo.
- `archivado`: movido a legacy por trazabilidad.

## Nota sobre Lite / Pro

Las referencias a Lite y Pro siguen existiendo en docs historicas, specs y material de diseño. En el estado actual:
- no se consideran rutas activas del producto;
- si pueden seguir sirviendo como contexto de arquitectura y diseño;
- cualquier decision ejecutable debe respetar primero las rutas reales y el router actual.
