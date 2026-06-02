# Cuentas y Transacciones — OWFINANCE 2026

> Documento de producto. Tipos de cuenta, tipos de transacción y el flujo del menú de
> transacciones tal como existen en el código (`AccountType`, `Account`, `TransactionType`,
> `Transaction`, `PaymentTransaction`, `ItemTransaction`).
> Última actualización: 2026-06-02.

## 1. Tipos de cuenta (`account_types`)

| Tipo | Icono | Uso |
|------|-------|-----|
| **Banco** | `bank` | Cuenta bancaria tradicional (ingresos y gastos) |
| **Tarjeta de Crédito** | `credit-card` | Compras y pagos diferidos |
| **Efectivo** | `cash` | Dinero físico disponible |
| **Cashea** | — | Operaciones de Cashéa (compra a cuotas, VE) |

**Atributos de cuenta (`accounts`)**:
- Multi-moneda: `USD`, `EUR`, `VES` (cada cuenta tiene su moneda).
- `balance_cached` — saldo cacheado para no recalcular en cada lectura.
- `account_folders` — carpetas para agrupar cuentas.
- `accounts_taxes` — impuestos asociados a una cuenta.
- `account_user` — cuentas **compartidas** entre usuarios (con FK a carpeta).

## 2. Tipos de transacción (`transaction_types`)

| Slug | Nombre | Efecto |
|------|--------|--------|
| `income` | Ingreso | Entra dinero; alimenta el reparto a cántaros |
| `expense` | Egreso | Sale dinero; se imputa a un cántaro |
| `transfer` | Transferencia | Mueve dinero **entre cuentas** (no es gasto ni ingreso) |
| `payment` | Pago | Pago que puede dividirse en **varias cuentas** (pago múltiple) |
| `ajuste` | Ajuste | Corrige el saldo de una cuenta sin un movimiento real |

Flag `transactions.include_in_balance` — permite registrar movimientos que NO afectan el saldo
(ej. informativos), y `transactions.category_id` para clasificar.

## 3. Menú de transacciones — opciones (de `TransactionCreateDialog.vue`)

El diálogo de creación cubre, en su forma **avanzada (PRO)**:

1. **Ingreso / Egreso simple** — monto, concepto, cuenta, categoría, cántaro.
2. **Transferencia entre cuentas** — `account_from_id` → `account_to_id`.
   - Soporta **cross-currency**: si las cuentas tienen distinta moneda, pide **tasa** y
     muestra preview (modo multiplicar o dividir).
3. **Pago múltiple (advanced payment)** — un gasto pagado con **varias cuentas a la vez**
   (`payment_transactions`); valida que la suma de pagos cuadre con el total
   (`paymentsMismatch`).
4. **Ítems de transacción (advanced amount)** — desglose por líneas de ítem con **cantidad**
   e **impuestos por ítem** (`item_transactions`, `item_taxes`).
5. **Impuestos** — IGTF 3% y Comisión Pago Móvil 0.30% (`payment_transaction_taxes`),
   aplicables p. ej. a pagos en divisa.
6. **Saldo inicial** — registrar el saldo de apertura de una cuenta.
7. **Tasas** — marcar tasa como "actual" u "oficial" en operaciones con conversión.

## 4. Carga masiva (bulk import)

- Endpoint `/api/v1/transactions/bulk` con **dry-run** (vista previa antes de aplicar).
- Reglas de tipo, mapeo de columnas, y validación de saldo esperado.
- ⚠️ Bugs abiertos relacionados: **BUG-001..005** (reglas de tipo en preview, transfer en
  dry-run, saldo post-import, suite de pruebas mixtas, filtro vs "All"). Ver `BUGS/README.md`.

## 5. Doble eje: cuenta vs cántaro

Cada gasto en **PRO** responde a dos preguntas independientes:
- **¿De dónde salió el dinero?** → una **cuenta** (banco, efectivo, tarjeta…).
- **¿A qué presupuesto pertenece?** → un **cántaro**.

Esta separación es lo que distingue PRO de LITE (donde solo existe el cántaro).
Ver `MODOS_LITE_VS_PRO.md`.
