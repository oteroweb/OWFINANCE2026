TAREA CONCRETA: OWF-221

Lee .owf/STATE.md y .owf/TASKS.md para contexto completo. Luego haz EXACTAMENTE esto:

1. Crea un composable 'src/stores/useUserCurrencies.ts' que sea la fuente de verdad unica para leer/escribir user_currencies:
   - fetchAll() -> GET /api/v1/user-currencies
   - updateRate(code, type, value) -> PUT /api/v1/user-currencies/{id} con current_rate o official_rate
   - 'rates' como ref reactiva compartida
   - upsertFromApi() para mergear respuesta API con estado local

2. Refactoriza ExchangeRatesTable.vue (src/components/ExchangeRatesTable.vue) para usar este store en vez de su logica local.

3. En ProHomeView.vue (src/pages/user/ProHomeView.vue), reemplaza el HTML inline de tasas (lineas 120-152, el bloque 'Exchange Rates Widget') con el componente ExchangeRatesTable.

4. En transactions/index.vue (src/pages/user/transactions/index.vue), el ExchangeRatesWidget inline (linea 4099+), reemplazalo tambien por ExchangeRatesTable.

5. Build de verificacion: cd OWFinanceFrontend2025 && npx quasar build -m spa

6. Actualiza .owf/TASKS.md marcando OWF-221 como [x].

NO toques backend. NO deployes. Solo frontend.
