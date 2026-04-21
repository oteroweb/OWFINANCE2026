# WEEK2 — Días 11-15 del Calendario MVP

**Tipo**: Trabajo técnico (IA puede ejecutar)
**Prerequisito**: MANUAL-001 completado, staging funcionando

## Día 11: Monitoring básico

### Sentry (error tracking)
```bash
# Backend
composer require sentry/sentry-laravel
php artisan sentry:publish --dsn=TU_DSN

# Frontend
npm install @sentry/vue
```
- Backend: capturar excepciones no manejadas
- Frontend: capturar errores Vue + errores de SSE streaming

### Logging AI
- Agregar log entry cada vez que una extracción falla (confidence < 0.5)
- Dashboard simple: `GET /api/v1/ai/usage-summary` (total tokens, costo estimado del mes)

## Día 12: Feature flags UI

El modelo `AiUserSetting` ya existe en backend. Completar:
- Ver TECH-001 para instrucciones detalladas
- Endpoint GET/PUT /api/v1/ai/settings
- Página frontend settings

## Día 13: Exportación de transacciones

### Backend
- `GET /api/v1/transactions/export?format=csv&from=2026-01-01&to=2026-04-30`
- Devuelve CSV con: fecha, tipo, monto, descripción, categoría, cuenta
- Middleware: auth:sanctum, throttle genérico

### Frontend
- Botón "Exportar" en la lista de transacciones
- Usar `URL.createObjectURL` para descarga sin pasar por servidor proxy

## Día 14: Notificaciones push (preparación)

- Instalar `@capacitor/push-notifications` (Android)
- Backend: tabla `device_tokens` (user_id, token, platform, created_at)
- Endpoint `POST /api/v1/notifications/register-device`
- NO implementar envío aún — solo registro de devices

## Día 15: Polish final LITE layout

- Verificar que todas las rutas del LITE layout cargan sin errores
- Verificar responsividad en viewport 375px (iPhone SE)
- Verificar que QuickActionSheet cierra correctamente en todos los casos
- Agregar splash screen / loading state inicial
