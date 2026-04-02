# Arquitectura del Proyecto OWFINANCE2026

## 1. Resumen ejecutivo
OWFINANCE2026 es un sistema financiero con dos aplicaciones desacopladas:
- Backend API en Laravel (`OWFINANCEBackend2025`)
- Frontend Quasar/Vue para web y mobile (`OWFinanceFrontend2025`)

Operacion diaria en local se coordina desde scripts de la raiz del workspace.

## 2. Topologia

```text
[Web Quasar SPA] ----\
                      \--> [Laravel API /api/v1] ---> [MySQL/SQLite]
[Mobile Capacitor] ---/
```

Notas:
- El frontend consume API via Axios con token bearer.
- Mobile usa el mismo frontend compilado via Capacitor.

## 3. Backend (OWFINANCEBackend2025)

### 3.1 Stack y estructura
- Laravel 12, PHP >= 8.2, Sanctum, Scribe.
- Controladores: 34
- Modelos: 55
- Servicios: 5
- Migraciones: 76
- Tests: 27 archivos feature/testcase

Directorios clave:
- `app/Http/Controllers/Api`
- `app/Models/Entities` y `app/Models/Repositories`
- `app/Services`
- `routes/api/*.php`
- `database/migrations`

### 3.2 Enrutamiento y versionado
- El prefijo real de API es `/api/v1` y se aplica globalmente en `bootstrap/app.php`.
- Las rutas se cargan por archivo en `routes/api/`.
- Endpoints principales:
  - `auth`
  - `users`, `profile`
  - `accounts`, `account_types`, `account-folders`
  - `transactions`, `payment-transactions`, `item_transactions`
  - `categories`, `items`, `taxes`, `providers`, `clients`
  - `jars`, `jar-templates`, settings y balance de jars

### 3.3 Patrones de dominio
- Enfoque controller + repository.
- Respuesta de API en envelope `{status, code, message, data}`.
- Policias registradas para recursos sensibles (Jar, Category, Transaction, etc).
- Observer de transacciones (`TransactionObserver`).
- Tarea programada mensual:
  - comando `jars:materialize-cycles` (1ro de cada mes 00:15).

### 3.4 Autenticacion y autorizacion
- Sanctum por token personal.
- Frontend envia bearer token.
- Varios endpoints usan `auth:sanctum`; otros aun expuestos solo con middleware `api`.

## 4. Frontend (OWFinanceFrontend2025)

### 4.1 Stack y estructura
- Quasar 2, Vue 3, TypeScript, Pinia, Axios.
- Paginas: 46
- Componentes: 22
- Stores: 8
- Composables: 4

Directorios clave:
- `src/pages` (admin y user)
- `src/components`
- `src/stores`
- `src/boot/axios.ts`
- `src/router/routes.ts`

### 4.2 Flujo de sesion y API
- `src/boot/axios.ts` define `baseURL` desde `VITE_API_BASE_URL`.
- Interceptor request agrega `Authorization: Bearer <token>`.
- Interceptor response normaliza errores usando envelope backend.
- `src/stores/auth.ts` persiste sesion en localStorage.

### 4.3 Ruteo UI
- Layouts separados por rol:
  - `/admin/*`
  - `/user/*`
- Guard de router valida autenticacion y rol.

## 5. Mobile (Capacitor)

- Config en `src-capacitor/capacitor.config.json`.
- Scripts de soporte:
  - `dev-mobile.sh` (hot reload Android)
  - `deploy-mobile.sh` (android/ios/both + dev/staging/prod)
  - `build-apk.sh`, `deploy-android.sh`

## 6. Operacion y despliegue

### 6.1 Desarrollo local
Desde raiz:
- `./switch-env.sh local`
- `./dev-start.sh`

Servicios esperados:
- Backend en `:8000`
- Frontend en `:3000`

### 6.2 Backend deploy remoto
- Script release style: `OWFINANCEBackend2025/deploy/remote_deploy.sh`
- Workflow CI existente: `.github/workflows/deploy.yml` (requiere hardening y validacion funcional).

### 6.3 Mobile deploy
- Principal: `./deploy-mobile.sh [android|ios|both] [dev|staging|prod]`

## 7. Evaluacion tecnica (hallazgos)

### 7.1 Fortalezas
1. Estructura modular clara por dominios.
2. Contrato envelope backend/frontend relativamente consistente.
3. Scripteria amplia para desarrollo local y mobile.
4. Cobertura de tests backend no trivial para APIs principales.

### 7.2 Riesgos e inconsistencias
1. Inconsistencia de versionado API en scripts:
   - `env-config.sh` genera `/api` mientras el backend expone `/api/v1`.
2. Documentacion desalineada:
   - README raiz indica Laravel 11, pero composer usa Laravel 12.
3. Seguridad de rutas:
   - Algunas rutas de dominio parecen carecer de `auth:sanctum` y deberian revisarse.
4. CI/CD backend:
   - `deploy.yml` tiene bloque shell complejo y friccion potencial; necesita simplificacion y prueba en entorno controlado.
5. Git distribuido:
   - Backend y frontend son repos separados; release management requiere disciplina por repo.

## 8. Recomendaciones de arquitectura inmediata
1. Unificar fuente de verdad de entornos:
   - garantizar que todos los scripts usen `/api/v1`.
2. Definir matriz de seguridad de endpoints:
   - publico vs autenticado vs admin.
3. Consolidar pipeline deploy backend:
   - adoptar script simple y trazable (rollback, logs, healthcheck).
4. Agregar tests frontend basicos:
   - smoke tests de login, guard de rutas y formularios de transacciones.
5. Establecer convencion de cambios cross-repo:
   - plantilla de PR con impacto backend/frontend y checklist de compatibilidad.

## 9. Archivos de referencia
- [AGENTS.md](/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/AGENTS.md)
- [CONSULTAS_OPERATIVAS.md](/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/docs/CONSULTAS_OPERATIVAS.md)
