# 🏦 hola OWFINANCE 2026

Sistema integral de gestión financiera con backend Laravel y frontend Quasar (Web + Móvil)

## 📁 Estructura del Proyecto

```
OWFINANCE2026/
├── OWFINANCEBackend2025/     # Backend Laravel (API REST)
├── OWFinanceFrontend2025/     # Frontend Quasar (Web/Mobile)
├── logs/                      # Logs de desarrollo
├── dev-start.sh               # 🚀 Iniciar entorno dev
├── dev-stop.sh                # 🛑 Detener entorno dev
├── env-config.sh              # 🔧 Configurar entornos
├── mobile-build.sh            # 📱 Compilar apps móviles
├── telegram-notify.sh         # 🔔 Avisos locales por Telegram
├── telegram-heartbeat.sh      # ♻️ Heartbeats opcionales por Telegram
├── telegram-context-bridge.py # 🔁 Bridge de contexto OWFINANCE <-> Telegram
├── telegram-bridge-loop.sh    # 🤖 Poll/respuesta automatica orientada a eventos
├── telegram-heartbeat-loop.sh # ⏱️ Heartbeat recurrente opcional en background
├── telegram-notify-wrap.sh    # ✅ Avisos automaticos al terminar tareas
├── telegram-step.sh           # 📍 Evento corto local -> Telegram/transcript
└── ops-status.sh              # 📈 Status rápido dev/stage/prod
```

## 🚀 Inicio Rápido

### 1️⃣ Configuración Inicial

```bash
# Dar permisos de ejecución a los scripts
chmod +x *.sh

# Configurar entorno de desarrollo
./env-config.sh dev

# Instalar dependencias del backend
cd OWFINANCEBackend2025
composer install
php artisan migrate --seed
cd ..

# Instalar dependencias del frontend
cd OWFinanceFrontend2025
npm install
cd ..
```

### 2️⃣ Iniciar Desarrollo

```bash
# Inicia backend (puerto 8000) y frontend (puerto 3000)
./dev-start.sh

# Acceder a:
# - Backend API: http://localhost:8000
# - Frontend Web: http://localhost:3000
```

### 3️⃣ Detener Desarrollo

```bash
./dev-stop.sh
```

## 🌍 Gestión de Entornos

### Desarrollo Local
```bash
./env-config.sh dev
```

### Staging
```bash
./env-config.sh staging
# Editar archivos .env.staging generados
```

### Producción
```bash
./env-config.sh prod
# ⚠️ Revisar y configurar credenciales reales
```

## 📱 Compilación Móvil

### Requisitos Previos

**iOS:**
- macOS
- Xcode instalado
- CocoaPods: `sudo gem install cocoapods`

**Android:**
- Android Studio
- Java JDK 11+
- Variables de entorno configuradas (`ANDROID_HOME`, `JAVA_HOME`)

### Compilar Apps

```bash
# Android (desarrollo)
./mobile-build.sh android dev

# iOS (desarrollo)
./mobile-build.sh ios dev

# Ambas plataformas (producción)
./mobile-build.sh both prod
```

### Desarrollo con Hot-Reload

```bash
cd OWFinanceFrontend2025

# Android con hot-reload
quasar dev -m capacitor -T android

# iOS con hot-reload
quasar dev -m capacitor -T ios
```

## 🛠️ Tecnologías

### Backend
- **Framework:** Laravel 11.x
- **Base de datos:** MySQL / SQLite
- **API:** RESTful con Sanctum Auth
- **Documentación:** Scribe / Swagger

### Frontend
- **Framework:** Quasar 2.x (Vue 3 + TypeScript)
- **Estado:** Pinia
- **Routing:** Vue Router
- **HTTP:** Axios
- **UI:** Material Design

### Mobile
- **Capacitor:** Compilación nativa iOS/Android
- **PWA:** Progressive Web App support

## 📊 Flujo de Trabajo Recomendado

1. **Desarrollo Local**
   ```bash
   ./dev-start.sh
   # Editar código con hot-reload automático
   ```

