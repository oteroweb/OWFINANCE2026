# MANUAL-002 — Deploy a Staging

**Tipo**: Acción manual
**Prerequisito**: MANUAL-001 completado
**Tiempo estimado**: 30-60 minutos

## Backend (servidor staging)

```bash
# En el servidor staging
git pull origin main
composer install --no-dev --optimize-autoloader

# .env en servidor — copiar de .env.example y llenar:
# APP_ENV=production
# APP_DEBUG=false
# DB_*, REDIS_URL, AI_*_PROVIDER, *_API_KEY

php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan migrate --force
php artisan db:seed --class=AiUserSettingsSeeder
```

## Frontend

```bash
cd OWFinanceFrontend2025
npm install
npm run build
# Copiar dist/spa/ al servidor
```

## Nginx SPA (si no está configurado)

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

## Smoke tests

Ver: `OWFINANCEBackend2025/DEPLOY_STAGING.md` para lista completa de smoke tests.
