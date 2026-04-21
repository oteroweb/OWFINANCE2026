# SKILL.md - OWFINANCE2026 DEV Routes Testing

## Descripción
Esta skill documenta todas las rutas válidas del entorno DEV de OWFINANCE2026 para evitar errores 404 durante el testing y debugging. Se aplica cuando necesites verificar rutas disponibles o cuando encuentres errores 404.

## ⚠️ LECCIÓN APRENDIDA: No Usar Admin para Testing de Usuario Normal

**ERROR COMÚN**: Usar `admin@demo.com` para probar funcionalidad de usuario normal.

**CORRECTO**: Usar `otero@demo.com` (password: `password`) como usuario de pruebas principal para testing de usuario normal.

**Por qué importa**:
- Los administradores pueden tener permisos diferentes
- El comportamiento de la UI puede variar según el rol
- Las rutas de redirect son diferentes (/admin vs /user/home)
- Los tests deben reflejar el comportamiento real del usuario final

**Regla de oro**: Usa el rol correcto para cada tipo de testing:
- Testing de usuario normal → `otero@demo.com`
- Testing de admin → `admin@demo.com`
- Testing de invitado → `guest@demo.com`

## Cuándo usar esta skill
- Al hacer testing en entornos DEV/STAGE/PROD
- Cuando encuentres errores 404 
- Al documentar flujos de navegación
- Para validar rutas después de cambios en el router
- Al hacer testing automatizado del navegador

## URLs Base por Entorno

### DEV Environment
- Base URL: `https://appfinanzasdev.blockshift.website`
- API Base: `https://appfinanzasdev.blockshift.website/api/v1`

### STAGE Environment  
- Base URL: `https://appfinanzas.blockshift.website`
- API Base: `https://appfinanzas.blockshift.website/api/v1`

### PROD Environment
- Base URL: `https://appfinanzas.blockshift.website` 
- API Base: `https://appfinanzas.blockshift.website/api/v1`

## Rutas Frontend Válidas

### Rutas Públicas (sin autenticación)
- `/login` - Pantalla de login
- `/` - Redirect automático a `/login`

### Rutas de Usuario Autenticado (`/user/*`)
**Requiere autenticación y role 'user'**
- `/user` - Redirect automático a `/user/home`
- `/user/home` - Dashboard principal del usuario
- `/user/expense-analysis` - Análisis de gastos
- `/user/transactions` - Gestión de transacciones
- `/user/accounts` - Gestión de cuentas
- `/user/categories` - Gestión de categorías
- `/user/taxes` - Gestión de impuestos
- `/user/config` - Configuración de usuario
- `/user/jars` - Gestión de jarras (ahorros)

### Rutas de Administrador (`/admin/*`)
**Requiere autenticación y role 'admin'**
- `/admin` - Dashboard de administración
- `/admin/transactions-old` - Transacciones (versión antigua)
- `/admin/transactions` - Gestión de transacciones
- `/admin/currencies` - Gestión de monedas
- `/admin/clients` - Gestión de clientes
- `/admin/users` - Gestión de usuarios
- `/admin/account_type` - Tipos de cuenta
- `/admin/accounts` - Gestión de cuentas
- `/admin/taxes` - Gestión de impuestos
- `/admin/item_categories` - Categorías de items
- `/admin/items` - Gestión de items
- `/admin/jars` - Gestión de jarras
- `/admin/categories` - Gestión de categorías
- `/admin/rates` - Gestión de tasas
- `/admin/providers` - Gestión de proveedores

### Ruta Inteligente
- `/dashboard` - Redirect automático basado en rol:
  - No autenticado → `/login`
  - Role 'admin' → `/admin`
  - Role 'user' → `/user/home`

## Credenciales de Testing (DEV/STAGE)

### ⚠️ IMPORTANTE: Usuario de Pruebas Principal
**USAR ESTE PARA TESTING DE USUARIO NORMAL**
- Email: `otero@demo.com`
- Password: `password`
- Role: `user`
- Accede a: rutas `/user/*`
- **Este es el usuario de pruebas principal para testing**

### Usuarios Adicionales Disponibles

#### Usuario Administrador (solo para testing admin)
- Email: `admin@demo.com`
- Password: `password`
- Role: `admin`
- Accede a: rutas `/admin/*`
- **NO usar para testing de usuario normal**

#### Usuario Demo Genérico
- Email: `user@demo.com`
- Password: `password`
- Role: `user`
- Accede a: rutas `/user/*`

#### Usuario Invitado
- Email: `guest@demo.com`
- Password: `password`
- Role: `guest`
- Accede a: rutas `/user/*` (permisos limitados)

## Errores Comunes y Soluciones

### ⚠️ ERROR CRÍTICO: Duplicación de Prefijo `/app/app/`
**Problema**: Navegación produce URLs con prefijo duplicado `/app/app/ai-coach`, `/app/app/home`, etc.

**Causa Raíz**: 
- El router de Vue está montado en `publicPath: '/app/'` (definido en `quasar.config.ts`)
- Algunos componentes usaban rutas absolutas con `/app/` cuando deberían usar rutas relativas `/user/`
- Esto causa duplicación: base `/app/` + ruta `/app/home` = `/app/app/home` ❌

**Archivos que tenían rutas incorrectas (CORREGIDOS)**:
1. `src/layouts/LiteDesktopLayout.vue`:
   - `/app/profile` → `/user/config` ✅
   - `/app/ai-coach` → `/user/home` (temporal, ruta pendiente) ⏳
   - `/app/notifications` → `/user/home` (temporal, ruta pendiente) ⏳

