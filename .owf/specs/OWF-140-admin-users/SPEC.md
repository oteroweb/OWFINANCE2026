# OWF-140 — Admin: Gestión Completa de Usuarios

**Épica:** Panel Administrativo · Gestión Profunda de Usuarios  
**Estado:** SPEC  
**Prioridad:** P1  
**IDs de tarea:** OWF-140 … OWF-152  
**Creado:** 2026-06-28

---

## 1. Objetivo

El administrador necesita poder **ver, configurar y actuar sobre cualquier usuario** desde un panel dedicado dentro del Admin. Hoy el panel `/admin/users` solo es una tabla CRUD básica. El nuevo módulo añade:

1. Vista detalle del usuario con todas sus entidades (cuentas, cántaros, transacciones, configuración)
2. Capacidad de **impersonar** un usuario (login-as) para soporte y debug sin conocer su contraseña
3. Gestión de credenciales y roles desde el admin
4. Operaciones de administración: activar/desactivar, reiniciar contraseña, limpiar tokens, ver actividad

---

## 2. Estado actual

| Lo que existe | Gaps |
|---|---|
| `/admin/users` — tabla CRUD (CrudPage genérico) | Sin detalle por usuario |
| `UserController.php` — CRUD + change_status | Sin impersonación |
| `AdminLayout.vue` — sidebar con link a usuarios | Sidebar básico sin íconos ni secciones |
| Roles CRUD (`/admin/roles`) | No se puede cambiar rol de un usuario desde su detalle |
| `UserSettingController.php` | No accesible desde admin |

---

## 3. Funcionalidades requeridas

### 3.1 Lista de usuarios mejorada (`/admin/users`)

- Tabla con columnas: avatar, nombre, email, rol (badge color), plan (Lite/Pro), activo, último acceso, fecha registro
- Filtros: búsqueda por nombre/email, por rol, por estado (activo/inactivo/eliminado), por plan
- Acciones inline: activar/desactivar toggle, ir al detalle, impersonar, eliminar
- KPI row encima: total usuarios, activos hoy, registros este mes, plan Pro count

### 3.2 Detalle de usuario (`/admin/users/:id`)

Pantalla de detalle dividida en secciones (tabs o cards):

| Sección | Qué muestra / permite |
|---|---|
| **Perfil** | nombre, email, teléfono, ciudad, ocupación, fecha nacimiento, rol, plan, activo toggle, cambiar contraseña |
| **Cuentas** | lista de cuentas del usuario (nombre, moneda, balance, tipo, activo) — solo lectura |
| **Cántaros** | lista de jars (nombre, %, tipo, balance) — solo lectura |
| **Transacciones** | últimas 20 transacciones con monto, categoría, fecha — solo lectura, link a detalle |
| **Configuración** | layout_mode, notifications, strict_budget, financial goal, monthly income |
| **Tasas** | user_currencies del usuario — puede añadir/editar |
| **Seguridad** | tokens activos (count), último login, botón "Revocar todos los tokens", botón "Enviar reset password" |
| **Actividad** | log de últimas acciones (futuro — placeholder con "Próximamente") |

### 3.3 Impersonación (`POST /admin/users/:id/impersonate`)

- El admin hace clic en "Iniciar sesión como" en el detalle o en la lista
- El backend genera un token temporal para ese usuario (scope = `impersonate`, expira en 2h)
- El frontend guarda el token real del admin en `sessionStorage` como `admin_token`
- Carga el token del usuario impersonado como token activo
- Muestra un banner fijo en la UI: **"Estás viendo como [Nombre]. [Volver al admin]"**
- Al hacer clic en "Volver al admin": restaura el `admin_token`, redirige a `/admin/users/:id`
- Solo un nivel de impersonación (no se puede impersonar siendo impersonado)

### 3.4 Gestión de credenciales desde admin

- **Cambiar contraseña** del usuario directamente (sin conocer la actual): campo en el detalle
- **Reset password link**: enviar email de reset sin entrar a la cuenta
- **Revocar tokens**: eliminar todos los `personal_access_tokens` del usuario

### 3.5 AdminLayout mejorado

Sidebar rediseñado con secciones, íconos Material Symbols, badge de conteo en Usuarios:

