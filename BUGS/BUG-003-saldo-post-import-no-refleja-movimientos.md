# BUG-003 - Saldo post-import no refleja movimientos reales inmediatamente

## Estado
- Estado: `todo`
- Prioridad: `alta`
- Fecha registro: `2026-03-14`
- Reportado por: usuario

## Modulo
- Frontend transacciones + balances
- Pantalla: `user/transactions` (tabla con columna Balance)
- Flujo: despues de importar desde carga masiva

## Descripcion
Justo despues de importar, el saldo mostrado de la cuenta y la corrida de balance no reflejan los movimientos esperados. En algunos casos la tabla muestra pocos movimientos o calculo no real.

## Evidencia reportada
- Captura posterior a import con saldo visible no consistente.
- Se observa diferencia entre saldo esperado por fuente y saldo mostrado en UI.
- Se indica que no muestra movimientos esperados inmediatamente despues del import.

## Pasos para reproducir
1. Ejecutar import masivo (dry_run=false).
2. Volver a `user/transactions` filtrando una cuenta y periodo.
3. Revisar banner de saldo y columna balance corrido.
4. Comparar contra movimientos realmente importados / fuente.

## Resultado actual
- Saldo post-import puede quedar desfasado.
- Lista visible puede no reflejar todos los movimientos esperados al instante.

## Resultado esperado
- Tras import exitoso, refresco consistente de:
  - saldo de cuenta
  - lista de movimientos del periodo
  - balance corrido

## Hipotesis tecnicas
- Orden de refresco entre `runFetch`, `fetchSingleAccountBalance` y eventos globales.
- Race condition entre recalc backend y fetch inmediato frontend.
- Filtros activos (cuenta/periodo/paginacion) ocultan parte de movimientos nuevos.

## Checklist de futura solucion
1. Forzar secuencia estable tras import: recalc -> fetch lista -> fetch saldo -> recomputar running balance.
2. Agregar telemetria/console debug temporal de pipeline de refresco.
3. Test funcional con import y validacion del saldo final esperado.
