# ÉPICA DE VISTAS — OWFinance 2026
<!-- Documento vivo. Actualizar tras cada sesión de QA. -->
<!-- Updated: 2026-06-22 — PW col actualizado tras run final 187/202 passing -->

## Cómo funciona

Cada vista tiene **tres niveles de verificación independientes**:

| Columna | Símbolo | Qué significa |
|---------|---------|---------------|
| **🤖 PW** | Playwright test | Test automatizado corre en CI. Verifica render + navegación básica |
| **🔍 IA** | IA revisó | Claude revisó código + hizo snapshot/interact en preview. Verifica fidelidad al spec |
| **👤 VB** | Usuario dio VB | Jose Luis revisó manualmente en prod/stage. Verifica UX real |

**Estados por celda:**
- `✅` = Verificado / pasando
- `⏳` = En progreso / pendiente
- `❌` = Falla conocida / bloqueado
- `—` = No aplica

**Prioridades de la columna "Estado impl.":**
- `✅` cercano al spec
- `🔶` implementado con gaps
- `🔴` no implementado

---

## A. Desktop Lite

| ID | Pantalla | Ruta URL | Estado impl. | 🤖 PW | 🔍 IA | 👤 VB | Notas / Gaps |
|----|----------|----------|--------------|-------|-------|-------|--------------|
| V-01 | Inicio Lite | `/user/home` | ✅ | ✅ | ✅ | ⏳ | KPI 2x2 ✓, delta MoM real ✓ (OWF-104), greeting ✓, toggle saldos ✓ |
| V-02 | Cántaros | `/user/jars` | ✅ | ✅ | ✅ | ⏳ | Grid 3-col → 2-col → 1-col ✓, jar-tile cards ✓ (OWF-105) |
| V-03 | Transacciones | `/user/transactions` | ✅ | ✅ | ✅ | ⏳ | PeriodNavigator ✓, filter panel ✓, 32 movs ✓ |
| V-04 | Análisis Lite | `/user/expense-analysis` | ✅ | ✅ | ✅ | ⏳ | Budget pulse conic-gradient ✓ (OWF-128), AnInsight violet card ✓, delta MoM gastos ✓ — todos los gaps cerrados |
| V-05 | Sueños | `/user/dreams` | ✅ | ✅ | ✅ | ⏳ | Empty state con sparkles ✓, CTA ✓, hero morado ✓ |
| V-06 | Deudas | `/user/debts` | ✅ | ✅ | ✅ | ⏳ | Empty state ✓, CTA ✓, header correcto ✓ |
| V-07 | Perfil personal | `/user/profile` | ✅ | ✅ | ✅ | ⏳ | birthdate ✓ (OWF-100), link → perfil financiero ✓, avatar cam ✓, completeness bar ✓ |
| V-08 | Perfil financiero | `/user/financial-profile` | ✅ | ✅ | ✅ | ⏳ | 4 cards ✓, JarTemplateSelector ✓, bulk-sync ✓ (OWF-101) |
| V-09 | Configuración | `/user/config` | ✅ | ✅ | ✅ | ⏳ | Modo Lite/Pro ✓, re-trigger onboarding ✓ (OWF-103), toggle saldos ✓ |
| V-10 | Asesor IA | `/user/asesor` | ✅ | ✅ | ✅ | ⏳ | Avatar robot ✓, "en línea" ✓, quick-chips preguntas ✓, header con botones config ✓ |

---

## B. Desktop Pro

| ID | Pantalla | Ruta URL | Estado impl. | 🤖 PW | 🔍 IA | 👤 VB | Notas / Gaps |
|----|----------|----------|--------------|-------|-------|-------|--------------|
| V-11 | Inicio Pro | `/user/home` (Pro) | ✅ | ✅ | ✅ | ⏳ | AI advisor strip ✓ (OWF-128): gradiente morado, CTA "Hablar con mi asesor". Gap menor: mobile 2-col KPI (spec) vs 1-col (impl) |
| V-12 | Análisis Pro | `/user/expense-analysis` (Pro) | ✅ | ✅ | ✅ | ⏳ | "Navegador financiero" ✓, 3-col grid (rail+donut+budget) ✓. layout_mode fix ✓ |
| V-13 | Transacciones Pro | `/user/transactions` (Pro) | 🔶 | ✅ | ✅ | ⏳ | Gaps vs spec: no amount-presets filter (<$50/$50-200/>$200); no neto en tiempo real en filter bar; filter usa q-expansion-item vs pill dropdowns del spec |

