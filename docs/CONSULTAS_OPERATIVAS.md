# Consultas Operativas para IA - OWFINANCE2026

Estado documental: `vigente`

Este documento define respuestas estandar por tipo de consulta tecnica.

## 1. "Quiero levantar el proyecto local"

Pasos:
1. `./switch-env.sh local`
2. `./dev-start.sh`
3. verificar:
   - backend: `http://localhost:8000`
   - frontend: `http://localhost:3000`
4. estado: `./status.sh`

Checks rapidos:
- Si el puerto esta ocupado, liberar `8000` o `3000`.
- Confirmar `OWFinanceFrontend2025/.env` con `/api/v1`.

## 2. "Quiero correr solo frontend contra backend remoto"

Pasos:
1. `./switch-env.sh remote`
2. `cd OWFinanceFrontend2025 && npm run dev`

Validar:
- `VITE_API_BASE_URL` apunta al dominio remoto con `/api/v1`.

## 3. "Quiero compilar Android/iOS"

Android dev:
1. `./deploy-mobile.sh android dev`

Android prod:
1. revisar `.env.production`
2. `./deploy-mobile.sh android prod`

iOS dev/prod:
1. `./deploy-mobile.sh ios dev` o `ios prod`
2. abrir y firmar en Xcode si aplica.

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
- validar y simplificar `.github/workflows/deploy.yml` antes de usarlo como pipeline oficial.

## 5. "Quiero agregar o cambiar un endpoint API"

Checklist:
1. Crear o editar ruta en `routes/api/*.php`.
2. Mantener prefijo global `/api/v1`.
3. Implementar en controller y repo.
4. Mantener envelope de respuesta `{status, code, message, data}`.
5. Definir middleware correcto (`auth:sanctum` si aplica).
6. Probar con y sin token.

## 6. "Quiero cambiar una pantalla frontend"

Checklist:
1. Ubicar ruta en `src/router/routes.ts`.
2. Revisar `docs/03-frontend/RUTAS.md`.
3. Modificar pagina o componente.
4. Revisar store y llamadas API implicadas.
5. Validar login, permisos y `npm run lint`.

## 7. "Quiero actualizar jars"

Archivos clave backend:
- `routes/api/jars.php`
- `app/Http/Controllers/Api/JarController.php`
- `app/Http/Controllers/Api/JarBalanceController.php`
- `app/Services/JarBalanceService.php`

Invariantes:
1. suma de porcentajes activos <= 100
2. categoria pertenece a maximo un jar por usuario
3. operaciones scoped al usuario autenticado

## 8. "Quiero investigar un bug de autenticacion"

Checklist:
1. backend:
   - `routes/api/auth.php`
   - `app/Http/Controllers/Api/AuthController.php`
2. frontend:
   - `src/stores/auth.ts`
   - `src/boot/axios.ts`
3. validar:
   - token en localStorage
   - header Authorization enviado
   - redireccion 401 a `/login`

## 9. "Quiero preparar release segura"

Previo:
1. revisar `docs/00-sistema/GIT_HYGIENE_AND_SAFE_UPDATE.md`
2. `./status.sh`
3. verificar rama y cambios en ambos repos
4. ejecutar tests o lint minimos

Release sugerido:
1. backend release
2. frontend web/mobile build
3. smoke test de login + transacciones + jars
4. rollback plan documentado
5. cleanup gate final

## 10. "Quiero hacer pull o actualizar repos"

Secuencia obligatoria:
1. ejecutar el preflight de `docs/00-sistema/GIT_HYGIENE_AND_SAFE_UPDATE.md`
2. confirmar si el repo esta en detached HEAD
3. fijar rama local con tracking correcto
4. recien entonces actualizar

Si el repo esta detached o ambiguo, el agente no debe hacer `pull` automatico.

## 11. "Quiero que la IA analice rapido todo el proyecto"

Secuencia minima recomendada:
1. leer `AGENTS.md`
2. leer `docs/ARQUITECTURA_PROYECTO.md`
3. revisar `docs/00-sistema/FLUJO_OPERATIVO_UNIFICADO.md`
4. ejecutar chequeos de estado y revisar rutas/paginas
5. entregar:
   - riesgos
   - deuda tecnica
   - acciones recomendadas

## 12. Plantilla de respuesta para agentes

Usar este formato:
1. Contexto detectado.
2. Estado actual.
3. Acciones ejecutadas.
4. Hallazgos o riesgos.
5. Proximos pasos concretos.
