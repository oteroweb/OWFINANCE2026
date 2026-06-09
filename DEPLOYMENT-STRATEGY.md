# OWFINANCE2026 Deployment & Branch Strategy

**Version:** 2.0
**Date:** 2026-06-09
**Status:** Active

---

## Repository Architecture

OWFINANCE2026 uses a **monorepo + git submodules** structure with 3 interconnected repositories:

```
OWFINANCE2026 (central orchestrator)
├── OWFinanceFrontend2025/ (submodule — Quasar 2 + Vue 3 + TypeScript + Capacitor)
│   ├── src/components/
│   ├── src/layouts/
│   ├── src/pages/
│   ├── src/stores/
│   └── package.json (npm)
│
└── OWFINANCEBackend2025/ (submodule — Laravel 12)
    ├── app/Http/Controllers/
    ├── app/Models/
    ├── routes/
    ├── database/migrations/
    └── composer.json
```

**Why submodules?**
- Independent versioning per repository
- Each repo can have its own release cycle
- Central OWFINANCE2026 tracks exact commits
- Clear separation of concerns (backend/frontend/ops)

---

## Environment Strategy

### Three-Environment Pipeline

```
LOCAL (Development)
    ↓ (git push origin feature/xxx)
DEV (Integration)
    ↓ (PR merge dev → stage)
STAGE (Testing / QA)
    ↓ (PR merge stage → master, release tag)
PROD (Live)
```

### Environment Details

| Environment | Branch | URL (propuesta) | Servidor | Usuario SSH | Deploy Time |
|-------------|--------|-----------------|----------|-------------|-------------|
| **LOCAL** | `feature/*` | localhost:9000 (Quasar) / localhost:8000 (Laravel) | — | — | Instant |
| **DEV** | `dev` | `dev.owfinances.com` | 178.156.160.70 | appfinan2 | ~5 min |
| **STAGE** | `stage` | `stage.owfinances.com` | 178.156.160.70 | appfinan1 | ~5 min |
| **PROD** | `master` | `app.owfinances.com` | 178.156.160.70 | appfinan1 | ~10 min |

> **Nota:** Las URLs de `owfinances.com` están pendientes de configuracion DNS (ver sección abajo).

---

## Branch Structure & Workflow

### Permanent Branches (Protected)

```
master
├── Stable production code
├── Deployed to: PROD (app.owfinances.com)
├── Create PRs from: stage
├── Protection: Require 1+ approvals, all tests pass
└── Tag: v*.*.* (semantic versioning)

stage
├── Release candidate / QA environment
├── Deployed to: STAGE (stage.owfinances.com)
├── Create PRs from: dev
├── Protection: Require tests pass, 1+ approvals
└── Auto-deploy on merge

dev
├── Integration branch (daily builds)
├── Deployed to: DEV (dev.owfinances.com)
├── Create PRs from: feature/*, bugfix/*
├── Protection: Require tests pass
└── Auto-deploy on merge
```

### Feature Branches

```
feature/ofb-001-header-lite
feature/ofb-002-bottom-nav
feature/ofb-029-fab-sheet

bugfix/fix-responsive-header
hotfix/critical-auth-bug
```

**Branch naming:**
- `feature/{ticket-code}-{description}` for new features
- `bugfix/{description}` for bug fixes
- `hotfix/{description}` for production urgent fixes (branch from master)

---

## Workflow: From Code to Production

### Step 1: Local Development (Developer)

```bash
# Start from dev
git checkout dev
git pull origin dev

# Create feature branch
git checkout -b feature/ofb-001-header-lite

# Work on changes
cd OWFinanceFrontend2025
quasar dev          # Frontend on localhost:9000
# OR
cd OWFINANCEBackend2025
php artisan serve   # Backend on localhost:8000

git add -A
git commit -m "feat: implement header lite component"

# Keep branch up to date with dev
git fetch origin
git rebase origin/dev
```

### Step 2: Push & Create PR to DEV (Developer)

```bash
# Push feature branch
git push origin feature/ofb-001-header-lite

# Create PR in GitHub
# - Base: dev
# - Head: feature/ofb-001-header-lite
# - Title: "feat: implement header lite component (OFB-001)"
# - Description: Link to ticket, acceptance criteria, testing notes
```

**Automated on PR:**
- PHP linting (Laravel Pint)
- TypeScript compiler (strict mode)
- ESLint + Prettier
- Unit tests (PHPUnit + Vitest)
- Build verification

