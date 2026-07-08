# OWF Entity Map — Skill de Referencia de Entidades

**Propósito**: Referencia canónica de todas las entidades de la base de datos de OWFINANCE, sus relaciones, y las reglas de negocio críticas que un agente debe conocer antes de tocar código relacionado con datos.

> **Actualizado**: 2026-07-08 desde esquema real de prod (MySQL)

---

## Regla de uso

Antes de implementar cualquier feature o fix que involucre:
- Transacciones, cuentas, categorías, cántaros (jars)
- IA / advisor
- Deudas, sueños, metas

→ **Leer este skill primero** para entender el modelo de datos correcto.

---

## Entidades Core — Finanzas

### `transactions` — Transacción principal
**Columnas**: `id, name, amount, description, date, active, provider_id, url_file, rate_id, transaction_type_id, user_id, account_id, category_id, amount_tax, include_in_balance, deleted_at`

> ⚠️ **NO tiene `jar_id`** en prod MySQL (fue añadida solo al migration local, nunca se corrió ALTER en prod). La relación con jars pasa por `item_transactions.jar_id` o via categoría.

**Regla crítica**: `transactions` es el encabezado. El DETALLE está en `item_transactions`. El sistema de cántaros y la mayoría del reporting lee `item_transactions`, NO `transactions` directamente.

---

### `item_transactions` — Línea de detalle (fuente de verdad para cántaros)
**Columnas**: `id, item_id, quantity, transaction_id, name, amount, tax_id, rate_id, description, jar_id, active, deleted_at, date, category_id, item_category_id, user_id, custom_name, is_fee, fee_type`

**Regla crítica**: `JarBalanceService.calculateSpentAmount()` lee SOLO esta tabla via JOIN con `transactions`. Si una transacción no tiene `item_transaction`, su monto NO se cuenta en ningún cántaro.

**Gotcha**: Transacciones simples (sin items explícitos) deben tener un `item_transaction` default creado automáticamente. Esto lo hace `TransactionController` desde el fix OWF-173 (2026-07-08). Transacciones antiguas se repararon con `transactions:repair-items` + `transactions:repair-item-jar-id`.

---

### `payment_transactions` — Legs de pago (débitos en cuentas)
**Columnas**: `id, transaction_id, account_id, user_currency_id, amount, active, deleted_at`

**Regla crítica**: Una transferencia tiene DOS payment_transactions: una con amount > 0 y otra con amount < 0 en la misma `transaction_id`. La detección de transferencia es: `$hasPos && $hasNeg`.

---

### `accounts` — Cuentas bancarias/wallet
**Columnas**: `id, name, currency_id, initial, balance_cached, balance, account_type_id, active, is_default, include_in_global_balance, deleted_at`

Relacionada con `account_user` (many-to-many con users), `account_folders` (organización), `payment_transactions`.

---

### `categories` — Categorías de gasto/ingreso
**Columnas**: `id, name, icon, active, date, parent_id, transaction_type_id, include_in_balance, type, sort_order, user_id, deleted_at`

Linked a jars via pivot `jar_category`.

---

## Entidades de Cántaros (Jars)

### `jars` — Cántaro (envelope de presupuesto)
**Columnas**: `id, user_id, name, description, percent, refresh_mode, allow_negative_balance, negative_limit, start_date, use_global_start_date, reset_cycle, reset_cycle_day, target_amount, last_reset_date, fixed_amount, type, base_scope, active, sort_order, color, leverage_from_jar_id, deleted_at`

**Dos modos de balance**:
1. **Con categorías** (`jar_category` tiene registros para este jar): `calculateSpentAmount` filtra `item_transactions` via `COALESCE(item_transactions.category_id, transactions.category_id) IN (jar's categories)`
2. **Sin categorías** (directo): filtra `item_transactions.jar_id = jar->id`

→ El modo con categorías es el más común. El modo directo requiere que `item_transactions.jar_id` esté correctamente seteado.

### `jar_category` — Pivot categoría↔cántaro
**Columnas**: `id, jar_id, category_id, active, deleted_at`

Principal lookup para: "¿a qué jar pertenece esta categoría?". Usado por `txCatalog.ts` en frontend via `jarForCategory()`.

### `jar_base_category` — Pivot de categorías base (templates)
Similar a `jar_category` pero para categorías base de templates.

