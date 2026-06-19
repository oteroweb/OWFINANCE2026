# OteroWeb — Prompt de Diseño Web + Mapa de Archivos

> Documento maestro y autocontenido para construir **oteroweb.com**.
> La PARTE 2 está lista para **copiar y pegar** en v0.dev, Claude Design, Figma AI o entregar a un desarrollador. No necesita contexto extra.

---

## PARTE 1 — MAPA DE ARCHIVOS (Drive → Sección del sitio)

| Documento Drive | Alimenta | Qué extraer |
|---|---|---|
| 🧠 **Cerebro Central v3.0** | Identidad global, Hero, Sobre mí | Título (Systems Founder · DevOps + AI), posicionamiento, tagline, headline. |
| ✍️ **Narrativa de Marca v2.1** | Hero, `/historia`, tono | Los 4 actos de la historia, voz de marca, frases ancla. |
| 📋 **Sesión Pendientes Master** | (no es contenido web) | Las 8 preguntas abiertas → ver PARTE 3 "Lo que falta". |
| 🗓️ **Plan de Acción 1H Diaria** | (operativo, no web) | — |
| 🌐 **Este documento** | Todo el sitio | Prompt de diseño + arquitectura + copy final. |
| 🎨 **Brand Brief (colores/tipos)** | Sistema visual | Hex exactos, tipografía, reglas. |
| 🧪 **Casos / Portafolio (NDA-safe)** | `/` Casos, `/servicios` | 4 casos sin romper NDA. |

---

## PARTE 2 — [ COPIAR Y PEGAR ESTO EN v0.dev / CLAUDE DESIGN / FIGMA AI ]

Construye **oteroweb.com**, el sitio personal/profesional de un *Systems Founder* (DevOps + Automatización con IA). Sigue TODO lo de abajo al pie de la letra.

### 1. Quién es (contexto, no para mostrar literal)
José Luis Otero (@oteroweb). 18 años construyendo sistemas. DevOps, automatización con IA y productos propios (funda **OWFinances**, un SaaS de finanzas personales con IA). 100% remoto desde Barquisimeto, Venezuela. Mentalidad de *builder*: hace cosas, no solo habla de ellas.

**Posicionamiento (CRÍTICO):** el sitio vende por **prueba y resultado**, NO por ego. Autoridad demostrada con lo que construye (sistemas que no fallan, casos en producción, stack, building in public) — nunca con adjetivos sobre sí mismo. *Menos es más. Mostrar en vez de decir.*

### 2. Identidad visual

**Colores (hex exactos):**
| Token | Hex | Uso |
|---|---|---|
| Navy profundo | `#0D1F3C` | Fondo de secciones oscuras (hero, CTA final). |
| Verde prosperidad | `#00C896` | **Color de marca.** CTAs, highlights, datos clave, acentos. |
| Fondo claro | `#F8FAFC` | Secciones en modo claro. |
| Texto oscuro | `#1E293B` | Texto sobre fondos claros. |
| Oro acento | `#F59E0B` | Acento puntual (badges "Building in Public", 1 nodo). Muy poco. |
| Surface dark | `#13294D` | Tarjetas en modo oscuro. |
| Texto muted | `#94A3B8` | Texto secundario en oscuro. |

El **verde `#00C896` sobre navy `#0D1F3C`** es la firma. El oro casi no se usa.

**Tipografía (máx. 3 fuentes):**
- **Display / títulos:** `Space Grotesk` (700) — geométrica, precisa, tipo dev-tool. *(Inter/Poppins Bold son alternativas aceptables; Space Grotesk es la elegida.)*
- **Cuerpo:** `Inter` (400/500/600).
- **Código / técnico:** `JetBrains Mono` — eyebrows en mayúsculas con tracking, tags de stack, terminal, números tabulares, cifras de dinero.

