# BUGS Diferidos — Post MVP

**Decisión**: Estos bugs fueron identificados pero diferidos para después del lanzamiento MVP.
**Fuente**: Sprint planning sesión Abril 2026

## BUG-001 a BUG-005 — Bulk Import

**Contexto**: Funcionalidad de importación masiva de transacciones tiene bugs.
**Estado**: Diferidos — no bloquean MVP

### Para atacar estos bugs en una sesión futura:

1. Abrir una sesión nueva de Claude Code
2. Proporcionar contexto: "Hay bugs en la funcionalidad de bulk import de OWFINANCE2026"
3. El agente debe:
   - Leer `src/pages/` y buscar archivos relacionados con "import" o "bulk"
   - Leer el controlador backend correspondiente
   - Identificar y reproducir cada bug
   - Crear tickets en Notion OwFinance Backlog antes de fijar

### Notion Backlog IDs para referencia
- Backlog database está en OWFINANCE_2026 workspace de Notion
- Parent page: 32de7ace-9767-809c-b2fa-dba505ef2915

## Cómo reportar nuevos bugs

Agregar aquí con formato:
```
## BUG-XXX — [Título corto]
**Síntoma**: qué pasa
**Reproducir**: pasos exactos
**Archivo afectado**: path/al/archivo
**Prioridad**: Alta/Media/Baja
```
