# BULK Transfers Guardrails (Frontend + Backend)

Fecha: 2026-03-14

## Objetivo
Evitar inconsistencias en importaciones masivas de transacciones, especialmente en transferencias, para que no se alteren saldos de cuentas ni métricas de cántaros.

## Resumen Ejecutivo
- Una fila de tipo `transfer` sin `items` debe enviar `amount` a nivel raíz del row.
- Una transferencia debe crear exactamente 2 pagos (`payments`):
  - origen: monto negativo
  - destino: monto positivo
- Para filas no transferencia, los `items.amount` deben ir normalizados en moneda base del usuario para no inflar gasto de cántaros.
- El backend valida que pagos convertidos por tasa coincidan con el monto de transacción.

## Contrato de Payload (Bulk)
Endpoint: `POST /api/v1/transactions/bulk`

Envelope:
- `mode`: `table | excel | text`
- `dry_run`: `true | false`
- `rows`: array de filas

### Row no-transfer (expense/income)
Campos mínimos recomendados:
- `name`
- `date`
- `amount` (monto en moneda base, con signo según tipo)
- `items[]` (normalmente 1 ítem con mismo signo que `amount`)
- `payments[]` (1 payment con monto en moneda de la cuenta + `rate`)

### Row transfer
Campos requeridos:
- `name`
- `date`
- `amount` (obligatorio si `items` está vacío)
- `items: []`
- `payments` con exactamente 2 registros:
  - payment 1: `account_id` origen, `amount` negativo
  - payment 2: `account_id` destino, `amount` positivo
  - ambos con `rate > 0`

Ejemplo válido:
```json
{
  "name": "TRANSFER cambio binance",
  "date": "2026-03-09 12:00:00",
  "amount": 601.89,
  "include_in_balance": true,
  "items": [],
  "payments": [
    { "account_id": 12, "amount": -35511.35, "rate": 59 },
    { "account_id": 15, "amount": 35511.35, "rate": 59 }
  ],
  "client_row_id": "trf-2"
}
```

## Escenarios y Comportamiento Esperado

### Escenario A: Expense en cuenta VES
Entrada:
- `payments[0].amount = -6951.35`
- `rate = 530`

Esperado:
- `items.amount` persistido en base: `-13.12` aprox.
- impacto cántaro usa `items.amount` (base), no el monto en VES.

### Escenario B: Income en cuenta VES
Entrada:
- `payments[0].amount = +1790`
- `rate = 530`

Esperado:
- `items.amount` persistido positivo en base.
- si el concepto es ingreso, no debe enviarse con signo negativo.

### Escenario C: Transferencia 12 -> 15
Entrada:
- dos payments opuestos, misma magnitud absoluta
- `items: []`
- `amount` raíz obligatorio

Esperado:
- backend acepta row
- aparecen 2 `payment_transactions`
- no se registra como gasto de cántaro (sin ítems de gasto)

### Escenario D: Transferencia sin `amount`
Esperado:
- backend rechaza con error:
  - `Amount is required when items are not provided`

### Escenario E: Transferencia con 1 payment o signos inválidos
Esperado:
- backend rechaza:
  - `Transfers must have exactly 2 payments with opposite signs`

## Validaciones Críticas Backend
Servicio: `app/Services/TransactionBulkService.php`

Reglas clave:
- ownership de cuentas (usuario autenticado)
- cardinalidad y signos de transferencias
- `rate != 0`
- montos convertidos por tasa deben cuadrar con `amount` de transacción en no-transfer

## Lógica Crítica Frontend
Componente: `src/components/TransactionBulkImportDialog.vue`

Reglas clave:
- detectar tipo `transfer` y construir payload con 2 payments
- incluir `amount` raíz en filas transfer
- para no-transfer, convertir `itemAmount = paymentAmount / rate` para persistir en base
- validar `from_account_id` y `to_account_id` para transfer

## Cántaros: Regla de Consistencia
Servicio: `app/Services/JarBalanceService.php`

- `spent` se calcula con `SUM(ABS(item_transactions.amount))`
- por eso `item_transactions.amount` debe quedar en base y con signo correcto
- se excluyen transacciones `deleted_at` y `active = 0`

## Checklist Operativo de Importación
1. Ejecutar `dry_run=true`.
2. Revisar `results[]` y confirmar `ok=true` en todas las filas.
3. Verificar que transferencias traigan `amount` raíz.
4. Ejecutar import real (`dry_run=false`).
5. Recalcular cuentas afectadas:
   - `POST /accounts/{id}/recalculate-account`
6. Validar saldos y corrida en UI por cuenta filtrada.

## Diagnóstico Rápido de Errores Comunes
- Error: `Amount is required when items are not provided`
  - Causa: transferencia sin `amount` raíz.
  - Acción: agregar `amount` en row transfer.

- Error: saldo final muy distinto al Excel
  - Causa probable: transferencias no importadas o ingresos con signo invertido.
  - Acción: verificar filas transfer presentes y signos de ingresos.

- Cántaros inflados
  - Causa: `items.amount` guardado en moneda de cuenta en vez de base.
  - Acción: asegurar conversión en frontend antes de enviar payload.

## Recomendaciones para No Reincidir
- Mantener `dry_run` como paso obligatorio antes de cualquier import real.
- No ejecutar `curl` manual con payload desactualizado si la UI ya fue corregida.
- En transferencias, usar siempre plantilla con `amount` raíz + 2 payments opuestos.
- Agregar pruebas automáticas para:
  - transfer sin amount
  - transfer con 2 payments válidos
  - expense en moneda no-base con conversión de ítem
