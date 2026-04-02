# Análisis de Campos - Carga Masiva vs Formulario Completo

**Fecha**: 2026-03-10  
**Estado**: Implementación V1 (campos básicos) + Plan de mejora

---

## 📋 Comparativa: Campos Soportados

| Campo | Form (CreateDialog) | Carga Masiva V1 | Falta | Notas |
|-------|------|------|-------|-------|
| **Transaction Type** | ✅ transaction_type_id | ⚠️ Pasa como string | ❌ Necesita ID mapping | Crítico para diferencia entre ingreso/egreso/transfer |
| **Concepto/Nombre** | ✅ name | ✅ name | - | OK |
| **Fecha** | ✅ datetime | ✅ date | - | OK (sin hora) |
| **Categoría** | ✅ category_id | ✅ category_name → lookup | - | OK (lookup por nombre) |
| **Proveedor** | ✅ provider_id | ❌ | ❌ **FALTA** | Importante para gastos |
| **Descripción** | ✅ description | ❌ | ❌ **FALTA** | Opcional pero útil |
| **URL Archivo** | ✅ url_file | ❌ | ❌ **FALTA** | Support de comprobantes |
| **Monto** | ✅ amount | ✅ amount | - | OK |
| **Account** | ✅ account_id | ✅ Por nombre → lookup | - | OK (lookup) |
| **Items (líneas)** | ✅ items[] | ✅ items[] | - | OK (básico) |
| **Item.amount** | ✅ | ✅ | - | OK |
| **Item.quantity** | ✅ | ❌ | ❌ **CRÍTICO** | Falta en construcción de items |
| **Item.category** | ✅ item_category_id | ❌ | ❌ **CRÍTICO** | Categoría de línea de factura |
| **Item.description** | ✅ | ❌ | ❌ | Descripción de ítem |
| **Payments** | ✅ payments[] | ✅ payments[] | - | OK (básico) |
| **Payment.account_id** | ✅ | ✅ | - | OK |
| **Payment.amount** | ✅ | ✅ | - | OK |
| **🔴 TASAS (RATES)** | ✅ p.rate | ❌ | ❌ **CRÍTICO** | **FALTA COMPLETAMENTE** - Para cross-currency |
| **is_current** | ✅ p.rateMarkCurrent | ❌ | ❌ | Marcar como tasa actual |
| **is_official** | ✅ p.rateMarkOfficial | ❌ | ❌ | Marcar como tasa oficial |
| **Tax** | ✅ p.tax_id | ❌ | ❌ **IMPORTANTE** | Impuestos en pagos |
| **Tax Amount** | ✅ amount_tax | ❌ | ❌ | Monto de impuesto |
| **Include in Balance** | ✅ include_in_balance | ✅ | - | OK (default true) |
| **Active** | ✅ active | ❌ | ❌ | Transacción activa/inactiva |

---

## 🚨 Campos CRÍTICOS que Faltan

### 1. **Tasas de Cambio (rate)** - PRIORIDAD 1
   - **Impacto**: Sin esto, transferencias cross-currency FALLARÁN
   - **Dónde se necesita**: En `payments[*].rate`
   - **Ejemplo**: Si transfiero USD → EUR, necesito especificar el rate 1 USD = X EUR
   - **Solución propuesta**:
     - Agregar columna `Tasa` en TABLA (input numérico opcional)
     - Agregar columna `Tasa` en EXCEL (optional)
     - Agregar campo `tasa` en TEXTO (después de monto)
     - Auto-detectar si es cross-currency y REQUERIR la tasa

### 2. **Tipo de Transacción (transaction_type_id)** - PRIORIDAD 1
   - **Impacto**: CRÍTICO - Determina si es ingreso, egreso o transferencia
   - **Estado actual**: Se pasa como string ('expense', 'income', 'transfer')
   - **Problema**: Backend si requiere transmission_type_id, no el slug
   - **Solución**:
     - Mapear slugs a IDs de transaction_types
     - O requerir ID en lugar de string

### 3. **Cantidad (quantity) en items** - PRIORIDAD 2
   - **Impacto**: Items con cantidad > 1 no se calculan correctamente
   - **Ejemplo**: 10 unidades × $5 = $50, pero si no se pasa quantity=10, se usa 1 implícito
   - **Solución**: Soportar `cantidad` o `quantity` en modo TABLA y TEXTO

### 4. **Categoría de Ítem (item_category_id)** - PRIORIDAD 2
   - **Impacto**: Líneas de factura sin categorización
   - **Solución**: Lookup por nombre (como con categorías de transacción)

