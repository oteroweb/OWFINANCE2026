# BUG-005 - Records per page "All" ignora filtro de marzo y usa universo global

## Estado
- Estado: `todo`
- Prioridad: `alta`
- Fecha registro: `2026-03-14`
- Reportado por: usuario

## Modulo
- Frontend tabla de transacciones
- Vista: listado de transacciones (filtro por periodo)
- Impacto: visualizacion, sumatorias y validacion manual de datos del mes

## Descripcion
Al seleccionar `Records per page = All` en la tabla, el comportamiento esperado es mostrar todas las transacciones del filtro activo (por ejemplo, marzo).

Actualmente, al usar `All`, la tabla toma un conjunto global (o paginacion no acotada al filtro del periodo) y no respeta que el usuario esta en marzo.

## Resultado actual
- El usuario filtra por marzo.
- Cambia `Records per page` a `All`.
- La grilla muestra registros fuera del periodo filtrado o calcula el total como si fuera global.

## Resultado esperado
- `All` debe significar "todas las filas del filtro actual", no "todas las filas de todo el historial".
- Si el filtro activo es marzo, deben mostrarse solo transacciones de marzo.
- Los contadores, sumatorias y paginacion deben permanecer consistentes con ese filtro.

## Pasos para reproducir
1. Ir a la vista de transacciones.
2. Aplicar filtro de periodo: marzo.
3. Verificar total inicial con paginacion normal.
4. Cambiar `Records per page` a `All`.
5. Observar que se incorporan filas fuera de marzo o cambia el total como global.

## Hipotesis tecnica inicial
- El cambio a `All` podria estar reseteando/omitiendo parametros de filtro (`from`, `to`, `period`) en la consulta al backend.
- O bien la capa de frontend recalcula dataset local sin volver a aplicar el filtro temporal.

## Checklist de futura solucion
1. Trazar request de red cuando se cambia a `All`.
2. Verificar que el query preserve filtros de periodo.
3. Agregar prueba de regresion: periodo marzo + `All`.
4. Validar contador final (ej. `1-22 of 22`) contra dataset filtrado real.
