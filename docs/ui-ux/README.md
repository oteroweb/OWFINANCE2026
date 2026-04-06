# UI / UX Docs Index

Estado documental: `vigente`

Este directorio ya fue depurado para dejar solo la documentacion UI/UX que sigue siendo util para decisiones activas o transicionales.

## Nucleo activo recomendado

### Autoridad principal

1. `docs/03-frontend/RUTAS.md`
   Verdad de rutas activas y navegación real.
2. `08-frozen-canonical-design-system-brief.md`
   Baseline canonico de implementación visual.
3. `09-freeze-stitch-flujo-core-matrix.md`
   Matriz congelada de flujos core y mapping Stitch -> implementación.
4. `MASTER_UI_SOURCES.md`
   Fuente operativa de IDs y pantallas Stitch.
5. `03-unified-design-rules.md`
   Intención de diseño y experiencia, subordinada al baseline congelado si hay conflicto.

### Documentos transicionales que siguen vivos

- `05-current-state-live-inventory.md`
  Snapshot técnico de la app viva; útil para contrastar teoría contra estado real.
- `10-layout-refactor-legacy-pro-lite-mini-spec.md`
  Spec estructural de transición para separar Legacy, Lite y Pro sin romper contratos.

## Qué ya no vive aquí

Se movieron a `docs/archive/legacy-docs/` por duplicidad, antigüedad o por haber sido superados por fuentes más fuertes:

- `ui-ux-00-master-design-system-raw.md`
- `ui-ux-01-happy-jar-reference.md`
- `ui-ux-02-current-ui-inventory-and-architecture.md`
- `ui-ux-04-current-state-human-describe`
- `ui-ux-04-current-state-human-describe.md`
- `ui-ux-06-version-matrix-differences.md`
- `ui-ux-07-master-prompt-generator.md`

## Regla de uso

- Si toca rutas o navegación, manda `docs/03-frontend/RUTAS.md`.
- Si toca implementación visual o migración UI, mandan `08` y `09`.
- Si toca referencia visual de Stitch, manda `MASTER_UI_SOURCES.md`.
- Si un documento entra en conflicto con código o rutas reales, pierde autoridad.

## Resultado de la limpieza

El bloque `ui-ux/` deja de mezclar:
- inspiración histórica;
- prompting viejo;
- inventarios redundantes;
- matrices antiguas de Lite/Pro;
- y snapshots narrativos duplicados.

Ahora conserva un núcleo mucho más corto y fácil de mantener.

## Próximo paso recomendado

Corregir encoding y añadir etiqueta de estado visible dentro de los archivos que siguen activos:
- `03-unified-design-rules.md`
- `05-current-state-live-inventory.md`
- `08-frozen-canonical-design-system-brief.md`
- `09-freeze-stitch-flujo-core-matrix.md`
- `10-layout-refactor-legacy-pro-lite-mini-spec.md`
- `MASTER_UI_SOURCES.md`
