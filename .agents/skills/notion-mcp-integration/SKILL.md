---
name: notion-mcp-integration
description: Prefer Notion MCP for backlog and ticket work, with a controlled HTTP API fallback when MCP auth or connectivity fails.
---

# Notion MCP Integration Skill

Use this skill when the user needs to read or update Notion backlog, sprint, task, or ticket data in the OWFINANCE2026 workspace.

## 1. Prioridad de ejecucion
- Usa primero Notion MCP para operaciones de backlog, tickets y tareas cuando las herramientas MCP esten disponibles y respondan correctamente.
- Si el MCP falla por autenticacion, conectividad, servidor no cargado o herramientas ausentes, puedes usar el API HTTP de Notion via script/bash solo si `NOTION_API_TOKEN` esta disponible y la operacion sigue limitada a backlog/tareas.
- Si tampoco hay token valido, detente y pide al usuario restaurar MCP o proporcionar el entorno correcto; no improvises credenciales.

## 2. Variables de entorno
- Requerida para fallback: `NOTION_API_TOKEN`
- Opcional: `NOTION_DATABASE_ID`
- Si `NOTION_DATABASE_ID` no existe, confirma el destino antes de crear registros via API.

## 3. Reglas de seguridad
- No expongas tokens, headers completos, IDs sensibles ni pegues secretos en la respuesta.
- Limita el fallback API a operaciones operativas de backlog/tareas; evita cambios amplios o destructivos.
- Antes de crear o actualizar en lote, valida el `database_id`, propiedades objetivo y alcance del cambio.
- Prefiere payloads pequenos, idempotentes y auditables; resume resultados sin imprimir secretos.

## 4. Flujo corto recomendado
1. Intenta leer o escribir con Notion MCP.
2. Si recibes error de auth/conectividad o no existen herramientas MCP, verifica si `NOTION_API_TOKEN` esta disponible.
3. Si hay token valido, usa el API HTTP de Notion via script/bash para la operacion puntual.
4. Si no hay token o falta contexto critico, informa el bloqueo y no fuerces la accion.

## 5. Ejemplo: tickets desde propuesta markdown
1. Lee la propuesta markdown y extrae titulo, resumen, prioridad y criterios de aceptacion.
2. Intenta crear los tickets en Notion via MCP.
3. Si MCP falla por auth/conectividad y existe `NOTION_API_TOKEN` (+ `NOTION_DATABASE_ID` si ya se conoce), crea las paginas en la base de backlog usando el API HTTP.
4. Devuelve al usuario un resumen breve de tickets creados, pendientes y cualquier validacion manual restante.

## 6. Script fallback del workspace
- Script recomendado: `notion-import/create_tickets_from_proposal.py`
- Uso base: `NOTION_API_TOKEN=... NOTION_DATABASE_ID=... python3 notion-import/create_tickets_from_proposal.py new_tickets_proposal.md`
- Si el `database_id` no esta en entorno: `NOTION_API_TOKEN=... python3 notion-import/create_tickets_from_proposal.py new_tickets_proposal.md <database_id>`
- Para validar parseo sin escribir en Notion: `python3 notion-import/create_tickets_from_proposal.py new_tickets_proposal.md <database_id> --dry-run`
