# OWFINANCE - Guía de Enfoque de Desarrollo

**Fecha**: 2026-04-06  
**Versión**: 1.0  
**Estado**: Activo

## 📋 Propósito

Este documento centraliza todos los skills, guías, patrones y flujos de trabajo para el desarrollo de OWFINANCE. Úsalo como punto de partida para cualquier tarea de desarrollo.

---

## 🎯 Skills Instalados por Dominio

### Frontend Architecture

#### 1. `owfinance-layout-architecture`
- **Ubicación**: `.agents/skills/owfinance-layout-architecture/`
- **Propósito**: Sistema de layouts dinámicos (Lite, Pro, Legacy)
- **Documentación**: `docs/03-frontend/SISTEMA_LAYOUTS_DINAMICOS.md`
- **Cuándo usar**:
  - Modificar o crear layouts
  - Agregar componentes a un layout específico
  - Debugging de páginas vacías o layout que no cambia
  - Organizar componentes por layout mode

**Conceptos clave**:
```typescript
// DynamicRoleLayout selecciona layout según auth.settings.layout_mode
// Lite → LiteMobileLayout | LiteDesktopLayout (responsive)
// Pro → ProLayout (en desarrollo)
// Legacy → LegacyLayout (default)
```

**Regla crítica**: DynamicRoleLayout NO tiene `<router-view />`, solo los layouts hijos.

---

#### 2. `owfinance-dev-routes-testing`
- **Ubicación**: `.agents/skills/owfinance-dev-routes-testing/`
- **Propósito**: Testing de rutas, navegación, y validación de paths
- **Documentación**: Incluida en el skill
- **Cuándo usar**:
  - Agregar nuevas rutas
  - Validar que no hay duplicados `/app/app/`
  - Probar navegación entre páginas
  - Debugging de rutas 404

**Scripts clave**:
```bash
./validate-routes.sh              # Validar rutas sin /app/
cd OWFinanceFrontend2025 && npm run dev  # Dev server
```

**Test user**: `otero@demo.com` / `test1234` (datos de prueba, NO producción)

---

### UI/UX Design

#### 3. `ow-finance-ux-expert`
- **Ubicación**: `.agents/skills/ow-finance-ux-expert/`
- **Propósito**: Hub de diseño que integra StitchMCP, Magic UI, y Liquid Glass system
- **Documentación**: `docs/ui-ux/`
- **Cuándo usar**:
  - Diseñar nuevos componentes
  - Implementar diseño de Stitch
  - Crear animaciones (Emil Kowalski patterns)
  - Generar imágenes con Nano Banana

**Master sources**: `docs/ui-ux/MASTER_UI_SOURCES.md`

---

#### 4. `ui-ux-pro-max`
- **Ubicación**: `.agents/skills/ui-ux-pro-max/`
- **Propósito**: 50 estilos, 21 palettes, 50 font pairings, componentes shadcn/ui
- **Cuándo usar**:
  - Crear componentes UI desde cero
  - Buscar paletas de colores
  - Implementar charts, dashboards
  - Revisar diseño por accesibilidad

---

#### 5. `emil-design-eng`
- **Ubicación**: `.agents/skills/emil-design-eng/`
- **Propósito**: Filosofía de polish UI, detalles invisibles, animaciones refinadas
- **Cuándo usar**:
  - Afinar transiciones y animaciones
  - Mejorar microinteracciones
  - Revisar "feelingness" de la app

---

#### 6. `web-design-guidelines`
- **Ubicación**: `.agents/skills/web-design-guidelines/`
- **Propósito**: Auditoría de diseño web, accesibilidad, best practices
- **Cuándo usar**:
  - Revisar UI/UX antes de release
  - Auditar accesibilidad
  - Validar contra guidelines de diseño web

---

### Backend & API

#### 7. Laravel Backend Patterns
- **Documentación**: `docs/02-backend/`
- **Recursos**:
  - `ARQUITECTURA_PROYECTO.md` - Arquitectura general
  - `CONSULTAS_OPERATIVAS.md` - Playbook de consultas frecuentes
  - `01-configuracion/GUIA_INSTALACION_BACKEND.md`

