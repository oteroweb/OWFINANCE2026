# AGENTS.md - Guia para agentes de IA en OWFINANCE2026

## Objetivo
Este archivo define como debe operar un agente de IA en este workspace para:
- analizar el sistema rapido;
- hacer cambios sin romper contratos;
- desplegar y actualizar con seguridad.

Fecha de referencia de esta guia: 2026-03-01.

## Alcance del workspace
Este workspace contiene dos repositorios Git separados:
- `OWFINANCEBackend2025` (Laravel API)
- `OWFinanceFrontend2025` (Quasar/Vue Web + Mobile con Capacitor)

Directorio raiz de coordinacion (scripts y docs compartidos):
- `README.md`
- `dev-start.sh`, `dev-stop.sh`, `switch-env.sh`, `deploy-mobile.sh`, `status.sh`, `telegram-notify.sh`, `telegram-heartbeat.sh`, `ops-status.sh`

## Mapa rapido del sistema
- Backend:
  - Framework: Laravel 12 + Sanctum (`OWFINANCEBackend2025/composer.json`)
  - Prefijo API real: `/api/v1` (`OWFINANCEBackend2025/bootstrap/app.php`)
  - Dominios principales: auth, users, accounts, categories, transactions, jars, rates, currencies.
- Frontend:
  - Framework: Quasar 2 + Vue 3 + TypeScript (`OWFinanceFrontend2025/package.json`)
  - Cliente API: `src/boot/axios.ts`
  - Rutas UI: `src/router/routes.ts`
  - Estado: Pinia (`src/stores/*`)
- Mobile:
  - Capacitor en `OWFinanceFrontend2025/src-capacitor`
  - Build/deploy via scripts de raiz (`deploy-mobile.sh`, `build-apk.sh`, `dev-mobile.sh`)

## Contratos tecnicos que NO se deben romper
1. API base versionada:
   - Usar siempre `/api/v1`.
   - Ejemplo correcto: `http://localhost:8000/api/v1`.
2. Autenticacion:
   - Token bearer de Sanctum.
   - Frontend inyecta token en interceptor (`src/boot/axios.ts`).
3. Envelope de respuesta API:
   - Backend suele responder `{ status, code, message, data }`.
   - Frontend interpreta `status=FAILED` o `code>=400` como error.
4. Scoping por usuario:
   - Endpoints sensibles (`transactions`, `jars`, `accounts`) aplican logica de usuario autenticado.
5. Jars:
   - Hay logica avanzada de sync/batch, exclusividad de categorias y porcentajes <= 100.
   - Cualquier cambio debe preservar estas invariantes.

## Flujo de trabajo recomendado para agentes
1. Leer contexto minimo:
   - `README.md` (raiz)
   - `docs/ARQUITECTURA_PROYECTO.md`
   - `docs/CONSULTAS_OPERATIVAS.md`
2. Confirmar entorno activo:
   - `./status.sh`
   - revisar `OWFinanceFrontend2025/.env`
3. Si la tarea toca backend:
   - revisar ruta en `OWFINANCEBackend2025/routes/api/*.php`
   - revisar controlador/repo/model implicados.
4. Si la tarea toca frontend:
   - revisar store, boot/axios y pagina/ruta implicada.
5. Ejecutar verificaciones minimas antes de cerrar:
   - Backend: `cd OWFINANCEBackend2025 && php artisan test` (si aplica y hay tiempo)
   - Frontend: `cd OWFinanceFrontend2025 && npm run lint`

## Comandos base (raiz)
- Arranque local web completo:
  - `./switch-env.sh local`
  - `./dev-start.sh`
- Detener servicios:
  - `./dev-stop.sh`
- Estado general:
  - `./status.sh`
- Estado operativo extendido:
  - `./ops-status.sh dev`
  - `./ops-status.sh stage`
- Sincronizacion de punteros del workspace:
  - `./sync-submodule-pointers.sh --report`
  - `./sync-submodule-pointers.sh --commit`
  - `./push-workspace.sh backend "mensaje"`
  - `./push-workspace.sh frontend "mensaje"`
- Avisos por Telegram:
  - `./telegram-notify.sh test --title OWFINANCE`
  - `./telegram-step.sh --title Worker "Task step happened"`
  - `./telegram-heartbeat.sh --title Worker --interval 300 "Task still running"` solo si hace falta un heartbeat real
- Mobile Android dev:
  - `./dev-mobile.sh`
- Deploy mobile:
  - `./deploy-mobile.sh android dev`
  - `./deploy-mobile.sh both prod`

