# OWFINANCE — Estado del Workspace
<!-- PROTOCOLO: Todo agente LEE este archivo al iniciar sesion. -->
<!-- Solo un agente escribe a la vez. Updated = timestamp del ultimo escritor. -->
<!-- Tareas se referencian por ID (OWF-NNN) → ver .owf/TASKS.md -->

**Updated:** 2026-06-19T23:00:00Z
**By:** claude-code

---

## En Progreso RIGHT NOW

| ID | Tarea | Agente | Progreso | Detalle |
|----|-------|--------|----------|---------|
| — | — | — | — | Sin tareas activas |

---

## Sesión 2026-06-19 (parte 2) — Tareas completadas

| OWF | Que hizo |
|-----|----------|
| OWF-018 | ✅ NaN% fix MonthlyIncomePanel + responsive 320-375px: Number.isFinite guards en useCalculatedIncome + computeds |
| OWF-019 | ✅ i18n: useI18n en BottomNavMobile + nav.dreams en ES/EN locales |
| OWF-021 | ✅ Monitoring: Sentry boot (VITE_SENTRY_DSN) + useFeatureFlags composable (VITE_FF_*) |
| OWF-022 | ✅ Android: capacitor.config.js + build:android script en package.json |

## Sesión 2026-06-19 — Tareas completadas

| OWF | Que hizo |
|-----|----------|
| OWF-008 | ✅ Transición Lite↔Pro: AppShell reactivo + config toggle PATCH /user/settings |
| OWF-009 | ✅ Rutas Pro: alias /user/settings, BottomNavMobile 5 tabs 1 fila (no-wrap) |
| OWF-010 | ✅ Playwright ESM config + baseURL + skip guards en todos los tests con auth |
| OWF-012 | ✅ Password Reset: ForgotPasswordPage + ResetPasswordPage + backend routes |
| OWF-016 | ✅ Redirect por rol ya estaba en router beforeEach |
| OWF-017 | ✅ Rutas públicas ok: PHP proxy sirve / → Vue / → LandingPage. Tests pasan prod |
| OWF-028 | ✅ Nav Pro mobile: eliminados 7→5 tabs, no flex-wrap |
| OWF-049 | ✅ Cántaros con descripción: tipo, mkJar, loadJarData, bulk-sync, UI textarea |
| OWF-011 | ✅ UI Configuración Asesor IA: dialog bottom-sheet nombre+personalidad+enabled |
| OWF-013 | ✅ GitHub Actions deploy.yml: master→prod, stage→staging con secrets |
| OWF-055 | ✅ Integración rediseño → AppShell único |
| OWF-056 | ✅ AppShell.vue: shell único Lite+Pro+Mobile |
| OWF-057 | ✅ AppPrefsSection en Config |
| OWF-058 | ✅ HomeView datos reales |
| OWF-059 | ✅ Onboarding automático en AppShell |
| OWF-060 | ✅ Limpieza layouts legacy |

---

## Pending (por prioridad)

| ID | Pri | Tarea | Type |
|----|-----|-------|------|
| OWF-004 | P0 | Deploy Staging (desbloqueado) | infra |
| OWF-005 | P1 | GitHub Secrets por entorno | infra |
| OWF-006 | P1 | Probar deploy stage end-to-end | infra |
| ~~OWF-011~~ | ~~P2~~ | ~~UI Configuración Asesor IA~~ | ~~feat~~ |
| ~~OWF-013~~ | ~~P2~~ | ~~GitHub Actions deploy.yml~~ | ~~infra~~ |
| OWF-019 | P2 | i18n ES/EN | feat |
| OWF-020 | P2 | Sincronizar DB Stage → Dev | infra |
| OWF-049 | P2 | Cántaros: contexto rico extendido (emoji, tags) | feat |

---

## Blocked

| ID | Razon | Desbloquea |
|----|-------|------------|
| OWF-001 | SSH keys — prod OK. Dev/stage pendientes | OWF-005, OWF-006 |

---

## Stats

| Metrica | Valor |
|---------|-------|
| **Total** | 61 tareas |
| **Completadas** | 54 (89%) |
| **En progreso** | 0 |
| **Bloqueadas** | 1 |
| **Disponibles** | 14 |
| **Progreso** | ███████████████░░░░░ 75% |

---

## Next Up (por prioridad)

1. **OWF-004/005/006** — Deploy Staging + GitHub Secrets
2. **OWF-011** — UI Configuración Asesor IA
3. **OWF-013** — GitHub Actions CI/CD
4. **OWF-019** — i18n ES/EN
5. **OWF-022** — Android build + PRO pages

---

## Historial Reciente

| Fecha | Agente | OWF | Que hizo |
|-------|--------|-----|----------|
| 2026-06-19 | claude-code | OWF-008,009,028 | BottomNavMobile 5 tabs Pro mobile no-wrap, AppShell nav fix |
| 2026-06-19 | claude-code | OWF-049 | Cántaros description: type+mkJar+loadJarData+payload+UI |
| 2026-06-19 | claude-code | OWF-010,017 | Playwright ESM config + tests arreglados + URLs prod correctas |
| 2026-06-19 | claude-code | OWF-055..060 | AppShell único, rediseño, onboarding, legacy cleanup |
| 2026-06-11 | claude-code | OWF-054 | Fix navegación router |
| 2026-06-10 | claude-code | OWF-007 | Billetera implícita Lite |
| 2026-06-10 | opencode | OWF-047..048 | Mensajes ES + router DOM fix |
| 2026-06-08 | claude-code | OWF-035..045 | Infra agentes + Design System F0-F5 |

---

## Legacy ID Mapping

| Viejo | → OWF | Viejo | → OWF |
|-------|-------|-------|-------|
| MANUAL-001 | OWF-003 | DS-32 | OWF-007 |
| MANUAL-002 | OWF-004 | DS-33 | OWF-008 |
| TECH-001 | OWF-011 | DS-34 | OWF-009 |
| TECH-002 | OWF-010 | DS-51 | OWF-010 |
| TECH-003 | OWF-012 | DS-52 | OWF-019 |
| TECH-LP-02 | OWF-007 | BUG-006 | OWF-019 |
| TECH-LP-03 | OWF-042 | INFRA-001..004 | OWF-035..038 |
| TECH-LP-04 | OWF-008 | DS-01..52 | OWF-039..045 |
| OPS-001 | OWF-020 | WEEK2-A | OWF-021 |
| BUG-001..008 | OWF-023..028, OWF-046 | WEEK2-B | OWF-022 |