**Patrones clave**:
```php
// API base versionada
Route::prefix('api/v1')->group(function () {
    // Rutas aquí
});

// Autenticación Sanctum
$user = $request->user(); // User autenticado
```

**Envelope de respuesta**:
```json
{
  "status": "success|failed",
  "code": 200,
  "message": "...",
  "data": {}
}
```

---

### DevOps & Deployment

#### 8. `owf-role-devops-platform-sre`
- **Ubicación**: `.agents/skills/owf-role-devops-platform-sre/`
- **Propósito**: Deploy, infraestructura, reliability
- **Scripts de deploy**:
  ```bash
  ./deploy-backend.sh "mensaje"   # Deploy backend a producción
  ./deploy-frontend.sh "mensaje"  # Deploy frontend a producción
  ./deploy-mobile.sh android dev  # Deploy mobile Android
  ```

**URLs de producción**:
- Frontend SPA: `https://appfinanzas.blockshift.website/app/`
- API Backend: `https://appfinanzas.blockshift.website/api/v1`

---

#### 9. `workspace-pointer-sync`
- **Ubicación**: `.agents/skills/workspace-pointer-sync/`
- **Propósito**: Sincronizar punteros Git del workspace central
- **Scripts**:
  ```bash
  ./sync-submodule-pointers.sh --report   # Ver estado
  ./sync-submodule-pointers.sh --commit   # Sincronizar
  ./push-workspace.sh backend "msg"       # Push backend
  ./push-workspace.sh frontend "msg"      # Push frontend
  ```

---

### Operational Roles

#### 10-28. OWF Role Skills
Roles operativos para diferentes funciones del producto:

| Skill | Función |
|-------|---------|
| `owf-role-ceo-strategy` | Estrategia, roadmap, decisiones ejecutivas |
| `owf-role-product-owner` | Backlog, historias de usuario, aceptación |
| `owf-role-product-operations` | Métricas, optimización, release health |
| `owf-role-scrum-master-planning` | Sprints, capacidad, blockers |
| `owf-role-sales-commercial` | Pricing, pipeline, ofertas |
| `owf-role-ui-ux-design-steward` | Diseño, consistencia visual, journeys |
| `owf-role-finance-unit-economics` | Costos, pricing, viabilidad |
| `owf-role-marketing-growth` | Posicionamiento, adquisición, retención |
| `owf-role-customer-success` | Onboarding, soporte, feedback |
| `owf-role-risk-compliance` | Trust, safeguards, compliance |
| `owf-role-data-insights` | Métricas, reporting, decisiones basadas en datos |
| `owf-role-engineering-architecture` | Decisiones técnicas, boundaries, maintainability |
| `owf-role-qa-release-quality` | Testing, coverage, regression control |
| `owf-role-devops-platform-sre` | Deploy, infra, reliability |

**Ubicación**: `.agents/skills/owf-role-*/`

---

### Composition & React Patterns

#### 29. `vercel-composition-patterns`
- **Propósito**: React composition patterns (compound components, render props)
- **Cuándo usar**: Refactorizar componentes con muchos boolean props

---

#### 30. `vercel-react-best-practices`
- **Propósito**: Performance optimization de React/Next.js
- **Cuándo usar**: Optimizar bundle, data fetching, performance

---

#### 31. `vercel-react-native-skills`
- **Propósito**: React Native y Expo best practices
- **Cuándo usar**: Desarrollo mobile con React Native

---

### Documentation & Context