## URLs de produccion (activas desde 2026-03-06)

| Recurso | URL |
|---|---|
| **Frontend SPA** | `https://appfinanzas.blockshift.website/app/` |
| **API Backend** | `https://appfinanzas.blockshift.website/api/v1` |
| **Health check API** | `POST https://appfinanzas.blockshift.website/api/v1/auth/login` |

- Servidor: LiteSpeed, Ubuntu 24.04, IP `178.156.160.70`, user `appfinan1`, puerto SSH 22.
- Ambos servicios corren en el mismo dominio, sin subdominios extra.
  - `/app/` → Quasar SPA estatica servida desde `~/public_html/app/`
  - `/api/v1/` → Laravel 12 desde `~/OWFINANCEBACKEND2025/`, `public_html` enlazada a `public/`

## Deploy y actualizaciones

### Instrucción crítica para agentes
**NO realices ningún deploy (ni backend ni frontend ni mobile) a menos que el usuario indique explícitamente la palabra "deploya" en su mensaje.**

### Deploy rapido (scripts de raiz)

```bash
# Subir cambios de backend
./deploy-backend.sh "descripcion del cambio"

# Subir cambios de frontend
./deploy-frontend.sh "descripcion del cambio"
```

### Lo que hace cada script

**`deploy-backend.sh`**:
1. `git add -A && git commit` con el mensaje dado
2. `git push origin main` → github.com/oteroweb/OWFINANCEBACKEND2025
3. SSH al servidor: `git pull + composer install + php artisan migrate + caches`
4. Verifica respuesta HTTP del API

**`deploy-frontend.sh`**:
1. `git add -A && git commit` con el mensaje dado
2. `git push origin main` → github.com/oteroweb/OWFINANCEFRONTEND2025
3. `npx quasar build -m spa` con `.env.production` (`VITE_API_BASE_URL=https://appfinanzas.blockshift.website/api/v1`)
4. `rsync dist/spa/ → appfinan1@178.156.160.70:~/public_html/app/`

### Configuracion clave de produccion

- Frontend `quasar.config.ts`: `publicPath: '/app/'` — assets bajo `/app/assets/`
- Backend `public/.htaccess`: regla que excluye `/app/` del rewrite de Laravel
- Frontend `.env.production`: `VITE_API_BASE_URL=https://appfinanzas.blockshift.website/api/v1`
- Servidor `.env` (`~/OWFINANCEBACKEND2025/.env`): `APP_ENV=production`, `APP_DEBUG=false`, `APP_URL=https://appfinanzas.blockshift.website`

### GitHub Actions (backend automatico)
- Archivo: `OWFINANCEBackend2025/.github/workflows/deploy.yml`
- Trigger: push a `main`
- Requiere secret `SSH_KEY` en el repo de GitHub (clave privada cuyo pub esta en `authorized_keys` del servidor)
- Hace: git pull + composer + migrate + artisan:cache en el servidor

### Mobile
- Estrategia principal en `deploy-mobile.sh`.
- Entorno mobile usa backend remoto (`.env.mobile`) por defecto.

## Riesgos conocidos (detectar antes de ejecutar cambios grandes)
1. Scripts y docs no siempre consistentes:
   - `env-config.sh` genera frontend `.env` con `/api` en vez de `/api/v1`.
2. `README.md` raiz menciona Laravel 11, pero backend actual usa Laravel 12.
3. GitHub Actions `deploy.yml` requiere que el secret `SSH_KEY` este configurado en el repo.
4. Existen dos repositorios Git independientes; commits/versionado deben hacerse por repo.
5. El `.htaccess` de `public/` tiene regla critica para `/app/` — NO eliminar.
6. El repo central usa punteros Git para backend y frontend; despues de hacer push en esos repos puede hacer falta sincronizar el root con `./sync-submodule-pointers.sh --commit`.

## Regla de oro para agentes
Antes de modificar deployment, auth, rutas o jars:
- documentar impacto;
- validar contrato API;
- dejar pasos de rollback claros.

## Tooling de agentes instalado en este workspace

### Agent Teams Lite
- El workspace conserva `CLAUDE.md` como referencia de integración ATL, pero el entorno activo del usuario prioriza OpenCode, Antigravity/Gemini y VS Code.
- Skills SDD disponibles en `.claude/skills/`:
  - `sdd-init`, `sdd-explore`, `sdd-propose`, `sdd-spec`, `sdd-design`, `sdd-tasks`, `sdd-apply`, `sdd-verify`, `sdd-archive`, `skill-registry`.
