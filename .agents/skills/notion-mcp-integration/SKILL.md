---
name: notion-mcp-integration
description: Use exclusively the Notion MCP tools to handle any task that involves Notion, backlogs or tickets.
---

# Notion MCP Integration Skill

This skill enforces best practices when the User requests to interact with Notion in the OWFinance2026 workspace.

## 1. Regla de Oro (No Scripts)
**Bajo ninguna circunstancia** debes crear scripts de NodeJS (`/tmp/...`), `curl` o llamadas directas al API de Notion. Debes **usar EXCLUSIVAMENTE las herramientas nativas del MCP de Notion** que el entorno inyecta en tu contexto.

## 2. Herramientas MCP
Utiliza las herramientas inyectadas (típicamente bajo el prefijo del MCP de Notion) para leer bases de datos, crear páginas o añadir bloques.

## 3. Entorno y Configuración
El token y el Database ID ya están alojados en las variables de entorno de tu archivo global `mcp_config.json`:
- `NOTION_API_TOKEN`
- `NOTION_DATABASE_ID` (Base de Datos principal del Backlog: `32de7ace976781958d00dd0d61583eac`)

## 4. Fallback (Restart Required)
Si intentas realizar una acción en Notion pero te das cuenta de que las herramientas `mcp_NotionMCP_*` o similares aún **no están disponibles en tu lista de tools**, significa que el servidor MCP no se ha cargado. 
**No escribas un script**. En su lugar, dile al usuario:
*"He detectado que las herramientas del MCP de Notion no están activas en mi entorno. Por favor, haz un `Reload Window` en tu editor para que el servidor MCP se inicialice, y vuelve a pedirme la tarea."*