2. **Pruebas en Móvil**
   ```bash
   # Compilar y probar en dispositivo/emulador
   ./mobile-build.sh android dev
   ```

3. **Deployment**
   ```bash
   # Configurar entorno
   ./env-config.sh prod
   
   # Backend: seguir guía en OWFINANCEBackend2025/deploy/
   # Frontend: quasar build
   ```

## 📝 Scripts Disponibles

| Script | Descripción |
|--------|-------------|
| `dev-start.sh` | Inicia backend + frontend en desarrollo |
| `dev-stop.sh` | Detiene todos los servicios |
| `env-config.sh [env]` | Configura variables de entorno |
| `mobile-build.sh [platform] [mode]` | Compila apps móviles |
| `telegram-notify.sh [send|test|chat-id]` | Envía avisos locales por Telegram usando env vars |
| `telegram-heartbeat.sh` | Mantiene heartbeats opcionales para tareas largas, no como modo por defecto |
| `telegram-context-bridge.py` | Comparte transcript/snapshot con Telegram, mantiene comandos y responde chat libre con Gemini CLI local o fallback deterministico |
| `telegram-step.sh` | Registra un paso local y lo manda a Telegram de forma concisa |
| `ops-status.sh [dev|stage|prod]` | Ejecuta checks rápidos de estado operativo |

## 🔗 URLs Importantes

- **Backend Dev:** http://localhost:8000
- **Frontend Dev:** http://localhost:3000
- **API Docs:** http://localhost:8000/docs
- **Swagger:** http://localhost:8000/swagger.json

## 📚 Documentación Adicional

- [Backend README](OWFINANCEBackend2025/README.md)
- [Frontend README](OWFinanceFrontend2025/README.md)
- [API Documentation](OWFINANCEBackend2025/docs/)
- [Frontend Guides](OWFinanceFrontend2025/docs/)
- [Telegram Notifications](docs/01-configuracion/TELEGRAM_NOTIFICATIONS.md)

## 🔔 Telegram y Ops Status

```bash
# Cargar secretos solo en tu shell local
source .env.local

# Enviar aviso manual
./telegram-notify.sh send --type progress --title Backend "Migracion iniciada"

# Modo recomendado: evento puntual corto
./telegram-step.sh --title Backend "Migracion iniciada"
./telegram-step.sh --title Backend --type success "Migracion terminada"

# Guardar y mandar un snapshot compartido al bridge
./telegram-context-bridge.py snapshot --title Context --send "OWFINANCE prioriza bridge de contexto y comando /status"

# Leer comandos y mensajes libres entrantes, responder automaticamente
./telegram-context-bridge.py pull --respond

# Simular un mensaje libre local y obtener respuesta desde el contexto compartido
./telegram-context-bridge.py chat "Que sabemos del estado dev y del modelo de contexto compartido?"

# Arrancar/parar el loop automatico de polling/respuesta orientado a eventos
./telegram-bridge-loop.sh start --interval 30
./telegram-bridge-loop.sh start --interval 30 --mode auto
./telegram-bridge-loop.sh start --interval 30 --mode local-context
./telegram-bridge-loop.sh stop

# Aviso automatico cuando un comando termina
./telegram-notify-wrap.sh --title OpsCheck -- ./ops-status.sh dev

# Heartbeat solo para tareas realmente largas o silenciosas
./telegram-heartbeat.sh --title Dev --status dev --interval 120 "Build sigue corriendo"
./telegram-heartbeat-loop.sh start --interval 60 --title Worker --status dev "Task sigue corriendo"
./telegram-heartbeat-loop.sh stop

# Ver estado rapido
./ops-status.sh dev
./ops-status.sh stage
```

Para obtener el `TELEGRAM_CHAT_ID`, abre el bot en Telegram, enviale `/start` y luego ejecuta `./telegram-notify.sh chat-id`.

