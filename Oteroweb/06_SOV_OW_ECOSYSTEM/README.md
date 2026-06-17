# SOV-OW — Sistema Operativo de Vida Personal con IA

> Proyecto transversal @oteroweb · En producción activa · Beta privada
> Stack: Hermes Agent v0.14.0 · Python 3.14 · Telegram · MacBook Pro M5 (servidor local)

---

## ¿Qué es SOV-OW?

SOV-OW no es un chatbot. No es un asistente genérico. Es un **sistema operativo de vida personal** — un ecosistema de **13 agentes IA especializados** que comparten memoria semántica, contexto cruzado y orquestación centralizada, diseñado para gestionar TODOS los aspectos de la vida de una persona: finanzas, salud, emociones, hogar, desarrollo, productividad y más.

Opera 24/7 en un MacBook Pro M5 como servidor local, con Telegram como interfaz principal.

**El diferencial técnico clave:** ningún asistente personal en el mercado tiene memoria auto-aprendible que conecta finanzas con salud con emociones con productividad en tiempo real.

---

## Arquitectura General

```
JOSE (CEO)
  └── COACH CENTRAL / SUPERASESOR (Orquestador Level 1)
        ├── AGENT_STATUS.md — dashboard vivo
        ├── 11 Cron Jobs de automatización
        └── Distribuye a 12 especialistas ↓

  Especialistas (Level 2):
  ├── 💰 OWFINANCE       — Finanzas, cántaros, tasas, presupuesto
  ├── 💪 FIT-NUTRITION   — Proteína, entrenamiento, macros
  ├── 😴 BIO-HACKING     — Sueño, ciclos circadianos, suplementos
  ├── 💆 EMOCIONAL       — Tracking ánimo, escucha, patrones
  ├── 🏠 DOMESTICO       — Inventario, mantenimiento, vehículo
  ├── 💻 DEV SQUAD       — Laravel/Vue3, OWFinance app, deployments
  ├── 🗒️ PLANIFICADOR    — Tiempo, metas, prioridades diarias
  ├── ⚡ PRODUCTIVIDAD   — Ejecución momento a momento
  ├── ⚙️ CONFIGURADOR    — Sistema, infra, backups
  ├── 🧠 MEMORIA         — Bitácora, archivo, búsqueda semántica
  ├── 🎯 SUEÑOS Y METAS  — Visión largo plazo
  └── 🤝 CONCIENCIA      — Compañero holístico, check-in
```

---

## Arquitectura de Memoria — 3 Capas (Blackboard)

```
CAPA 3 — SEMÁNTICA:   Cognee (grafo 1,030 nodos / 1,546 edges) + LanceDB (vectores 551+ chunks)
CAPA 2 — BLACKBOARD:  context/shared/ — 70 archivos de coordinación inter-agente
CAPA 1 — GROUND TRUTH: context/ + memory/vault/ — Markdown como fuente de verdad
```

**Protocolo obligatorio:** Cada agente lee 7 archivos compartidos ANTES de responder, garantizando que todos tengan el mismo contexto del usuario en todo momento.

---

## Los 13 Agentes — Detalle

| # | Agente | Dominio | Qué hace |
|---|--------|---------|----------|
| 1 | Coach Central | Orquestación | CEO Briefing matutino, distribución, status checks, vaciado de vida |
| 2 | OWFinance | Finanzas | Sistema cántaros (12 jars), tasa BCV/P2P, flujo de caja, Google Sheets sync |
| 3 | Fit-Nutrition | Salud física | 150g proteína/día, pesos crudo/cocido, macros USDA, diseño de rutinas |
| 4 | Bio-Hacking | Sueño/optimización | Ciclos circadianos, HRV, suplementos, protocolos de descanso |
| 5 | Emocional | Salud emocional | Tracking ánimo, patrones, escucha activa — sin lenguaje CEO |
| 6 | Doméstico | Hogar/auto | Inventario, mantenimiento, reparaciones, presupuesto hogar |
| 7 | Dev Squad | Desarrollo | Laravel/Vue3, OWFinance local+remoto, ReputationStacker, MCP, Stitch |
| 8 | Planificador | Organización | Metas→bloques de tiempo, priorización, sprint planning |
| 9 | Productividad | Ejecución | Divide jornada en bloques, tracking momento a momento |
| 10 | Configurador | Sistema/infra | Crear agentes, backups, diagnósticos, updates, voice bridge |
| 11 | Memoria | Archivo | Bitácora diaria, búsqueda semántica, consolidación |
| 12 | Sueños y Objetivos | Visión | Mapa de sueños, conexión visión-acción, retrospectivas |
| 13 | Conciencia | Compañía | Check-in holístico, acceso a todos los dominios, apoyo emocional |

