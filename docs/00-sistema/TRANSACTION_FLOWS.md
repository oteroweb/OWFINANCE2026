# OWFinance — Flujos de Transacciones (Referencia Completa)

> Documentado 2026-07-02. Verificado con simulaciones 10/10 PASS en local.
> Backend: Laravel 12 + Sanctum. Endpoint: `POST /api/v1/transactions`

---

## Contrato de API

### Reglas de `items[].amount`
- `amount` = **total de la línea** (ya incluye la multiplicación `qty × precio_unit`).
- El backend NO multiplica por `quantity`. El cliente manda el total.
- Ejemplo correcto: qty=2, precio=22.50 → `amount: 45.00` (NO `amount: 22.50`)

### Reglas de `payments[]`
- Siempre requerido. Mínimo 1 elemento.
- Gasto/Ingreso: todos misma dirección (negativos o positivos).
- Transferencia: exactamente 2 pagos con **signos opuestos** (+/-).
- Multi-moneda: incluir `rate` (tasa relativa a moneda del usuario).
- El backend valida que la suma de `payments` (convertida a moneda base) sea igual al `amount`.

---

## Casos de Prueba — TODOS VERIFICADOS ✓

### 1. Gasto Simple — Misma Moneda (USD)
```json
{
  "name": "Supermercado planificado",
  "amount": -45.00,
  "date": "2026-07-02 10:00:00",
  "transaction_type_id": 3,
  "category_id": 1087,
  "tags": [4],
  "payments": [{ "account_id": 35, "amount": -45.00 }]
}
```
- `amount` negativo = egreso.
- 1 payment = cuenta de débito.
- Tags: `planificado` (id 4).

---

### 2. Gasto con Etiqueta de Comportamiento
```json
{
  "name": "Ropa tienda impulso",
  "amount": -120.00,
  "date": "2026-07-02 11:00:00",
  "transaction_type_id": 3,
  "category_id": 1087,
  "tags": [3],
  "payments": [{ "account_id": 35, "amount": -120.00 }]
}
```
- Tag `impulso` (id 3) marca compras no planificadas.

---

### 3. Gasto con Comisión Pago Móvil (sub-item `is_fee`)
```json
{
  "name": "Pago Movil Farmacia",
  "amount": -103.00,
  "date": "2026-07-02 12:00:00",
  "transaction_type_id": 3,
  "category_id": 1087,
  "tags": [1, 2],
  "payments": [{ "account_id": 36, "amount": -103.00 }],
  "items": [
    { "name": "Farmacia", "quantity": 1, "amount": -100.00, "category_id": 1087 },
    { "name": "Comision pago movil", "quantity": 1, "amount": -3.00,
      "category_id": 1087, "is_fee": true, "fee_type": "pago_movil",
      "tags": [1, 2] }
  ]
}
```
- `amount` de la TX = suma de items.
- `is_fee: true` + `fee_type: "pago_movil"` identifica la comisión.
- Tags en la TX raíz Y en el item-fee para filtrar "total comisiones".
- La comisión mantiene la **misma categoría** del gasto principal.

---

### 4. Factura con Artículos de Distintas Categorías (Detalle Factura)
```json
{
  "name": "Factura Supermercado Mixta",
  "amount": -85.00,
  "date": "2026-07-02 13:00:00",
  "transaction_type_id": 3,
  "payments": [{ "account_id": 35, "amount": -85.00 }],
  "items": [
    { "name": "Carne", "quantity": 1, "amount": -40.00, "category_id": 1087 },
    { "name": "Almuerzo x2", "quantity": 2, "amount": -45.00, "category_id": 1088 }
  ]
}
```
- `amount` de la TX = suma absoluta de items (`-40 + -45 = -85`).
- Cada item tiene su propia `category_id` → cántaro diferente.
- `amount` por item es el **total de la línea** (2 × 22.50 = 45, no 22.50).
- Sin `category_id` en la TX raíz cuando hay items (opcional).

---

### 5. Ingreso Simple (USD)
```json
{
  "name": "Salario Julio",
  "amount": 2000.00,
  "date": "2026-07-02 10:00:00",
  "transaction_type_id": 2,
  "category_id": 1087,
  "tags": [5],
  "payments": [{ "account_id": 35, "amount": 2000.00 }]
}
```
- `amount` positivo = ingreso.
- `transaction_type_id: 2` = Ingreso.

---

### 6. Ingreso Recurrente sin Categoría
```json
{
  "name": "Renta local",
  "amount": 800.00,
  "date": "2026-07-02 10:00:00",
  "transaction_type_id": 2,
  "tags": [5],
  "payments": [{ "account_id": 35, "amount": 800.00 }]
}
```
- Tag `recurrente` (id 5) para filtrar ingresos periódicos.
- `category_id` es opcional.