### 5. **Proveedor (provider_id)** - PRIORIDAD 3
   - **Impacto**: Gastos sin asociación a proveedor
   - **Solución**: Lookup por nombre o crear automáticamente

### 6. **Impuestos (taxes)** - PRIORIDAD 3
   - **Impacto**: No se capturan montos de impuesto
   - **Solución**: Soportar `impuesto` o `tax_id` en payments

---

## 📊 Campos por Modo de Entrada

### TABLA (actualmente)
```
Fecha | Concepto | Tipo | Monto | Cuenta | Categoría
```

**Propuesta mejorada**:
```
Fecha | Concepto | Tipo | Monto | Cantidad | Cuenta | Categoría | Tasa | Impuesto | Proveedor
```

### EXCEL (actualmente)
Detecta automáticamente basado en headers multiidioma
```
Fecha/fecha/Date/date
Concepto/concepto/Name/name
Tipo/tipo/Type/type
Monto/monto/Amount/amount
Cuenta/cuenta/Account/account
Categoría/categoria/Category/category
```

**Propuesta mejorada**:
```
+ Tasa/tasa/Rate/rate
+ Impuesto/impuesto/Tax/tax_id
+ Cantidad/cantidad/Quantity/quantity
+ Proveedor/proveedor/Provider/provider_id
+ Descripción/descripción/Description/description
```

### TEXTO (actualmente)
```
fecha;concepto;tipo;monto;cuenta;categoría
```

**Propuesta mejorada**:
```
fecha;concepto;tipo;monto;cantidad;cuenta;categoría;tasa;impuesto;proveedor;descripción
```

Con soporte para múltiples separadores (`;`, TAB, `,`, `|`)

---

## 🛠️ Plan de Mejora - Fases

### Fase 1 (URGENTE - próxima)
- [ ] Agregar soporte para **Tasa (rate)** en los 3 modos
- [ ] Validar que si es cross-currency, tasa sea REQUERIDA
- [ ] Mapear transaction_type como string → ID correcto
- [ ] Agregar **Cantidad** en items

### Fase 2 (IMPORTANTE)
- [ ] Agregar **Categoría de Ítem** (item_category_id)
- [ ] Agregar **Proveedor** con lookup/auto-create
- [ ] Agregar **Impuestos** en payments

### Fase 3 (MEJORAS)
- [ ] Agregar **Descripción** de transacción
- [ ] Agregar **URL Archivo** para comprobantes
- [ ] Agregar **Active** flag

---

## 💾 Ejemplo de Carga Completa (EXCEL)

| Fecha | Concepto | Tipo | Monto | Cantidad | Cuenta Origen | Categoría | Tasa | Proveedor |
|-------|----------|------|-------|----------|---------------|-----------|------|-----------|
| 2026-03-10 | Compra Supermercado | expense | 150.00 | 1 | Tarjeta Crédito | Alimentos | - | Carrefour |
| 2026-03-10 | Transferencia USD→EUR | transfer | 1000.00 | 1 | Cuenta USD | - | 0.92 | - |
| 2026-03-11 | Venta Producto | income | 500.00 | 5 | Cuenta Banco | Ventas | - | Cliente ABC |

---

## 📝 Notas Técnicas

### Backend (TransactionBulkService.php)
✅ Soporta todos estos campos en `validateRow()`:
- transaction_type_id, provider_id, amount_tax, rate_id
- items[*].quantity, items[*].tax_id, items[*].rate_id, items[*].category_id
- payments[*].rate, payments[*].is_current, payments[*].is_official

❌ LO QUE FALTA:
- Validación de transaction_type_id (actualmente falta maps string → ID)
- Auto-creation de provider (si no existe)

### Frontend (TransactionBulkImportDialog.vue)
✅ Soporta:
- Lookup de account por nombre
- Lookup de category por nombre
- Normalización desde Excel/Texto

❌ LO QUE FALTA:
- Lookup de transaction_type (string → ID)
- Campos de rate, quantity, provider
- Auto-fill de rates si es cross-currency

---

## 📌 Recomendación Inmediata

**PARA USAR HOY**:
- ✅ Carga masiva funciona para transacciones simples (1 cuenta)
- ✅ Funciona para cross-currency SI incluyes la TASA en el monto como "1000.00@0.92"
- ⚠️ Mejor hacer CARGA MASIVA + AJUSTES MANUALES hasta Fase 1

**ANTES DE USAR EN PRODUCCIÓN**:
- [ ] Implementar Fase 1 (Tasas, Cantidad, Transaction Type mapping)
- [ ] Agregar validación robusta de cross-currency
- [ ] Agregar tests para todos los casos

