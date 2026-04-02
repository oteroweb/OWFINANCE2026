# 🚨 Troubleshooting - Solución de Problemas

## Problemas Comunes

### 1. **Error: API en `/api` en lugar de `/api/v1`**
**Problema:** Frontend envía requests a `/api` pero backend espera `/api/v1`

**Causa:** Script `env-config.sh` genera `.env` incorrecto

**Solución:**
```bash
# Editar manualmente OWFinanceFrontend2025/.env
VITE_API_BASE_URL=http://localhost:8000/api/v1
```

**Verificación:** Ver [`ENV_STRATEGY.md`](../../01-configuracion/ENV_STRATEGY.md)

---

### 2. **Error: Token Sanctum no funciona**
**Problema:** Requests reciben 401 Unauthorized

**Causa:** Token no incluido o expirado

**Solución:**
```javascript
// En src/boot/axios.ts (Frontend)
const token = localStorage.getItem('authToken');
if (token) {
  config.headers.Authorization = `Bearer ${token}`;
}
```

**Verificación:** Ver [`SOLICITUD_CAMBIOS_FRONTEND.md`](../../02-backend/integracion-frontend/SOLICITUD_CAMBIOS_FRONTEND.md#-autenticación-requerida)

---

### 3. **Error: 404 en jars endpoints**
**Problema:** GET `/api/v1/users/{id}/jars` retorna 404

**Causa:** Usuario no autenticado o ID incorrecto

**Solución:**
1. Confirmar token válido en header
2. Confirmar user ID correcto
3. Ver bug report: [`CORRECCION_ERROR_404_JARROS.md`](../../02-backend/bugfixes/CORRECCION_ERROR_404_JARROS.md)

---

### 4. **Error: Porcentajes de jars > 100%**
**Problema:** Sistema acepta jars con suma > 100%

**Causa:** Validación frontend incompleta o falta sync con backend

**Solución:**
- Frontend: Validar suma antes de enviar
- Backend: Validación en `JarController@store`
- Ver análisis: [`ANALISIS_LOGICA_PORCENTAJE_CANTAROS.md`](../../02-backend/implementacion/ANALISIS_LOGICA_PORCENTAJE_CANTAROS.md)

---

### 5. **Error: Entorno remoto no responde**
**Problema:** Backend remoto `appfinanzas.blockshift.website` no accesible

**Causa:** Servidor caído, conectividad, o credenciales vencidas

**Solución:**
```bash
# Probar conectividad
curl -I https://appfinanzas.blockshift.website/api/v1/health

# Si falla, cambiar a local
./switch-env.sh local
```

---

### 6. **Error: Mobile app no conecta a backend**
**Problema:** Android/iOS app recibe timeout o connection refused

**Causa:** `.env.mobile` apunta a localhost, pero dispositivo no puede acceder

**Solución:**
```bash
# .env.mobile DEBE usar URL remota
VITE_API_BASE_URL=https://appfinanzas.blockshift.website/api/v1

# Luego rebuild
./deploy-mobile.sh android dev
```

---

## Diagnóstico Rápido

```bash
# 1. Verificar entorno activo
./status.sh

# 2. Verificar backend está corriendo
curl http://localhost:8000/api/v1

# 3. Verificar token válido
localStorage.getItem('authToken')  # En DevTools console

# 4. Ver logs
tail -f logs/*  # Si existen

# 5. Revisar .env activo
cat OWFinanceFrontend2025/.env
```

---

**📍 Última actualización:** 2026-03-01
