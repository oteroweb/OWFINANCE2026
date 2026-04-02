# 🔧 02 - Backend (Laravel 12 + Sanctum)

Documentación técnica completa del backend: arquitectura, endpoints, implementación, integración con frontend, testing y bugfixes.

## Subcategorías

### 📐 [arquitectura/](./arquitectura/) - Diseño del Sistema
Documentación de diseño y arquitectura:
- `jar-system-architecture.md` - Arquitectura del sistema de jarros
- `jar-balance-system.md` - Sistema de saldos (balance) de jarros
- `before-after-architecture.md` - Comparación antes/después de cambios

### 🔗 [endpoints/](./endpoints/) - API Endpoints
Referencias rápidas y especificaciones de endpoints:
- `accounts-endpoints.md` - Endpoints de cuentas
- `jar-quick-reference.md` - Referencia rápida de jarros
- `user-currencies.md` - Currencies y conversiones
- `transaction-payloads.md` - Estructura de payloads de transacciones

### ✅ [implementacion/](./implementacion/) - Cambios Completados
Documentación de implementaciones realizadas:
- `IMPLEMENTATION_SUMMARY.md` - Resumen final del sistema de jarros simplificado
- `IMPLEMENTATION_COMPLETE.md` - Detalles de implementación completada
- `jar-implementation-summary.md` - Resumen específico de jarros
- `ANALISIS_LOGICA_PORCENTAJE_CANTAROS.md` - Análisis de lógica de porcentajes
- `quick-start-jar-sync.md` - Guía rápida de sincronización

### 🔗 [integracion-frontend/](./integracion-frontend/) - Requests & Cambios Frontend
Especificaciones para solicitudes del frontend:
- `SOLICITUD_CAMBIOS_FRONTEND.md` - Solicitud de cambios (principal)
- `SOLICITUD_FRONTEND_INDEX.md` - Índice de solicitudes
- `FRONTEND_INTEGRATION_GUIDE.md` - Guía de integración completa
- `FRONTEND_QUICK_REFERENCE.md` - Referencia rápida para frontend
- `frontend-jar-logic-guide.md` - Guía de lógica para el frontend
- `frontend-code-examples.md` - Ejemplos de código
- `FRONTEND-INDEX.md` & `FRONTEND-SUMMARY.md` - Resúmenes

### 🧪 [testing/](./testing/) - Tests & Validación
Guías de testing y ejemplos:
- `API_TESTING_EXAMPLES.md` - Ejemplos de testing de API
- `jar-testing-guide.md` - Guía de testing para jarros

### 🐛 [bugfixes/](./bugfixes/) - Bugs Resueltos
Documentación de bugs encontrados y solucionados:
- `BUGFIX_SQL_AMBIGUITY.md` - Fix de ambigüedad SQL
- `CORRECCION_ERROR_404_JARROS.md` - Corrección de error 404 en jarros
- `BULK_TRANSFERS_GUARDRAILS.md` - Reglas, escenarios y checklist para importaciones masivas con transferencias

### 📊 [visuales/](./visuales/) - Diagramas y Visuales
Documentación visual del sistema:
- `jar-balance-visual.md` - Guía visual con ejemplos de balances

---

**🔐 Contrato Técnico No-Break:**
- API base: `/api/v1`
- Autenticación: Bearer token Sanctum
- Respuesta: `{ status, code, message, data }`
- Scoping: Por usuario autenticado (transactions, jars, accounts)

**📍 Última actualización:** 2026-03-01