### Step 3: Merge to DEV

```bash
# When approved:
git checkout dev
git pull origin dev
git merge --no-ff feature/ofb-001-header-lite
git push origin dev

# DEV environment auto-deploys via script
```

**Auto-deployment to DEV:**
- Triggers: manual or CI/CD on merge to dev
- Command: `./deploy-frontend.sh dev` + `./deploy-backend.sh dev`
- Deploys to dev.owfinances.com
- Telegram notification sent

### Step 4: Integration Testing in DEV (QA/Team)

```
Deploy to DEV
↓
Team tests in DEV environment
- Visual regression testing
- Cross-device testing (mobile + web)
- API integration testing
↓
If issues: Create bugfix PRs against dev
If OK: Ready for stage
```

### Step 5: Promote to STAGE (Tech Lead)

```bash
# Create PR from dev → stage
git checkout stage
git pull origin stage
git merge --no-ff dev
git push origin stage

# STAGE auto-deploys
./deploy-frontend.sh stage
./deploy-backend.sh stage
```

### Step 6: Sign-Off & Deploy to PROD (Manager/Tech Lead)

```bash
# Create PR from stage → master
git checkout master
git pull origin master
git merge --no-ff stage
git push origin master

# Create release tag
git tag -a v1.2.3 -m "Release v1.2.3: OWFINANCE2026"
git push origin v1.2.3

# Deploy to PROD (manual trigger)
./deploy-frontend.sh stage   # prod uses appfinan1 / stage env vars
./deploy-backend.sh stage
# Run smoke tests after deploy
```

---

## Configuracion DNS Pendiente

Para activar el dominio `owfinances.com`, crear los siguientes registros A en el panel DNS:

| Subdominio | Tipo | Valor (IP) | TTL |
|------------|------|------------|-----|
| `app.owfinances.com` | A | 178.156.160.70 | 3600 |
| `stage.owfinances.com` | A | 178.156.160.70 | 3600 |
| `dev.owfinances.com` | A | 178.156.160.70 | 3600 |
| `owfinances.com` | A | 178.156.160.70 | 3600 |
| `www.owfinances.com` | CNAME | owfinances.com | 3600 |

**Pasos post-DNS:**
1. Confirmar propagacion: `dig app.owfinances.com`
2. Actualizar VirtualHosts en el servidor (Nginx/Apache) para cada subdominio
3. Emitir certificados SSL via Let's Encrypt: `certbot --nginx -d app.owfinances.com -d stage.owfinances.com -d dev.owfinances.com`
4. Actualizar variables de entorno en los scripts (reemplazar `blockshift.website` → `owfinances.com`)
5. Actualizar `.env.production` y `.env.dev` en los submodulos

---

## Scripts de Deploy

### deploy-frontend.sh

Compila el frontend Quasar y lo sube via rsync+SSH al servidor.

```bash
# Uso:
./deploy-frontend.sh [stage|dev] ["mensaje de commit opcional"]

# Ejemplos:
./deploy-frontend.sh dev                              # Deploy a dev.owfinances.com
./deploy-frontend.sh stage "feat: nueva pantalla"    # Deploy a stage.owfinances.com

# Que hace:
# 1. Lee el entorno (stage → appfinan1, dev → appfinan2)
# 2. Hace git commit + push del submodulo frontend
# 3. Compila con 'quasar build' usando el .env correspondiente
# 4. Sube dist/ via rsync al servidor
# 5. Envia notificacion Telegram al finalizar
```

| Parametro | stage | dev |
|-----------|-------|-----|
| Usuario SSH | appfinan1 | appfinan2 |
| Branch | stage | dev |
| ENV file | .env.production | .env.dev |
| URL destino | stage.owfinances.com (pendiente) | dev.owfinances.com (pendiente) |
| Dir remoto | public_html/app | OWFINANCEBACKEND2025/public/app |

### deploy-backend.sh

Sincroniza el backend Laravel via rsync+SSH y ejecuta comandos post-deploy.

```bash
# Uso:
./deploy-backend.sh [stage|dev]

# Ejemplos:
./deploy-backend.sh dev     # Deploy backend a dev
./deploy-backend.sh stage   # Deploy backend a stage (default)

# Que hace:
# 1. rsync del directorio OWFINANCEBackend2025/ al servidor
# 2. Excluye: .env, vendor/, node_modules/, .git/
# 3. Ejecuta remotamente: composer install, php artisan migrate, php artisan config:cache
# 4. Verifica health endpoint (/up)
# 5. Envia notificacion Telegram al finalizar
```

