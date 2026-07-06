# OWF-140 — Frontend Tasks

**Stack:** Quasar 2 + Vue 3 + TypeScript + Pinia  
**Rutas admin:** `src/router/admin.routes.ts`  
**Páginas admin:** `src/pages/admin/`  
**Layout:** `src/layouts/AdminLayout.vue`  
**Auth store:** `src/stores/auth.ts`

---

## OWF-145 — AdminUsersListView mejorada

**Archivo:** `src/pages/admin/users/index.vue` (reescribir, ya existe pero es solo `<CrudPage>`)

### Estructura
```
AdminUsersListView
├── KpiRow (4 chips: Total / Activos hoy / Este mes / Pro)
├── FiltersBar
│   ├── q-input search (nombre/email)
│   ├── q-select rol (todos/admin/user)
│   ├── q-select estado (todos/activo/inactivo)
│   └── q-select plan (todos/lite/pro)
└── q-table (users)
    Columnas: avatar | nombre+email | rol badge | plan pill | activo toggle | último acceso | acciones
    Acciones por fila: [👤 Detalle] [🔑 Impersonar] [⏸ Activar/Desactivar] [🗑 Eliminar]
```

### Estado Pinia (nuevo store o en el mismo componente)
```typescript
const users = ref<UserRow[]>([])
const kpis  = ref<{ total_users, active_today, registered_this_month, pro_count }>()
const filters = reactive({ search: '', role: '', active: null, plan: '' })
const pagination = reactive({ page: 1, rowsPerPage: 20, rowsNumber: 0 })
```

### Llamadas API
```typescript
GET /api/v1/users?page=&per_page=&search=&role=&active=&sort_by=created_at&descending=true
// El endpoint existente ya soporta estos params; añadir kpis en DashboardController o inline aquí
```

### Impersonar (inline en la tabla)
```typescript
async function impersonate(userId: number) {
  const r = await api.post(`/admin/users/${userId}/impersonate`)
  authStore.startImpersonation(r.data.data.token, r.data.data.user)
  router.push('/user/home')
}
```

---

## OWF-146 — AdminUserDetailView

**Archivo:** `src/pages/admin/users/detail.vue` (nuevo)  
**Ruta:** `/admin/users/:id`

### Estructura
```
AdminUserDetailView
├── PageHeader
│   ├── Avatar (iniciales) + Nombre + Email
│   ├── Badge rol (admin=rojo, user=azul)
│   ├── Badge plan (Pro=morado, Lite=gris)
│   ├── active toggle
│   └── Actions: [Impersonar] [Cambiar contraseña] [Revocar tokens] [Enviar reset]
└── q-tabs
    ├── tab: Perfil
    │   └── form: nombre, email, teléfono, ciudad, país, ocupación, birthdate, moneda, rol select
    ├── tab: Cuentas
    │   └── q-table readonly: nombre, moneda, balance, tipo, activo
    ├── tab: Cántaros
    │   └── q-table readonly: nombre, %, tipo, balance, activo
    ├── tab: Transacciones
    │   └── q-table últimas 20: fecha, nombre, monto (colored), categoría, tipo
    ├── tab: Configuración
    │   └── fields: layout_mode, notifications, strict_budget, monthly_income, financial_goal
    ├── tab: Tasas
    │   └── lista user_currencies editable: moneda, tasa, es_actual, es_oficial
    └── tab: Seguridad
        ├── "Tokens activos: N"
        ├── "Último acceso: fecha"
        ├── btn [Revocar todos los tokens]
        ├── btn [Enviar email de reset]
        └── form cambiar contraseña (solo campo nueva contraseña)
```

### Llamadas API
```typescript
GET  /api/v1/admin/users/:id/detail       → carga todo
PUT  /api/v1/users/:id                     → guarda perfil
PUT  /api/v1/admin/users/:id/password      → cambia contraseña
DELETE /api/v1/admin/users/:id/tokens      → revoca tokens
POST /api/v1/admin/users/:id/reset-password-email → envía email
POST /api/v1/admin/users/:id/impersonate   → impersonar (luego redirige)
```

---

## OWF-147 — Impersonation en authStore + ImpersonationBanner

### `src/stores/auth.ts` — añadir