2. `src/components/MonthlyIncomePanel.vue`:
   - `/app/config` → `/user/config` ✅

3. `src/components/OnboardingModal.vue`:
   - `/app/home` → `/user/home` ✅

4. `src/components/liquid/LiquidBottomNav.vue`:
   - `/app/home` → `/user/home` ✅
   - `/app/transactions` → `/user/transactions` ✅
   - `/app/accounts` → `/user/accounts` ✅
   - `/app/config` → `/user/config` ✅

5. `src/components/ProSidebar.vue`:
   - `/app/home` → `/user/home` ✅
   - `/app/transactions` → `/user/transactions` ✅
   - `/app/jars` → `/user/jars` ✅
   - `/app/config` → `/user/config` ✅

6. `src/components/shared/LiquidBottomNavNew.vue`:
   - `/app/home` → `/user/home` ✅
   - `/app/transactions` → `/user/transactions` ✅
   - `/app/jars` → `/user/jars` ✅
   - `/app/config` → `/user/config` ✅

7. `src/layouts/LiteMobileLayout.vue`:
   - onTabChange routes: `/app/home` → `/user/home` ✅
   - path detection: `/app/transactions` → `/user/transactions` ✅
   - `/app/jars` → `/user/jars` ✅
   - `/app/config` → `/user/config` ✅

8. `src/pages/user/config.ts`:
   - userMenuLinks: todos con `/app/` → `/user/` ✅

**Solución General**:
```typescript
// ❌ INCORRECTO - causa /app/app/home
router.push('/app/home')
<router-link to="/app/config">

// ✅ CORRECTO - produce /app/user/home
router.push('/user/home')
<router-link to="/user/config">
```

**Regla de oro**: Cuando `publicPath: '/app/'` está configurado, TODAS las rutas en el código deben ser relativas al router (`/user/*`, `/admin/*`, `/login`), NUNCA incluir `/app/` manualmente.

### ⏳ Rutas Pendientes de Crear

Las siguientes rutas se mencionan en componentes pero NO existen en `routes.ts`:
- `/user/ai-coach` - Asistente de IA (actualmente redirige a `/user/home`)
- `/user/notifications` - Panel de notificaciones (actualmente redirige a `/user/home`)
- `/user/profile` - Perfil de usuario (actualmente usa `/user/config`)

**TODO**: Crear estas rutas en `src/router/routes.ts` cuando se implementen las vistas correspondientes.

### 🛠️ Script de Validación de Rutas

Para verificar que no existen rutas con `/app/` que causen duplicaciones:

```bash
./validate-routes.sh
```

Este script busca patrones incorrectos:
- `to="/app/"`
- `push('/app/')`
- `route: '/app/'`
- `includes('/app/')`

**Output esperado**: `✅ VALIDACIÓN EXITOSA: Todas las rutas usan /user/ o /admin/ correctamente`

### Error 404 en `/app/user/home`
**Problema**: Intentar acceder a `/app/user/home`
**Solución**: Usar `/user/home` (sin el prefijo `/app`)

### Error 404 en rutas admin sin autenticación
**Problema**: Acceder a rutas `/admin/*` sin estar logueado
**Solución**: Primero hacer login con credenciales de admin

### Error 404 en rutas de rol incorrecto
**Problema**: Usuario normal intentando acceder a `/admin/*`
**Solución**: Usar credenciales de admin o acceder a rutas `/user/*`

## Workflow de Testing Recomendado

### 1. Testing Manual con Browser
```javascript
// 1. Navegar a login
await page.goto('/login');

// 2. Hacer login con usuario de pruebas normal
await page.fill('[name="email"]', 'otero@demo.com');
await page.fill('[name="password"]', 'password');
await page.click('button[type="submit"]');

// 3. Verificar redirect correcto
// User debe ir a /user/home
// Admin debe ir a /admin (solo si usas admin@demo.com)
```

### 2. Testing de Rutas Específicas
```javascript
// Testing ruta de usuario (usar otero@demo.com)
await page.goto('/user/home');
await expect(page).toHaveURL(/.*\/user\/home/);

// Testing ruta de admin (solo con admin@demo.com)
await page.goto('/admin');
await expect(page).toHaveURL(/.*\/admin/);
```

### 3. Verificación de Autenticación
Todas las rutas excepto `/login` y `/` requieren autenticación válida.

## Estructura de URL Completa (DEV)
```
https://appfinanzasdev.blockshift.website/login
https://appfinanzasdev.blockshift.website/user/home
https://appfinanzasdev.blockshift.website/admin
https://appfinanzasdev.blockshift.website/dashboard
```

## API Endpoints (Backend)
Base: `/api/v1/` seguido de:
- `auth/login` - Login
- `auth/logout` - Logout
- `users/*` - Gestión de usuarios
- `transactions/*` - Transacciones
- `accounts/*` - Cuentas
- `categories/*` - Categorías
- etc.

## Notas Importantes
- **NO usar el prefijo `/app`** en las rutas del frontend
- Siempre verificar autenticación antes de testing rutas protegidas
- Los redirects automáticos pueden cambiar la URL esperada
- El rol determina qué rutas están disponibles
- Las rutas públicas son mínimas (solo login)

## Debugging 404s
1. Verificar que la ruta existe en `src/router/routes.ts`
2. Confirmar autenticación si es ruta protegida  
3. Verificar rol correcto para la ruta
4. Comprobar sintaxis de URL (sin `/app` prefix)
5. Revisar redirects automáticos en el router