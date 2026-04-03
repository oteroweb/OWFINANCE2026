# Set de herramientas OWFINANCE

Guia practica del stack de herramientas de agentes que hoy conviene usar en OWFINANCE2026.

## Resumen ejecutivo

- OpenCode ya tiene activos `superpowers@git+https://github.com/obra/superpowers.git` y `ecc-universal`.
- `engram` ya esta instalado y funcionando; hoy es la memoria persistente principal del proyecto.
- `claude-mem` no se instala por ahora en OpenCode. Se documenta como opcion futura para evitar solapamiento, mas configuracion y confusion operativa.
- El setup OWFINANCE ya activo se apoya en Drive como hub canonico, Notion con MCP primero y fallback controlado, Google Workspace MCP, bridge de Telegram y GGA por repo.

## Estado OWFINANCE ya activo

### Drive hub

- **Que es**: la carpeta compartida `OWFINANCE` en Google Drive.
- **Para que sirve**: fuente de verdad para estrategia, roles, planning y contexto compartido.
- **Como usarlo**: primero buscar o actualizar el doc canonico en Drive; bajar al repo solo resumenes cortos cuando hagan falta para ejecucion local.
- **Como ayuda a OWFINANCE**: evita duplicacion y mantiene ownership por rol.
- **Como complementa al resto**: `documentator`, Google Workspace MCP y Notion trabajan mejor si Drive sigue siendo el origen canonico.
- **Uso diario recomendado**: usarlo siempre que el trabajo sea de estrategia, roadmap, roles o documentacion operativa compartida.

### Notion con MCP primero y fallback controlado

- **Que es**: integracion operativa para backlog, tickets y seguimiento.
- **Para que sirve**: mover propuestas o tareas del repo a Notion sin perder el contexto del proyecto.
- **Como usarlo**: intentar primero MCP; usar fallback con `notion-import/create_tickets_from_proposal.py` solo si MCP falla por auth o conectividad.
- **Workflow recomendado**: ver `docs/01-configuracion/NOTION_TICKET_WORKFLOW.md` para el flujo corto ticket -> rol -> Drive -> Notion -> contexto local.
- **Como ayuda a OWFINANCE**: mantiene el backlog vivo sin mezclarlo con la documentacion canonica.
- **Como complementa al resto**: Drive decide y Notion ejecuta; `documentator` y `notion-mcp-integration` cubren ambos lados.
- **Uso diario recomendado**: usarlo para backlog activo y seguimiento de entregables, no como reemplazo de Drive.

### Google Workspace MCP

- **Que es**: MCP local para Drive, Docs y Calendar.
- **Para que sirve**: buscar, leer y actualizar docs y archivos de Google Workspace desde el agente.
- **Como usarlo**: usar las herramientas Drive/Docs/Calendar cuando el trabajo necesite leer o sincronizar artefactos fuera del repo.
- **Como ayuda a OWFINANCE**: acelera discovery documental y evita copiar contenido manualmente entre Drive y el workspace.
- **Como complementa al resto**: potencia a `documentator` y refuerza el flujo Drive-first.
- **Uso diario recomendado**: usarlo cuando el trabajo requiera docs canonicos o coordinacion operativa en Google Workspace.

### Telegram bridge

- **Que es**: bridge local entre OWFINANCE y Telegram via transcript, snapshot y cola compartida.
- **Para que sirve**: recibir avisos, consultar contexto y mantener una conversacion operativa paralela.
- **Como usarlo**: scripts `telegram-notify.sh`, `telegram-step.sh`, `telegram-heartbeat.sh` y `telegram-context-bridge.py`.
- **Como ayuda a OWFINANCE**: da visibilidad operativa rapida y reduce el tiempo de chequeo manual.
- **Como complementa al resto**: se apoya en el contexto del repo, en Drive y en Gemini local sin guardar secretos en el repo.
- **Uso diario recomendado**: usarlo para estado, avisos de progreso, snapshots y consultas operativas rapidas.

### GGA

- **Que es**: Gentleman Guardian Angel, guardrail local por repo.
- **Para que sirve**: revisar cambios antes de commit y reforzar contratos tecnicos.
- **Como usarlo**: `gga run` dentro de `OWFINANCEBackend2025` o `OWFinanceFrontend2025`; `gga install` para hooks si hace falta reinstalarlos.
- **Como ayuda a OWFINANCE**: protege rutas, auth, contratos API y convenciones sensibles.
- **Como complementa al resto**: mientras Engram guarda memoria y los skills ayudan a producir, GGA ayuda a no romper cosas.
- **Uso diario recomendado**: correrlo antes de commits relevantes o cambios de backend/frontend con impacto real.

## Herramientas principales

### Superpowers

- **Que es**: plugin de skills orientados a ejecucion disciplinada, debugging, planes, revision y trabajo con subagentes.
- **Para que sirve**: dar metodos concretos para investigar bugs, escribir planes y verificar cambios con mas rigor.
- **Como usarlo**: en OpenCode queda activo por plugin global `superpowers@git+https://github.com/obra/superpowers.git`; se invoca por sus skills cuando un flujo pide debugging sistematico, TDD o planes.
- **Como ayuda a OWFINANCE**: es util para cambios delicados en backend, integraciones, bugs complejos y tareas donde conviene un metodo repetible.
- **Como complementa al resto**: complementa a los skills OWFINANCE con metodo generalista; no reemplaza ni el contexto del proyecto ni Engram.
- **Uso diario recomendado**: usarlo cuando haya ambiguedad tecnica, bugs dificiles o necesidad de planificar/validar con mas rigor que una edicion simple.