---

### 7. Transferencia Misma Moneda (USD → USD)
```json
{
  "name": "Traspaso USD",
  "amount": 500.00,
  "date": "2026-07-02 14:00:00",
  "transaction_type_id": 4,
  "tags": [6],
  "payments": [
    { "account_id": 35, "amount": -500.00 },
    { "account_id": 35, "amount": 500.00 }
  ]
}
```
- **Exactamente 2 payments** con signos opuestos.
- `transaction_type_id: 4` = Transferencia.
- Tag `transferencia_interna` (id 6).
- `amount` en la TX = monto positivo del movimiento.

---

### 8. Gasto Moneda Extranjera (cuenta VES, usuario USD)
```json
{
  "name": "Mercado VES",
  "amount": -200.00,
  "date": "2026-07-02 15:00:00",
  "transaction_type_id": 3,
  "category_id": 1087,
  "payments": [{ "account_id": 36, "amount": -7300.00, "rate": 36.5 }]
}
```
- `amount` de la TX = en moneda del usuario (USD).
- `payment.amount` = en moneda de la cuenta (VES = 200 × 36.5 = 7300).
- `rate` = cuántas unidades de moneda-cuenta equivalen a 1 USD.
- El backend valida: `7300 / 36.5 = 200 ≈ amount`.

---

### 9. Split Pago Multi-Moneda (USD + VES mismo gasto)
```json
{
  "name": "Restaurante split USD+VES",
  "amount": -50.00,
  "date": "2026-07-02 16:00:00",
  "transaction_type_id": 3,
  "category_id": 1088,
  "payments": [
    { "account_id": 35, "amount": -25.00 },
    { "account_id": 36, "amount": -912.50, "rate": 36.5 }
  ]
}
```
- 2 payments con el **mismo signo** = pago dividido (no transferencia).
- Validación: `25.00 + (912.50 / 36.5) = 25.00 + 25.00 = 50.00 ✓`
- En el frontend (Pro mode): panel "Split" con 2+ cuentas.

---

### 10. Transferencia entre Monedas (USD → VES, cambio de divisas)
```json
{
  "name": "Cambio USD a VES",
  "amount": 100.00,
  "date": "2026-07-02 17:00:00",
  "transaction_type_id": 4,
  "payments": [
    { "account_id": 35, "amount": -100.00 },
    { "account_id": 36, "amount": 3650.00, "rate": 36.5 }
  ]
}
```
- Signos opuestos → detectado como transferencia.
- `rate` en el payment positivo (VES) porque la cuenta VES difiere de moneda base.
- El primer payment (USD, signo negativo) no necesita `rate` si coincide con moneda base.

---

## Tags del Sistema

| ID | Slug | Uso |
|----|------|-----|
| 1 | `comision` | Cargos bancarios / fee de servicio |
| 2 | `pago_movil` | Transacciones vía pago móvil |
| 3 | `impulso` | Compras no planificadas |
| 4 | `planificado` | Gastos previstos en presupuesto |
| 5 | `recurrente` | Movimientos periódicos (suscripciones) |
| 6 | `transferencia_interna` | Entre cuentas propias |

---

## Bugs Encontrados y Corregidos (2026-07-02)

### BUG-1: `items[].amount` multiplicado incorrectamente por `quantity`
- **Donde**: `TransactionController::store()` línea 363
- **Antes**: `$sum += ($amt * $qty)` — doble conteo cuando qty > 1
- **Después**: `$sum += $amt` — `amount` es el total de la línea
- **Commit**: `1082732`

### BUG-2: `User::isAdmin()` faltaba en el modelo
- **Donde**: `app/Models/Entities/User.php`
- **Síntoma**: 500 error al crear transacciones (usuarios no-admin)
- **Fix**: Método agregado verificando `role.slug in ['admin', 'superadmin']`
- **Commit**: `1082732`

---

## Frontend — Flujo SmartTransactionModal

| Panel Pro | Datos enviados |
|-----------|----------------|
| Sin panel | TX simple: `amount`, `category_id`, `payments[1]` |
| Comisión | `amount` = base + comisión; sin items |
| Split | `payments[N]` múltiples cuentas, misma dirección |
| Items/Factura | `items[]` con `name`, `quantity`, `amount` (total), `category_id` por item |

**Regla cántaro**: el `jar_id` nunca se selecciona manualmente. Se deriva de `category_id` via `jarForCategory()` en el cliente, y se envía en el payload.
