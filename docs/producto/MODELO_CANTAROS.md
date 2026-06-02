# Modelo de Cántaros (Jars) — OWFINANCE 2026

> Documento de producto. Describe la dinámica de los cántaros tal como existe en el código
> (`OWFINANCEBackend2025`: `Jar`, `JarSetting`, `JarCycle`, `JarWithdrawal`, `JarTransfer`,
> `JarAdjustment`, `JarTemplate`). Fuente única de la verdad del comportamiento de cántaros.
> Última actualización: 2026-06-02.

## 1. Concepto

Un **cántaro** (jar) es una categoría de presupuesto que recibe un **porcentaje del ingreso**.
El usuario reparte el **100% de su ingreso mensual** entre sus cántaros (método Harv Eker /
"6 jars"). Cada cántaro tiene un **saldo disponible** que sube con los ingresos asignados y
baja con los gastos imputados.

Plantilla por defecto (`JarTemplateSeeder`):

| Cántaro | % | base |
|---------|---|------|
| Necesidades básicas | 55% | todo el ingreso |
| Diversión | 10% | todo el ingreso |
| Ahorro | 10% | todo el ingreso |
| Educación | 10% | todo el ingreso |
| Reservas | 10% | todo el ingreso |
| (libre) | 5% | — |

## 2. Tipos de cántaro (`jars.type`)

| Tipo | Campo | Significado |
|------|-------|-------------|
| `percent` | `percent` (0–100) | Recibe un % del ingreso. Es el modo principal. |
| `fixed` | `fixed_amount` | Recibe un monto fijo por ciclo, no un %. |

**Base de cálculo (`base_scope`)**:
- `all_income` — el % se aplica sobre **todo** el ingreso del ciclo.
- `categories` — el % se aplica solo sobre el ingreso de **ciertas categorías** (pivote `jar_category` / `jar_base_category`).

## 3. Campos de comportamiento (`jars` + `jar_settings`)

| Campo | Rol |
|-------|-----|
| `percent` / `fixed_amount` | Asignación del cántaro |
| `base_scope` | Sobre qué ingreso se calcula |
| `target_amount` | Meta (cántaros de ahorro / objetivo) |
| `allow_negative_balance` + `negative_limit` | Permite sobregiro controlado |
| `refresh_mode` | Cómo se recalcula el disponible |
| `reset_cycle` + `reset_cycle_day` | Si el cántaro se reinicia por ciclo y en qué día |
| `start_date` / `use_global_start_date` | Inicio del cántaro (propio o global) |
| `last_reset_date` | Último reinicio aplicado |
| `status` / `active` | Estado del cántaro |
| `color`, `sort_order` | Presentación |
| `leverage_from_jar_id` | Apalancamiento: de qué cántaro toma prestado (ver §6) |

## 4. Saldo disponible — cómo se compone

```
disponible = asignado_por_ingresos
           − gastos_imputados
           + ajustes_manuales        (tabla jar_adjustments)
           − retiros                 (tabla jar_withdrawals)
           ± transferencias          (tabla jar_transfers)
           ± apalancamiento          (jar_settings.auto_leverage)
```

> Regla de fuente de verdad: los ajustes manuales NO viven en una columna del cántaro;
> viven en `jar_adjustments` (se eliminó la columna `adjustment` legacy). Esto evita
> descuadres y deja trazabilidad.

## 5. Ciclos (`jar_cycles`)

Para no recalcular recursivamente saldos acumulativos, el sistema **materializa** un snapshot
de cada cántaro al inicio del ciclo:
- Comando programado `jars:materialize-cycles` corre el **día 1 de cada mes a las 00:15**
  (`bootstrap/app.php → withSchedule`).
- Guarda saldo de cierre y `total_withdrawals` del ciclo anterior.
- Cántaros acumulativos (ej. Ahorro) arrastran saldo; cántaros de gasto se reinician según
  `reset_cycle`.

## 6. Apalancamiento entre cántaros (leverage)

Permite que un cántaro **tome prestado** disponible de otro cuando se queda corto:
- `jars.leverage_from_jar_id` y `jar_settings.leverage_jar_id` + `auto_leverage_enabled`.
- Tabla `jar_leverage_settings` para configuración fina.
- Caso típico: "Diversión" se apalanca de "Reservas" en lugar de quedar en negativo.

## 7. Operaciones sobre cántaros

| Operación | Tabla | Descripción |
|-----------|-------|-------------|
| Ajuste manual | `jar_adjustments` | Corrige el disponible sin un movimiento real |
| Retiro | `jar_withdrawals` | Saca dinero del cántaro (ej. cumplir meta) |
| Transferencia | `jar_transfers` | Mueve disponible entre dos cántaros |
| Plantilla | `jar_templates` (+ pivotes) | Crea un set de cántaros de golpe |

## 8. Relación con cuentas y transacciones

- En **PRO**, un gasto se registra contra una **cuenta** (de dónde sale el dinero) y se imputa
  a un **cántaro** (a qué presupuesto pertenece). Cuenta y cántaro son ejes independientes.
- En **LITE**, no hay cuentas: el gasto baja directamente el saldo del cántaro.
  Ver `MODOS_LITE_VS_PRO.md`.

Detalle de cuentas y transacciones: `CUENTAS_Y_TRANSACCIONES.md`.
