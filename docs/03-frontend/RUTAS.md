# Rutas del Frontend — OWFinance

> Fuente de verdad para todas las rutas de la SPA.  
> Generado: 2026-04-03 | Framework: Quasar 2 + Vue Router 4 | Modo web: `history`

---

## Bases de entorno

| Entorno | `vueRouterBase` / `publicPath` | API Backend |
|---------|-------------------------------|-------------|
| **Local dev (web)** | `/app/` | `http://localhost:8000/api/v1` (`.env` local) |
| **Dev remoto (web)** | `/app/` | `https://appfinanzasdev.blockshift.website/api/v1` (`.env.dev`) |
| **Producción (web)** | `/app/` | `https://appfinanzas.blockshift.website/api/v1` (`.env.production`) |
| **Móvil Android/iOS** | `/` (hash mode) | `https://appfinanzas.blockshift.website/api/v1` (`.env.mobile`) |
| **Móvil beta/dev** | `/` (hash mode) | `https://appfinanzasdev.blockshift.website/api/v1` (`.env.mobile-dev`) |

> **Regla clave:** La `vueRouterBase` es el prefijo que Vue Router antepone a todas las rutas en la URL del navegador. Sin embargo, **dentro del código** (router.push, redirect, to.path) siempre se usa la ruta interna **sin** el prefijo `/app/`.

---

## Arquitectura de layouts del área de usuario

El área `/user` usa un único punto de entrada: **`DynamicRoleLayout.vue`**. Este componente selecciona el layout visual en tiempo de ejecución basándose en `auth.settings.layout_mode`:

| `layout_mode` | Layout cargado | Estado |
|---------------|----------------|--------|
| `lite` | `LiteMobileLayout.vue` | ✅ Activo — diseño mobile-first Liquid Glass |
| `pro` | `ProLayout.vue` | 🔧 En desarrollo |
| `legacy` | `LegacyLayout.vue` | ✅ Fallback por defecto si `layout_mode` no está definido |

> El valor de `layout_mode` viene de `auth.settings` (endpoint `/user/settings`). Si no existe, cae en `legacy`.

> **Nota sobre admin:** El rol `admin` existe y tiene sus propias rutas bajo `/admin` con `AdminLayout.vue`, pero **no es prioritario en esta etapa** del producto.

---

## Tabla de rutas — Web (prefijo `/app/`)

### Rutas públicas

| Ruta Vue Router | URL Local | URL Dev remoto | URL Producción | Descripción |
|-----------------|-----------|----------------|----------------|-------------|
| `/login` | `http://localhost:9000/app/login` | `https://appfinanzasdev.blockshift.website/app/login` | `https://appfinanzas.blockshift.website/app/login` | Pantalla de inicio de sesión |
| `/` | → redirect `/login` | → redirect `/login` | → redirect `/login` | Raíz — redirige a login |
| `/dashboard` | → redirect dinámica por rol | → idem | → idem | Alias inteligente; ve a `/admin` o `/user/home` según rol |

### Rutas de usuario autenticado (`role: user`)

| Ruta Vue Router | URL Local | URL Dev remoto | URL Producción | Descripción |
|-----------------|-----------|----------------|----------------|-------------|
| `/user` | `http://localhost:9000/app/user` | `.../app/user` | `.../app/user` | → redirect automático a `/user/home` |
| `/user/home` | `http://localhost:9000/app/user/home` | `.../app/user/home` | `.../app/user/home` | **Dashboard principal del usuario** ⬅ destino post-login |
| `/user/transactions` | `http://localhost:9000/app/user/transactions` | `.../app/user/transactions` | `.../app/user/transactions` | Movimientos / transacciones |
| `/user/accounts` | `http://localhost:9000/app/user/accounts` | `.../app/user/accounts` | `.../app/user/accounts` | Cuentas bancarias |
| `/user/categories` | `http://localhost:9000/app/user/categories` | `.../app/user/categories` | `.../app/user/categories` | Categorías de gastos/ingresos |
| `/user/jars` | `http://localhost:9000/app/user/jars` | `.../app/user/jars` | `.../app/user/jars` | Jars (sobres de dinero) |
| `/user/taxes` | `http://localhost:9000/app/user/taxes` | `.../app/user/taxes` | `.../app/user/taxes` | Impuestos |
| `/user/expense-analysis` | `http://localhost:9000/app/user/expense-analysis` | `.../app/user/expense-analysis` | `.../app/user/expense-analysis` | Análisis de gastos |
| `/user/config` | `http://localhost:9000/app/user/config` | `.../app/user/config` | `.../app/user/config` | Configuración / perfil del usuario |

### Rutas de administrador (`role: admin`) — _No prioritario actualmente_

