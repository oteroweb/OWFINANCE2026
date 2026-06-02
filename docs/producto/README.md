# 📦 Producto — Comienza aquí

> Punto de entrada a la documentación de **producto** de OWFINANCE 2026: cómo funciona el
> negocio (cántaros, cuentas, transacciones) y sus **variaciones** (modos LITE / PRO).
> Para el estado del trabajo y tareas: `../../START_HERE.md` y `../../TASKS_LEDGER.md`.
> Última actualización: 2026-06-02.

## 🧭 Qué leer y en qué orden

> 👉 **¿Quieres ver y entender TODO de un vistazo?** Empieza por
> [`PANORAMA_360.md`](./PANORAMA_360.md) — descripción + experiencia de usuario + todas las
> pantallas y funciones + índice de dónde vive cada detalle.

| # | Documento | Qué explica | Estado |
|---|-----------|-------------|--------|
| 0 | [`PANORAMA_360.md`](./PANORAMA_360.md) | **Visión 360**: qué es, UX, mapa de pantallas, catálogo de funciones, variaciones, índice | ✅ |
| 1 | [`MODELO_CANTAROS.md`](./MODELO_CANTAROS.md) | Dinámica de cántaros: %/fijo, base, saldo, ciclos, apalancamiento, ajustes/retiros/transferencias | ✅ |
| 2 | [`CUENTAS_Y_TRANSACCIONES.md`](./CUENTAS_Y_TRANSACCIONES.md) | Tipos de cuenta (banco, tarjeta, efectivo, cashea) y de transacción (income, expense, transfer, payment, ajuste) | ✅ |
| 3 | [`FLUJOS_TRANSACCIONES.md`](./FLUJOS_TRANSACCIONES.md) | Todos los caminos para registrar un movimiento + diagramas Mermaid + propuestas de optimización (P1–P9) | ✅ |
| 4 | [`MODOS_LITE_VS_PRO.md`](./MODOS_LITE_VS_PRO.md) | **Variación principal**: matriz funcional LITE vs PRO + checklist "todo funciona" | ✅ |

## 🎯 Resumen en 30 segundos

- **Cántaros (jars)**: categorías que reciben un % del ingreso; el usuario reparte el 100%.
- **Doble eje en PRO**: cada gasto responde *¿de qué cuenta salió?* (cuenta) y *¿a qué
  presupuesto pertenece?* (cántaro).
- **Modelo de transacción unificado**: `POST /api/v1/transactions` con `payments[]` + `items[]`;
  el tipo se infiere del signo/cantidad de pagos (1=simple, 2 opuestos=transfer, N=split).
- **Dos modos**:
  - **LITE** — cántaros con saldo, **una billetera implícita única** (sin trackeo de cuentas),
    registro rápido. Prioriza facilidad.
  - **PRO** — full: cuentas multi-moneda, transacciones avanzadas (split, items, impuestos,
    cross-currency), bulk import, analítica. Prioriza control.
  - LITE es un **subconjunto** de PRO (misma BD); la transición no pierde datos.

## 🔗 Documentación relacionada

- Arquitectura técnica: [`../ARQUITECTURA_PROYECTO.md`](../ARQUITECTURA_PROYECTO.md)
- Backend (endpoints, jars): [`../02-backend/`](../02-backend/)
- Layouts dinámicos (legacy/pro/lite): [`../03-frontend/SISTEMA_LAYOUTS_DINAMICOS.md`](../03-frontend/SISTEMA_LAYOUTS_DINAMICOS.md)
- Design system: [`../ui-ux/DESIGN_MAP.md`](../ui-ux/DESIGN_MAP.md)
- Reglas para agentes: [`../../AGENTS.md`](../../AGENTS.md)

## 🚧 Huecos de documentación (pendientes)

Para tener el sistema **completo** con todas las posibilidades y variaciones, faltan:
`GLOSARIO`, `MATRIZ_FUNCIONALIDADES`, `CASOS_DE_USO`, `MONEDAS_Y_TASAS`, `IMPUESTOS`,
`CATEGORIAS_E_ITEMS`, `IA_FEATURES`, `ROADMAP_OPTIMIZACIONES` (P1–P9), y en backend
`MODELO_DATOS_ERD`, `SEGURIDAD_Y_PERMISOS`. Ver el mapa completo en `../INDICE_MAESTRO_PROYECTO.md`.
