# Findings — Épica Transacciones OWFinance
**Última actualización:** 2026-06-29

---

## F1 — Arquitectura backend de categorías↔cántaros

La relación categoría→jar NO es una columna directa en `categories`. Existe via:
- **Tabla pivot:** `jar_category` (jar_id, category_id) — ya existe en prod (migración `2025_08_21_000110_create_jar_category_table.php`)
- **Model:** `Category` NO tiene `jars()` belongsToMany definido aún
- **API:** `GET /categories` no incluye jar_id en la respuesta

**Implicación:** El frontend NO puede derivar jar_id desde el API actual. Hay que:
1. Agregar `jars()` al modelo
2. Eager-load el primer jar en el repo
3. Exponer `jar_id` en el response del controller

---

## F2 — Dos flows de form de transacción en el frontend

El sistema tiene DOS flujos paralelos de alta/edición:

**Flow A — SmartTransactionModal** (`SmartTransactionModal.vue`)
- Modal moderno, Lite-first, mobile-friendly
- Tabs: Escribir / Voz / Foto / Auto IA
- Tiene `category_id` ✅
- NO tiene jar selector ni AnchoredJarChip ❌
- NO envía `jar_id` en el POST ❌
- Se abre desde AppShell → QuickActionSheet → `ui.showSmartModal`

**Flow B — TransactionFormDialog** (`TransactionFormDialog.vue` + `useTransactionForm.ts`)
- Dialog legacy completo, Pro-oriented
- Tiene Provider, Account, Rate, TransactionType
- NO tiene `category_id` ni jar ❌❌
- Se abre desde LiteTransactionsView → "Editar" → `ui.openEditTransactionDialog(id)`

**Conclusión:** Hay que actualizar AMBOS flows.

---

## F3 — LiteTransactionsView ya tiene detail sheet básico

En `LiteTransactionsView.vue` líneas 187-250 existe `tx-detail-sheet`:
- **View mode:** muestra tipo, categoría, jarName (si existe), fecha
- **Acciones:** Eliminar (con API delete), Cerrar, Editar
- **Editar** llama `ui.openEditTransactionDialog(id)` → abre TransactionFormDialog (Flow B)
- El dato `detailTx.jarName` y `detailTx.jarColor` están en la interface `TxItem` local
- **Problema:** el API no devuelve jar en la lista de transacciones, así que jarName siempre está vacío

**Para OWF-156:** Hay que:
1. Hacer que el API devuelva jar (via category.jars eager-load)
2. Upgrade el sheet a edición inline (no abrir TransactionFormDialog)
3. Agregar duplicar

---

## F4 — Transaction store: category_id no está tipado

El interface `Transaction` en `transactions.ts` no tiene `category_id`:
```typescript
export interface Transaction {
  id: number
  name: string
  amount: number
  // ... NO tiene category_id ni jar_id
  provider_id: number
  // ...
}
```

La API sí devuelve `category_id` y `category` (relación) — el backend los incluye en el SELECT (línea 38 de TransactionController). Pero el frontend los ignora por falta de tipado.

**Para OWF-153/156:** Hay que extender la interface `Transaction` con `category_id?: number | null`, `category?: { id: number; name: string; jar_id?: number | null } | null`, `jar_id?: number | null`.

---

## F5 — Canonical categories: enfoque global vs por-usuario

El sistema soporta:
- Categorías globales: `user_id = null` (visible para todos)
- Categorías por usuario: `user_id = X`

El endpoint `tree()` ya filtra ambas:
```php
$q->whereNull('user_id')->orWhere('user_id', $effectiveUserId);
```

**Decisión:** Las 15 categorías canónicas del tx-catalog.js se seedean como `user_id = null`. Así están disponibles para todos los usuarios. Si un usuario crea categorías propias, se suman.

---

## F6 — Las 15 categorías canónicas del tx-catalog.js

```
Gastos · j1 (Necesidades básicas 55%):
  1. Vivienda        icon: home
  2. Supermercado    icon: shopping_cart
  3. Servicios       icon: bolt
  4. Transporte      icon: directions_car
  5. Salud           icon: favorite

Gastos · j2 (Diversión 10%):
  6. Restaurantes    icon: restaurant
  7. Entretenimiento icon: sports_esports
  8. Ropa            icon: checkroom
  9. Suscripciones   icon: subscriptions

Gastos · j4 (Educación 10%):
  10. Educación      icon: school
  
Gastos · j3 (Ahorro 10%):
  11. Inversión      icon: trending_up

Gastos · j5 (Reservas 10%):
  12. Otros          icon: category

Ingresos (sin jar):
  20. Salario        icon: payments
  21. Freelance      icon: work
  22. Ingresos       icon: savings
```

**Nota:** Los IDs (1..22) son del tx-catalog.js. En la DB tendrán IDs de auto-increment diferentes. El mapeo se hace por nombre.

---

## F7 — TransactionController ya acepta category_id

`POST /transactions` y `PUT /transactions/:id` ya validan y guardan `category_id`:
- Línea 235: `'category_id' => 'nullable|exists:categories,id'`
- Línea 408: `'category_id' => $request->input('category_id')`
- Línea 765: `if ($request->has('category_id')) { $data['category_id'] = ... }`

**No hay que tocar el TransactionController** para aceptar jar_id — la derivación es responsabilidad del frontend. El backend ya guarda lo que le mandamos.

---

## F8 — Items ya soportan jar_id en el backend

Para ítems individuales de transacciones:
- Línea 247: `'items.*.jar_id' => 'nullable|exists:jars,id'`
- Línea 514: `'jar_id' => $it['jar_id'] ?? null`

Para el feature de monto por artículos (OWF-157), el backend ya lo soporta.

---

## F9 — QuickActionSheet: punto de entrada mobile

`src/components/liquid/QuickActionSheet.vue` es el bottom-sheet en mobile que muestra las opciones rápidas. Probablemente llama a `ui.openSmartModal()`. Para el feature Pro mobile (OWF-157) hay que ver si agregar directamente en este sheet o crear uno separado.

---

## F10 — Jars en prod: nombres vs IDs

Los jars canónicos en el sistema:
- En la DB: IDs auto-increment (pueden ser 1, 2, 3, 4, 5)
- En tx-catalog.js: IDs string `j1..j5`
- Los nombres coinciden: "Necesidades básicas", "Diversión", "Ahorro", "Educación", "Reservas"

**Para el seeder (OWF-160):** buscar jars por `name` en la DB, no por ID numérico.