| Ruta Vue Router | URL Local | URL Dev remoto | URL Producción | Descripción |
|-----------------|-----------|----------------|----------------|-------------|
| `/admin` | `http://localhost:9000/app/admin` | `.../app/admin` | `.../app/admin` | Dashboard de administración |
| `/admin/transactions` | `http://localhost:9000/app/admin/transactions` | `.../app/admin/transactions` | `.../app/admin/transactions` | Transacciones (vista admin) |
| `/admin/transactions-old` | `http://localhost:9000/app/admin/transactions-old` | `.../app/admin/transactions-old` | `.../app/admin/transactions-old` | Transacciones — vista legacy |
| `/admin/currencies` | — | — | `.../app/admin/currencies` | Divisas |
| `/admin/clients` | — | — | `.../app/admin/clients` | Clientes |
| `/admin/users` | — | — | `.../app/admin/users` | Usuarios |
| `/admin/account_type` | — | — | `.../app/admin/account_type` | Tipos de cuenta |
| `/admin/accounts` | — | — | `.../app/admin/accounts` | Cuentas |
| `/admin/taxes` | — | — | `.../app/admin/taxes` | Impuestos (admin) |
| `/admin/item_categories` | — | — | `.../app/admin/item_categories` | Categorías de ítems |
| `/admin/items` | — | — | `.../app/admin/items` | Ítems |
| `/admin/jars` | — | — | `.../app/admin/jars` | Jars (admin) |
| `/admin/categories` | — | — | `.../app/admin/categories` | Categorías (admin) |
| `/admin/rates` | — | — | `.../app/admin/rates` | Tasas |
| `/admin/providers` | — | — | `.../app/admin/providers` | Proveedores |

### Ruta catch-all (404)

| Ruta Vue Router | Comportamiento |
|-----------------|----------------|
| `/:catchAll(.*)*` | Muestra `ErrorNotFound.vue` |

---

## Tabla de rutas — Móvil (Capacitor, hash mode, prefijo `/`)

En modo Capacitor (`quasar dev -m capacitor` o build móvil), el router usa **hash history** y base `/`. Las rutas son idénticas en nombre pero la URL usa `#`:

| Ruta Vue Router | URL en dispositivo/emulador |
|-----------------|-----------------------------|
| `/login` | `file:///android_asset/www/index.html#/login` |
| `/user/home` | `file:///android_asset/www/index.html#/user/home` |
| `/user/transactions` | `file:///android_asset/www/index.html#/user/transactions` |
| (resto de rutas) | `...#/{ruta}` |

---

## Flujo de selección de layout (área usuario)

```
Usuario autenticado entra a /user/*
          │
          ▼
  DynamicRoleLayout.vue
          │
          ├─ layout_mode === 'lite'    → LiteMobileLayout.vue  (Liquid Glass, mobile-first)
          ├─ layout_mode === 'pro'     → ProLayout.vue
          └─ default / no definido    → LegacyLayout.vue
```

`layout_mode` se configura en `/user/config` y se persiste en backend vía `/user/settings`.

---

## Flujo de navegación post-login

```
Usuario ingresa credenciales en /login
          │
          ▼
  auth.login() → guarda token + role en Pinia/localStorage
          │
          ▼
  navigateByRole() en LoginPage.vue
    ├─ role === 'admin'  → router.push('/admin')
    └─ role === 'user'   → router.push('/user')
                                  │
                                  ▼
                       redirect interno → '/user/home'
                       (UserLayout.vue cargado)
```

### Guard de router (beforeEach) — `src/router/index.ts`

| Condición | Acción |
|-----------|--------|
| Accede a `/login` estando ya autenticado como `admin` | Redirige a `/admin` |
| Accede a `/login` estando ya autenticado como `user` | Redirige a `/user/home` |
| Accede a ruta con `requiresAuth: true` sin token | Redirige a `/login` |
| Accede a ruta con `meta.role` que no coincide con el suyo | Redirige a `/login` |

---

## Bug corregido (2026-04-03)

**Problema:** El guard en `src/router/index.ts` redirigía a `/app/home` para usuarios con `role === 'user'`.  
**Por qué fallaba:** `/app/home` es la URL del navegador (con el prefijo de `vueRouterBase`), no una ruta interna de Vue Router. Vue Router buscaba la ruta `/app/home` y no existía → **404**.  
**Corrección:** Cambiado a `/user/home`, que es la ruta interna correcta definida en `routes.ts`.

```diff
- return next('/app/home')
+ return next('/user/home')
```

Archivo: `OWFinanceFrontend2025/src/router/index.ts`

---

## Referencias de código

| Archivo | Propósito |
|---------|-----------|
| `OWFinanceFrontend2025/src/router/routes.ts` | Definición de todas las rutas |
| `OWFinanceFrontend2025/src/router/index.ts` | Creación del router + guard `beforeEach` |
| `OWFinanceFrontend2025/quasar.config.ts` | `vueRouterBase`, `vueRouterMode`, `publicPath` por modo |
| `OWFinanceFrontend2025/src/pages/LoginPage.vue` | Lógica `navigateByRole()` post-login |
| `OWFinanceFrontend2025/src/layouts/DynamicRoleLayout.vue` | Selector dinámico de layout por `layout_mode` |
| `OWFinanceFrontend2025/src/layouts/LiteMobileLayout.vue` | Layout Lite — Liquid Glass, mobile-first |
| `OWFinanceFrontend2025/src/layouts/ProLayout.vue` | Layout Pro (en desarrollo) |
| `OWFinanceFrontend2025/src/layouts/LegacyLayout.vue` | Layout Legacy — fallback por defecto |
