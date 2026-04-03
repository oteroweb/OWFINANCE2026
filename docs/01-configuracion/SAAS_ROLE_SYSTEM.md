# Sistema de roles SaaS de OWFINANCE2026

Este documento define un sistema reusable de roles operativos para trabajar OWFINANCE2026 desde OpenCode, Gemini/Antigravity y otros agentes compatibles sin perder contexto de negocio, producto y entrega.

## Objetivo

- Dar a cada agente un sombrero operativo claro para pensar y responder como una funcion real del negocio.
- Mantener alineacion con el contexto actual: metodologia Jars, producto premium, Web + Mobile, modo Lite vs Pro, y backlog con IA/voz/OCR.
- Evitar que backlog, tareas y seguimiento comercial se improvisen fuera del flujo existente de Notion.
- Hacer explicita la responsabilidad documental de cada rol dentro de la carpeta Drive `OWFINANCE`, que actua como hub canonico y fuente de verdad compartida.

## Ubicacion de los roles

- Workspace skills: `.agents/skills/owf-role-*/SKILL.md`
- Copia para OpenCode sidebar: `~/.config/opencode/skills/owf-role-*/SKILL.md`
- Slash commands sugeridos: `~/.config/opencode/commands/role-*.md`
- Hub documental canonico: carpeta Drive `OWFINANCE` (`https://drive.google.com/drive/folders/1tjxzCrWceyWPXydOL374FytD0ExM_Jkh`) con `01_GERENCIA_ESTRATEGIA`, `02_PRODUCTO_Y_TECNOLOGIA`, `03_MARKETING_Y_CONTENIDO`, `04_OPERACIONES_Y_CLIENTE`, `05_FINANZAS_Y_RIESGO`, `06_AI_CONTEXT` y `Manual de Cultura y Metas`.

## Roles instalados

| Rol | Skill | Uso principal | Handoff natural |
|---|---|---|---|
| CEO / Strategy | `owf-role-ceo-strategy` | apuestas, foco, pricing, mercado | Product Owner, Finance, Marketing |
| Product Owner | `owf-role-product-owner` | roadmap, stories, criterios | Scrum, UX, Product Ops |
| Product Operations | `owf-role-product-operations` | metricas, optimizacion, experimentos | Product Owner, Data, Scrum |
| Scrum Master / Planning | `owf-role-scrum-master-planning` | sprint, capacidad, blockers | Product, UX, Risk |
| Sales / Commercial | `owf-role-sales-commercial` | ofertas, demos, objeciones | Marketing, CEO, Customer Success |
| UI/UX Design Steward | `owf-role-ui-ux-design-steward` | consistencia premium, reviews, handoff | Product Owner, Scrum |
| Finance / Unit Economics | `owf-role-finance-unit-economics` | costos, margenes, pricing | CEO, Marketing, Product |
| Marketing / Growth | `owf-role-marketing-growth` | posicionamiento, campañas, activacion | Sales, Customer Success, CEO |
| Customer Success | `owf-role-customer-success` | onboarding, soporte, retencion | Product, Marketing, Sales |
| Risk / Compliance | `owf-role-risk-compliance` | guardrails, data trust, lanzamientos sensibles | Scrum, Finance, UX |
| Data Insights | `owf-role-data-insights` | definicion de KPIs, reporting, analisis | Product Ops, Marketing, Finance |
| Engineering Architecture | `owf-role-engineering-architecture` | decisiones tecnicas, guardrails, arquitectura | Scrum, DevOps, QA |
| QA / Release Quality | `owf-role-qa-release-quality` | estrategia de pruebas, regresion, release gates | Scrum, Product, Risk |
| DevOps / Platform / SRE | `owf-role-devops-platform-sre` | despliegues, confiabilidad, observabilidad | Architecture, Risk, QA |

## Propiedad documental en Drive

Todo rol OWFINANCE debe mantener sus docs canonicos, playbooks y decision logs en la carpeta Drive `OWFINANCE`, que es la fuente de verdad documental. El repo guarda solo resumentes cortos, instrucciones de agentes o referencias operativas cuando hacen falta.

