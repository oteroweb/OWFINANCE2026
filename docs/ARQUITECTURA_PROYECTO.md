# Arquitectura del Proyecto OWFINANCE2026

Estado documental: `vigente`

## 1. Resumen ejecutivo

OWFINANCE2026 es un workspace coordinador con dos repositorios Git separados:
- `OWFINANCEBackend2025`: Laravel API
- `OWFinanceFrontend2025`: Quasar/Vue web + mobile

La operacion diaria se coordina desde la raiz del workspace con scripts compartidos y documentacion operativa corta.

## 2. Topologia

```text
[Web Quasar SPA] ----\
                      \--> [Laravel API /api/v1] ---> [MySQL/SQLite]
[Mobile Capacitor] ---/
```

Notas:
- El frontend consume API via Axios con token bearer.
- Mobile usa el mismo frontend compilado via Capacitor.
- El prefijo de API vigente es `/api/v1`.

## 3. Backend

### 3.1 Stack y estructura
- Laravel 12, PHP >= 8.2, Sanctum, Scribe.
- Directorios clave:
  - `app/Http/Controllers/Api`
  - `app/Models/Entities`
  - `app/Models/Repositories`
  - `app/Services`
  - `routes/api/*.php`
  - `database/migrations`

### 3.2 Contratos activos
- API versionada en `/api/v1`.
- Envelope de respuesta: `{ status, code, message, data }`.
- Scoping por usuario en endpoints sensibles.
- Jars con invariantes de porcentaje y exclusividad por categoria.

### 3.3 Riesgos vigentes
- Scripts y docs historicas aun mezclan `/api` y `/api/v1`.
- Hay que revisar matriz de seguridad de endpoints y middleware.
- El flujo de actualizacion Git debe endurecerse antes de cualquier `pull`.

## 4. Frontend

### 4.1 Stack y estructura
- Quasar 2, Vue 3, TypeScript, Pinia, Axios.
- Directorios clave:
  - `src/pages`
  - `src/components`
  - `src/stores`
  - `src/boot/axios.ts`
  - `src/router/routes.ts`

### 4.2 Flujo de sesion y API
- `src/boot/axios.ts` define `baseURL` desde `VITE_API_BASE_URL`.
- El interceptor de request agrega bearer token.
- El interceptor de response normaliza errores usando el envelope del backend.

### 4.3 Ruteo UI vigente
- La SPA web se sirve con base publica `/app/`.
- Las rutas internas activas del router viven hoy en la familia:
  - `/login`
  - `/register`
  - `/app/*`
  - `/admin/*`
- El detalle ejecutable de rutas vive en `docs/03-frontend/RUTAS.md`.

## 5. Lite / Pro: estado correcto

- Lite y Pro siguen siendo utiles como lenguaje de densidad, layout y diseño.
- Hoy no deben tratarse como rutas activas del producto.
- Si aparecen en specs, tratarlos como:
  - baseline historico;
  - contexto de arquitectura o handoff visual;
  - iniciativa futura que requiere una spec vigente para reactivarse.

## 6. Operacion y despliegue

### 6.1 Desarrollo local
- `./switch-env.sh local`
- `./dev-start.sh`
- `./status.sh`

### 6.2 Backend deploy remoto
- Script release style: `OWFINANCEBackend2025/deploy/remote_deploy.sh`
- Workflow CI existente: `.github/workflows/deploy.yml`

### 6.3 Mobile deploy
- Principal: `./deploy-mobile.sh [android|ios|both] [dev|staging|prod]`

## 7. Documentos autoridad relacionados

- `docs/00-sistema/FLUJO_OPERATIVO_UNIFICADO.md`
- `docs/00-sistema/GIT_HYGIENE_AND_SAFE_UPDATE.md`
- `docs/CONSULTAS_OPERATIVAS.md`
- `docs/03-frontend/RUTAS.md`
