# Rutas del Frontend - OWFinance

Estado documental: `vigente`

Fuente de verdad para las rutas activas de la SPA.

## Nota de alcance

- Este documento describe rutas activas y ejecutables.
- Referencias a `/lite` o `/pro` en otros documentos no deben usarse como verdad de routing actual.
- La app web se publica bajo `/app/`, pero el router interno usa rutas sin ese prefijo base.

## Bases de entorno

| Entorno | Base publica | API backend |
|---|---|---|
| Local web | `/app/` | `http://localhost:8000/api/v1` |
| Dev remoto web | `/app/` | `https://appfinanzasdev.blockshift.website/api/v1` |
| Produccion web | `/app/` | `https://appfinanzas.blockshift.website/api/v1` |
| Mobile | `/` | backend remoto segun `.env.mobile*` |

## Rutas publicas vigentes

- `/login`
- `/register`
- `/`
  Redirige a `/login`
- `/dashboard`
  Redireccion inteligente por rol

## Rutas de usuario vigentes

Todas viven bajo `/app/*` en el router real actual:
- `/app/home`
- `/app/expense-analysis`
- `/app/transactions`
- `/app/accounts`
- `/app/categories`
- `/app/taxes`
- `/app/config`
- `/app/jars`

Compatibilidad legacy:
- `/app/user/:pathMatch(.*)*`
  Redirige a la ruta limpia equivalente bajo `/app/*`

## Rutas de admin vigentes

- `/admin`
- `/admin/transactions`
- `/admin/transactions-old`
- `/admin/currencies`
- `/admin/clients`
- `/admin/users`
- `/admin/account_type`
- `/admin/accounts`
- `/admin/taxes`
- `/admin/item_categories`
- `/admin/items`
- `/admin/jars`
- `/admin/categories`
- `/admin/rates`
- `/admin/providers`

## Guard y reglas

- Si una ruta requiere auth y no hay sesion, redirige a `/login`.
- Si el rol no coincide, redirige a `/login`.
- Si se entra a `/login` con sesion activa:
  - admin -> `/admin`
  - user -> `/app/home`

## Archivos de referencia

- `OWFinanceFrontend2025/src/router/routes.ts`
- `OWFinanceFrontend2025/src/router/index.ts`
- `OWFinanceFrontend2025/quasar.config.ts`
