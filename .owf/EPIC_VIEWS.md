# ÉPICA DE VISTAS — OWFinance 2026
<!-- Documento vivo. Actualizar tras cada sesión de QA. -->
<!-- Updated: 2026-06-22 -->

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
| V-01 | Inicio Lite | `/user/home` | 🔶 | ⏳ | ✅ | ⏳ | KPI 2x2 ✓, categorías ✓, cántaros list ✓. Falta delta MoM (OWF-104) |
| V-02 | Cántaros | `/user/jars` | 🔶 | ⏳ | ✅ | ⏳ | Rainbow bar ✓, lista con % ✓. Spec pide grid 2-3 col (OWF-105) |
| V-03 | Transacciones | `/user/transactions` | ✅ | ⏳ | ✅ | ⏳ | PeriodNavigator ✓, eyebrow ✓, filter panel ✓, 32 movs listados ✓ |
| V-04 | Análisis Lite | `/user/expense-analysis` | 🔶 | ⏳ | ✅ | ⏳ | Controles compactos ✓, KPI 3-col ✓. Falta donut visual + insight IA |
| V-05 | Sueños | `/user/dreams` | ✅ | ⏳ | ✅ | ⏳ | Empty state con sparkles ✓, CTA ✓, hero morado ✓ |
| V-06 | Deudas | `/user/debts` | ✅ | ⏳ | ✅ | ⏳ | Empty state ✓, CTA ✓, header correcto ✓ |
| V-07 | Perfil personal | `/user/profile` | 🔶 | ⏳ | ✅ | ⏳ | Completado 50% bar ✓, campos nombre/ocupación/ingreso ✓. Teléfono presente ✓. Falta birthdate + link → perfil financiero (OWF-100) |
| V-08 | Perfil financiero | `/user/financial-profile` | 🔶 | ⏳ | ✅ | ⏳ | Chips seleccionables ✓, secciones Quién soy + Situación ✓. Falta JarTemplateSelector (OWF-101) |
| V-09 | Configuración | `/user/config` | 🔶 | ⏳ | ✅ | ⏳ | Modo Lite/Pro ✓, Tema toggle ✓, Ocultar saldos ✓, links a sub-páginas ✓. Falta re-trigger onboarding (OWF-103) |
| V-10 | Asesor IA | `/user/asesor` | ✅ | ⏳ | ✅ | ⏳ | Avatar robot ✓, "en línea" ✓, quick-chips preguntas ✓, header con botones config ✓ |

---

## B. Desktop Pro

| ID | Pantalla | Ruta URL | Estado impl. | 🤖 PW | 🔍 IA | 👤 VB | Notas / Gaps |
|----|----------|----------|--------------|-------|-------|-------|--------------|
| V-11 | Inicio Pro | `/user/home` (Pro) | 🔶 | ⏳ | ⏳ | ⏳ | KPI grid OK. Falta: AccountsPanel lateral (OWF-106) |
| V-12 | Análisis Pro | `/user/expense-analysis` (Pro) | ✅ | ⏳ | ⏳ | ⏳ | 3-col grid rail+donut+budget OK. Deploy prod ✓ |
| V-13 | Transacciones Pro | `/user/transactions` (Pro) | 🔶 | ⏳ | ⏳ | ⏳ | AccountFilter multi-select ✓. Panel derecho AccountsPanel falta |

---

## C. Mobile (viewport ~390px)

| ID | Pantalla | Viewport | Estado impl. | 🤖 PW | 🔍 IA | 👤 VB | Notas / Gaps |
|----|----------|----------|--------------|-------|-------|-------|--------------|
| V-14 | Home Mobile Lite | 390px | 🔶 | ⏳ | ✅ | ⏳ | KPI 2x2 correcto en mobile ✓. Categorías y cántaros list ✓. Falta delta MoM (OWF-104) |
| V-15 | Home Mobile Pro | 390px | 🔶 | ⏳ | ⏳ | ⏳ | Sin verificar — requiere usuario Pro |
| V-16 | Tx Mobile | 390px | ✅ | ⏳ | ✅ | ⏳ | PeriodNavigator compact ✓, lista 32 movs ✓, botón Filtros ✓. Filter como overlay (OWF-108 bottom-sheet pendiente) |
| V-17 | Cántaros Mobile | 390px | 🔶 | ⏳ | ✅ | ⏳ | Rainbow bar ✓, lista con % ✓. Grid spec pendiente (OWF-105) |
| V-18 | Deudas Mobile | 390px | ✅ | ⏳ | ✅ | ⏳ | Empty state correcto, CTA funcional ✓ |
| V-19 | Sueños Mobile | 390px | ✅ | ⏳ | ✅ | ⏳ | Empty state morado + sparkles ✓, CTA ✓ |
| V-20 | Asesor Mobile | 390px | ✅ | ⏳ | ✅ | ⏳ | Chat centrado, quick-chips ✓, header compact ✓ |
| V-21 | Config Mobile | 390px | 🔶 | ⏳ | ✅ | ⏳ | Grupos ✓, Lite/Pro toggle ✓. Falta re-trigger onboarding (OWF-103) |
| V-22 | Perfil Financiero Mobile | 390px | 🔶 | ⏳ | ✅ | ⏳ | Chips ✓, scroll vertical ✓. Falta JarTemplateSelector (OWF-101) |

