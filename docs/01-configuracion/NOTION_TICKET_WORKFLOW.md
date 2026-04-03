# Flujo practico para tickets Notion OWFINANCE

Guia corta para tomar un ticket de Notion, ejecutarlo con el skill correcto, mantener Drive como fuente canonica y cerrar el loop de contexto.

## 1. Elegir el ticket correcto

- Prioriza primero tickets con `Priority` mas alta y `Status` accionable.
- Status accionables: `Ready`, `Todo`, `Backlog` con contexto suficiente, o `In Progress` si ya existe trabajo en marcha que conviene terminar.
- No arranques tickets en `Blocked`, `Waiting`, `Done` o sin contexto minimo.
- Usa `Role` como filtro real de ownership: si el ticket no cae claro en un rol OWFINANCE, primero aclara ownership antes de ejecutar.
- Si hay empate, toma el ticket que tenga mejor definicion de alcance, dependencia mas cercana y menor riesgo de bloqueo externo.

## 2. Elegir skill de rol y skills de soporte

- Carga un rol principal segun el campo `Role` y los criterios de aceptacion del ticket.
- Usa un solo owner principal y, si hace falta, suma uno o dos roles de soporte.
- Mapeo rapido:
  - Producto, roadmap, historias -> `owf-role-product-owner`
  - UX, UI, handoff visual -> `owf-role-ui-ux-design-steward`
  - Arquitectura, backend, limites tecnicos -> `owf-role-engineering-architecture`
  - QA, regresion, release gates -> `owf-role-qa-release-quality`
  - DevOps, observabilidad, runtime -> `owf-role-devops-platform-sre`
  - Marketing, growth, ventas, customer success, riesgo o finanzas -> usar el skill OWF especifico del dominio
- Si el ticket toca docs canonicos de rol, discovery en Drive o sync corto al repo, suma `documentator`.
- Si el ticket necesita cambios de backlog, status o comments en Notion, suma `notion-mcp-integration`.
- Si el trabajo durara bastante o necesita visibilidad, suma `telegram-ops-notifier`.

## 3. Decidir entre Drive, Notion y repo local

- Drive `OWFINANCE` es la fuente de verdad para estrategia, playbooks, roadmap, decision logs y docs compartidos por rol.
- Notion es para backlog, estado, ownership, seguimiento y handoff operativo.
- El repo guarda solo resumenes cortos, instrucciones de agentes o contexto local estable cuando hace falta para ejecucion.

## 4. Cuando usar documentator

- Usalo si necesitas encontrar el doc canonico correcto en Drive antes de trabajar.
- Usalo si el ticket cambia PRD, roadmap, playbook, decision log o cualquier documento compartido por rol.
- Usalo si necesitas dejar un resumen corto en el repo que apunte al doc canonico de Drive.
- No lo cargues para un cambio puramente operativo de status en Notion sin impacto documental.

## 5. Notion MCP primero, fallback solo cuando haga falta

- Para leer ticket, cambiar `Status`, actualizar propiedades o dejar comentarios, intenta primero Notion MCP.
- Usa fallback solo si MCP falla por auth o conectividad.
- Fallback aceptado:
  - HTTP API o script ya definido si existe `NOTION_API_TOKEN` valido
  - `python3 notion-import/create_tickets_from_proposal.py new_tickets_proposal.md <database_id>` para importes desde markdown del workspace
- Si MCP falla y no existe helper seguro para la operacion puntual, no inventes un flujo nuevo: deja nota local de sync pendiente y sigue con la ejecucion documental/local.

## 6. Flujo operativo recomendado

1. Abrir Notion y elegir ticket por `Priority`, `Status` y `Role`.
2. Cargar el rol principal OWF; sumar `documentator`, `notion-mcp-integration` y `telegram-ops-notifier` solo si aplican.
3. Leer el ticket completo, links, docs relacionadas y dependencias.
4. Si hay trabajo real en marcha, pasar el ticket a `In Progress` con Notion MCP.
5. Buscar o actualizar primero el doc canonico en Drive cuando el ticket cambie contexto compartido.
6. Ejecutar el trabajo tecnico, operativo o documental.
7. Guardar en el repo solo el resumen minimo necesario para agentes o ejecucion futura.
8. Guardar decisiones, descubrimientos o bugfixes en Engram con `mem_save` y `project: OWFINANCE2026`.
9. Actualizar Notion con estado final (`In Review`, `Done` o el que use el tablero), nota de resultado y links a Drive/local si aplican.
10. Enviar Telegram solo para inicio relevante, bloqueo, milestone util o cierre; no para cada paso pequeno.

## 7. Como cerrar documentacion y contexto

- Drive: actualiza el doc canonico del rol primero.
- Notion: deja el estado correcto y una nota corta con resultado, bloqueo o siguiente accion.
- Repo local: deja solo referencia, resumen corto o instruccion estable si el workspace la necesita.
- Engram: guarda decision, discovery o bugfix importante en cuanto ocurra; no lo dejes para el final.
- Telegram: usar avisos low-noise con `./telegram-step.sh` o `./telegram-notify.sh` cuando otra persona o tu yo futuro necesiten visibilidad rapida.

## 8. Ejemplo concreto

Ticket en Notion:

- `Priority: Alta`
- `Status: Ready`
- `Role: Product Owner, UI/UX`
- Tema: refinar onboarding Lite vs Pro y dejar criterios de aceptacion listos para ejecucion

Flujo:

1. Se elige porque es `Alta` y esta en `Ready`.
2. Skill principal: `owf-role-product-owner`.
3. Skill de soporte: `owf-role-ui-ux-design-steward`.
4. Como cambia criterios y doc de producto, se suma `documentator`.
5. Se usa Notion MCP para pasar el ticket a `In Progress`.
6. Se busca en Drive el doc canonico de onboarding dentro de `02_PRODUCTO_Y_TECNOLOGIA` y se actualizan alcance, criterios y handoff.
7. Si el repo necesita contexto estable, se deja un resumen corto con link o referencia al doc canonico, sin duplicar el contenido entero.
8. Se guarda en Engram una decision tipo `decision` con el cambio de alcance y los archivos/docs afectados.
9. Se manda un aviso por Telegram al arrancar si el trabajo va a durar bastante, y otro cuando el paquete queda listo para revision.
10. Se actualiza Notion a `In Review` con nota corta: que cambio, donde esta el doc en Drive y que falta validar.

## Regla corta

- Drive decide.
- Notion coordina.
- El repo resume.
- Telegram avisa.
- Engram recuerda.
