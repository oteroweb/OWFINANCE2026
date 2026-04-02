# Analisis e Instrucciones - Carga Masiva de Transacciones

Fecha: 2026-03-09
Scope: OWFINANCEBackend2025 + OWFinanceFrontend2025

## 1) Objetivo de la futura tarea
Implementar carga masiva de transacciones por tres vias:
- formulario tabular (multiples filas)
- importacion de Excel (.xlsx)
- pegado de texto masivo separado por `;` y por nuevas lineas

Sin romper contratos actuales (`/api/v1`, Sanctum, envelope de respuesta, logica de balances/cuentas/jars).

## 2) Resultado del analisis (estado actual)

### 2.1 Backend (Laravel)
Estado actual:
- Existe CRUD individual de transacciones en `routes/api/transactions.php` y `TransactionController`.
- Ruta principal de creacion actual: `POST /api/v1/transactions` (`save`).
- No existe endpoint batch para transacciones actualmente.
- El `save` actual ya tiene logica compleja de validacion y negocio:
  - valida `items` y `payments`
  - valida permisos de cuentas por usuario
  - maneja conversion por tasas
  - recalcula balances de cuentas afectadas
  - diferencia flujos de ingreso/egreso/transferencia

Archivos clave revisados:
- `OWFINANCEBackend2025/routes/api/transactions.php`
- `OWFINANCEBackend2025/app/Http/Controllers/Api/TransactionController.php`
- `OWFINANCEBackend2025/bootstrap/app.php` (prefijo `/api/v1` por agrupacion de `routes/api/*.php`)

Patrones reutilizables encontrados para batch:
- `UserJarController::bulkUpsertJars` (validacion por elemento, transaccion DB, respuesta estandar)
- `JarMonthlyOverrideController::bulkUpsert` (pre-validaciones globales + respuesta estructurada)

Tests existentes relacionados:
- `tests/Feature/Api/TransactionTest.php`
- `tests/Feature/Api/AccountBalanceTest.php`

### 2.2 Frontend (Quasar/Vue)
Estado actual:
- El store `transactions` solo maneja create/update/delete individuales (`addTransaction`, `updateTransaction`).
- UI de creacion actual (`TransactionCreateDialog`) ya construye payload sofisticado (items/payments, signos, tasas, transferencias).
- No hay modulo para importacion masiva de transacciones.
- No hay dependencia para leer Excel (`xlsx`/SheetJS no esta en `package.json`).

Archivos clave revisados:
- `OWFinanceFrontend2025/src/stores/transactions.ts`
- `OWFinanceFrontend2025/src/components/TransactionCreateDialog.vue`
- `OWFinanceFrontend2025/src/pages/user/transactions/index.vue`
- `OWFinanceFrontend2025/package.json`

Conclusiones frontend:
- Conviene reutilizar reglas de armado de payload desde la logica actual de dialogo.
- Conviene agregar una pantalla/modal dedicada de "Carga masiva" en `user/transactions`.

## 3) Gap exacto vs requerimiento
Falta construir:
- endpoint backend para insercion masiva
- contrato de respuesta por fila (exitos/errores parciales)
- parser de Excel
- parser de texto (`;` + newline)
- UI tabular editable para multiples filas
- vista previa y validacion antes de confirmar importacion

## 4) Diseno propuesto (implementacion futura)

### 4.1 API nueva recomendada
Agregar endpoint:
- `POST /api/v1/transactions/bulk`

Request propuesto:
```json
{
  "mode": "table|excel|text",
  "dry_run": false,
  "rows": [
    {
      "name": "Supermercado",
      "date": "2026-03-09 10:20:00",
      "transaction_type_id": 2,
      "provider_id": null,
      "category_id": 15,
      "include_in_balance": true,
      "items": [
        { "name": "Compra", "amount": -35.5, "item_category_id": 15 }
      ],
      "payments": [
        { "account_id": 3, "amount": -35.5, "rate": 1, "is_current": null, "is_official": null }
      ],
      "client_row_id": "row-1"
    }
  ]
}
```

Response propuesta:
```json
{
  "status": "OK",
  "code": 200,
  "message": "Bulk processed",
  "data": {
    "total": 20,
    "created": 18,
    "failed": 2,
    "results": [
      { "index": 0, "client_row_id": "row-1", "ok": true, "transaction_id": 1234 },
      { "index": 1, "client_row_id": "row-2", "ok": false, "errors": { "payments": ["..."], "amount": ["..."] } }
    ]
  }
}
```