```typescript
// State nuevo
const impersonating = ref<boolean>(false)
const impersonatedUser = ref<User | null>(null)

// Actions
function startImpersonation(token: string, user: User) {
  const adminToken = authToken.value  // token actual del admin
  sessionStorage.setItem('owf_admin_token', adminToken)
  sessionStorage.setItem('owf_admin_user', JSON.stringify(authUser.value))
  authToken.value = token
  authUser.value = user
  impersonating.value = true
  impersonatedUser.value = user
}

function stopImpersonation() {
  const adminToken = sessionStorage.getItem('owf_admin_token')
  const adminUser  = JSON.parse(sessionStorage.getItem('owf_admin_user') || '{}')
  sessionStorage.removeItem('owf_admin_token')
  sessionStorage.removeItem('owf_admin_user')
  authToken.value = adminToken
  authUser.value  = adminUser
  impersonating.value = false
  impersonatedUser.value = null
}
```

### `src/components/ImpersonationBanner.vue` (nuevo)

```vue
<template>
  <div v-if="authStore.impersonating" class="impersonation-banner">
    <q-icon name="manage_accounts" />
    Estás viendo la cuenta de
    <strong>{{ authStore.impersonatedUser?.name }}</strong>
    <q-btn flat dense label="Volver al Admin" @click="stop" />
  </div>
</template>
```

CSS: banner fixed top, z-index 9999, fondo `#EF4444` (rojo alerta), texto blanco, altura 40px.

**Montar en `AppShell.vue`** (ya tiene la estructura de layout):
```vue
<ImpersonationBanner />   <!-- antes del <router-view> -->
```

---

## OWF-148 — AdminLayout sidebar v2

**Archivo:** `src/layouts/AdminLayout.vue` (mejorar el existente)

### Cambios
1. Añadir secciones con `q-item-label header`
2. Añadir `q-item-section avatar` con iconos a cada ítem
3. Badge en "Usuarios" con count total
4. Añadir link a `/admin/users/:id` como sub-ruta dinámica cuando hay un usuario abierto
5. Añadir botón "Cerrar sesión" con confirmación al final del drawer

### Grupos del sidebar
```vue
<!-- USUARIOS -->
<q-item-label header>Usuarios</q-item-label>
<q-item to="/admin/users">
  <q-item-section avatar><q-icon name="group" /></q-item-section>
  <q-item-section>Todos los usuarios</q-item-section>
  <q-item-section side><q-badge :label="usersCount" color="primary" /></q-item-section>
</q-item>
<q-item to="/admin/roles">
  <q-item-section avatar><q-icon name="manage_accounts" /></q-item-section>
  <q-item-section>Roles</q-item-section>
</q-item>

<!-- CATÁLOGOS -->
<q-item-label header>Catálogos</q-item-label>
<!-- currencies, account_type, taxes, item_categories, items, providers, transaction_types, clients, rates -->

<!-- SISTEMA -->
<q-item-label header>Sistema</q-item-label>
<!-- system, ai_monitor -->
```

---

## OWF-149 — Modal cambiar contraseña

**Componente:** `src/components/admin/ChangePasswordModal.vue` (nuevo)

```vue
<q-dialog v-model="open">
  <q-card style="min-width:360px">
    <q-card-section>
      <div class="text-h6">Cambiar contraseña</div>
      <div class="text-caption text-grey-6">{{ user.name }}</div>
    </q-card-section>
    <q-card-section>
      <q-input v-model="password" type="password" label="Nueva contraseña" />
      <q-input v-model="confirmation" type="password" label="Confirmar" />
    </q-card-section>
    <q-card-actions align="right">
      <q-btn flat label="Cancelar" v-close-popup />
      <q-btn unelevated color="primary" label="Cambiar" @click="save" :loading />
    </q-card-actions>
  </q-card>
</q-dialog>
```

---

## Actualización del router admin

**Archivo:** `src/router/admin.routes.ts`

```typescript
// Añadir a los children de /admin:
{ path: 'users/:id', component: () => import('pages/admin/users/detail.vue') },
```

---

## Archivos a crear/modificar

| Acción | Archivo |
|---|---|
| REESCRIBIR | `src/pages/admin/users/index.vue` |
| CREAR | `src/pages/admin/users/detail.vue` |
| CREAR | `src/components/ImpersonationBanner.vue` |
| CREAR | `src/components/admin/ChangePasswordModal.vue` |
| MODIFICAR | `src/stores/auth.ts` (añadir impersonation state/actions) |
| MODIFICAR | `src/layouts/AdminLayout.vue` (sidebar v2) |
| MODIFICAR | `src/layouts/AppShell.vue` (montar ImpersonationBanner) |
| MODIFICAR | `src/router/admin.routes.ts` (añadir ruta detail) |
