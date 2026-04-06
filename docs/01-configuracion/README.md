# ⚙️ 01 - Configuración & Entorno

Documentación de **configuración multi-entorno**, variables de entorno, y estrategia de deployments.

## Archivos

### 🌐 Estrategia Multi-Entorno
- **ENV_STRATEGY.md** - Estrategia completa de configuración
  - Archivos `.env` según escenario (local, remote, mobile, production)
  - Cómo cambiar entre configuraciones
  - Backend URLs para cada entorno
  - Cuándo usar cada env

### 🤖 Tooling de agentes
- **AI_AGENT_TOOLING.md** - Integración de Engram, Agent Teams Lite y GGA
  - Ubicación de skills y registro local
  - Configuración MCP de workspace
  - Configuración `.gga` para backend y frontend
  - Comandos de instalación y uso diario
- **NOTION_TICKET_WORKFLOW.md** - Flujo corto para tomar un ticket de Notion y cerrarlo bien
  - Seleccion por prioridad, status y role
  - Skills OWFINANCE, `documentator` y uso de Notion MCP vs fallback
  - Cierre de Drive, Notion, Telegram y contexto local
- **STITCH_MCP_OPERATIONAL_SETUP.md** - Contrato operativo de Stitch y runtime MCP
  - IDs canonicos
  - Como referenciar Stitch en tickets
  - Que hacer si MCP o Stitch no estan disponibles
- **DOCUMENTATION_CLEANUP_POLICY.md** - Politica de archivo y consolidacion documental
  - Archivo antes de eliminar
  - Estados documentales
  - Criterios de archivo y mantenimiento
- **../../set-herramientas.md** - Mapa practico del stack activo de agentes
  - Superpowers, `ui-ux-pro-max`, ECC y Engram
  - Comparativa concreta `Engram vs Claude-mem`
  - Recomendación diaria para OWFINANCE y estado actual del setup
- **TELEGRAM_NOTIFICATIONS.md** - Setup local para avisos por Telegram
  - Variables `TELEGRAM_BOT_TOKEN` y `TELEGRAM_CHAT_ID`
  - Modo recomendado low-noise y orientado a eventos
  - Scripts `./telegram-notify.sh`, `./telegram-step.sh`, `./ops-status.sh` y `./telegram-context-bridge.py`
  - Comandos `/status`, `/status dev`, `/status stage`, `/status prod`, `/help`, `/last`, `/context` y chat natural
  - Respuesta libre en modo `auto`: Gemini CLI local primero, fallback deterministico si no aplica
  - Paso exacto para descubrir el `chat_id` sin guardar el token en el repo
  - Runtime local bajo `~/.config/owfinance-ops/context-bridge/` para transcript, inbox y snapshot compartidos
- **GOOGLE_WORKSPACE_MCP_SETUP.md** - Checklist exacto para preparar Google Workspace MCP
  - APIs a habilitar en Google Cloud Console
  - Credencial recomendada y artifact a entregar
  - Guía corta para OAuth Desktop app

---

**📌 Referencia rápida:**
- `.env.local` → Desarrollo web en navegador (backend local)
- `.env.remote` → Desarrollo web contra servidor remoto
- `.env.mobile` → Apps móviles (Android/iOS)
- `.env.production` → Builds finales para tiendas

**📍 Última actualización:** 2026-03-01
