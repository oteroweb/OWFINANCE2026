# OpenCode Runtime Setup

Estado documental: `transicional`

Configuracion local aplicada para OpenCode en esta maquina.

## Modelo real configurado para agentes

- Los agentes SDD de OpenCode quedaron apuntando al proveedor/modelo real `google/gemini-2.5-flash`.
- Esto reemplaza los placeholders `<your-provider/your-model>` en:
  - `sdd-orchestrator`
  - `sdd-init`
  - `sdd-explore`
  - `sdd-propose`
  - `sdd-spec`
  - `sdd-design`
  - `sdd-tasks`
  - `sdd-apply`
  - `sdd-verify`
  - `sdd-archive`

## Estado real encontrado durante el saneamiento

- `c:\Users\pc\.config\opencode\opencode.json` estaba invalido y no cargaba MCPs.
- `opencode.cmd mcp list` devolvia `No MCP servers configured`.
- No se detecto una configuracion local reproducible de Notion o Stitch en OpenCode lista para reusar sin rearmar credenciales o endpoints.

## MCPs objetivo para OpenCode

- `context7`
- `NotionMCP` o equivalente local reproducible
- `StitchMCP` o equivalente local reproducible
- `engram` cuando exista una entrada MCP valida en este runtime

## Integraciones bloqueadas por credenciales o autorizacion faltante

- `GitHubMCP` no se agrego porque falta autenticacion utilizable en esta maquina.
- Integraciones de historial de chat corporativo o enterprise siguen bloqueadas si no existe API oficial, export administrativo o credenciales aprobadas.

## Nota operativa importante

- El acceso directo al historial de chats de plataformas corporativas no queda disponible automaticamente por tener OpenCode o MCP.
- Ese acceso depende de APIs oficiales del proveedor, exports administrados por la empresa, o integraciones aprobadas con credenciales vigentes.

## Archivos relevantes

- Config global OpenCode: `/Users/joseluisoterolopez/.config/opencode/opencode.json`
- Config MCP adicional usada como referencia local: `/Users/joseluisoterolopez/.gemini/antigravity/mcp_config.json`
- Guia operativa de Stitch: `docs/01-configuracion/STITCH_MCP_OPERATIONAL_SETUP.md`
