# Consultas Operativas para IA - OWFINANCE2026

Este documento define respuestas estandar por tipo de consulta tecnica.

## 1. "Quiero levantar el proyecto local"

Pasos:
1. `./switch-env.sh local`
2. `./dev-start.sh`
3. Verificar:
   - Backend: `http://localhost:8000`
   - Frontend: `http://localhost:3000`
4. Estado: `./status.sh`

Checks rapidos:
- Si puerto ocupado: liberar `8000` o `3000`.
- Confirmar `OWFinanceFrontend2025/.env` con `/api/v1`.

## 2. "Quiero correr solo frontend contra backend remoto"

Pasos:
1. `./switch-env.sh remote`
2. `cd OWFinanceFrontend2025 && npm run dev`

Validar:
- `VITE_API_BASE_URL` apunta a dominio remoto con `/api/v1`.

## 3. "Quiero compilar Android/iOS"

Android dev:
1. `./deploy-mobile.sh android dev`

Android prod:
1. revisar `.env.production`
2. `./deploy-mobile.sh android prod`

iOS dev/prod (macOS):
1. `./deploy-mobile.sh ios dev` o `ios prod`
2. abrir y firmar en Xcode.

## 4. "Quiero desplegar backend"

Base:
1. generar artefacto de `OWFINANCEBackend2025`
2. usar flujo release (`releases/<timestamp>`, `current`, `shared`)
3. ejecutar:
   - `composer install --no-dev --optimize-autoloader`
   - `php artisan config:cache`
   - `php artisan migrate --force`

Referencia:
- `OWFINANCEBackend2025/deploy/remote_deploy.sh`

Nota:
- validar y simplificar `.github/workflows/deploy.yml` antes de usar como pipeline oficial.

## 5. "Quiero agregar o cambiar un endpoint API"

Checklist:
1. Crear/editar ruta en `routes/api/*.php` (recordar prefijo global `/api/v1`).
2. Implementar en controller y repo.
3. Mantener envelope de respuesta `{status, code, message, data}`.
4. Definir middleware correcto (`auth:sanctum` si aplica).
5. Probar:
   - `php artisan test`
   - pruebas manuales con token y sin token.

## 6. "Quiero cambiar una pantalla frontend"

Checklist:
1. Ubicar ruta en `src/router/routes.ts`.
2. Modificar pagina/componente en `src/pages` o `src/components`.
3. Revisar store implicado (`src/stores/*`).
4. Revisar llamadas API en composables/store/axios.
5. Validar:
   - login activo y permisos por rol
   - console sin errores
   - `npm run lint`.

## 7. "Quiero actualizar jars (logica de cantaros)"

Archivos clave backend:
- `routes/api/jars.php`
- `app/Http/Controllers/Api/JarController.php`
- `app/Http/Controllers/Api/JarBalanceController.php`
- `app/Services/JarBalanceService.php`

Invariantes:
1. suma de porcentajes activos <= 100.
2. categoria pertenece a maximo un jar por usuario.
3. operaciones en jars deben quedar scoped al usuario autenticado.

## 8. "Quiero investigar un bug de autenticacion"

Checklist:
1. Backend:
   - `routes/api/auth.php`
   - `app/Http/Controllers/Api/AuthController.php`
2. Frontend:
   - `src/stores/auth.ts`
   - `src/boot/axios.ts`
3. Validar:
   - token presente en localStorage
   - header Authorization enviado
   - redireccion 401 a `/login`

## 9. "Quiero preparar release segura"

Previo:
1. `./status.sh`
2. verificar rama y cambios en ambos repos:
   - `OWFINANCEBackend2025/.git`
   - `OWFinanceFrontend2025/.git`
3. ejecutar tests/lint minimos.

Release sugerido:
1. backend release
2. frontend web/mobile build
3. smoke test de login + transacciones + jars
4. rollback plan documentado.

## 10. "Quiero que la IA analice rapido todo el proyecto"

Secuencia minima recomendada para el agente:
1. Leer [AGENTS.md](/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/AGENTS.md).
2. Leer [ARQUITECTURA_PROYECTO.md](/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/docs/ARQUITECTURA_PROYECTO.md).
3. Ejecutar:
   - `./status.sh`
   - `find OWFINANCEBackend2025/routes/api -type f`
   - `find OWFinanceFrontend2025/src/pages -type f`
4. Entregar hallazgos en formato:
   - riesgos
   - deuda tecnica
   - acciones recomendadas (corto/mediano plazo).

## 11. Plantilla de respuesta para agentes

Usar este formato:
1. Contexto detectado.
2. Estado actual (servicios, entorno, rama).
3. Acciones ejecutadas.
4. Hallazgos/riesgos.
5. Proximos pasos concretos.