### ui-ux-pro-max

- **Que es**: skill local de inteligencia UI/UX para planning, implementacion y revision de interfaces.
- **Para que sirve**: mantener coherencia visual, enfoque mobile-first y calidad de experiencia en frontend.
- **Como usarlo**: cargar el skill cuando la tarea toque pantallas, componentes Quasar, flujos UX o criterios visuales.
- **Como ayuda a OWFINANCE**: alinea el frontend con las reglas del proyecto y evita soluciones genericas o inconsistentes.
- **Como complementa al resto**: trabaja junto con las guias de `docs/ui-ux/`, el rol `owf-role-ui-ux-design-steward` y los skills operativos del repo.
- **Uso diario recomendado**: usarlo siempre que una tarea cambie UI, UX, copy de interfaz o estructura visual relevante.

### Everything Claude Code / ECC

- **Que es**: paquete amplio de comandos, agentes y convenciones reutilizables; en OpenCode la pieza instalada es `ecc-universal`.
- **Para que sirve**: ampliar discoverability y disponer de prompts, comandos y patrones portables entre entornos compatibles.
- **Como usarlo**: mantener `ecc-universal` en la lista de plugins de OpenCode y usar sus comandos cuando aporten plantillas o workflows ya probados.
- **Como ayuda a OWFINANCE**: suma un set amplio de utilidades sin obligar a reescribir flujos desde cero.
- **Como complementa al resto**: cubre casos generales; los skills OWFINANCE siguen siendo la capa especifica del negocio.
- **Uso diario recomendado**: usarlo como toolbox secundario, no como fuente principal de contexto del proyecto.

### Engram

- **Que es**: memoria persistente de sesiones y observaciones, expuesta por MCP.
- **Para que sirve**: recordar decisiones, bugs, hallazgos y resumenes entre sesiones y entre agentes.
- **Como usarlo**: guardar decisiones y bugfixes con observaciones estructuradas, y recuperar contexto antes de seguir trabajo previo.
- **Como ayuda a OWFINANCE**: reduce perdida de contexto entre sesiones largas, cambios multi-repo y flujos con varios agentes.
- **Como complementa al resto**: da continuidad a Superpowers, ECC, roles OWFINANCE, Telegram bridge y workflows SDD.
- **Uso diario recomendado**: usarlo todos los dias para guardar decisiones importantes y recuperar contexto antes de retomar trabajo.

### Claude-mem

- **Que es**: proyecto de memoria para agentes disponible en npm/GitHub, con adaptador OpenCode `@ephemushroom/opencode-claude-mem`.
- **Para que sirve**: ofrecer otra capa de memoria persistente orientada al ecosistema Claude/OpenCode.
- **Como usarlo**: solo si se decide hacer una prueba controlada y se define claramente cuando escribir ahi y cuando escribir en Engram.
- **Como ayuda a OWFINANCE**: podria servir para comparar experiencia de memoria o cubrir algun caso de uso especifico si Engram no alcanzara.
- **Como complementa al resto**: hoy complementa poco porque se superpone con Engram en la necesidad principal de OWFINANCE.
- **Uso diario recomendado**: no usarlo a diario por ahora; dejarlo como opcion experimental documentada.

## Engram vs Claude-mem

### Lo que ya resuelve Engram en OWFINANCE

- Ya esta instalado y operativo en esta maquina.
- Ya forma parte de OpenCode y de otros entornos usados en el proyecto.
- Ya existe convencion de trabajo del repo apoyada en Engram para session summary, decisiones y recuperacion de contexto.
- Ya esta integrado con los flujos SDD y con el trabajo multi-agente actual.

### Lo que implicaria sumar Claude-mem ahora

- Agregar otra memoria con proposito parecido.
- Definir reglas nuevas para evitar doble escritura o recuerdos inconsistentes.
- Mantener otra pieza mas en OpenCode, con mayor costo de setup y soporte.
- Aumentar confusion operativa sobre cual memoria consultar o actualizar primero.

### Recomendacion practica para este proyecto

- **Decision**: mantener Engram como memoria principal y documentar `claude-mem` como opcion futura, sin instalarlo ahora en OpenCode.
- **Motivo principal**: OWFINANCE ya tiene una solucion de memoria funcionando, adoptada y validada; sumar otra hoy agrega overlap, no una necesidad clara.
- **Cuando reconsiderarlo**: solo si aparece un caso concreto donde Engram falle en recuperacion, UX, granularidad o integracion requerida por el equipo.
- **Como probarlo sin ruido**: hacer una prueba acotada fuera del setup principal, con un criterio explicito de exito y una sola fuente de verdad definida durante la prueba.

## Recomendacion diaria de uso

1. Usar `engram` como memoria principal antes y despues de tareas relevantes.
2. Usar skills OWFINANCE y `documentator` para contexto de negocio, docs y arquitectura.
3. Usar `ui-ux-pro-max` siempre que la tarea toque frontend o experiencia.
4. Usar `superpowers` cuando haga falta metodo fuerte para debugging, planes o verificacion.
5. Usar `ecc-universal` como toolbox secundaria de comandos y patrones.
6. Usar `GGA` antes de cerrar cambios relevantes.
7. Mantener `claude-mem` solo como opcion experimental hasta que exista una necesidad concreta.

## Configuracion OpenCode recomendada hoy

```json
{
  "plugin": [
    "superpowers@git+https://github.com/obra/superpowers.git",
    "ecc-universal"
  ]
}
```

Ese estado es el mas practico hoy para OWFINANCE: aprovecha lo ya validado y evita duplicar memoria persistente sin una razon clara.