- Convenciones compartidas en `.claude/skills/_shared/`.
- Registro local de skills en `.atl/skill-registry.md`.

### Engram
- Se asume como binario global instalado en la máquina.
- Configuración MCP de workspace en `.vscode/mcp.json`.
- Configuración global activa también en OpenCode (`~/.config/opencode/opencode.json`) y Gemini/Antigravity (`~/.gemini/settings.json`).
- Preferencia de persistencia para flujos SDD: `engram` cuando esté disponible.

### Roles operativos OWFINANCE
- Skills de rol del workspace en `.agents/skills/owf-role-*/`.
- Skill operativo de Telegram/Ops en `.agents/skills/telegram-ops-notifier/`.
- Skill de bridge/contexto Telegram en `.agents/skills/telegram-context-bridge/`.
- El bridge Telegram mantiene exactamente `/status`, `/status dev`, `/status stage`, `/status prod`, `/help`, `/last` y `/context`; los mensajes libres se responden como chat paralelo OWFINANCE con Gemini CLI local si esta disponible o con fallback deterministico de transcript/snapshot/docs.
- Skill documental del workspace en `.agents/skills/documentator/`.
- Copia para discoverability de OpenCode en `~/.config/opencode/skills/owf-role-*/`.
- Copia OpenCode del skill operativo en `~/.config/opencode/skills/telegram-ops-notifier/`.
- Copia OpenCode del skill de bridge en `~/.config/opencode/skills/telegram-context-bridge/`.
- Copia OpenCode del skill documental en `~/.config/opencode/skills/documentator/`.
- Slash commands sugeridos en `~/.config/opencode/commands/role-*.md`.
- Slash command sugerido para Telegram/Ops en `~/.config/opencode/commands/telegram-ops.md`.
- Slash command sugerido para documentación en `~/.config/opencode/commands/documentator.md`.
- Documento de referencia: `docs/01-configuracion/SAAS_ROLE_SYSTEM.md`.
- La carpeta Drive `OWFINANCE` (`https://drive.google.com/drive/folders/1tjxzCrWceyWPXydOL374FytD0ExM_Jkh`) es el hub documental canonico y la fuente de verdad para estrategia, roles, planning y contexto compartido; bajar al repo solo resumenes cortos cuando hagan falta para agentes o ejecucion local.
- Cada rol OWF debe mantener docs, playbooks y decision logs canonicos en su carpeta primaria dentro de esa carpeta Drive `OWFINANCE`; usar `documentator` para discovery, estructura o sync corto al repo.
- Roles/skills instalados: `owf-role-ceo-strategy`, `owf-role-product-owner`, `owf-role-product-operations`, `owf-role-scrum-master-planning`, `owf-role-sales-commercial`, `owf-role-ui-ux-design-steward`, `owf-role-finance-unit-economics`, `owf-role-marketing-growth`, `owf-role-customer-success`, `owf-role-risk-compliance`, `owf-role-data-insights`, `owf-role-engineering-architecture`, `owf-role-qa-release-quality`, `owf-role-devops-platform-sre`, `documentator`, `telegram-ops-notifier`, y `telegram-context-bridge`.
- Si un rol necesita actualizar backlog, sprint, tareas o colas operativas en Notion, debe cargar primero `notion-mcp-integration`, intentar MCP primero y usar fallback HTTP API solo cuando MCP falle por auth/conectividad y exista `NOTION_API_TOKEN` valido. Para propuestas markdown del workspace, usar `notion-import/create_tickets_from_proposal.py`.

### Gentleman Guardian Angel (GGA)
- Configuración por repositorio:
  - `OWFINANCEBackend2025/.gga`
  - `OWFinanceFrontend2025/.gga`
- Ambas configuraciones usan este `AGENTS.md` como `RULES_FILE` compartido.
- Para activar hooks: ejecutar `gga install` dentro de cada repo Git.

**Regla de UI/UX (Frontend):**
Si la tarea toca el Frontend, DEBES leer la documentación y las directrices en `docs/ui-ux/` (particularmente `02-current-ui-inventory-and-architecture.md`, `03-unified-design-rules.md` y **`MASTER_UI_SOURCES.md`**) para asegurar consistencia visual con las fuentes de Stitch, un enfoque "mobile-first" y respetar las definiciones "Lite" vs "Pro". Apóyate en el skill `ui-ux-pro-max` si requieres generar o estructurar componentes.

## Referencias
- Arquitectura general: `docs/ARQUITECTURA_PROYECTO.md`
- Playbook por consulta: `docs/CONSULTAS_OPERATIVAS.md`