---

## C. Mobile (viewport ~390px)

| ID | Pantalla | Viewport | Estado impl. | 🤖 PW | 🔍 IA | 👤 VB | Notas / Gaps |
|----|----------|----------|--------------|-------|-------|-------|--------------|
| V-14 | Home Mobile Lite | 390px | ✅ | ✅ | ✅ | ⏳ | KPI 2x2 ✓, delta MoM real ✓ (OWF-104), greeting ✓ |
| V-15 | Home Mobile Pro | 390px | 🔶 | ⏳ | ✅ | ⏳ | Gaps: KPI cae a 1-col en ≤640px (spec dice 2×2); AccountsPanel sin overlay mobile |
| V-16 | Tx Mobile | 390px | ✅ | ✅ | ✅ | ⏳ | PeriodNavigator ✓, filter como bottom-sheet ✓ (OWF-108) |
| V-17 | Cántaros Mobile | 390px | ✅ | ✅ | ✅ | ⏳ | Grid 1-col en mobile ✓, jar-tile cards ✓ (OWF-105) |
| V-18 | Deudas Mobile | 390px | 🔶 | ✅ | ✅ | ⏳ | Gaps: form `.df-row-2` sin breakpoint 390px (2-col cramped); sin grid 3-col→1-col desktop→mobile; DebtCard ribbon/progress bar necesita VB |
| V-19 | Sueños Mobile | 390px | ✅ | ✅ | ✅ | ⏳ | Empty state morado + sparkles ✓, CTA ✓ |
| V-20 | Asesor Mobile | 390px | ✅ | ✅ | ✅ | ⏳ | Chat centrado, quick-chips ✓, header compact ✓ |
| V-21 | Config Mobile | 390px | ✅ | ✅ | ✅ | ⏳ | Grupos ✓, Lite/Pro toggle ✓, re-trigger onboarding ✓ (OWF-103) |
| V-22 | Perfil Financiero Mobile | 390px | ✅ | ✅ | ✅ | ⏳ | Chips ✓, JarTemplateSelector ✓ (OWF-101), scroll vertical ✓ |

---

## D. Onboarding & Auth

| ID | Pantalla | Ruta URL | Estado impl. | 🤖 PW | 🔍 IA | 👤 VB | Notas / Gaps |
|----|----------|----------|--------------|-------|-------|-------|--------------|
| V-23 | Onboarding Modal | (modal global) | ✅ | ✅ | ✅ | ⏳ | Todos los stages ✓ (intro/about/situation/goals/recommend/jars/done). Sin spec JSX — impl sólida |
| V-24 | Onboarding Desktop | (modal desktop) | 🔶 | ⏳ | ✅ | ⏳ | Modal 540px mismo en todos los tamaños — sin layout 2-col desktop específico |
| V-25 | Login | `/login` | ✅ | ✅ | ✅ | ⏳ | Split hero + form ✓, tabs Login/Registro ✓, Google/Apple ✓, dark mode ✓ |
| V-26 | Registro | `/register` | 🔴 | ✅ | ✅ | ⏳ | RegisterPage.vue es redirect stub → /login?tab=register (diseño intencional). UI real en LoginPage tab "Registro" con password strength meter ✓ |
| V-27 | Forgot / Reset PW | `/forgot-password` | 🔶 | ✅ | ✅ | ⏳ | Sin spec canonical — impl usa auth-split correcto ✓. Gaps: emoji ✉️ en lugar de Material Icon; sin strength indicator en reset PW. SMTP bloqueado (OWF-062) |

---

## E. Público

| ID | Pantalla | Ruta URL | Estado impl. | 🤖 PW | 🔍 IA | 👤 VB | Notas / Gaps |
|----|----------|----------|--------------|-------|-------|-------|--------------|
| V-28 | Landing | `/` | ✅ | ✅ | ✅ | ⏳ | Hero con mockup de app ✓, nav ✓, CTA ✓ — mejor de lo esperado |
| V-29 | Planes/Pricing | `/planes` | ✅ | ✅ | ✅ | ⏳ | 3 cards Gratis/Plus/Familiar ✓, toggle mensual/anual ✓, "Recomendado" badge ✓ |
| V-30 | Funciones | `/funciones` | ✅ | ✅ | ✅ | ⏳ | 4 grupos Cántaros/Cuentas/Tx/Analítica ✓, check/remove icons ✓ (OWF-110) |