#### 32. `documentator`
- **Ubicación**: `.agents/skills/documentator/`
- **Propósito**: Gestión de documentación, Drive como fuente de verdad
- **Drive folder**: `OWFINANCE` (https://drive.google.com/drive/folders/1tjxzCrWceyWPXydOL374FytD0ExM_Jkh)
- **Cuándo usar**:
  - Crear nueva documentación
  - Sincronizar Drive → repo
  - Discovery de docs existente

**Principio**: Drive es canónico, repo tiene solo resúmenes cortos.

---

#### 33. `context-cleanup-steward`
- **Ubicación**: `.agents/skills/context-cleanup-steward/`
- **Propósito**: Release gate, consolidación de docs, de-drift vs código/Notion/Drive
- **Cuándo usar**: Antes de release, para limpiar y consolidar documentación

---

### Telegram & Ops Monitoring

#### 34. `telegram-ops-notifier`
- **Ubicación**: `.agents/skills/telegram-ops-notifier/`
- **Propósito**: Enviar updates a Telegram, ops checks dev/stage/prod
- **Scripts**:
  ```bash
  ./telegram-notify.sh test --title OWFINANCE
  ./telegram-step.sh --title Worker "Step happened"
  ./ops-status.sh dev
  ```

---

#### 35. `telegram-context-bridge`
- **Ubicación**: `.agents/skills/telegram-context-bridge/`
- **Propósito**: Bridge de contexto OWFINANCE a Telegram
- **Comandos**: `/status`, `/status dev`, `/help`, `/last`, `/context`
- **Chat libre**: Responde con Gemini CLI si disponible

---

### Notion & Backlog Integration

#### 36. `notion-mcp-integration`
- **Ubicación**: `.agents/skills/notion-mcp-integration/`
- **Propósito**: Integración con Notion MCP, backlog, tickets
- **Cuándo usar**:
  - Actualizar backlog en Notion
  - Crear tickets desde propuestas markdown
  - Sincronizar tareas con Notion

**Prioridad**: MCP primero, fallback a HTTP API si falla.

**Script Python**: `notion-import/create_tickets_from_proposal.py`

---

### Workflow & Planning

#### 37. `prompt-improver`
- **Ubicación**: `.agents/skills/prompt-improver/`
- **Propósito**: Meta-skill que fuerza clarificación antes de ejecutar planes
- **Cuándo usar**: Cuando scope es ambiguo o request complejo

---

#### 38. SDD Skills (Spec-Driven Development)
- **Ubicación**: `.claude/skills/sdd-*/`
- **Skills**:
  - `sdd-init` - Inicializar SDD en proyecto
  - `sdd-explore` - Explorar ideas antes de commitear
  - `sdd-propose` - Crear propuesta de cambio
  - `sdd-spec` - Escribir specs con requirements
  - `sdd-design` - Diseño técnico y arquitectura
  - `sdd-tasks` - Breakdown de tareas
  - `sdd-apply` - Implementar tareas
  - `sdd-verify` - Validar implementación
  - `sdd-archive` - Archivar cambio completado

**Cuándo usar**: Features sustanciales que requieren planning estructurado.

---

#### 39. `writing-plans`
- **Ubicación**: `.claude/skills/writing-plans/`
- **Propósito**: Crear planes antes de tocar código
- **Cuándo usar**: Multi-step task antes de implementar

---

#### 40. `planning-with-files`
- **Ubicación**: `.claude/skills/planning-with-files/`
- **Propósito**: Manus-style file planning (task_plan.md, findings.md, progress.md)
- **Cuándo usar**: Organizar trabajo complejo, auto-recovery después de /clear

---

#### 41. `verification-before-completion`
- **Ubicación**: `.claude/skills/verification-before-completion/`
- **Propósito**: Verificar antes de declarar trabajo completo
- **Cuándo usar**: Antes de PR, commit, o task_complete

**Checklist**:
```bash
# Backend
cd OWFINANCEBackend2025 && php artisan test

# Frontend
cd OWFinanceFrontend2025 && npm run lint

# Routes
./validate-routes.sh
```

---

## 🔄 Flujo de Trabajo Típico

### 1. Nueva Feature (Frontend)

```bash
# 1. Leer layout architecture skill
# → .agents/skills/owfinance-layout-architecture/SKILL.md

# 2. Determinar layout target (Lite, Pro, Legacy, o todos)

# 3. Leer diseño Stitch si aplica
# → docs/ui-ux/MASTER_UI_SOURCES.md

# 4. Crear componente
# → components/liquid/ (si es Lite)
# → components/pro/ (si es Pro)
# → components/ (si es compartido)

# 5. Integrar en layout correspondiente
# → layouts/LiteMobileLayout.vue (ejemplo)

# 6. Probar en mobile, tablet, desktop

# 7. Validar rutas
./validate-routes.sh

# 8. Lint y build
cd OWFinanceFrontend2025
npm run lint
npm run build

# 9. Deploy a dev
./deploy-frontend.sh "feat: descripción"

# 10. Probar en dev environment
# → https://dev.appfinanzas.blockshift.website/app/

# 11. Si todo OK, deploy a prod
./deploy-frontend.sh "prod: descripción"
```

---

### 2. Nueva Feature (Backend)

```bash
# 1. Leer arquitectura backend
# → docs/02-backend/ARQUITECTURA_PROYECTO.md

# 2. Consultar playbook operativo si aplica
# → docs/02-backend/CONSULTAS_OPERATIVAS.md

# 3. Crear ruta, controlador, modelo, repositorio
# → routes/api/*.php
# → app/Http/Controllers/
# → app/Models/
# → app/Repositories/

# 4. Escribir tests
# → tests/Feature/

# 5. Ejecutar tests
cd OWFINANCEBackend2025
php artisan test

# 6. Deploy a dev
./deploy-backend.sh "feat: descripción"

# 7. Probar endpoint en dev
curl -X POST https://dev.appfinanzas.blockshift.website/api/v1/...

# 8. Si todo OK, deploy a prod
./deploy-backend.sh "prod: descripción"
```

---

### 3. Bugfix

```bash
# 1. Crear doc del bug
# → BUGS/BUG-XXX-descripcion.md

# 2. Investigar root cause
# → Usar semantic_search, grep_search, read_file

# 3. Implementar fix

# 4. Verificar fix con tests
./validate-routes.sh    # Si es route fix
npm run lint            # Si es frontend
php artisan test        # Si es backend

# 5. Actualizar doc del bug con solución aplicada

# 6. Deploy
./deploy-backend.sh "fix: BUG-XXX descripción"
# o
./deploy-frontend.sh "fix: BUG-XXX descripción"

# 7. Marcar bug como resuelto en doc
```

**Ejemplo reciente**: `BUGS/BUG-007-EXTENDED-FIX-REPORT.md`, `BUGS/BUG-008-layout-lite-vistas-vacias.md`

---

### 4. Deploy Mobile (Android)

```bash
# 1. Configurar env mobile
cd OWFinanceFrontend2025
cp .env.mobile .env

# 2. Build
npm run build

# 3. Sync Capacitor
npx cap sync android

# 4. Abrir Android Studio
npx cap open android

# 5. Build APK en Android Studio
# → Build → Build Bundle(s) / APK(s) → Build APK(s)

# 6. O usar script de deploy
./deploy-mobile.sh android dev
./deploy-mobile.sh android prod
```

**Alternativa dev rápido**:
```bash
./dev-mobile.sh    # Abre en Android Studio con hot reload
```

---

### 5. Trabajo con Notion Backlog

```bash
# 1. Cargar skill notion-mcp-integration
# → .agents/skills/notion-mcp-integration/SKILL.md

# 2. Buscar MCP tools
# → mcp_notion_API-post-search
# → mcp_notion_API-post-page

# 3. Si MCP falla, usar fallback HTTP
# → NOTION_API_TOKEN debe estar en env

# 4. O usar script Python
cd notion-import
python create_tickets_from_proposal.py --proposal ../new_tickets_proposal.md
```

---

### 6. Sincronización de Docs con Drive

```bash
# 1. Cargar skill documentator
# → .agents/skills/documentator/SKILL.md

# 2. Acceder a Drive folder OWFINANCE
# → https://drive.google.com/drive/folders/1tjxzCrWceyWPXydOL374FytD0ExM_Jkh

# 3. Bajar docs necesarios al repo
# → Solo resúmenes cortos en docs/
# → Drive mantiene la versión canónica completa

# 4. Actualizar docs en repo
# → docs/README.md
# → docs/00-sistema/
# → docs/01-configuracion/
# → etc.
```

---

## 🛠️ Scripts de Raíz Disponibles

### Development

```bash
./dev-start.sh           # Arrancar backend + frontend local
./dev-stop.sh            # Detener servicios
./dev-mobile.sh          # Dev mobile con hot reload
./status.sh              # Ver estado general
./switch-env.sh local    # Cambiar a env local
./switch-env.sh dev      # Cambiar a env dev
./switch-env.sh prod     # Cambiar a env prod
```

### Deployment

```bash
./deploy-backend.sh "mensaje"         # Deploy backend
./deploy-frontend.sh "mensaje"        # Deploy frontend
./deploy-mobile.sh android dev        # Deploy mobile Android dev
./deploy-mobile.sh android prod       # Deploy mobile Android prod
./deploy-mobile.sh both prod          # Deploy Android + iOS prod
```

### Validation & Status

```bash
./validate-routes.sh                  # Validar rutas sin /app/
./ops-status.sh dev                   # Estado operativo dev
./ops-status.sh stage                 # Estado operativo stage
./ops-status.sh prod                  # Estado operativo prod
```

### Git & Sync

```bash
./sync-submodule-pointers.sh --report    # Ver estado de punteros
./sync-submodule-pointers.sh --commit    # Commit punteros
./push-workspace.sh backend "msg"        # Push backend
./push-workspace.sh frontend "msg"       # Push frontend
```

### Telegram & Notifications

```bash
./telegram-notify.sh test --title OWFINANCE
./telegram-step.sh --title Worker "Step happened"
./telegram-heartbeat.sh --title Worker --interval 300 "Task running"
./telegram-bridge-loop.sh                # Iniciar bridge loop
```

### Android Specific

```bash
./build-android.sh                    # Build Android
./build-apk.sh                        # Build APK
./deploy-android.sh                   # Deploy Android
./android-logs.sh                     # Ver logs Android
./adb-tools.sh                        # Herramientas ADB
./fix-java-android.sh                 # Fix issues Java/Android
```

### Environment & Setup

```bash
./env-config.sh                       # Configurar .env files
./setup-mobile.sh                     # Setup mobile inicial
./bump-version.sh                     # Incrementar versión
```

---

## 📚 Documentación Clave por Dominio

### Sistema General

- `README.md` - Overview del proyecto
- `AGENTS.md` - Guía para agentes de IA (workspace root)
- `CLAUDE.md` - Agent Teams Lite orchestrator
- `PROJECT_CONTEXT.md` - Contexto del proyecto

### Arquitectura

- `docs/ARQUITECTURA_PROYECTO.md` - Arquitectura general
- `docs/03-frontend/SISTEMA_LAYOUTS_DINAMICOS.md` - **NUEVO** Sistema de layouts
- `docs/02-backend/CONSULTAS_OPERATIVAS.md` - Playbook operativo backend

### Configuración

- `docs/01-configuracion/GUIA_INSTALACION_BACKEND.md` - Setup backend
- `docs/01-configuracion/GUIA_INSTALACION_FRONTEND.md` - Setup frontend
- `docs/01-configuracion/SAAS_ROLE_SYSTEM.md` - Sistema de roles
- `ENV_STRATEGY.md` - Estrategia de environments

### UI/UX

- `docs/ui-ux/MASTER_UI_SOURCES.md` - **Fuentes maestras de diseño**
- `docs/ui-ux/02-current-ui-inventory-and-architecture.md` - Inventario UI
- `docs/ui-ux/03-unified-design-rules.md` - Reglas de diseño
- `docs/ui-ux/04-stitch-extraction-plan.md` - Plan Stitch

### Mobile

- `MOBILE_DEPLOYMENT_GUIDE.md` - Guía de deploy mobile
- `docs/04-mobile/` - Docs específicas mobile

### Deployment

- `DEPLOYMENT-STRATEGY.md` - Estrategia de deployment
- `DEPLOYMENT-STATUS.md` - Estado de deploys
- `docs/devops/` - Docs DevOps

### Bugs & Tickets

- `BUGS/` - Todos los bug reports
- `docs/tickets/` - Propuestas de tickets
- `NOTION_BACKLOG.md` - Backlog de Notion

---

## 🎯 Principios Fundamentales

### 1. Contratos Técnicos Irrompibles

❌ **NUNCA romper**:
- API base versionada: `/api/v1`
- Autenticación Sanctum con bearer token
- Envelope de respuesta: `{ status, code, message, data }`
- Scoping por usuario autenticado
- Lógica de jars (exclusividad, porcentajes ≤ 100)

### 2. Rutas Frontend

✅ **SIEMPRE**:
- Usar `/user/*` para rutas de usuario autenticado
- Validar con `./validate-routes.sh` antes de deploy
- Nunca usar `/app/*` directamente (genera `/app/app/`)

### 3. Layouts Dinámicos

✅ **SIEMPRE**:
- DynamicRoleLayout NO tiene `<router-view />`
- Layouts hijos SÍ tienen `<router-view />`
- Componentes Lite → `components/liquid/`
- Componentes Pro → `components/pro/`
- Componentes compartidos → `components/`

### 4. Testing Antes de Deploy

✅ **SIEMPRE verificar**:
```bash
./validate-routes.sh                      # Routes OK
cd OWFinanceFrontend2025 && npm run lint  # Lint OK
cd OWFINANCEBackend2025 && php artisan test  # Tests OK
```

### 5. Documentación Canon

✅ **Drive es fuente de verdad**:
- Estrategia, roles, planning → Google Drive `OWFINANCE`
- Repo tiene solo resúmenes cortos
- Usar `documentator` skill para sync

### 6. Deploy Seguro

✅ **Orden de deploy**:
1. Dev environment primero
2. Validar manualmente
3. Prod solo si dev OK
4. GitHub Actions hace deployment automático en backend

---

## 🚨 Anti-Patterns (NUNCA HACER)

❌ **Routes**:
- Usar `/app/home` en vez de `/user/home`
- No validar con `validate-routes.sh`

❌ **Layouts**:
- Poner `<router-view />` en DynamicRoleLayout
- Olvidar `<router-view />` en layout hijo
- Importar componentes con auto-import en layouts (usar import explícito)

❌ **Components**:
- Crear duplicados en múltiples carpetas
- No usar props para adaptar componentes compartidos
- Hardcodear valores en lugar de usar stores

❌ **Deploy**:
- Deploy a prod sin probar en dev primero
- No ejecutar tests antes de deploy
- Deploy sin mensaje de commit descriptivo

❌ **Documentation**:
- Crear docs largos en repo (usar Drive)
- No actualizar docs después de cambios
- Ignorar documentación existente

---

## 🔮 Roadmap de Skills

### Pendientes de Crear

- [ ] `owfinance-transaction-bulk-testing` - Testing de carga masiva
- [ ] `owfinance-jars-logic-guide` - Lógica avanzada de jars
- [ ] `owfinance-api-versioning` - Estrategia de versionado API
- [ ] `owfinance-testing-strategy` - Estrategia de testing (unit, feature, e2e)

### Pendientes de Actualizar

- [ ] `owfinance-dev-routes-testing` - Agregar sección de layouts
- [ ] `documentator` - Mejorar sync Drive → repo
- [ ] `telegram-context-bridge` - Agregar más comandos útiles

---

## 📞 Contacto y Recursos

### URLs Producción

- **Frontend**: https://appfinanzas.blockshift.website/app/
- **API**: https://appfinanzas.blockshift.website/api/v1
- **Health check**: POST /api/v1/auth/login

### Servidor

- **IP**: 178.156.160.70
- **User**: appfinan1
- **SSH Port**: 22
- **Stack**: LiteSpeed, Ubuntu 24.04, Laravel 12, Quasar 2

### Drive Canonical

- **Folder**: OWFINANCE
- **URL**: https://drive.google.com/drive/folders/1tjxzCrWceyWPXydOL374FytD0ExM_Jkh

---

**Última actualización**: 2026-04-06  
**Versión**: 1.0  
**Mantenido por**: Equipo OWFINANCE Development

---

## 📝 Changelog

### 2026-04-06 - v1.0
- ✅ Creación inicial del handbook
- ✅ Documentación de layouts dinámicos
- ✅ Creación de skill `owfinance-layout-architecture`
- ✅ Inventario completo de 41 skills
- ✅ Flujos de trabajo por tipo de tarea
- ✅ Scripts y comandos disponibles
- ✅ Principios fundamentales y anti-patterns