**Escala de títulos:** Hero `clamp(46px, 7vw, 98px)`, line-height `~0.97`, letter-spacing `-2.8px`. Títulos de sección `clamp(34px, 4vw, 52px)`. Cuerpo `16–21px`. Eyebrows mono `13px / mayúsculas / tracking 2–3px / verde`.

**Referencias de estilo:** Linear.app · Vercel.com · Raycast (oscuro, nítido, dev-tool) + Nubank (premium pero accesible).

### 3. Reglas de diseño (NO negociables)
1. Usa los hex exactos, sin aproximar.
2. Máximo 3 fuentes.
3. Secciones oscuras = `#0D1F3C`; claras = `#F8FAFC`.
4. Verde `#00C896` para CTAs / highlights / datos. Oro `#F59E0B` solo como acento puntual.
5. **Mucho aire.** Padding de sección generoso (120–140px vertical). Frases cortas.
6. Radios generosos (tarjetas 18–24px, botones pill 999px). **Sin bordes 1px duros** como marco dominante — usa elevación y contraste de superficie.
7. Animaciones sutiles (fade-up al hacer scroll, 150–220ms, ease-out). Nada llamativo.
8. Elementos de estética terminal/código bienvenidos (JetBrains Mono como decoración funcional).
9. Mobile-first. Modo oscuro por defecto + toggle a claro.
10. Bilingüe ES/EN con toggle (español por defecto).

### 4. Arquitectura y copy (6 páginas)

#### `/` HOME — 6 bloques, poco texto
1. **HERO** (navy, tipografía gigante, mucho aire):
   - Eyebrow: `18 AÑOS · DEVOPS · IA · PRODUCTO`
   - Título: **"Sistemas que no se caen."** + en verde **"Software como libertad."**
   - Sub (1 línea): "Infraestructura, automatización con IA y productos que escalan. 100% remoto."
   - CTAs: `Ver los sistemas` (verde) · `Hablemos` (outline)
   - Fila de stats: **18** años de experiencia · **100%** remoto · **+12** ingenieros formados
2. **EL SISTEMA** (claro): título "Infraestructura, IA y producto como una sola pieza." A un lado, **grafo de nodos animado** (DevOps, IA, Agentes, OWFinances, CI/CD, Cloud conectados a un nodo central "JLO"). Al otro, 3 capacidades ultra-cortas con tags de stack:
   - **Infraestructura & DevOps** — "Construida para no caerse." `AWS · Kubernetes · Docker · CI/CD`
   - **Automatización con IA** — "Workflows que trabajan solos." `MCP · Agentes · n8n · Claude`
   - **Productos propios** — "SaaS que escalan." `OWFinances · OWShop`
