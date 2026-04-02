# Pruebas Pendientes - Integracion Bulk Import

Fecha: 2026-03-14

## Objetivo
Cubrir todos los escenarios de importacion masiva para evitar regresiones en:
- creacion de transacciones
- deteccion de tipo
- conversion por tasa
- saldo final por cuenta
- reflejo en vista previa y lista final

## Regla Operativa
En cada deploy que toque bulk import o transacciones:
1. ejecutar suite minima obligatoria
2. registrar resultado en esta misma hoja
3. bloquear deploy si falla un caso critico

## Matriz de escenarios

### Modos de entrada
- Excel
- Tabla
- Texto

### Composicion del lote
- Solo gastos
- Solo ingresos
- Solo transferencias
- Mixto (gastos + ingresos + transferencias)

### Cardinalidad
- 1 fila
- Varias filas

## Casos obligatorios

| ID | Modo | Composicion | Cardinalidad | Validaciones clave | Estado |
|---|---|---|---|---|---|
| TST-BULK-001 | Excel | Solo gastos | 1 | dry_run ok, create ok, saldo esperado | pendiente |
| TST-BULK-002 | Excel | Solo gastos | Varias | suma egresos, categorias, saldo | pendiente |
| TST-BULK-003 | Excel | Solo ingresos | 1 | signo correcto, saldo aumenta | pendiente |
| TST-BULK-004 | Excel | Solo ingresos | Varias | suma ingresos, saldo final | pendiente |
| TST-BULK-005 | Excel | Solo transferencias | 1 | 2 payments opuestos, amount raiz, saldo A/B | pendiente |
| TST-BULK-006 | Excel | Solo transferencias | Varias | multiples transferencias, filtros por cuenta | pendiente |
| TST-BULK-007 | Excel | Mixto | Varias | saldo final esperado, vista previa consistente | pendiente |
| TST-BULK-008 | Tabla | Solo gastos | 1 | dry_run ok, create ok, saldo esperado | pendiente |
| TST-BULK-009 | Tabla | Solo gastos | Varias | suma egresos, categorias, saldo | pendiente |
| TST-BULK-010 | Tabla | Solo ingresos | 1 | signo correcto, saldo aumenta | pendiente |
| TST-BULK-011 | Tabla | Solo ingresos | Varias | suma ingresos, saldo final | pendiente |
| TST-BULK-012 | Tabla | Solo transferencias | 1 | 2 payments opuestos, amount raiz, saldo A/B | pendiente |
| TST-BULK-013 | Tabla | Solo transferencias | Varias | multiples transferencias, filtros por cuenta | pendiente |
| TST-BULK-014 | Tabla | Mixto | Varias | saldo final esperado, vista previa consistente | pendiente |
| TST-BULK-015 | Texto | Solo gastos | 1 | dry_run ok, create ok, saldo esperado | pendiente |
| TST-BULK-016 | Texto | Solo gastos | Varias | suma egresos, categorias, saldo | pendiente |
| TST-BULK-017 | Texto | Solo ingresos | 1 | signo correcto, saldo aumenta | pendiente |
| TST-BULK-018 | Texto | Solo ingresos | Varias | suma ingresos, saldo final | pendiente |
| TST-BULK-019 | Texto | Solo transferencias | 1 | 2 payments opuestos, amount raiz, saldo A/B | pendiente |
| TST-BULK-020 | Texto | Solo transferencias | Varias | multiples transferencias, filtros por cuenta | pendiente |
| TST-BULK-021 | Texto | Mixto | Varias | saldo final esperado, vista previa consistente | pendiente |

## Criterios de aceptacion por caso
- dry_run devuelve ok por fila valida
- import real crea exactamente las filas esperadas
- transferencias crean 2 payment_transactions con signos opuestos
- para filas sin items en transfer, amount raiz obligatorio
- saldo de cuentas coincide con calculo manual del lote
- filtro por cuenta muestra movimientos relevantes esperados
- balance corrido en UI consistente tras recalculo

## Bitacora de ejecucion por deploy

| Fecha | Deploy/Commit | Casos ejecutados | Resultado | Observaciones |
|---|---|---|---|---|
| 2026-03-14 | Pendiente | Pendiente | Pendiente | Inicializacion de plan de pruebas |
