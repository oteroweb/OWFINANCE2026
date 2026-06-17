# OWFINANCE — Contexto Rico
<!-- PROTOCOLO: Decisiones, archivos clave, gotchas, patrones. -->
<!-- Cualquier agente puede escribir aqui. Es la memoria colectiva. -->

## Arquitectura

- **Backend**: Laravel 12 + Sanctum, API prefix `/api/v1`, DB SQLite (local), MySQL (prod)
- **Frontend**: Quasar 2 + Vue 3 + TypeScript, Pinia stores, `publicPath: '/'` (opcion B — antes era `/app/`)
- **Mobile**: Capacitor en `src-capacitor/`
- **Server**: LiteSpeed (no Apache), Ubuntu 24.04, IP 178.156.160.70

## Archivos Criticos (no romper)

- `OWFINANCEBackend2025/config/database.php` — usa valor literal 1011 para MYSQL_ATTR_SSL_CA (PHP 8.5)
- `OWFINANCEBackend2025/bootstrap/app.php` — `error_reporting(E_ALL & ~E_DEPRECATED)`
- `OWFINANCEBackend2025/public/.htaccess` — regla critica para `/app/`, NO eliminar
- `OWFinanceFrontend2025/quasar.config.ts` — `publicPath: '/'`, `vueRouterBase: '/'`, devServer `0.0.0.0:9000`
- `OWFinanceFrontend2025/src/router/public.routes.ts` — rutas publicas como children de PublicLayout (no instancias separadas)
- `OWFinanceFrontend2025/src/layouts/DynamicRoleLayout.vue` — slot pattern: renderiza layout y pasa `<router-view />` como slot
- `OWFinanceFrontend2025/src/boot/axios.ts` — interceptor bearer token
- `OWFinanceFrontend2025/src/stores/auth.ts` — login devuelve `{token, user, role}`, resilience para responses contaminadas

## Deploy

- Scripts raiz: `deploy-backend.sh`, `deploy-frontend.sh` — consumen `.deploy/<env>.sh`
- `.deploy/` centraliza credenciales, `.gitignore` excluye dev/stage/prod.sh
- `.deploy/sync-secrets.sh` sincroniza local → GitHub Secrets via `gh`
- Frontend build: `.htaccess` + PHP wrapper (`index.php` → `_app.html`) para no-cache en LiteSpeed
- Servidor estatico LAN: `npx serve -s dist/spa -l 9000` con symlink `app -> .` (se pierde al rebuild)

## Routing Opcion B (deployado 2026-06-10)

- `publicPath: '/'` — assets se sirven desde `/assets/` (symlink a `/app/assets/`)
- `public_html/index.php` (server): API routes (`/api/*`, `/up`) → Laravel. Todo lo demas → SPA `_app.html`
- Symlinks en `public_html/`: `assets` → `app/assets`, `icons` → `app/icons`, `favicon.ico` → `app/favicon.ico`
- Rutas publicas: children de PublicLayout (una sola instancia)
- DynamicRoleLayout: renderiza layout via `v-if` y pasa `<router-view />` como slot content
- Layouts: usan `<slot><router-view /></slot>` — funciona standalone (slot fallback) y via DynamicRoleLayout (slot provided)

## Gotchas Conocidos

- PHP 8.5 depreca `PDO::MYSQL_ATTR_SSL_CA` — causa warnings que contaminan JSON. Fix en database.php + bootstrap
- Frontend `response.data` puede ser string si PHP emite warnings. auth.ts tiene regex fallback
- Symlink `app -> .` en dist/spa se pierde al hacer rebuild — hay que recrearlo
- `.env` del frontend cambia frecuentemente (local/remote/mobile/LAN) — no commitear por accidente
- Backend usa SQLite local, MySQL en server — migraciones deben ser compatibles
- Passwords prod: `S$ratoga.1990` para todos los users (actualizado via tinker 2026-06-10)
- Playwright login tests son flaky (state leaks between sequential tests) — no es bug de routing

## Entornos

| Entorno | URL | User SSH | Branch | Frontend Path | PHP | DB |
|---------|-----|----------|--------|---------------|-----|----|
| dev | appfinanzasdev.blockshift.website | appfinan2 | dev | ~/OWFINANCEBACKEND2025/public/app | ? | MySQL |
| stage | appfinanzas.blockshift.website | appfinan1 | stage | ~/public_html/app | ? | MySQL |
| prod | owfinances.com | owfinanc1 (ver .deploy/prod.sh) | main | ~/public_html/app | **8.4 LTS** | MySQL localhost (socket) |

## Produccion (owfinances.com) — Notas de setup

- Backend desplegado: `~/OWFINANCEBACKEND2025/` — Laravel 12.20.0, 47 tablas migradas
- `.env.production` subido como `.env` — APP_KEY generado, DB conecta via socket
- `composer.lock` generado con PHP 8.5 local — usar `--ignore-platform-reqs` si falla en server
- LiteSpeed: necesita `.htaccess` raíz + `index.php` proxy + `.user.ini` para PHP 8.4 handler
- `view:cache` falla intencionalmente — app es API-only, no tiene Blade views
- **No confundir**: `public_html/` es el web root del dominio. Backend Laravel vive en `~/OWFINANCEBACKEND2025/` con su propio `public/`
- Server no tiene `.git` en OWFINANCEBACKEND2025 — deploy es rsync directo, no git pull
- Composer en server: `/opt/ecp-php84/bin/php /usr/bin/composer --ignore-platform-reqs`

## IP LAN (dev temporal)

- Frontend: `http://192.168.31.107:9000/`
- Backend: `http://192.168.31.107:8000/api/v1`
- Cambiar `.env` de vuelta a localhost cuando no se necesite LAN

## Decisiones de Diseno

- Login split-panel del Redesign manteniendo toda la logica funcional
- Role se extrae en orden: `body.role` → `user.role.slug` → `user.role_slug` → `user.role_name`
- `auth.login()` devuelve `{token, user, role}` explicito para evitar reactividad Pinia inmediata
- Router guard usa `useAuthStore()` en vez de leer localStorage directo
- Rutas publicas como children de un unico PublicLayout (opcion B) — evita blank pages entre rutas
- DynamicRoleLayout usa slot pattern en vez de `<component :is>` sin slot — child routes necesitan `<router-view />` a la profundidad correcta