Reglas backend recomendadas:
- `DB::transaction` por fila (no por todo el lote), para permitir exito parcial.
- Reutilizar logica de `TransactionController::save` en un servicio comun para evitar duplicar reglas.
- Mantener enforcement de ownership/autorizacion de cuentas por usuario.
- Mantener recalc de balances por transaccion creada.
- Soportar `dry_run=true` (valida todo, no persiste) para vista previa segura.

### 4.2 Frontend - experiencia de usuario
Agregar en `user/transactions` boton: `Carga masiva`.
Modal/pantalla con 3 tabs:
- Tab 1: `Tabla`
  - grid editable con columnas base
  - agregar/eliminar filas
  - validacion inline por celda
- Tab 2: `Excel`
  - upload `.xlsx`
  - seleccion de hoja
  - mapeo columnas -> campos internos
  - preview de N filas
- Tab 3: `Texto`
  - textarea masiva
  - formato por linea con `;`
  - ejemplo:
    - `2026-03-09 10:00:00;Supermercado;expense;35.50;Cuenta Principal;Alimentos`
    - `2026-03-09 12:00:00;Salario;income;1200;Cuenta USD;Nomina`

Flujo recomendado:
1. Captura (tabla/excel/texto)
2. Normalizacion a `rows[]`
3. Validacion local + `dry_run` backend
4. Correccion de filas con error
5. Confirmar importacion real
6. Resumen final (creadas/fallidas + descarga de errores CSV)

### 4.3 Parseo de texto (`;` y nuevas lineas)
Reglas recomendadas:
- Delimitador principal por linea: `;`
- Soportar encabezado opcional
- Ignorar lineas vacias
- Trim de espacios
- Formato minimo de columna sugerido:
  - `fecha;concepto;tipo;monto;cuenta;categoria;descripcion`
- `tipo` aceptar alias: `income|ingreso`, `expense|egreso|gasto`, `transfer|transferencia`
- `monto` aceptar coma o punto decimal (normalizar)

### 4.4 Excel
Recomendacion tecnica:
- agregar dependencia `xlsx` (SheetJS)
- convertir hoja a JSON y mapear con encabezados flexibles
- vista de mapeo con sugerencias automaticas por nombre de columna

## 5) Instrucciones de implementacion (orden sugerido)

### Fase A - Backend primero
1. Crear servicio de dominio, por ejemplo `TransactionBulkService`, que reutilice reglas de guardado actuales.
2. Agregar metodo `bulkSave` en `TransactionController`.
3. Registrar ruta `POST /transactions/bulk` en `routes/api/transactions.php`.
4. Implementar `dry_run` y resultado por fila.
5. Agregar tests feature:
   - exito parcial
   - todo valido
   - todo invalido
   - permisos de cuenta
   - recalculo de balances

### Fase B - Frontend carga masiva
1. Crear componente nuevo, por ejemplo `TransactionBulkImportDialog.vue`.
2. Agregar accion store `bulkAddTransactions(payload)` en `stores/transactions.ts`.
3. Implementar parser texto `;` + newline.
4. Implementar import Excel con `xlsx`.
5. Implementar tabla editable + validacion cliente.
6. Integrar `dry_run` + confirmacion + resumen final.

### Fase C - Integracion UX
1. Boton `Carga masiva` en `user/transactions/index.vue`.
2. Plantilla de ejemplo descargable (`csv/xlsx`) desde la UI.
3. Mensajeria clara de errores por fila y scroll directo a filas invalidas.

## 6) Riesgos y cuidados
- No romper flujo existente de creacion individual.
- Mantener contrato de seguridad (auth + account ownership).
- Cuidado con signos de montos (income/expense/transfer).
- Cuidado con conversion de moneda y tasas en lote.
- Cuidado con performance (lotes grandes): usar chunks (ejemplo 100 filas por request).

## 7) Definicion de terminado (DoD)
- Se pueden cargar multiples transacciones por tabla, excel y texto.
- Soporte de separador `;` + nuevas lineas confirmado.
- Errores se muestran por fila sin perder las filas validas.
- Backend responde con resumen detallado de creadas/fallidas.
- Tests backend nuevos en verde.
- Lint frontend en verde.

## 8) Estimacion alta nivel
- Backend batch + tests: 1.5 a 2.5 dias
- Frontend (3 tabs + parsers + UX): 2 a 3.5 dias
- Integracion + ajustes + QA: 1 a 1.5 dias
- Total estimado: 4.5 a 7.5 dias de trabajo
