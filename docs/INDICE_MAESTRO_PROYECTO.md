# Indice Maestro del Proyecto OWFINANCE

Estado documental: `vigente`

Este documento es el mapa maestro para evaluar y reorganizar la documentacion del workspace.

## 1. Fuente unica de verdad propuesta

Modelo decidido: `mixto fuerte`.

Distribucion correcta de verdad:
- Drive `OWFINANCE`
  Fuente canonica de estrategia, roadmap, ownership, planning, role docs y decision logs.
- Notion
  Sistema operativo del backlog, estado, handoff y cleanup tracking.
- Repo `docs/`
  Fuente tecnica operativa para ejecutar trabajo local con seguridad.

Regla practica:
- Drive decide.
- Notion coordina.
- Repo ejecuta y resume.

## 2. Documentacion activa del repo

### 2.1 Autoridad global

- `docs/README.md`
  Hub principal de documentacion activa.
- `docs/ARQUITECTURA_PROYECTO.md`
  Arquitectura tecnica vigente del workspace.
- `docs/CONSULTAS_OPERATIVAS.md`
  Playbook operativo rapido.
- `docs/INDICE_MAESTRO_PROYECTO.md`
  Indice documental y estructural del proyecto.

### 2.2 Sistema y flujo

- `docs/00-sistema/README.md`
- `docs/00-sistema/FLUJO_OPERATIVO_UNIFICADO.md`
- `docs/00-sistema/GIT_HYGIENE_AND_SAFE_UPDATE.md`

Uso:
- flujo end-to-end;
- preflight Git obligatorio;
- reglas de cierre y cleanup gate.

### 2.3 Configuracion y tooling

- `docs/01-configuracion/README.md`
- `docs/01-configuracion/AI_AGENT_TOOLING.md`
- `docs/01-configuracion/NOTION_TICKET_WORKFLOW.md`
- `docs/01-configuracion/STITCH_MCP_OPERATIONAL_SETUP.md`
- `docs/01-configuracion/DOCUMENTATION_CLEANUP_POLICY.md`
- `docs/01-configuracion/OPENCODE_RUNTIME_SETUP.md`
- `docs/01-configuracion/ENV_STRATEGY.md`
- `docs/01-configuracion/GOOGLE_WORKSPACE_MCP_SETUP.md`
- `docs/01-configuracion/TELEGRAM_NOTIFICATIONS.md`
- `docs/01-configuracion/SAAS_ROLE_SYSTEM.md`

### 2.4 Backend

- `docs/02-backend/README.md`
- `docs/02-backend/arquitectura/*`
- `docs/02-backend/bugfixes/*`
- `docs/02-backend/endpoints/*`

### 2.5 Frontend

- `docs/03-frontend/README.md`
- `docs/03-frontend/RUTAS.md`

### 2.6 UI / UX

- `docs/ui-ux/MASTER_UI_SOURCES.md`
- `docs/ui-ux/02-current-ui-inventory-and-architecture.md`
- `docs/ui-ux/03-unified-design-rules.md`
- `docs/ui-ux/08-frozen-canonical-design-system-brief.md`
- `docs/ui-ux/09-freeze-stitch-flujo-core-matrix.md`
- `docs/ui-ux/10-layout-refactor-legacy-pro-lite-mini-spec.md`

Nota:
- Este bloque aun necesita depuracion fina, porque mezcla material vigente, congelado y transicional.

## 3. Documentacion legacy o secundaria

Ubicacion:
- `docs/archive/legacy-docs/`

Archivos ya archivados:
- `00-sistema-ARQUITECTURA_PROYECTO.md`
- `00-sistema-CONSULTAS_OPERATIVAS.md`
- `00-sistema-README-root.md`
- `PROJECT_CONTEXT.md`
- `current_ui_inventory.md`

Estos ya no deben usarse como autoridad.

## 4. Estructura interna real del backend

Repo:
- `OWFINANCEBackend2025`

Capas principales:
- `app/Http`
  HTTP layer, controllers, requests y middleware Laravel.
- `app/Models/Entities`
  Modelos de dominio.
- `app/Models/Repositories`
  Repositorios y acceso a datos.
- `app/Services`
  Logica de negocio y servicios de aplicacion.
