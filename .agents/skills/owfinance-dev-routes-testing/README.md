# OWFINANCE DEV Routes Testing Skill

## Qué hace este skill

Documenta todas las rutas válidas de OWFINANCE2026 en los entornos DEV/STAGE/PROD para evitar errores 404 durante testing.

## Usuario de Pruebas Principal

**⚠️ IMPORTANTE**: Usar `otero@demo.com` (password: `password`) para testing de usuario normal, NO `admin@demo.com`.

## Cuándo usar

- Al hacer testing en DEV/STAGE/PROD
- Cuando encuentres errores 404
- Al documentar flujos de navegación
- Para validar rutas después de cambios en el router
- Al hacer testing automatizado del navegador

## Información Clave

### Credenciales de Testing
- **Usuario Normal (usar este)**: `otero@demo.com` / `password`
- Usuario Admin: `admin@demo.com` / `password`
- Usuario Demo: `user@demo.com` / `password`
- Usuario Guest: `guest@demo.com` / `password`

### URLs Base
- DEV: `https://appfinanzasdev.blockshift.website`
- STAGE/PROD: `https://appfinanzas.blockshift.website`

## Reportes de Testing

- `../../BUGS/BUG-007-menu-duplicacion-app-resolved.md` - Fix inicial de navegación bottom nav
- `../../BUGS/BUG-007-EXTENDED-FIX-REPORT.md` - Fix completo de TODAS las duplicaciones /app/app/

## Scripts de Utilidad

- `../../validate-routes.sh` - Script de validación automática de rutas (verifica que no existan /app/ incorrectos)
- `../../clear-cache.sh` - Script para forzar recarga de frontend sin caché del navegador

### Estructura de Rutas
- Rutas públicas: `/login`, `/`
- Rutas de usuario: `/user/*` (requiere role: user)
- Rutas de admin: `/admin/*` (requiere role: admin)
- Dashboard inteligente: `/dashboard` (redirige según rol)

## Error Común Evitado

❌ **Error**: Usar `admin@demo.com` para probar funcionalidad de usuario normal
✅ **Correcto**: Usar `otero@demo.com` para testing de usuario normal

Los administradores tienen diferentes permisos, rutas de redirect y comportamiento de UI que los usuarios normales.

## Ver Documentación Completa

Consulta [SKILL.md](SKILL.md) para:
- Lista completa de rutas válidas
- Workflows de testing recomendados
- Soluciones a errores comunes
- Ejemplos de código para testing automatizado
