# Tooling de Agentes - OWFINANCE2026

Esta guía documenta la integración local de:

- `engram`
- `agent-teams-lite`
- `gentleman-guardian-angel`

## 1. Qué quedó agregado al proyecto

### Agent Teams Lite
- `CLAUDE.md`
- `.claude/skills/_shared/`
- `.claude/skills/sdd-init/`
- `.claude/skills/sdd-explore/`
- `.claude/skills/sdd-propose/`
- `.claude/skills/sdd-spec/`
- `.claude/skills/sdd-design/`
- `.claude/skills/sdd-tasks/`
- `.claude/skills/sdd-apply/`
- `.claude/skills/sdd-verify/`
- `.claude/skills/sdd-archive/`
- `.claude/skills/skill-registry/`
- `.atl/skill-registry.md`

### Engram
- `.vscode/mcp.json`

### Gentleman Guardian Angel
- `OWFINANCEBackend2025/.gga`
- `OWFinanceFrontend2025/.gga`

## 2. Criterio de integración

- `agent-teams-lite` se integró como skills locales del workspace.
- `engram` no se versiona dentro del proyecto; se usa como binario global y se conecta por MCP.
- `gentleman-guardian-angel` tampoco se vendorizó; se dejó configurado por repo mediante archivos `.gga`.

## 3. Estado actual en esta máquina

### Instalado
- `engram 1.10.8`
- `gga v2.8.0`

### Configurado
- OpenCode: `engram setup opencode`
- Gemini CLI / Antigravity: `engram setup gemini-cli`
- VS Code: MCP agregado con `code --add-mcp ...`
- Engram HTTP server activo localmente en `http://localhost:7437`
- OpenCode MCPs locales/remotos tambien incluyen `NotionMCP`, `StitchMCP`, `FetchMCP`, `TimeMCP` y `context7` cuando existen credenciales/configuracion de maquina
- OpenCode plugins activos: `superpowers@git+https://github.com/obra/superpowers.git` y `ecc-universal`
- `claude-mem` queda documentado como opcion futura; no se instala por defecto porque hoy se superpone con Engram y agrega costo operativo sin necesidad clara
- Para operaciones de backlog/tareas en Notion, el skill `notion-mcp-integration` prioriza MCP y solo permite fallback HTTP API si MCP falla por auth/conectividad y existe `NOTION_API_TOKEN`.
- Fallback recomendado del workspace: `python3 notion-import/create_tickets_from_proposal.py new_tickets_proposal.md <database_id>` usando `NOTION_API_TOKEN` y, si se prefiere, `NOTION_DATABASE_ID` por entorno.
- El workspace incluye `telegram-context-bridge`, con copia en OpenCode, para sincronizacion practica via transcript/snapshot/queue con Telegram sin exponer secretos ni prometer una sesion nativa identica.
- Hooks GGA instalados en:
  - `OWFINANCEBackend2025/.git/hooks/pre-commit`
  - `OWFinanceFrontend2025/.git/hooks/pre-commit`

## 4. Instalación global requerida

```bash
brew install gentleman-programming/tap/engram
brew install gentleman-programming/tap/gga
```

Si usas OpenCode como agente principal:

```bash
engram setup opencode
```

En esta máquina `brew install gentleman-programming/tap/engram` falló por Xcode desactualizado, por lo que `engram` se instaló manualmente desde el binario oficial release en `/usr/local/bin/engram`.

## 5. Activación en este workspace

### Engram

VS Code ya puede descubrir el MCP del workspace desde:

- `.vscode/mcp.json`

También quedó disponible para:

- OpenCode: `~/.config/opencode/opencode.json`
- Gemini CLI / Antigravity: `~/.gemini/settings.json`

Resumen runtime OpenCode en esta maquina:

- `docs/01-configuracion/OPENCODE_RUNTIME_SETUP.md`

Comandos útiles:

```bash
engram serve
engram tui
engram search "owfinance"
engram context OWFINANCE2026
```

### GGA

Instala hooks por repo:

```bash
cd /Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFINANCEBackend2025
gga install

cd /Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025
gga install
```

Ejecutar revisión manual:

```bash
cd /Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFINANCEBackend2025
gga run

cd /Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/OWFinanceFrontend2025
gga run
```

## 6. Archivos clave

### `CLAUDE.md`
- Activa el modo coordinador de Agent Teams Lite.
- Define el flujo SDD y la preferencia por delegar análisis e implementación.
- Se conserva como referencia; no es el agente principal de esta máquina.

### `.atl/skill-registry.md`
- Índice local de skills y convenciones del workspace.
- Sirve para resolver rutas de skills sin depender de memoria de sesión.

### `OWFINANCEBackend2025/.gga`
- Revisión IA para archivos backend.
- Usa `../AGENTS.md` como reglas comunes.

### `OWFinanceFrontend2025/.gga`
- Revisión IA para archivos frontend.
- Usa `../AGENTS.md` como reglas comunes.

## 7. Recomendación operativa

Orden recomendado para trabajar con cambios grandes:

1. usar `engram context OWFINANCE2026`
2. trabajar desde OpenCode, Antigravity o VS Code usando Engram + skills del workspace
3. validar cambios con `gga run` en el repo afectado
4. luego hacer commit/push

## 8. Notas

- El workspace raíz tiene dos repos Git separados: backend y frontend.
- `GGA` debe instalar hooks dentro de cada repo, no en la raíz del workspace.
- `Engram` es compartido a nivel máquina, no a nivel repo.
- Antigravity usa la configuración MCP en `~/.gemini/settings.json`; el archivo `~/.gemini/antigravity/mcp_config.json` puede mantenerse para otros MCPs específicos del IDE.
- Guia operativa ampliada del stack actual: `set-herramientas.md`.
