# OWFinance 2026 — Proyecto Central

**Ubicación:** `~/OW_Ecosystem/apps/owfinance/central/PROYECTO/`  
**Fecha:** 2026-06-01  
**Estado:** 🟡 En construcción

---

## 🎯 Objetivo

Centralizar en una sola carpeta la documentación viva del entorno de desarrollo:
- Qué MCP servers están activos
- Qué skills/agents tenemos
- Qué conectores (APIs, webhooks) estamos usando
- Qué scripts de utilidad existen

---

## 1. MCP Servers (Activos)

### Configuración Global
**Archivo:** `~/.hermes/config.yaml`

| Server | Comando | Descripción | Estado |
|--------|---------|-------------|--------|
| `duckduckgo` | `duck-duck-mcp` | Búsqueda web sin API key | ✅ Activo |
| `filesystem` | `mcp-server-filesystem` | Acceso filesystem OW_Ecosystem + Documents | ✅ Activo |
| `github` | `mcp-server-github` | Repos, PRs, issues (cuenta OteroWeb) | ✅ Activo |
| `github_rs` | `mcp-server-github` | Repos cuenta ReputationStacker | ✅ Activo |
| `notion` | `@notionhq/notion-mcp-server` | Notion API — DB Backlog | ✅ Activo |
| `stitch` | `stitch-mcp` | Stitch MCP (UI design) GCP `hermes-497105` | ✅ Activo |
| `slack` | `slack-mcp-server@latest` | Slack workspace RS HQ (DM Ian-Fernando) | ✅ Activo |

### Credenciales MCP
```
GitHub token (OteroWeb):    <REDACTADO — ver gestor de secretos / .env>
GitHub token (RS):           <REDACTADO — ver gestor de secretos / .env>
Notion token:               <REDACTADO — ver gestor de secretos / .env>
# ⚠️ Los tokens reales NO van en este archivo. Guárdalos en .env / variables de entorno.
# (Los tokens previos fueron expuestos aquí y deben ROTARSE.)
Stitch GCP project:         hermes-497105
Slack workspace (RS HQ):    Slack DM Ian-Fernando (D0A81CTQ9MF)
```

---

## 2. Skills (Agentes)

### Ubicación: `~/.hermes/skills/sov-ow/`

| Skill | Descripción | Estado |
|-------|-------------|--------|
| `coach-central.md` | Orquestador principal, CEO Summary | ✅ |
| `dev-squad.md` | Equipo dev Laravel/Vue3 | ✅ |
| `owfinance.md` | Asesor financiero, cántaros | ✅ |
| `emocional.md` | Salud emocional, tracking anímico | ✅ |
| `fit-nutrition.md` | Entrenador, 150g proteína | ✅ |
| `bio-hacking.md` | Ciclos circadianos, sueño | ✅ |
| `domestico.md` | Hogar, vehículo, inventario | ✅ |
| `memoria.md` | Archivero, diario, búsqueda | ✅ |
| `planificador.md` | Metas, prioridades diarias | ✅ |
| `productividad.md` | Ejecución momento a momento | ✅ |
| `suenos-objetivos.md` | Visión largo plazo | ✅ |
| `conciencia.md` | Sistema holístico | ✅ |
| `configurador.md` | Infraestructura, gateway | ✅ |

### Sub-carpetas de Skills
```
~/.hermes/skills/sov-ow/
├── core/           ← Plantillas base
├── finance/         ← OWFinance refs
├── health/         ← Salud refs
├── hogar/          ← Hogar refs
├── productivity/   ← Productividad refs
├── system/         ← Configuracion refs
├── vision/         ← Sueños refs
└── references/     ← Documentos de apoyo
```

---

## 3. Agentes OW_Ecosystem

### Ubicación: `~/OW_Ecosystem/agents/`

| Agent | Archivo | Función |
|-------|---------|---------|
| Coach Central | `coach-central.md` | Supervisa todo, CEO Summary matutino |
| Dev Squad | `dev-squad.md` | Laravel/Vue3, despliegues, código |
| OWFinance | `owfinance.md` | Cántaros, flujo caja, rentabilidad |
| Emocional | `emocional.md` | Check-ins, patrones, salud emocional |
| Fit Nutrition | `fit-nutrition.md` | Proteína 150g, EMOM, suplementos |
| Bio Hacking | `bio-hacking.md` | Sueño, ritmos circadianos |
| Doméstico | `domestico.md` | Hogar, carro, inventario |
| Memoria | `memoria.md` | Diario, archivo, búsqueda |
| Planificador | `planificador.md` | Metas, prioridades |
| Productividad | `productividad.md` | Ejecución diaria |
| Suenos Objetivos | `suenos-objetivos.md` | Visión, mapa de sueños |
| Conciencia | `conciencia.md` | Sistema cercano, acceso holístico |

---

## 4. Conectores Externos

### APIs y Servicios

| Servicio | Tipo | Estado | Notas |
|----------|------|--------|-------|
| **OWFinance API** | REST | ✅ Stage + Dev | Ver `context/shared/OWFINANCE_APP.md` |
| **Binance P2P** | API | ✅ Monitor activo | Cron `c564e22672bd` cada 30min |
| **OpenCode Go** | LLM | ✅ 3 API keys | RS Key para Cognee |
| **Ollama** | LLM | ✅ Local | qwen2.5:7b, llama3.2:3b, gemma3:12b |
| **Google Sheets** | Sync | ✅ OWFinance | Spreadsheet `17PiHrPmi0FFoQdIMtNjtX4MmxSsfYE7wZimIB83z_K0` |
| **Notion** | DB | ✅ Backlog | DB `32de7ace976781958d00dd0d61583eac` |

