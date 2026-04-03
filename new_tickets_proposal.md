# Propuesta de Nuevos Tickets para Notion (Backlog OW Finance 2026)

Por favor, revisa esta propuesta de los 6 nuevos tickets. Una vez los apruebes, los subiremos al servidor de Notion y prepararé los mockups interactivos (como el del Perfil con Sueños/Obstáculos).

---

## 6. Cuentas de Deuda Bidireccional (Ajenas)

### Información Básica
- **Name:** Implementar Cuentas de Deuda Bidireccionales (Ajenas)
- **Status:** To Do
- **Priority:** Alta
- **Role:** Backend, Fullstack
- **Estimación de Horas:** 12 a 16 horas

### User Story
"Como usuario que presta y pide dinero, quiero poder registrar cuentas de 'Deuda' donde el balance inicie en negativo (si yo debo dinero) o en positivo (si me deben a mí), para tener claro mi patrimonio real líquido."

### Criterios de Aceptación
- Nuevo `type` de cuenta en BD: `debt_payable` (lo que debo, balance negativo) y `debt_receivable` (lo que me deben, balance positivo).
- Al crear la cuenta, el usuario debe indicar quién es la contraparte (Nombre del deudor/acreedor).
- Estas cuentas deben restar o sumar del "Patrimonio Neto" global, pero aislarse del "Dinero Disponible" diario.

---

## 7. Cuentas Crypto con Interés Compuesto (Estilo Binance Earn)

### Información Básica
- **Name:** Soporte para Cuentas Crypto con Cálculo de Interés Compuesto
- **Status:** To Do
- **Priority:** Media
- **Role:** Backend, Finanzas
- **Estimación de Horas:** 16 a 24 horas

### User Story
"Como inversor, quiero poder tracking de mis saldos en Crypto (ej. USDT en Binance Earn) y visualizar cómo el interés compuesto diario afecta mi balance automáticamente sin tener que registrar centavos a mano."

### Criterios de Aceptación
- Nuevo `type` de cuenta: `crypto_earn`.
- Campo para configurar el **APY (Annual Percentage Yield)**.
- Un CRON job diario en Laravel que calcule el rendimiento del día sumando el interés compuesto al capital.
- Registro visual en el frontend mostrando "Rendimiento acumulado" separado del "Capital aportado".

---

## 8. Cuentas de Financiamiento "Cashea" (BNPL atado a BCV)

### Información Básica
- **Name:** Integración de Cuentas tipo "Cashea" (BNPL anclado a Tasa BCV)
- **Status:** To Do
- **Priority:** Alta
- **Role:** Backend, Contexto Local (Venezuela)
- **Estimación de Horas:** 20 a 24 horas

### User Story
"Como usuario en Venezuela que usa Cashea, quiero poder registrar una compra a cuotas financiadas sin interés, pero donde la deuda total varíe dinámicamente según la tasa oficial del BCV del día en que me toque pagar mi cuota (cada 14 días)."

### Criterios de Aceptación
- Generador automático de plan de pagos (Inicial + 3 cuotas cada 14 días).
- La deuda *se debe registrar nativamente en USD*, pero la UI debe mostrar su equivalente adeudado en VES actualizándose en tiempo real según la tasa BCV diaria.
- Aleras ("Notificaciones") 2 días antes del vencimiento de cada cuota.

---

## 9. Sincronización Automática de Tasa BCV (Scraper / API)

### Información Básica
- **Name:** Cronjob de Actualización Automática Tasa BCV (2x al día)
- **Status:** To Do
- **Priority:** Crítica
- **Role:** Backend, Infraestructura
- **Estimación de Horas:** 8 a 12 horas

### User Story
"Para asegurar que mis cántaros y deudas en Bolívares sean precisos, quiero que el sistema actualice automáticamente la tasa del Banco Central de Venezuela dos veces al día sin que yo tenga que ingresarla manual."

### Criterios de Aceptación
- CRON Job programado en Laravel (ej. 8:30 AM y 1:00 PM).
- Scraper seguro o conexión a API pública confiable para extraer la tasa oficial USD/VES.
- Almacenamiento histórico de tasas en base de datos (`exchange_rates_history`) para poder recalcular transacciones pasadas si hace falta.
- Notificación silenciosa en el Dashboard cuando la tasa se actualizó.

---

## 10. Perfil: Formulario Tabular de "Sueños y Metas"

### Información Básica
- **Name:** Formulario Dinámico de Sueños y Metas en Perfil
- **Status:** To Do
- **Priority:** Media
- **Role:** UX/UI, Frontend
- **Estimación de Horas:** 10 a 14 horas

### User Story
"Como usuario que planifica su futuro, quiero una sección en mi perfil financiero donde pueda listar mis Sueños/Metas (ej. Viaje a Japón, Comprar Auto) en formato tabular, asignándoles costo estimado y prioridad, para que el Coach IA los conozca."

### Criterios de Aceptación
- Componente Vue: `ProfileGoalsTable.vue` con capacidad de "Agregar Fila" dinámica.
- Columnas: Nombre de la Meta, Costo Estimado (USD), Plazo (Meses), Importancia (1-5).
- Los datos deben agregarse al array JSON del `financial_profile_context` para que el LLM del Coach IA los use para recomendar cuánto asignar a cada Cántaro.

---

## 11. Perfil: Identificación de "Obstáculos" Financieros

### Información Básica
- **Name:** Formulario Tabular de Obstáculos y Fricciones
- **Status:** To Do
- **Priority:** Media
- **Role:** UX/UI, Frontend
- **Estimación de Horas:** 8 a 12 horas

### User Story
"Quiero poder listar en mi perfil los obstáculos o fricciones que afectan mis finanzas (ej. Ayuda mensual a un familiar, Gastos médicos crónicos, Adicción a compras compulsivas), para que la IA entienda mi realidad y me aconseje mejor."

### Criterios de Aceptación
- Componente Vue: `ProfileObstaclesTable.vue`.
- Columnas: Tipo de Obstáculo (Emocional/Fijo/Imprevisto), Descripción corta, Impacto estimado mensual.
- Actualización de los mockups en StitchMCP para incluir estas dos nuevas tablas (Sueños y Obstáculos) en la vista de **Settings Desktop Pro**.