3. **OWFINANCES** (destacado): nombre + badge oro "Building in Public". "Inteligencia financiera personal con IA propia." → "6 años con el sistema: carro, casa, y la libertad financiera en construcción. Ahora lo construyo en público." CTA `Unirme a la lista` → owfinances.com. Visual: mini-dashboard con **% de progreso de metas** (Carro 100% · Casa 100% · Libertad financiera 64%), headline "EN CAMINO A LA LIBERTAD · 87%". Nunca cifras absolutas.e a la lista` → owfinances.com. Visual: mini-dashboard (saldo `$ 12,480.50` en verde + barras de metas).
4. **CASOS / PRUEBA** (claro): título "Sistemas en producción." 4 tarjetas NDA-safe (texto de 1 línea c/u):
   - **Pipeline MCP + Slack → Deploy** — "Un mensaje dispara build, tests y deploy. Sin manos."
   - **Crawlers inmobiliarios 24/7** — "Monitoreo de portales en tiempo real, alertas estructuradas."
   - **Infraestructura CI/CD AWS + Jenkins** — "Rebuild de entrega continua, alta disponibilidad."
   - **★ Equipo de agentes IA** (destacado) — "El output de 4 personas, operado por una."
   - Debajo: **strip de stack** (chips mono): `AWS · Kubernetes · Docker · Jenkins · n8n · MCP · Claude · Python`.
5. **EN UNA LÍNEA** (reemplaza la autobiografía): "Construyo en público y ayudo a ingenieros a pasar de ejecutor a arquitecto." + link `Leer la historia →`.
6. **CTA FINAL** (navy, centrado): "¿Construimos algo?" / "Arquitectura, automatización con IA o producto." → `Escribirme` · `LinkedIn`.

#### `/historia` — narrativa en 4 actos
- **Acto I — El origen:** Barquisimeto, 2008. Sin universidad, sin mentor. Curiosidad + instinto de entender sistemas. Base técnica en electrónica/electricidad/refrigeración = mente sistémica antes del código.
- **Acto II — Los años invisibles:** Ghost developer. Infra de empresa de streaming. Reputation Stacker: reconstruyó toda la infra de deploy (Docker, CI/CD, servicios conectados). Brillante pero invisible. Lección: excelencia sin narrativa solo sirve a otros.
- **Acto III — El sistema (6 años):** Aplicó la mente sistémica a su vida. **6 años con el Método Cántaros** → carro propio + casa propia + momentos reales de libertad financiera. Hitos, nunca montos. Honesto: la **libertad financiera sostenida es su meta activa** ("en el camino", no "ya llegué"). Disciplina (gym diario, 2 años de danza = la maestría se transfiere). Constructor literal: madera, plomería, electricidad. Mentoreó ~12 ingenieros.Repara madera, plomería y electricidad con sus manos. Mentoreó ~12 ingenieros.
- **Acto IV — Ahora:** OWFinances en público. Agentes IA como equipo. Convicción: el software es la herramienta de libertad más poderosa de este siglo.

#### `/productos`
1. **OWFinances** — Inteligencia financiera personal con **IA propia** (capa propietaria, no solo API de un tercero). Modelo SaaS por suscripción. **Etapa: pre-launch — MVP en uso privado diario.** NO afirmar usuarios ni revenue. CTA: campaña **Building in Public** para early adopters → lista de espera. (El precio NO se menciona en el sitio todavía.)
2. **OWShop** — Tiendas virtuales modulares, parte del ecosistema OW. En concepto. "Próximamente." Sin CTA aún.

#### `/servicios` (3, NDA-safe, cada uno con CTA `Conversemos`)
1. **Arquitectura de Infraestructura** — "Diseño sistemas que escalan sin sorpresas. DevOps, cloud, orquestación." (Audiencia C: CTOs / técnicos senior.)
2. **Automatización con IA** — "Convierto procesos manuales en workflows autónomos. Hermes Agent, n8n, agentes." (Audiencia B: emprendedores temprana etapa.)
3. **Mentoría Técnica** — "He formado ~12 ingenieros. Te ayudo a pasar de ejecutor a arquitecto." (Audiencia D: developers que quieren crecer.)

> Los 4 segmentos de audiencia: **A** libertad financiera · **B** emprendedores etapa temprana · **C** CTOs/senior (consultoría) · **D** developers (mentoring). Cada pieza de contenido apunta a uno.

#### `/blog` (placeholder)
"Próximamente. Sistemas, automatización, finanzas personales y construir en público." 3 teaser cards:
- "Cómo reconstruí infraestructura de producción sin downtime"
- "El Método Cántaros: 6 años aplicando un sistema financiero con software"
- "IA como equipo: cómo opero como fundador en solitario"

#### `/contacto`
Formulario: Nombre + Email + Mensaje + `Enviar`. Además: LinkedIn, GitHub, Email, y redes (TikTok, Instagram). Tagline: "Respondo en menos de 48 horas."

### 5. Tono
**ES:** directo, técnicamente seguro (no arrogante), empático con el contexto LATAM, energía de *builder*. Frases cortas. Los números hablan.
**NO ES:** corporativo, plantilla de agencia, hype, autobiográfico, "yo yo yo".

| NO escribas | Escribe |
|---|---|
| "Soy un apasionado experto en…" | "18 años. Sistemas en producción." |
| "Te ofrezco soluciones innovadoras" | "Workflows que trabajan solos." |
| Párrafo largo sobre mi vida | Una línea + prueba (casos, stack). |

### 6. Reglas de contenido (de la guía de marca v3.0 — OBLIGATORIAS)
- **DINERO: siempre en PORCENTAJES, nunca cifras absolutas.** Carro, casa y la solidez financiera se mencionan como **hitos**, no con valores. Narrativa honesta: "en el camino hacia la libertad financiera sostenida", nunca "ya llegué". → El mini-dashboard de OWFinances debe mostrar **% de progreso de metas**, NO un saldo en dólares.
- **NDA:** no nombrar clientes con detalles. **Reputation Stacker** SÍ se puede nombrar (≈3 años, infra DevOps completa) **sin** revelar arquitectura propietaria.
- **OWFinances:** respetar etapa (pre-launch, MVP privado). IA propia = "diferente y específico", **no** "mejor que OpenAI". No inventar usuarios/revenue.
- **Siempre 18 años** de experiencia. Nunca títulos genéricos ("Full Stack", "Senior Engineer") → usar **Systems Founder · DevOps + AI Automation**.
- **Equipo = agentes de IA** (orquesta agentes, no contrata developers).
- Venezuela/LATAM es parte de la identidad: presente, pero no el único eje.

### 7. Técnico
Mobile-first · dark por defecto + toggle claro · ES/EN toggle (español LATAM neutro por defecto) · fade-in al scroll (sutil) · rápido (sin frameworks pesados) · accesible (focus visible, contraste AA) · SEO básico (title/meta/OG, headings semánticos).

### 8. 10 cosas que NO hacer
1. ❌ Ilustraciones de personas de stock.
2. ❌ Gradientes neón.
3. ❌ Más de 3 fuentes.
4. ❌ Aproximar colores (usa los hex).
5. ❌ Tarjetas con borde-acento a la izquierda / cajas "takeaway".
6. ❌ Texto de relleno o stats inventadas.
7. ❌ Copy autobiográfico largo en el home.
8. ❌ Emoji como iconografía del sistema.
9. ❌ Bordes 1px duros como marco dominante.
10. ❌ Plantilla genérica de agencia / portfolio.
11. ❌ **Cifras absolutas de dinero** (usar porcentajes / hitos).
12. ❌ Títulos genéricos ("Full Stack", "Senior Engineer").

### 9. Tres direcciones de hero (elegir una)
- **A — "El Sistema":** hero editorial a la izquierda + grafo de nodos. Posiciona como arquitecto-referente.
- **B — "Building in Public":** hero partido con ventana de terminal en vivo. Momentum y prueba.
- **C — "Valor":** hero centrado, mínimo. Arranca por el resultado del cliente ("Tu operación, automatizada."). Casi sin auto-referencia.

[ FIN DEL PROMPT — copiar hasta aquí ]

---

## PARTE 3 — LO QUE FALTA POR DEFINIR (pendientes antes de cerrar)

1. **Handles reales** (hoy son placeholders): TikTok, Instagram, **LinkedIn (URL)**, GitHub (¿`github.com/oteroweb`?), **email** (¿`hola@oteroweb.com`?), **teléfono**.
2. **Foto profesional** para `/historia` y `/contacto` (hoy hay placeholder "JLO").
3. **Dirección de hero ganadora** (A / B / C) para construir las páginas internas.
4. **Dominio de correo** y formulario de contacto (¿a qué inbox llega?).
5. **CTA OWFinances:** ¿link directo a owfinances.com o captura de email aquí?
6. **Arreglo aplicado ✅:** el mini-dashboard de OWFinances ya muestra **% de progreso de metas** (87% · progreso general), no cifras absolutas.

> Ya resuelto: ✅ mini-dashboard ahora muestra **87% · progreso general** (porcentajes, no cifras).

> Ya NO pendiente: precio del SaaS (no se menciona), idioma por defecto (español confirmado).
