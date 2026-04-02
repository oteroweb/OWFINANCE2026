# ⚙️ Operaciones - Guías Step-by-Step

## 1. Arrancar Entorno Local Completo

```bash
# Paso 1: Cambiar a entorno local
./switch-env.sh local

# Paso 2: Verificar .env es correcto
cat OWFinanceFrontend2025/.env
# Debe mostrar: VITE_API_BASE_URL=http://localhost:8000/api/v1

# Paso 3: Iniciar servicios
./dev-start.sh

# Paso 4: Verificar status
./status.sh
```

**Resultado esperado:**
- Backend Laravel en `http://localhost:8000`
- Frontend Quasar en `http://localhost:5173` (o similar)
- Ambos logs corriendo

**Documentación:** Ver [`ENV_STRATEGY.md`](../../01-configuracion/ENV_STRATEGY.md)

---

## 2. Cambiar a Entorno Remoto

```bash
# Paso 1: Cambiar a remoto
./switch-env.sh remote

# Paso 2: Verificar .env
cat OWFinanceFrontend2025/.env
# Debe mostrar: VITE_API_BASE_URL=https://appfinanzas.blockshift.website/api/v1

# Paso 3: Frontend va a usar backend remoto
npm run dev  # En OWFinanceFrontend2025

# Paso 4: Abrir en navegador
# http://localhost:5173 (conectado a backend remoto)
```

**Documentación:** Ver [`ENV_STRATEGY.md`](../../01-configuracion/ENV_STRATEGY.md)

---

## 3. Hacer Deploy a Mobile (Android)

```bash
# Paso 1: Cambiar a entorno mobile
./switch-env.sh mobile

# Paso 2: Compilar APK debug
./deploy-mobile.sh android dev

# Paso 3: El script automáticamente:
# - Genera Capacitor assets
# - Compila Android Studio
# - Instala APK en dispositivo conectado

# Resultado: App Android en dispositivo
```

**Documentación:** Ver [`MOBILE_DEPLOYMENT_GUIDE.md`](../../04-mobile/deployment/MOBILE_DEPLOYMENT_GUIDE.md)

---

## 4. Hacer Deploy Remoto del Backend

```bash
# ⚠️ IMPORTANTE: Validar antes de ejecutar

# Paso 1: Revisar cambios
cd OWFINANCEBackend2025
git status

# Paso 2: Revisar contrato API NO rompe nada
# - /api/v1 sigue siendo el prefijo
# - Respuesta { status, code, message, data }
# - Autenticación Sanctum intacta

# Paso 3: Ejecutar script deploy (si existe)
./deploy/remote_deploy.sh

# ⚠️ ADVERTENCIA: Pipeline en .github/workflows/deploy.yml 
# contiene bloque shell complejo. VALIDAR ANTES de usar en producción.
```

**Documentación:** Ver [`AGENTS.md`](../../AGENTS.md) - Sección "Deploy y actualizaciones"

---

## 5. Verificar Sincronización de Jars

```bash
# Paso 1: Login en la app

# Paso 2: GET endpoint de jars
curl -X GET http://localhost:8000/api/v1/users/{user_id}/jars \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"

# Paso 3: Validar respuesta
# {
#   "status": "SUCCESS",
#   "code": 200,
#   "message": "Jars retrieved",
#   "data": [...]
# }

# Paso 4: Verificar invariantes
# - Suma de porcentajes <= 100%
# - Todas las jars tienen ID en DB
# - Las categorías asignadas existen
```

**Documentación:** Ver [`jar-quick-reference.md`](../../02-backend/endpoints/jar-quick-reference.md)

---

## 6. Ver Logs del Sistema

```bash
# Backend Laravel logs
tail -f OWFINANCEBackend2025/storage/logs/laravel.log

# Frontend Quasar dev logs
# (visible en terminal donde ejecutaste npm run dev)

# Android logcat
./android-logs.sh

# Estado general
./status.sh
```

---

## 7. Rollback Rápido

```bash
# Si algo se rompió en backend
cd OWFINANCEBackend2025
git log --oneline | head -5
git revert <commit-hash>
git push

# Si algo se rompió en frontend
cd OWFinanceFrontend2025
git log --oneline | head -5
git revert <commit-hash>
git push

# Si datos en DB se corrompieron
# ÚLTIMA OPCIÓN: Restaurar DB backup
# (Requiere acceso a backups, verificar con admin)
```

---

## Checklist Pre-Deployment

```bash
# Backend
[ ] ✅ No rompe contrato API /api/v1
[ ] ✅ Auth Sanctum sigue funcionando
[ ] ✅ Tests pasan: php artisan test
[ ] ✅ Sin errores de SQL ambigüedad
[ ] ✅ Jars mantienen invariantes (sum <= 100%)

# Frontend
[ ] ✅ npm run lint no da errores
[ ] ✅ Tests pasan (si existen)
[ ] ✅ .env apunta a backend correcto
[ ] ✅ Token Sanctum se envía en headers
[ ] ✅ Sin console.errors

# Mobile
[ ] ✅ .env.mobile usa backend remoto
[ ] ✅ APK se compila sin errores
[ ] ✅ Capacitor sync está actualizado
[ ] ✅ Permisos AndroidManifest OK
```

---

**📍 Última actualización:** 2026-03-01
