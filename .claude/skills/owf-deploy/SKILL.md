# Skill: owf-deploy

## Trigger
Invoke this skill when:
- The user says "deploya", "deploy", "sube a prod", "publica", "lanza a producción"
- A task (OWF-NNN) is marked complete and involves frontend or backend changes
- The user asks "¿está en prod?", "¿lo subiste?"

## Protocol: Deploy After Every Task

After completing any code task, ALWAYS deploy unless the user explicitly says not to.
This is the standard: **code done = deploy done**.

---

## Commands

### Frontend (Quasar SPA)
```bash
cd /Users/otero/OW_Ecosystem/apps/owfinance/central
./deploy-frontend.sh prod "OWF-NNN: descripción breve"
```

### Backend (Laravel)
```bash
cd /Users/otero/OW_Ecosystem/apps/owfinance/central
./deploy-backend.sh prod "OWF-NNN: descripción breve"
```

### Ambos (cuando hay cambios en frontend Y backend)
Run both — backend first, then frontend.

---

## What the scripts do

### deploy-frontend.sh prod
1. Health check de prod (owf-ops-status)
2. `git add -A && git commit` en submodule OWFinanceFrontend2025
3. `git push origin main`
4. `quasar build` con `.env.production` (ESLint incluido — BUILD FALLA si hay errores lint)
5. Crea `.htaccess` + PHP wrapper (`index.php` → `_app.html`) para no-cache en LiteSpeed
6. `rsync` de dist/spa/ → servidor remoto `~/public_html/app/`
7. Sync assets → `~/public_html/assets/`
8. Actualiza `~/public_html/index.php` (proxy API/SPA)
9. Verificación HTTP final + notificación Telegram

### deploy-backend.sh prod
1. `git add -A && git commit` en submodule OWFINANCEBackend2025
2. `git push origin main`
3. rsync código → servidor remoto
4. `composer install --no-dev`
5. `php artisan migrate --force`
6. `php artisan config:cache && route:cache && view:cache`
7. Verificación HTTP `/up`

---

## Critical: Build will fail if ESLint errors exist

Before running deploy, if you modified .vue or .ts files, check:
```bash
cd OWFinanceFrontend2025
npx vue-tsc --noEmit   # TypeScript check
```

Common ESLint errors to fix before deploy:
- `@typescript-eslint/no-unused-vars` — remove unused imports/computed/refs
- `@typescript-eslint/no-misused-promises` — wrap async in `void (async () => {...})()`
- `@typescript-eslint/no-base-to-string` — cast unknown types: `String(x as unknown)`
- `vue/no-deprecated-filter` — avoid `|` pipe in template binding expressions (TypeScript union types trigger this)

---

## Git submodule note

Frontend and backend are git submodules inside `/central`. When committing:
- Frontend: work from `OWFinanceFrontend2025/` directory → `git add src/...` (NOT `OWFinanceFrontend2025/src/...`)
- Backend: work from `OWFINANCEBackend2025/` directory
- The deploy scripts handle commits automatically via `git add -A`
- The `central` repo tracks the submodule pointer — commit there too after deploy

---

## Prod URLs
- Frontend: https://owfinances.com/app/
- API health: https://owfinances.com/up
- API base: https://owfinances.com/api/v1

---

## After deploy checklist
1. ✅ Exit code 0 from script
2. ✅ "DEPLOY COMPLETADO" in output
3. ✅ `frontend=OK:200` in verification line
4. Update `.owf/STATE.md` with deploy status
5. Update `.owf/TASKS.md` — mark OWF-NNN as [x] done
