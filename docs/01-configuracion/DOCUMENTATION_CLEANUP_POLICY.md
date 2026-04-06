# Documentation Cleanup Policy

Estado documental: `vigente`

OWFINANCE usa politica conservadora: `archivar primero`.

## 1. Objetivo

Reducir drift y duplicacion sin perder trazabilidad.

## 2. Reglas

- Un solo documento activo por tema.
- Antes de borrar, mover a `docs/archive/legacy-docs/`.
- Todo documento archivado debe marcarse como `archivado`.
- Todo documento reemplazado debe apuntar al documento autoridad vigente.
- No duplicar docs de Drive completas dentro del repo.

## 3. Criterios para archivar

Archivar cuando un documento:
- duplique una guia activa;
- describa rutas o flujos ya no vigentes;
- mezcle historia de producto con instrucciones operativas actuales;
- sea superado por un documento autoridad mas corto y preciso.

## 4. Criterios para mantener

Mantener si el documento:
- describe un contrato tecnico vigente;
- ayuda a ejecutar una tarea recurrente sin depender de Drive;
- conserva contexto tecnico dificil de redescubrir;
- sirve como baseline congelado claramente etiquetado.

## 5. Cierre del cleanup gate

Cada pasada de cleanup debe producir:
- lista de docs consolidadas;
- lista de docs archivadas;
- notas de riesgo si no es seguro eliminar;
- tickets de saneamiento en Notion si queda drift pendiente.