### Webhooks/Bridges

| Bridge | Script | Estado |
|--------|--------|--------|
| Telegram Heartbeat | `telegram-heartbeat.sh` | ✅ |
| Telegram Notify | `telegram-notify.sh` | ✅ |
| Telegram Context | `telegram-context-bridge.py` | ✅ |

### Slack (ReputationStacker HQ)

| Canal | ID | Uso |
|-------|---|-----|
| Workspace | RS HQ | DM a Ian-Fernando (D0A81CTQ9MF) |

---

## 5. Scripts de Utility

### Ubicación: `~/OW_Ecosystem/apps/owfinance/central/`

#### Deployment
| Script | Función |
|--------|---------|
| `deploy-backend.sh` | Push + SSH + migrate backend |
| `deploy-frontend.sh` | Push + build + rsync frontend |
| `dev-start.sh` | Iniciar entornos locales |
| `dev-stop.sh` | Detener entornos |
| `switch-env.sh` | Cambiar entorno (local/dev/stage) |

#### Base de Datos
| Script | Función |
|--------|---------|
| `sync_stage_to_dev.sh` | Restaurar backup stage en dev |
| `backup_mysql_stage.py` | Backup diario stage (cron) |

#### Testing/Mobile
| Script | Función |
|--------|---------|
| `dev-mobile.sh` | Android dev mode |
| `build-apk.sh` | Build APK local |
| `deploy-mobile.sh` | Deploy a tiendas |

#### Monitoreo
| Script | Función |
|--------|---------|
| `status.sh` | Estado general |
| `ops-status.sh` | Estado extendido dev/stage |
| `telegram-heartbeat-loop.sh` | Heartbeat continuo |

---

## 6. URLs y Endpoints

### Producción
| Recurso | URL |
|---------|-----|
| **Stage Frontend** | https://appfinanzas.blockshift.website/app/ |
| **Stage API** | https://appfinanzas.blockshift.website/api/v1 |
| **Dev Frontend** | https://appfinanzasdev.blockshift.website |
| **Dev API** | https://appfinanzasdev.blockshift.website/api/v1 |

### Repositorios
| Repo | URL |
|------|-----|
| **sov-ow** | https://github.com/oteroweb/sov-ow |
| **OWFINANCE2026** | https://github.com/oteroweb/OWFINANCE2026 |
| **OWFINANCEBACKEND2025** | https://github.com/oteroweb/OWFINANCEBACKEND2025 |
| **OWFINANCEFRONTEND2025** | https://github.com/oteroweb/OWFINANCEFRONTEND2025 |
| **voice-bridge-mood** | https://github.com/oteroweb/voice-bridge-mood |

### Otros
| Servicio | URL/ID |
|-----------|--------|
| **Google Sheets** | https://docs.google.com/spreadsheets/d/17PiHrPmi0FFoQdIMtNjtX4MmxSsfYE7wZimIB83z_K0 |
| **Notion Backlog** | DB `32de7ace976781958d00dd0d61583eac` |
| **Stitch GCP** | `hermes-497105` |

---

## 7. Tareas Pendientes

| Tarea | Archivo | Prioridad |
|-------|---------|-----------|
| Sync Stage DB → Dev DB | `TAREA_sync_stage_to_dev.md` | Media |
| — | — | — |

---

## 8. Estructura de Archivos

```
central/
├── PROYECTO/                    ← ESTE DOCUMENTO
│   └── README.md
├── OWFINANCEBackend2025/        ← Git submodule
├── OWFinanceFrontend2025/       ← Git submodule
├── docs/                        ← Documentación técnica
├── tests/                       ← Tests
├── src/                         ← Código fuente
├── scripts/                     ← Scripts root (delegación)
├── sync_stage_to_dev.sh         ← Script sync DB
├── deploy-backend.sh            ← Deploy backend
├── deploy-frontend.sh           ← Deploy frontend
├── dev-start.sh                 ← Start local
├── dev-stop.sh                  ← Stop local
└── [otros scripts]
```

---

## 9. Modelo de LLM Actual

**Provider:** `opencode-go`  
**Modelo primario:** `minimax-m2.7` (fallback chain configurado)

```
Primary:   minimax-m2.7
Fallback:  glm-5.1 → kimi-k2.5 → deepseek-v4-pro → deepseek-v4-flash → mimo-v2.5 → copilot/gpt-5.2 → zai
```

**Modelos locales (Ollama):**
| Modelo | Tamaño | Uso |
|--------|---------|-----|
| `qwen2.5:14b` | ~9GB | Cognee (mejor candidato) |
| `qwen2.5:7b` | ~4GB | Cognee fallback, general |
| `gemma3:12b` | ~12GB | Embeddings/text |
| `llama3.1:8b` | ~5GB | General |
| `llama3.2:3b` | ~2GB | Rápido/light |
| `nomic-embed-text:latest` | ~274MB | Embeddings vector |

---

## 10. Notas

- El proyecto usa git submodules para backend y frontend
- OWFINANCE2026 es el repo wrapper que coordina ambos
- Todos los agents usan el prefijo `/api/v1` en la API
- Auth: Token Bearer de Sanctum
- Telegram bot integrado para notificaciones

---

**Última actualización:** 2026-06-01 04:00 AM VET