# Bugs Backlog

Lista de bugs pendientes para resolver mas adelante.

## Estado
- `todo`: pendiente por analizar o resolver.
- `in-progress`: en trabajo.
- `blocked`: depende de otro cambio.
- `done`: resuelto y validado.

## Bugs registrados

| ID | Titulo | Modulo | Estado | Prioridad |
|---|---|---|---|---|
| BUG-001 | Reglas opcionales de tipo no aplican en vista previa | Bulk import de transacciones | todo | alta |
| BUG-002 | Transferencia falla en dry-run y vista previa no refleja payload valido | Bulk import + API /transactions/bulk | todo | alta |
| BUG-003 | Saldo post-import no refleja movimientos reales inmediatamente | Tabla transacciones + balance de cuenta | todo | alta |
| BUG-004 | Falta de pruebas mixtas bulk (transfer + ingreso + egreso + saldo esperado) | Bulk import + validacion de saldo | todo | alta |
| BUG-005 | Records per page "All" ignora filtro de marzo y usa universo global | Tabla transacciones + paginacion/filtros | todo | alta |
| BUG-006 | Inconsistencia de idioma: campos y etiquetas en ingles en lugar de espanol | UI/i18n transversal | todo | media |

## Pruebas Pendientes

- Suite de integracion bulk import: [TESTS_PENDING_BULK_INTEGRATION.md](TESTS_PENDING_BULK_INTEGRATION.md)

## Como agregar un nuevo bug
1. Crear un archivo nuevo `BUG-XXX-*.md` en esta carpeta.
2. Agregar una fila en esta tabla.
3. Incluir pasos para reproducir, resultado actual y resultado esperado.