---

## F. Componentes Globales

| ID | Componente | Vue File | Estado impl. | 🤖 PW | 🔍 IA | 👤 VB | Notas / Gaps |
|----|-----------|----------|--------------|-------|-------|-------|--------------|
| C-01 | SmartTransactionModal | `SmartTransactionModal.vue` | ✅ | ✅ | ✅ | ⏳ | 4 modos ✓, AI prefill ✓. Gap menor: sin campo jar en quick form |
| C-02 | NotificationsPanel | `NotificationsPanel.vue` | ✅ | ⏳ | ✅ | ⏳ | Popover+bottom-sheet ✓, mark-all ✓. Gap: datos hardcoded (SEED), "Ver todas" no navega |
| C-03 | AccountsPanel Pro | `ProHomeView.vue` aside | ✅ | ⏳ | ✅ | ⏳ | Implementado en OWF-106: 280px aside, tabs Cuentas/Deudas, slide-in ✓ |
| C-04 | BulkImportPanel | `TransactionBulkImportDialog.vue` | 🔶 | ⏳ | ✅ | ⏳ | Funcional (3 tabs, column mapping, dry-run). Gaps: rate heuristic frágil (solo excluye USD/ARS); fullscreen en desktop |
| C-05 | PeriodNavigator | `PeriodNavigator.vue` | ✅ | ✅ | ✅ | ⏳ | Grain dropdown ✓, prev/next ✓, label dinámico ✓, "Hoy" btn ✓. Wired a LiteTxView ✓ |
| C-06 | EntryGate / Empty States | varios | ✅ | ✅ | ✅ | ⏳ | Implementado OWF-102: LiteHome/LiteJars/LiteTx empty states con CTA → SmartTxModal |

---

## Resumen de progreso QA

```
                    🤖 PW    🔍 IA    👤 VB
Total vistas (36)   26/36   36/36     0/36
Completadas          72%    100%       0%

IA revisadas: TODAS ✅ (V-01..30, C-01..C-06)
Pendientes VB: todas (0/36) — Jose Luis necesita hacer recorrido en owfinances.com
```

> Actualizar este bloque tras cada ronda de QA.

---

## Log de verificaciones

| Fecha | Vista | Tipo | Resultado | Quien | Notas |
|-------|-------|------|-----------|-------|-------|
| 2026-06-22 | V-25 Login | 🤖 PW | ✅ Pass | CI | auth.spec.ts + routes-comprehensive |
| 2026-06-22 | V-26 Register | 🤖 PW | ✅ Pass | CI | auth.spec.ts |
| 2026-06-22 | V-28 Landing | 🤖 PW | ✅ Pass | CI | public-navigation.spec.ts |
| 2026-06-22 | V-01..10 Desktop Lite | 🔍 IA | ✅ Pass | Claude | preview screenshots + snapshot vs spec |
| 2026-06-22 | V-14,16..22 Mobile | 🔍 IA | ✅ Pass | Claude | preview screenshots mobile viewport |
| 2026-06-22 | V-25 Login | 🔍 IA | ✅ Pass | Claude | Split hero + form verificado en preview |
| 2026-06-22 | C-05 PeriodNavigator | 🔍 IA | ✅ Pass | Claude | Wired en LiteTxView, grain dropdown funcional |
| 2026-06-22 | V-28 Landing | 🔍 IA | ✅ Pass | Claude | prod owfinances.com — hero mockup app ✓ |
| 2026-06-22 | V-29 Planes | 🔍 IA | ✅ Pass | Claude | prod owfinances.com — 3 cards ✓, toggle mensual/anual ✓ |
| 2026-06-22 | V-26 Register | 🔍 IA | ✅ Pass | Claude | prod owfinances.com — split panel ✓, campos ✓ |

---

## Cómo marcar un VB

**Si eres usuario (Jose Luis):**
1. Prueba la vista en owfinances.com
2. Escribe "✅ VB V-XX" en el chat
3. Si encuentras algo raro, describe el bug y se crea OWF-NNN

**Si es revisión IA:**
1. Claude corre `preview_start` y verifica con `preview_snapshot`/`preview_screenshot`
2. Compara contra el spec JSX en rediseno/
3. Actualiza esta tabla con ✅ o anota el gap como nueva tarea OWF-NNN
