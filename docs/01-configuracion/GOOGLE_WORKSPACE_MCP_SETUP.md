# Google Workspace MCP Setup

Usa esta guia para preparar acceso MCP a Google Drive, Docs, Gmail y Calendar.

## Que habilitar en Google Cloud Console

1. Entra a `https://console.cloud.google.com/`.
2. Crea o selecciona el proyecto que usara el MCP.
3. En `APIs & Services > Library`, habilita estas APIs:
   - Google Drive API
   - Google Docs API
   - Gmail API
   - Google Calendar API
4. En `APIs & Services > OAuth consent screen`, configura el consentimiento antes de crear credenciales.

## Credencial recomendada

- Tipo: `OAuth client ID`
- Aplicacion: `Desktop app`
- Artifact esperado: `credentials.json`

## Datos minimos que debes completar

- Nombre de la app en OAuth consent screen
- User support email
- Developer contact email
- Scopes para Drive, Docs, Gmail y Calendar segun lo que vaya a usar el MCP
- Test users si el proyecto sigue en modo Testing

## Redirect y guidance para Desktop app

- Si eliges `Desktop app`, Google genera el flujo correcto para cliente local y normalmente no necesitas escribir redirect URIs manualmente.
- Si el MCP o launcher pide redirect URI explicita, usa la que documente ese MCP exacto; no inventes una de tipo web.
- Evita crear `Web application` salvo que el MCP lo exija expresamente.

## Donde obtener el archivo correcto

1. Ve a `APIs & Services > Credentials`.
2. Crea `OAuth client ID` con tipo `Desktop app`.
3. Abre la credencial creada.
4. Pulsa `Download JSON`.
5. Guarda el archivo como `credentials.json`.

## Lo que debes entregar despues

- Entrega el archivo `credentials.json` del OAuth client de tipo Desktop app.
- Si el proyecto esta en modo Testing, confirma tambien que la cuenta operativa fue agregada como test user.

## Estado local en esta maquina

- Perfil activo por defecto: `default`.
- Ubicacion esperada por `@dguido/google-workspace-mcp`: `~/.config/google-workspace-mcp/credentials.json` y `~/.config/google-workspace-mcp/tokens.json`.
- OpenCode usa una entrada MCP local en `~/.config/opencode/opencode.json` con servicios `drive,docs,gmail,calendar`.
- No guardar secretos ni tokens en docs del workspace.

## Checklist rapido

- Proyecto de Google Cloud seleccionado
- APIs habilitadas: Drive, Docs, Gmail, Calendar
- OAuth consent screen configurado
- OAuth client ID tipo Desktop app creado
- `credentials.json` descargado
- Cuenta operativa agregada como test user si aplica