### deploy-mobile.sh

Construye y distribuye la app movil (Android/iOS via Capacitor).

```bash
# Uso:
./deploy-mobile.sh [android|ios|both] [dev|staging|prod]

# Ejemplos:
./deploy-mobile.sh android dev      # APK de desarrollo
./deploy-mobile.sh android prod     # APK de produccion
./deploy-mobile.sh both staging     # Android + iOS para QA

# Requisitos:
# - Android: JAVA_HOME configurado, Android SDK instalado
# - iOS: Solo macOS con Xcode instalado
```

### Otros scripts utiles

| Script | Descripcion |
|--------|-------------|
| `./dev-start.sh` | Levanta entorno de desarrollo local |
| `./dev-stop.sh` | Detiene entorno de desarrollo local |
| `./ops-status.sh` | Muestra estado de los entornos remotos |
| `./sync_stage_to_dev.sh` | Sincroniza stage → dev (hotfixes) |
| `./push-workspace.sh` | Push del monorepo + submodulos |

---

## Submodule Synchronization

### Updating Submodules

```bash
# Clone with submodules
git clone --recurse-submodules <repo-url>

# Update all submodules to latest commits
git submodule update --init --recursive

# Work in submodule
cd OWFinanceFrontend2025
git checkout feature/ofb-001-header-lite
# ... make changes
git add -A
git commit -m "feat: header component"
git push origin feature/ofb-001-header-lite

# Return to parent and commit submodule reference
cd ..
git add OWFinanceFrontend2025
git commit -m "chore: update frontend submodule to latest"
git push origin feature/branch-name
```

---

## Rollback Strategy

### If Production Breaks

```bash
# Step 1: Identify the broken commit
git log --oneline master | head -5

# Step 2: Revert the commit (preferred — keeps history)
git revert abc1234 -m 1
git push origin master

# Step 3: OR reset to previous tag (more aggressive)
git reset --hard def5678
git tag v1.2.4-rollback
git push origin master --force-with-lease

# Step 4: Redeploy
./deploy-frontend.sh stage
./deploy-backend.sh stage

# Step 5: Post-incident
# - Create GitHub issue for RCA
# - Link to failed PR
# - Add regression tests
```

---

## Checklist: From Feature to Production

- [ ] **Local**
  - [ ] Feature branch created from `dev`
  - [ ] Changes tested locally
  - [ ] Tests pass (PHPUnit + Vitest)
  - [ ] TypeScript strict, no errors
  - [ ] ESLint passes, Prettier formatted
  - [ ] Commit messages follow convention

- [ ] **PR to DEV**
  - [ ] PR description links to ticket
  - [ ] Acceptance criteria documented
  - [ ] Screenshots/videos if UI change
  - [ ] Code review approved

- [ ] **Merge to DEV**
  - [ ] CI/CD pipeline passes
  - [ ] Deployed to dev.owfinances.com
  - [ ] Team QA testing completes
  - [ ] No blockers found

- [ ] **Promote to STAGE**
  - [ ] PR from dev → stage approved
  - [ ] Deployed to stage.owfinances.com
  - [ ] Full QA sign-off received
  - [ ] No security/compliance issues

- [ ] **Release to PROD**
  - [ ] PR from stage → master approved
  - [ ] Git tag created (v*.*.*)
  - [ ] Deployed to app.owfinances.com
  - [ ] Smoke tests pass
  - [ ] Telegram notification sent
  - [ ] Monitoring alerts configured

---

## Quick Reference: Common Tasks

### Start a new feature

```bash
git checkout dev && git pull origin dev
git checkout -b feature/ofb-XXX-description
# ... work ...
git push origin feature/ofb-XXX-description
# Create PR → base: dev
```

### Hotfix to production

```bash
git checkout master && git pull origin master
git checkout -b hotfix/critical-bug-fix
# ... fix ...
git push origin hotfix/critical-bug-fix
# Create PR → base: master, then cherry-pick to dev
```

### Check deployed version

```bash
# Check what commit is live
curl https://app.owfinances.com/up
git log --oneline master | head -5
```

---

**Last Updated:** 2026-06-09
**Next Review:** End of current sprint