---

## Stack Técnico Completo

```yaml
Runtime:         Hermes Agent v0.14.0 → Python 3.14 → Telegram Bot API
LLM Principal:   MiniMax M2.7 (OpenCode Go)
Fallback Chain:  GLM-5.1 → Kimi K2.5 → Qwen 3.6 Plus → DeepSeek V4 Pro → DeepSeek V4 Flash → MiMo V2.5 → GPT-5.2
Vision:          Ollama gemma3:12b (100% local, 8.1GB)
TTS:             Edge TTS es-VE-SebastianNeural (gratuito, offline)
Embeddings:      nomic-embed-text (768 dim, Ollama local)
Memoria:         Cognee + LanceDB — 1,030 nodos, 1,546 edges
Base de datos:   SQLite + LanceDB + Google Sheets (OWFinance)
Idioma:          100% español venezolano
Hardware:        MacBook Pro M5 (servidor local 24/7)
Interfaz:        Telegram (10 grupos especializados)
```

---

## 124 Archivos de Contexto

```
context/shared/    — 70 archivos (USER.md, CURRENT_STATE, KNOWLEDGE_GRAPH, GOALS_AND_PATTERNS, EVENTS, FACTS, AGENT_STATUS)
context/health/    — 16 archivos (nutrición, ejercicio, suplementos)
context/finance/   — 16 archivos (cántaros, tasas, flujo de caja)
context/dev/       — 7 archivos (OWFinance app, ReputationStacker)
context/domestico/ — 3 archivos (hogar, vehículo)
memory/vault/      — 22 archivos (diario, bitácora)
```

**Datos históricos importados:**
- 1,870 conversaciones de Gemini (Oct 2024 → May 2026)
- 854 mensajes de WhatsApp
- Distribuidos en 4 dominios: Salud (912) · Dev (2,114) · Finanzas (1,249) · Personal (285)

---

## 11 Automatizaciones Cron

| Automatización | Frecuencia | Función |
|---------------|------------|---------|
| CEO Briefing | Diario 6AM | Resumen consolidado de todos los agentes |
| Health Check | Diario 8AM | Valida logs, crea entries CRITICAL |
| Tasa BCV/P2P | 4×/día | Monitorea spread y alerta si sube >3pts |
| Binance P2P | Cada 30min | Rate P2P en tiempo real |
| Análisis Financiero | Semanal Dom 6PM | Gasto patterns, cántaros, investment opps |
| Portafolio Trading | Sábado 6PM | Prices, bot ranges, performance |
| Dropshipping | Martes 10AM | 5+ productos virales, evalúa márgenes |
| Message Tracker | Cada 5min | Detecta mensajes huérfanos sin respuesta |
| Message Watchdog | Cada 1h | Reinyecta mensajes pendientes |
| Message Cleaner | Diario 4AM | Limpieza de registros viejos |
| Cognee Nocturno | Diario 3AM | Re-indexa knowledge graph semántico |

---

## Comunicación Inter-Agente (Hub & Spoke)

```
1. Agente detecta hecho que afecta otro dominio
2. Escribe en FACTS/{fecha}.md con tagged destination
3. Escribe en EVENTS/{fecha}.md con solicitud formal → @agente
4. Coach Central lee EVENTS y rutea al especialista correcto
5. Especialista actúa y marca ✅ procesado

Ejemplo real:
  Emocional detecta mal sueño
    → escribe FACTS + EVENTS
    → @bio-hacking: mala noche
    → @fit-nutrition: posible SKIP de entrenamiento hoy
```

---

## Herramientas y Scripts (16+)

