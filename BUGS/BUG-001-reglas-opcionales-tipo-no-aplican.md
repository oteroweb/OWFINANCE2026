# BUG-001 - Reglas opcionales de tipo no aplican en vista previa

## Estado
- Estado: `todo`
- Prioridad: `alta`
- Fecha registro: `2026-03-14`
- Reportado por: usuario

## Modulo
- Frontend
- Pantalla: Carga masiva de transacciones
- Seccion: "Reglas opcionales de tipo"

## Descripcion
Cuando se configuran reglas de tipo y se pulsa "APLICAR REGLAS DE TIPO A VISTA PREVIA", los tipos de la tabla de vista previa no se actualizan como se espera.

## Ejemplo reportado
- Regla 1: `-` -> `Egreso`
- Regla 2: `+` -> `Transferencia`
- Accion: click en "APLICAR REGLAS DE TIPO A VISTA PREVIA"
- Resultado observado: la vista previa mantiene tipos previos y no refleja el mapeo esperado.

## Pasos para reproducir
1. Abrir carga masiva de transacciones.
2. Cargar datos en modo texto/excel.
3. Ir a "Reglas opcionales de tipo".
4. Definir al menos una regla de mapeo.
5. Pulsar "APLICAR REGLAS DE TIPO A VISTA PREVIA".
6. Revisar columna "3. Tipo" en la vista previa.

## Resultado actual
- Las reglas no se aplican correctamente en todas las filas.

## Resultado esperado
- Las filas deben actualizar su `type` segun las reglas configuradas, de forma consistente e inmediata en la vista previa.

## Notas tecnicas iniciales
- Revisar si la normalizacion se ejecuta sobre la fuente correcta segun `activeTab`.
- Revisar si hay overwrite posterior del `type` por otra transformacion o mapeo.
- Revisar si existe debounce/evento que rehaga el parse sin reglas.

## Evidencia
- Capturas adjuntas por el usuario (reglas configuradas y resultado en vista previa).
