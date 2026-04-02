# BUG-004 - Falta de pruebas mixtas bulk (transfer + ingreso + egreso + saldo esperado)

## Estado
- Estado: `todo`
- Prioridad: `alta`
- Fecha registro: `2026-03-14`
- Reportado por: usuario

## Modulo
- Frontend + Backend bulk import
- Endpoint: `POST /api/v1/transactions/bulk`
- Impacto: saldos de cuenta, vista previa, resultados post-import

## Descripcion
Actualmente no existe una suite de prueba robusta que cubra un lote mixto realista con:
- egresos
- ingresos
- transferencias
- validacion de saldo final esperado por cuenta

Esto permite regresiones donde una parte del lote funciona (egresos) pero otra falla o no impacta saldo como corresponde (transferencias), sin detectar el problema antes.

## Resultado actual
- Se detectan inconsistencias en runtime/manualmente.
- No hay evidencia automatizada de saldo final esperado tras import mixto.

## Resultado esperado
- Tener pruebas automatizadas que aseguren:
  1. `dry_run` valida correctamente filas mixtas.
  2. `dry_run=false` crea correctamente filas mixtas.
  3. El saldo final de la cuenta coincida con el saldo esperado del lote.
  4. Transferencias queden reflejadas en la cuenta destino/origen según filtros.

## Escenario minimo sugerido para test
Lote de 4 filas:
1. Egreso en cuenta A.
2. Ingreso en cuenta A.
3. Transferencia A -> B (2 payments, amount raiz, items vacio).
4. Egreso en cuenta B.

Aserciones clave:
- Conteo de creadas/fallidas.
- Existencia de 2 payment_transactions en transferencia.
- Saldo recalculado A y B despues de import.
- Coincidencia con saldo esperado manual del lote.

## Checklist de futura solucion
1. Crear tests de backend para lote mixto (feature/integration).
2. Crear al menos un test frontend/e2e de flujo de UI con vista previa.
3. Validar serializacion final del payload (snapshot o assert estructural).
4. Integrar pruebas en pipeline antes de deploy.