```
OWFINANCE ADMIN
─────────────────
📊 Dashboard        /admin
─────────────────
👥 USUARIOS
   Todos los usuarios /admin/users
   Roles            /admin/roles
─────────────────
🗂️ CATÁLOGOS
   Monedas          /admin/currencies
   Tipos de cuenta  /admin/account_type
   Impuestos        /admin/taxes
   Categorías ítem  /admin/item_categories
   Ítems            /admin/items
   Proveedores      /admin/providers
   Tipos de Tx      /admin/transaction_types
   Clientes         /admin/clients
   Tasas            /admin/rates
─────────────────
⚙️ SISTEMA
   Sistema          /admin/system
   Monitor IA       /admin/ai
─────────────────
[Cerrar sesión]
```

---

## 4. API contracts requeridos

Ver `API_CONTRACTS.md` en esta carpeta.

---

## 5. Flujo de impersonación

```
Admin en /admin/users/42
  → clic "Iniciar sesión como"
  → POST /api/v1/admin/users/42/impersonate
  ← { token: "xxx", user: {...} }
  → authStore.impersonate(token, user)  // guarda adminToken en sessionStorage
  → redirect /user/home (como el usuario 42)
  → ImpersonationBanner visible (fixed top)
  → clic "Volver al admin"
  → authStore.stopImpersonating()  // restaura adminToken
  → redirect /admin/users/42
```

---

## 6. Modelo de datos — sin cambios de schema

Todos los datos ya existen. Solo se necesitan endpoints admin nuevos y vistas frontend nuevas. No hay migraciones.

---

## 7. Sub-tareas OWF

| ID | Tipo | Descripción | Prioridad |
|----|------|-------------|-----------|
| OWF-140 | backend | `POST /admin/users/:id/impersonate` — genera token impersonación 2h | P0 |
| OWF-141 | backend | `GET /admin/users/:id/detail` — perfil completo + cuentas + jars + últimas tx + tokens | P1 |
| OWF-142 | backend | `PUT /admin/users/:id/password` — cambiar contraseña desde admin | P1 |
| OWF-143 | backend | `DELETE /admin/users/:id/tokens` — revocar todos los tokens | P1 |
| OWF-144 | backend | `POST /admin/users/:id/reset-password-email` — enviar email reset | P1 |
| OWF-145 | frontend | `AdminUsersListView` — lista mejorada con KPIs + filtros + acciones | P1 |
| OWF-146 | frontend | `AdminUserDetailView` — detalle con tabs: Perfil / Cuentas / Jars / Tx / Config / Seguridad | P1 |
| OWF-147 | frontend | Impersonation banner + `authStore.impersonate()` / `stopImpersonating()` | P0 |
| OWF-148 | frontend | AdminLayout sidebar v2: secciones + íconos + badge usuarios | P2 |
| OWF-149 | frontend | Modal "Cambiar contraseña" en detalle usuario (admin) | P2 |
| OWF-150 | frontend | Modal "Revocar tokens" con confirmación | P2 |
| OWF-151 | tests | Feature tests: impersonación + cambio password + revoke tokens | P2 |
| OWF-152 | tests | E2E Playwright: admin list → detalle → impersonar → banner → volver | P3 |

---

## 8. Restricciones y seguridad

- Token de impersonación: scope `['impersonate']` — no puede usarse para mutar roles/passwords
- Solo usuarios con `role.slug = 'admin'` pueden llamar rutas `/admin/users/*`
- Un admin no puede impersonar a otro admin (verificar rol del target)
- Log en tabla `activity_logs` (futura): registrar impersonación con `admin_id` + `target_user_id` + timestamp
- El token de impersonación expira en 2 horas (Sanctum `expiration` en config)

---

## 9. Criterios de aceptación

- [ ] Admin puede ver lista de todos los usuarios con filtros operativos
- [ ] Admin puede abrir el detalle de cualquier usuario y ver sus cuentas/cántaros/transacciones
- [ ] Admin puede cambiar el rol y contraseña de un usuario
- [ ] Admin puede impersonar un usuario → se muestra banner → puede volver al admin
- [ ] Admin puede revocar todos los tokens de un usuario
- [ ] Admin puede enviar email de reset de contraseña al usuario
- [ ] Todos los endpoints verifican `CheckRole:admin` antes de actuar
- [ ] Tests feature pasan (OWF-151)
