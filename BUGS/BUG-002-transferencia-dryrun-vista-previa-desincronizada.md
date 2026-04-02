# BUG-002 - Transferencia falla en dry-run y vista previa no refleja payload valido

## Estado
- Estado: `todo`
- Prioridad: `alta`
- Fecha registro: `2026-03-14`
- Reportado por: usuario

## Modulo
- Frontend + API bulk
- Pantalla: Carga masiva de transacciones (vista previa editable)
- Endpoint: `POST /api/v1/transactions/bulk`

## Descripcion
Al marcar una fila como `transfer` en la vista previa, el dry-run puede seguir fallando con:
`Amount is required when items are not provided`.

En el request capturado, la fila transfer llega sin `amount` en el nivel raiz, aunque ya tiene `items: []` y dos `payments` opuestos.

## Evidencia actual
- Fila fallida: `client_row_id: text-6`
- Error API:
  - `errors.amount[0] = Amount is required when items are not provided`
- En UI se ve tipo `transfer`, pero el payload enviado no siempre incluye `amount` raiz.
- Evidencia complementaria (manual):
  - La misma transferencia **si funciona** cuando se envía explícitamente `amount` raíz en el row.
  - Ejemplo validado por usuario: `amount: 99.0004235355444` con `payments` opuestos y `rate: 613.88`.

## Pasos para reproducir
1. Abrir Carga masiva en frontend.
2. Cargar filas en modo texto.
3. Convertir una fila a `transfer`.
4. Ejecutar dry-run.
5. Revisar request/response de `transactions/bulk`.

## Resultado actual
- API rechaza una fila transfer por falta de `amount`.
- Vista previa y payload quedan desincronizados en ciertos flujos.
- El backend sí procesa la transferencia cuando el payload está completo; el problema principal queda acotado a construcción/sincronización de payload en frontend.

## Resultado esperado
- Toda fila `transfer` en vista previa debe enviar siempre:
  - `amount` raiz
  - `items: []`
  - `payments` con 2 movimientos opuestos
- Dry-run debe validar `ok=true` cuando la fila esta bien formada.

## Hipotesis tecnicas
- Hay ruta de transformacion que no pasa por el builder corregido.
- Alguna accion posterior (reglas/mapeo) reescribe la fila y elimina `amount` raiz.
- Request usado en pruebas manuales puede no corresponder al payload construido por la UI actual.

## Checklist de futura solucion
1. Trazar payload final justo antes de `bulkAddTransactions`.
2. Asegurar guardrail: si `type=transfer` y no hay `amount`, derivarlo desde payments/rate.
3. Verificar que acciones de vista previa (reglas, remapeos, edición manual) no eliminen `amount` en filas transfer.
4. Agregar test E2E de dry-run con transferencia.