---

## D. Onboarding & Auth

| ID | Pantalla | Ruta URL | Estado impl. | 🤖 PW | 🔍 IA | 👤 VB | Notas / Gaps |
|----|----------|----------|--------------|-------|-------|-------|--------------|
| V-23 | Onboarding Modal | (modal global) | 🔶 | ⏳ | ⏳ | ⏳ | Intro stage ✓ (OWF-097). Falta: recommend stage con plan IA (OWF-107) |
| V-24 | Onboarding Desktop 2-col | (modal desktop) | 🔶 | ⏳ | ⏳ | ⏳ | Spec tiene layout 2-col (form\|preview). Tenemos 1-col centrado |
| V-25 | Login | `/login` | ✅ | ✅ | ✅ | ⏳ | Split hero + form ✓, tabs Login/Registro ✓, Google/Apple ✓, dark mode ✓ |
| V-26 | Registro | `/register` | 🔶 | ✅ | ⏳ | ⏳ | Funcional. Falta: password strength meter visual |
| V-27 | Forgot / Reset PW | `/forgot-password` | 🔶 | ⏳ | ⏳ | ⏳ | Código listo. SMTP prod bloqueado (OWF-062) |

---

## E. Público

| ID | Pantalla | Ruta URL | Estado impl. | 🤖 PW | 🔍 IA | 👤 VB | Notas / Gaps |
|----|----------|----------|--------------|-------|-------|-------|--------------|
| V-28 | Landing | `/` | 🔶 | ✅ | ⏳ | ⏳ | Funcional. Hero sin mockup de la app (OWF-109) |
| V-29 | Planes/Pricing | `/planes` | 🔶 | ⏳ | ⏳ | ⏳ | Tabla básica. Spec tiene comparativa detallada (OWF-110) |
| V-30 | Matriz Lite/Pro | `/matrix` | 🔶 | ⏳ | ⏳ | ⏳ | Fidelidad baja vs spec |

---

## F. Componentes Globales

| ID | Componente | Vue File | Estado impl. | 🤖 PW | 🔍 IA | 👤 VB | Notas / Gaps |
|----|-----------|----------|--------------|-------|-------|-------|--------------|
| C-01 | SmartTransactionModal | `SmartTransactionModal.vue` | 🔶 | ⏳ | ⏳ | ⏳ | 4 modos (Escribir/Voz/Foto/AutoIA). Foto OCR básico |
| C-02 | NotificationsPanel | `NotificationsPanel.vue` | ✅ | ⏳ | ⏳ | ⏳ | Popover desktop + bottom-sheet mobile |
| C-03 | AccountsPanel Pro | — | 🔴 | — | — | — | No implementado. Panel derecho ProShell (OWF-106) |
| C-04 | BulkImportPanel | `TransactionBulkImportDialog.vue` | 🔶 | ⏳ | ⏳ | ⏳ | Funcional. Spec tiene drag-and-drop más elaborado |
| C-05 | PeriodNavigator | `PeriodNavigator.vue` | ✅ | ⏳ | ✅ | ⏳ | Grain dropdown ✓, prev/next ✓, label dinámico ✓, "Hoy" btn ✓. Wired a LiteTxView ✓ |
| C-06 | EntryGate / Empty States | — | 🔴 | — | — | — | No implementado. Pantalla usuario sin datos (OWF-102) |

---

## Resumen de progreso QA

```
                    🤖 PW    🔍 IA    👤 VB
Total vistas (36)    3/36    18/36     0/36
Completadas           8%      50%       0%

IA revisadas: V-01..10, V-14, V-16..22, V-25, C-05
Pendientes IA: V-11..13 (Pro), V-15 (Pro), V-23..24 (Onboarding modal),
               V-26..30, C-01..C-04, C-06
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
