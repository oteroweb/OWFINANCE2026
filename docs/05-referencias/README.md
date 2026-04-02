# 📚 05 - Referencias & Índices

Índices y referencias cruzadas de toda la documentación. Centro de consulta rápida.

## Índice Maestro

### 🔍 Por Categoría
- [00 - Sistema & Arquitectura](../00-sistema/) - Arquitectura general e integración
- [01 - Configuración](../01-configuracion/) - Variables de entorno y multi-entorno
- [02 - Backend](../02-backend/) - Documentación técnica del backend Laravel
- [03 - Frontend](../03-frontend/) - Documentación técnica del frontend Quasar
- [04 - Mobile](../04-mobile/) - Deployment y desarrollo móvil
- [06 - Recursos Especiales](../06-recursos-especiales/) - Troubleshooting y operaciones

### 🔗 Archivo Especial (RAÍZ)
- **[`AGENTS.md`](../../AGENTS.md)** - Guía para agentes IA (RAÍZ)
  - Mapa rápido del sistema
  - Contratos técnicos NO-BREAK
  - Flujo recomendado de trabajo
  - Comandos base
  - Riesgos conocidos

---

## 🎯 Por Tipo de Tarea

### 📐 Leyendo sobre Arquitectura
1. Empezar en [`AGENTS.md`](../../AGENTS.md)
2. Continuar en [ARQUITECTURA_PROYECTO.md](../00-sistema/ARQUITECTURA_PROYECTO.md)
3. Para backend: [arquitectura/](../02-backend/arquitectura/)
4. Para frontend: [analisis/](../03-frontend/analisis/)

### 🔧 Desarrollando Característica Backend
1. Revisar [`SOLICITUD_CAMBIOS_FRONTEND.md`](../02-backend/integracion-frontend/)
2. Revisar endpoints: [endpoints/](../02-backend/endpoints/)
3. Revisar ejemplos: [frontend-code-examples.md](../02-backend/integracion-frontend/)
4. Revisar testing: [testing/](../02-backend/testing/)
5. Si hay error: [troubleshooting/](../06-recursos-especiales/troubleshooting/)

### 💻 Desarrollando en Frontend
1. Revisar [ANALISIS_LOGICA_ACTUAL.md](../03-frontend/analisis/)
2. Revisar guía: [BACKEND_SPECIFICATIONS.md](../03-frontend/especificaciones/)
3. Revisar ejemplos: [architecture/](../02-backend/arquitectura/)
4. Si hay error: [troubleshooting/](../06-recursos-especiales/troubleshooting/)

### 📱 Deployando a Mobile
1. Revisar [MOBILE_DEPLOYMENT_GUIDE.md](../04-mobile/deployment/)
2. Seguir guía en [operaciones/](../06-recursos-especiales/operaciones/)
3. Usar comando: `./deploy-mobile.sh <target> <env>`

### 🌐 Cambiando Entornos
1. Revisar [ENV_STRATEGY.md](../01-configuracion/)
2. Usar comando: `./switch-env.sh <env>`
3. Ver procedimiento en [operaciones/](../06-recursos-especiales/operaciones/)

### 🚨 Resolviendo Problemas
1. Ver [troubleshooting/](../06-recursos-especiales/troubleshooting/)
2. Revisar diagnóstico rápido
3. Seguir procedimiento de rollback si es necesario

---

## 📋 Referencias Cruzadas Rápidas

| Tema | Recursos |
|------|----------|
| **Sistema General** | [`AGENTS.md`](../../AGENTS.md), [ARQUITECTURA_PROYECTO.md](../00-sistema/) |
| **API Backend** | [endpoints/](../02-backend/endpoints/), [SOLICITUD_CAMBIOS_FRONTEND.md](../02-backend/integracion-frontend/) |
| **Sistema de Jarros** | [jar-system-architecture.md](../02-backend/arquitectura/), [jar-balance-system.md](../02-backend/arquitectura/) |
| **Integración Frontend** | [frontend-jar-logic-guide.md](../02-backend/integracion-frontend/), [ANALISIS_LOGICA_ACTUAL.md](../03-frontend/analisis/) |
| **Testing** | [jar-testing-guide.md](../02-backend/testing/), [API_TESTING_EXAMPLES.md](../02-backend/testing/) |
| **Bugfixes Resueltos** | [bugfixes/](../02-backend/bugfixes/) |
| **Mobile** | [MOBILE_DEPLOYMENT_GUIDE.md](../04-mobile/deployment/) |
| **Configuración** | [ENV_STRATEGY.md](../01-configuracion/) |
| **Troubleshooting** | [troubleshooting/](../06-recursos-especiales/troubleshooting/) |
| **Operaciones** | [operaciones/](../06-recursos-especiales/operaciones/) |

---

## 🔑 Palabras Clave de Búsqueda

- **Jars / Jarros** → [02-backend/arquitectura/](../02-backend/arquitectura/) + [02-backend/endpoints/](../02-backend/endpoints/)
- **Autenticación** → [02-backend/integracion-frontend/](../02-backend/integracion-frontend/) + [`AGENTS.md`](../../AGENTS.md)
- **Porcentajes** → [ANALISIS_LOGICA_PORCENTAJE_CANTAROS.md](../02-backend/implementacion/)
- **Balance** → [jar-balance-system.md](../02-backend/arquitectura/) + [jar-balance-visual.md](../02-backend/visuales/)
- **API /api/v1** → [`AGENTS.md`](../../AGENTS.md) + [endpoints/](../02-backend/endpoints/)
- **Error 404** → [CORRECCION_ERROR_404_JARROS.md](../02-backend/bugfixes/) + [troubleshooting/](../06-recursos-especiales/troubleshooting/)
- **Token Sanctum** → [SOLICITUD_CAMBIOS_FRONTEND.md](../02-backend/integracion-frontend/) + [troubleshooting/](../06-recursos-especiales/troubleshooting/)
- **Entornos (.env)** → [ENV_STRATEGY.md](../01-configuracion/)
- **Mobile Deploy** → [MOBILE_DEPLOYMENT_GUIDE.md](../04-mobile/deployment/) + [operaciones/](../06-recursos-especiales/operaciones/)

---

**📍 Última actualización:** 2026-03-01