- `app/Observers`
  Side effects de modelos.
- `app/Policies`
  Autorizacion.
- `routes/api/*.php`
  Mapa funcional de endpoints por dominio.

Dominios API detectados:
- auth
- user / users
- accounts / account_types / account-folders
- categories
- transactions / payments / items
- jars / jar_templates
- rates / currencies
- taxes
- clients / providers
- admin

Conclusiones:
- La estructura backend esta bastante modular por dominio.
- La mejor fuente tecnica del backend deberia salir de:
  - arquitectura vigente global;
  - quick references por dominio;
  - endpoints por dominio.
- No hace falta duplicar demasiada narrativa en varios sitios.

## 5. Estructura interna real del frontend

Repo:
- `OWFinanceFrontend2025`

Capas principales:
- `src/boot`
  Bootstrapping global como Axios.
- `src/router`
  Router y guards.
- `src/layouts`
  Shells de interfaz.
- `src/pages/User`
  Superficie funcional de usuario.
- `src/pages/Admin`
  Superficie funcional admin.
- `src/components`
  Componentes reutilizables.
- `src/stores`
  Estado Pinia.
- `src/composables`
  Hooks / logica compartida.
- `src/css`, `src/assets`, `src/i18n`

Layouts detectados:
- `AdminLayout.vue`
- `DynamicRoleLayout.vue`
- `LegacyLayout.vue`
- `LiteMobileLayout.vue`
- `MainLayout.vue`
- `ProLayout.vue`

Stores detectados:
- `auth.ts`
- `transactions.ts`
- `transactionTypes.ts`
- `jars.ts`
- `period.ts`
- `ui.ts`

Conclusiones:
- El frontend conserva huellas claras de transicion arquitectonica entre `Legacy`, `Lite`, `Pro` y el router real activo.
- La fuente unica de verdad del frontend deberia quedar dividida en:
  - rutas activas reales;
  - layouts activos vs historicos;
  - matriz de UI congelada / futura;
  - referencias Stitch.

## 6. Problemas documentales que aun existen

### 6.1 Drift de estado

- Algunos docs siguen en estado transicional pero sin una fecha o trigger claro de salida.
- Parte del bloque `ui-ux/` aun mezcla historia, freeze y propuesta.

### 6.2 Drift de encoding

- Hay varios archivos con mojibake o caracteres mal codificados.
- Eso hace mas dificil saber si un documento fue realmente saneado o solo movido.

### 6.3 Falta de indice por dominio

- Backend y frontend ya tienen bastante contenido, pero no existe aun un indice corto por dominio tecnico.

## 7. Organizacion objetivo recomendada

### 7.1 Mantener como autoridad

- `docs/README.md`
- `docs/INDICE_MAESTRO_PROYECTO.md`
- `docs/ARQUITECTURA_PROYECTO.md`
- `docs/CONSULTAS_OPERATIVAS.md`
- `docs/00-sistema/*`
- `docs/03-frontend/RUTAS.md`
- `docs/01-configuracion/NOTION_TICKET_WORKFLOW.md`
- `docs/01-configuracion/STITCH_MCP_OPERATIONAL_SETUP.md`
- `docs/01-configuracion/DOCUMENTATION_CLEANUP_POLICY.md`

### 7.2 Consolidar despues

- `docs/ui-ux/*`
  Separar en:
  - vigente
  - congelado
  - historico
- `docs/02-backend/*`
  Crear un README indice por dominio.
- `docs/03-frontend/*`
  Crear un README mas estructural: rutas, layouts, stores, componentes de alto impacto.

### 7.3 Mantener fuera del repo

- Estrategia
- Planning amplio
- ownership por rol
- decision logs de negocio

Eso sigue mejor en Drive.

## 8. Proximo orden de evaluacion recomendado

1. Validar `docs/ui-ux/` archivo por archivo y etiquetar cada uno como `vigente`, `congelado`, `transicional` o `archivado`.
2. Crear un indice backend por dominios reales de API.
3. Crear un indice frontend por rutas, layouts, stores y modulos.
4. Corregir encoding de los documentos autoridad.
5. Revisar archivos raiz restantes para decidir si siguen vivos o pasan a legacy.