El bridge usa un modelo de contexto compartido, no una sesion nativa identica: mantiene transcript, snapshot y cola local bajo `~/.config/owfinance-ops/context-bridge/`, conserva exactamente los comandos `/status`, `/status dev`, `/status stage`, `/status prod`, `/help`, `/last` y `/context`, y responde mensajes libres como un chat paralelo de OWFINANCE. En modo `auto`, intenta primero Gemini CLI local si ya esta disponible sin secretos nuevos; si no, cae a un responder deterministico con transcript, snapshot y docs locales Drive-first. Los launchers de automation guardan `pid` y logs bajo `~/.config/owfinance-ops/automation/`.

## 🤖 Tooling de IA

Este workspace ya integra las tres piezas pedidas para el flujo de agentes:

- **Agent Teams Lite**: skills SDD y registro local para flujos delegados, reutilizable desde OpenCode, Antigravity y otros agentes
- **Engram**: configuración MCP para VS Code, OpenCode, Gemini/Antigravity y agentes compatibles
- **Gentleman Guardian Angel (GGA)**: configuración por repo en `OWFINANCEBackend2025/.gga` y `OWFinanceFrontend2025/.gga`

### Estructura agregada

```text
OWFINANCE2026/
├── CLAUDE.md                  # Referencia ATL heredada (no es el agente principal)
├── .claude/skills/            # Skills SDD y convenciones compartidas
├── .atl/skill-registry.md     # Registro local de skills
├── .vscode/mcp.json           # MCP workspace para Engram
├── OWFINANCEBackend2025/.gga  # Reglas GGA backend
└── OWFinanceFrontend2025/.gga # Reglas GGA frontend
```

### Comandos recomendados

```bash
# Engram ya instalado y registrado
engram serve
engram setup opencode
engram setup gemini-cli

# Hooks GGA ya instalados por repo
cd OWFINANCEBackend2025 && gga install
cd ../OWFinanceFrontend2025 && gga install
```

### Agentes objetivo

- **OpenCode**: configurado globalmente en `~/.config/opencode/opencode.json`
- **VS Code**: configurado con MCP en `.vscode/mcp.json` y también agregado al perfil de usuario de VS Code
- **Antigravity / Gemini CLI**: configurado vía `~/.gemini/settings.json` y usa el mismo backend MCP de Engram

`CLAUDE.md` se conserva solo como referencia de Agent Teams Lite; no es el flujo principal de tu máquina.

Más detalle en `docs/01-configuracion/AI_AGENT_TOOLING.md`.

### Roles operativos SaaS

- Roles OWFINANCE instalados en `.agents/skills/owf-role-*/`
- Copia para OpenCode sidebar en `~/.config/opencode/skills/owf-role-*/`
- Slash commands sugeridos en `~/.config/opencode/commands/role-*.md`
- Guía operativa y plan de marketing en `docs/01-configuracion/SAAS_ROLE_SYSTEM.md`
- Backlog, tareas y seguimientos en Notion deben pasar por `notion-mcp-integration`

## 🐛 Troubleshooting

### Puerto ocupado
```bash
# Liberar puertos manualmente
lsof -ti:8000 | xargs kill -9  # Backend
lsof -ti:3000 | xargs kill -9  # Frontend
```

### Limpiar caché
```bash
# Backend
cd OWFINANCEBackend2025
php artisan cache:clear
php artisan config:clear

# Frontend
cd OWFinanceFrontend2025
rm -rf node_modules/.vite
npm run build
```

### Problemas con base de datos
```bash
cd OWFINANCEBackend2025
php artisan migrate:fresh --seed
```

## 🤝 Contribución

1. Crear rama feature: `git checkout -b feature/nueva-funcionalidad`
2. Commit cambios: `git commit -am 'Agrega nueva funcionalidad'`
3. Push a rama: `git push origin feature/nueva-funcionalidad`
4. Crear Pull Request

## 📄 Licencia

Propietario: OteroWeb  
Contacto: oterolopez1990@gmail.com

---

**Desarrollado con ❤️ por OteroWeb**