- **Voice Bridge Mood** — PWA de voz con inyección de contexto emocional (FastAPI + Whisper + Edge TTS)
- **Model Switcher** — Web UI para cambiar provider/modelo/fallbacks en tiempo real
- **OWFinance Google Sheets Sync** — Sincronización bidireccional
- **P2P Monitor** — Monitoreo en tiempo real de tasa Binance P2P
- **Tasa Monitor** — Tracking de tasa BCV oficial
- **Grid Bot Simulator** — Simulación de trading en Binance
- **Paper Trading Bot** — Trading experimental con capital simulado
- **Message Tracker** — Sistema de tracking y reintento de mensajes
- **OCR Swift** — Reconocimiento de texto en imágenes (100% local)
- **Cognee Scripts** — Pipeline de importación y búsqueda semántica (7 scripts)
- **Google Takeout Parser** — Importar historial de Gemini/WhatsApp

---

## Formato de Respuesta v4 (Dual Voice)

Cada agente responde en formato estandarizado:
1. **Audio corto** (1-2 frases, voice bubble inmediato)
2. **Audio largo** (detalle completo, voice bubble)
3. **Texto estructurado:** Corto: + Largo: + 🔑 Detalle 1 + 🔑 Detalle 2

---

## Posicionamiento Público — SOV-OW como Proyecto Transversal

### ¿Qué es públicamente mostrable?

| Componente | Mostrable | Notas |
|------------|-----------|-------|
| Arquitectura multi-agente | ✅ Sí | Diagrama técnico, sin datos personales |
| Stack técnico | ✅ Sí | Hermes, LLMs, LanceDB, Cognee |
| Cron jobs y automatizaciones | ✅ Sí | Sin contenido de los mensajes |
| Blackboard architecture | ✅ Sí | Diseño de 3 capas |
| Agente OWFinance | ✅ Sí | Método Cántaros, solo % |
| Voice Bridge | ✅ Sí | Demo sin datos reales |
| Datos emocionales/personales | ❌ No | Privacidad total |
| Conversaciones históricas | ❌ No | NDA + privacidad |
| Datos financieros reales | ❌ No | Solo porcentajes |

### Narrativa Pública

> "Construí un sistema operativo de vida personal con 13 agentes IA especializados que comparten memoria y se coordinan en tiempo real. Lo uso diariamente para gestionar finanzas, salud, desarrollo y productividad. Es el mismo tipo de arquitectura que ofrezco como consultor — probada en producción real."

### Potencial Comercial

**Funcionalidades únicas en el mercado:**
- Sistema de cántaros con tracking dual (Bs + USD)
- Cross-domain awareness real (salud afecta finanzas afecta emociones)
- Blackboard architecture con 124 archivos de contexto compartido
- Knowledge graph auto-aprendible — memoria que crece sola
- 11 automatizaciones cron 24/7
- Voice bridge con inyección de contexto emocional
- Sistema de mensajes huérfanos con reintento automático

**Modelo de monetización propuesto:**
- SaaS: $15–40/mes — suscripción al ecosistema completo
- Desarrollo modular: $200–500/proyecto — agentes a medida
- Consultoría de arquitectura: tarifa por hora

**Roadmap para lanzamiento público:**
- [ ] Landing page / pitch deck
- [ ] Onboarding wizard (configuración guiada)
- [ ] Dashboard web (actualmente solo Telegram)
- [ ] Sistema de billing (Stripe/PayPal)
- [ ] Multi-usuario (actualmente single-user)
- [ ] Privacy framework (GDPR/LOPD)
- [ ] Documentación de API para developers

---

## Conexión con la Marca @oteroweb

SOV-OW no es un proyecto separado — es el **meta-proyecto** que prueba todo lo que @oteroweb afirma:

| Lo que afirmo | Prueba que lo demuestra |
|---------------|------------------------|
| "Orquesto agentes IA como equipo" | SOV-OW: 13 agentes coordinados 24/7 |
| "Sistemas que trabajan mientras duermo" | 11 cron jobs + servidor local permanente |
| "IA real, no wrappers" | Blackboard + Cognee + LanceDB propios |
| "El output de 4-6 personas" | Un solo operador, cobertura total de vida |
| "Libertad financiera en construcción" | OWFinance agent + Método Cántaros en tiempo real |
| "18 años de sistemas" | La arquitectura refleja criterio acumulado real |

**Contenido generado por SOV-OW:**
- Reflexiones reales del Coach Central → material para posts
- Patrones detectados por el sistema → insights auténticos para audiencia
- El proceso de construcción de SOV-OW → storytelling técnico inigualable en LATAM

---

*Versión: 1.0 | Junio 2026 | Clasificación: Referencia pública parcial*