### `jar_cycles` — Ciclos de cántaro
**Columnas**: `id, jar_id, cycle_start_date, cycle_end_date, starting_balance, ending_balance, total_allocated, total_spent, total_adjustments, total_withdrawals, carryover_to_next`

### `jar_adjustments` — Ajustes manuales
### `jar_withdrawals` — Retiros del cántaro
### `jar_transfers` — Transferencias entre cántaros
### `jar_settings` — Config global del usuario para jars
### `jar_leverage_settings` — Config de leveraging mensual
### `jar_monthly_overrides` — Overrides por mes

---

## Entidades de IA

### `ai_conversations` + `ai_conversation_messages`
Thread de chat del advisor. `ai_conversations.status`: active/archived.

### `ai_extractions`
OCR/extracción de texto para crear transacciones. `was_confirmed` = true cuando el usuario aceptó.

### `ai_usage_log`
Log de consumo de tokens por feature y modelo.

### `ai_user_settings`
Perfil del usuario para el advisor: personalidad, goals, onboarding completado.

---

## Entidades de Metas Financieras

### `debts` — Deudas
**Columnas**: `id, user_id, name, provider, merchant, original_amount, balance, next_due_amount, next_due_date, total_installments, paid_installments, rate, status, notes, priority, deleted_at`

### `dreams` — Sueños/metas de ahorro
**Columnas**: `id, user_id, name, emoji, description, target_amount, saved_amount, color, priority, is_completed, completed_at, deleted_at`

**Regla**: Notificaciones usan `saved_amount / target_amount >= 0.5` como trigger de progreso.

---

## Entidades de Configuración

### `users`
**Columnas**: `id, name, phone, occupation, city, country, email, password, balance, monthly_income, currency_id, client_id, active, role_id, deleted_at`

### `currencies` + `user_currencies` + `rates`
Multi-moneda. `user_currencies.is_current` = moneda activa del usuario. `rates` guarda tasas de cambio históricas.

### `transaction_types`
Tipos: income, expense, transfer, etc. Identificados por `slug`.

### `tags` + `transaction_tags` + `item_transaction_tags`
Etiquetas libres para transacciones e items.

### `providers`
Proveedores/comercios: nombre, dirección, email, teléfono.

---

## Diagrama de relaciones clave

```
users
  ├── accounts (via account_user)
  ├── jars
  │     ├── jar_category → categories
  │     ├── jar_cycles
  │     ├── jar_adjustments
  │     ├── jar_withdrawals
  │     └── jar_transfers
  ├── transactions
  │     ├── item_transactions  ← FUENTE DE VERDAD para cántaros
  │     │     ├── jar_id       ← FK a jars (modo directo)
  │     │     └── category_id  ← FK a categories (modo categoría)
  │     └── payment_transactions → accounts
  ├── debts
  ├── dreams
  └── ai_conversations
        └── ai_conversation_messages
```

---

## Comandos de reparación disponibles

```bash
# Crear item_transactions para transacciones sin ellas (no-transfers)
php artisan transactions:repair-items [--execute] [--user=ID]

# Setear jar_id en item_transactions donde es null pero category tiene jar mapeado
php artisan transactions:repair-item-jar-id [--execute] [--user=ID]
```

Ambos son **dry-run por default**. Pasar `--execute` para aplicar.

---

## Gotchas conocidos

| Problema | Causa | Solución |
|----------|-------|----------|
| Cántaro muestra $0 gastado | `item_transactions` vacío para esas txs | Correr `transactions:repair-items --execute` |
| `jar_id=null` en item_transactions | Bug en repair original; pivot jar_category no consultado | Correr `transactions:repair-item-jar-id --execute` |
| `transactions.jar_id` no existe en prod | Columna fue añadida al migration de creación local, sin ALTER migration separado | No leer `transactions.jar_id` en código que corre en prod; usar `item_transactions.jar_id` |
| `jarForCategory()` devuelve null | `loadUserJars()` no llamado antes de submit | `SmartTransactionModal.onShow()` ya llama `loadCategoriesWithJars()` + `loadUserJars()` |
| Transferencia detectada incorrectamente | `payment_transactions` con pos+neg en mismo `transaction_id` | Chequear `$hasPos && $hasNeg` antes de crear item_transaction default |

---

## Cuándo actualizar este skill

- Cuando se agrega una tabla nueva
- Cuando se descubre un gotcha de negocio no documentado aquí
- Cuando cambia una regla crítica (ej. cómo `JarBalanceService` calcula balances)