| Rol | Carpeta Drive primaria | Documentos que debe mantener |
|---|---|---|
| CEO / Strategy | `01_GERENCIA_ESTRATEGIA` + `Manual de Cultura y Metas` | estrategia, apuestas, decisiones ejecutivas, narrativa cultural |
| Product Owner | `02_PRODUCTO_Y_TECNOLOGIA` | roadmap, PRDs, historias, criterios, decisiones de alcance |
| Product Operations | `04_OPERACIONES_Y_CLIENTE` | KPIs operativos, experimentos, retrospectivas, loops de mejora |
| Scrum Master / Planning | `04_OPERACIONES_Y_CLIENTE` | planes de sprint, blockers, readiness, seguimiento de entrega |
| Sales / Commercial | `01_GERENCIA_ESTRATEGIA` | ofertas, demos, objection maps, feedback comercial |
| UI/UX Design Steward | `02_PRODUCTO_Y_TECNOLOGIA` | reglas de UI, auditorias, handoffs, decisiones de experiencia |
| Finance / Unit Economics | `05_FINANZAS_Y_RIESGO` | pricing, modelos de unit economics, guardrails de costos |
| Marketing / Growth | `03_MARKETING_Y_CONTENIDO` | posicionamiento, lanzamientos, campañas, contenido, lifecycle |
| Customer Success | `04_OPERACIONES_Y_CLIENTE` | onboarding, soporte, playbooks de retencion, insights de clientes |
| Risk / Compliance | `05_FINANZAS_Y_RIESGO` | guardrails, revisiones de riesgo, condiciones de lanzamiento |
| Data Insights | `02_PRODUCTO_Y_TECNOLOGIA` | diccionario de KPIs, dashboards, readouts analiticos |
| Engineering Architecture | `02_PRODUCTO_Y_TECNOLOGIA` | ADRs, diagramas, patrones, limites tecnicos |
| QA / Release Quality | `02_PRODUCTO_Y_TECNOLOGIA` | planes de prueba, matrices de regresion, learnings de calidad |
| DevOps / Platform / SRE | `02_PRODUCTO_Y_TECNOLOGIA` | runbooks, readiness, incidentes, observabilidad y rollback |

## Reglas operativas

- Todo rol debe partir de `PROJECT_CONTEXT.md`, `AGENTS.md` y, cuando aplique, `NOTION_BACKLOG.md`.
- Roles orientados a backlog o tareas no deben inventar flujos paralelos de Notion. Deben cargar primero `notion-mcp-integration`, usar MCP primero y pasar al fallback controlado del workspace solo cuando MCP falle.
- Roles que toquen frontend deben respetar `docs/ui-ux/` y apoyarse en `ow-finance-ux-expert` antes de proponer cambios visuales.
- Ningun rol puede ignorar las reglas del proyecto sobre `/api/v1`, Sanctum, invariantes de Jars, o deploys sin la palabra `deploya`.
- Si un rol crea o actualiza documentacion de su dominio, debe tratar la carpeta Drive `OWFINANCE` como canonica y usar `documentator` para discovery, estructura o sync al repo cuando haga falta.

## Plan operativo de marketing basado en el contexto actual

### Posicionamiento

- Promesa central: control financiero disciplinado con el sistema de Jars, no solo tracking de gastos.
- Diferenciadores visibles: UX premium glassmorphism, multicuenta/multidivisa, Lite vs Pro, y captura asistida por IA.
- Narrativa comercial: menos friccion para registrar, mas claridad para decidir.

### Segmentos prioritarios

- Personas y familias que quieren disciplina presupuestaria real.
- Freelancers y trabajadores con ingresos variables que necesitan automatizar reparto y contexto financiero.
- Pequenos negocios o perfiles administrativos que valoran multicuenta, importacion y reportes Pro.

### Secuencia de go-to-market

1. Base de confianza: contenido y demos sobre Jars, control multicuenta y claridad del dashboard.
2. Ola de adquisicion IA: demos de voz, OCR y AI Coach como aceleradores de captura y asesoramiento.
3. Ola de conversion Pro: comparativas Lite vs Pro, bulk import, reportes avanzados y automatizaciones.

### Backlog de marketing conectado al backlog de producto

- Voz: demos cortos de registro de gastos en segundos.
- OCR: casos de uso de tickets/facturas para ahorro de tiempo.
- Reparto automatico en Jars: contenido educativo con ejemplos salariales y freelancers.
- Perfil contextual IA + chatbot: narrativa de asesor personalizado sin vender consejo financiero profesional.
- Lite vs Pro: comparativas de valor, no solo lista de features.
- Deteccion de patrones: mensajes de ahorro proactivo y tranquilidad.

### KPIs de growth a seguir

- Conversion de landing o waitlist.
- Activacion a primer valor (primera cuenta, primer jar, primera transaccion).
- Trial a Pro o paid conversion.
- Retencion de 30/90 dias.
- CAC, payback y costo variable por funcionalidades de IA.

## Uso practico en OpenCode

- Desde skills: cargar el skill del rol y trabajar con ese marco.
- Desde slash commands: usar `/role-ceo`, `/role-product-owner`, `/role-marketing`, etc.
- Si la salida debe terminar en backlog o tareas, el rol debe enrutar la operacion por `notion-mcp-integration`.
