# Importación a Notion - OWFINANCE2026 Backlog

Este directorio contiene los 7 tickets del backlog de OWFINANCE2026 en formato JSON para importar a Notion.

## Archivos incluidos

| # | Archivo | Ticket |
|---|---------|--------|
| 1 | `ticket-1-voice-nlp.json` | Sistema de Registro por Voz (NLP Core) |
| 2 | `ticket-2-ocr.json` | Visor e Ingesta de Recibos (OCR) |
| 3 | `ticket-3-jar-distribution.json` | Automatización de Reparto en Cántaros |
| 4 | `ticket-4-fab-chatbot.json` | UI de Gasto Rápido y Chatbot |
| 5 | `ticket-5-coach-ia.json` | Perfil Contextual para Coach Financiero (IA) |
| 6 | `ticket-6-lite-pro.json` | Implementación Front-end Adaptativa (Lite vs Pro) |
| 7 | `ticket-7-patterns.json` | Detección de Patrones y Notificación |

## Estructura de propiedades en Notion

Tu base de datos de Notion debe tener estas propiedades:

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| Name | Title | Nombre de la tarea |
| Status | Select | To Do, In Progress, Done |
| Priority | Select | Alta, Media, Baja, Urgente |
| Role | Multi-select | UX, Fullstack, Backend, AI Engineer, Frontend, Infra |
| Estimate | Text | Estimación en horas |
| User Story | Text | User Story en una línea |
| Acceptance Criteria | Text | Criterios de aceptación |
| Technical Details | Text | Detalles técnicos |

## Cómo importar

### Opción 1: Importación manual con curl

Requiere: `NOTION_API_TOKEN` y `NOTION_DATABASE_ID`

```bash
# Exportar variables
export NOTION_API_TOKEN="secret_..."
export NOTION_DATABASE_ID="32de7ace976781958d00dd0d61583eac"

# Importar cada ticket
cd notion-import

for file in ticket-*.json; do
  curl -X POST "https://api.notion.com/v1/pages" \
    -H "Authorization: Bearer $NOTION_API_TOKEN" \
    -H "Content-Type: application/json" \
    -H "Notion-Version: 2022-06-28" \
    -d @"$file"
done
```

### Opción 2: Usar Notion API SDK (Node.js)

```javascript
const { Client } = require('@notionhq/client');
const fs = require('fs');

const notion = new Client({ auth: process.env.NOTION_API_TOKEN });
const databaseId = process.env.NOTION_DATABASE_ID;

const files = [
  'ticket-1-voice-nlp.json',
  'ticket-2-ocr.json',
  'ticket-3-jar-distribution.json',
  'ticket-4-fab-chatbot.json',
  'ticket-5-coach-ia.json',
  'ticket-6-lite-pro.json',
  'ticket-7-patterns.json'
];

async function importTickets() {
  for (const file of files) {
    const data = JSON.parse(fs.readFileSync(file, 'utf8'));
    await notion.pages.create({
      parent: { database_id: databaseId },
      ...data
    });
    console.log(`✓ Importado: ${file}`);
  }
}

importTickets();
```

### Opción 3: Copiar manualmente

Abre cada archivo JSON y copia el contenido a Notion:
1. Abre Notion
2. Ve a tu base de datos del Backlog
3. Crea una nueva página
4. Pega el contenido en las propiedades correspondientes

## Después de importar

1. **Verifica** que las 7 tareas aparezcan en tu base de datos
2. **Assign** las tareas a ti mismo o a tu equipo
3. **Relaciona** con otras bases de datos si es necesario (usuarios, proyectos, etc.)
4. **Comparte** la base de datos con colaboradores

## Notas

- Los archivos JSON siguen el formato oficial de la API de Notion
- El contenido incluye children blocks para información adicional
- Las propiedades de texto rico (rich_text) soportan formato básico
- Los IDs de las tareas en Notion pueden diferir de los números en los nombres

## Soporte

Si tienes problemas con la importación, revisa:
1. Que tu token de API tenga permisos de creación de páginas
2. Que el ID de la base de datos sea correcto
3. Que las propiedades de la base de datos coincidan con los nombres en los JSON
