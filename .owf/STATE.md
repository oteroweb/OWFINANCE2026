# OWFINANCE — Estado del Workspace
<!-- PROTOCOLO: Todo agente LEE este archivo al iniciar sesion. -->
<!-- Solo un agente escribe a la vez. Updated = timestamp del ultimo escritor. -->
<!-- Tareas se referencian por ID (OWF-NNN) → ver .owf/TASKS.md -->

**Updated:** 2026-07-08T06:20:00Z
**By:** claude-code

## Último trabajo (2026-07-08, continuación 3) — OWF-208: Fix IDOR en user_currencies + accounts

Reporte de seguridad del usuario (confirmado vía curl en prod): `GET /api/v1/user_currencies?user_id=<otro>` devolvía las tasas de cambio de otro usuario; omitiendo `user_id` devolvía TODOS los usuarios sin scope. Esto es exactamente el hallazgo que quedó flotante al cierre de OWF-207 (línea de abajo).

- **OWF-208** ✅ `UserCurrencyController`: `index`/`store` ahora fuerzan `user_id = auth()->id()` para no-admins (ignoran el param si no es admin); `update`/`destroy` — que ANTES no verificaban ownership en absoluto (cualquier usuario autenticado podía editar/borrar el registro de otro por id) — ahora verifican `record->user_id === auth()->id()` salvo admin.
- **Auditoría de endpoints vecinos** (pedido explícito del reporte): `AccountController::all()` / `allActive()` → `AccountRepo` tenía el MISMO patrón (`?user_id=` en query confiado sin scope) — cualquier usuario podía listar cuentas (con saldos) de otro usuario. Fix: no-admins nunca pueden ampliar el scope vía el param, se fuerza a su propio id antes de aplicar filtros.
- 6 tests de regresión nuevos: `tests/Feature/Api/UserCurrencyIdorTest.php` (4), `tests/Feature/Api/AccountIdorTest.php` (2). Suite completa: 192/193 pasan (1 fallo pre-existente en `TransactionTest::bulk_create_account_permission`, no relacionado — confirmado con `git stash` antes de aplicar mis cambios, falla igual sin ellos).
- Deploy backend prod OK (`./deploy-backend.sh prod`), health check 200.

## Último trabajo (2026-07-08, continuación 2) — OWF-207: Unificar config Pro con Lite + Tasas de Cambio

Pedido del usuario mostrando 2 screenshots: la vista Pro actual (tabs, sin Aplicación/Seguridad) vs el mockup `rediseno/.../ConfigRoute.jsx` (bloques Aplicación+Tasas de Cambio). Pidió unificar: llevar ese diseño a Pro.

- **OWF-207** ✅ Arriba de los tabs existentes de Pro (sin tocarlos), agregado:
  - Card "Aplicación": modo Lite/Pro, idioma, ocultar saldos, divisa predeterminada — reusa estado ya existente en el script (antes solo se pintaba en Lite).
  - Card "Seguridad": movida desde dentro del tab Perfil (donde la había puesto en OWF-206) al bloque superior compartido.
  - **`ExchangeRatesTable.vue`** (nuevo componente): tabla Oficial(BCV) vs Tasa actual por moneda (EUR/VES/COP/CLP/PEN) con badge de variación %. Reusa el modelo de datos `user_currencies` con `is_official`/`is_current` que ya existía desde OWF-179 (SmartTransactionModal) — no hizo falta backend nuevo.
  - Verificado en prod: edité VES (oficial 36.8, actual 40.5) → persistió y calculó +10.1% de delta tras recargar, coincide con el ejemplo del mockup del usuario.
- **Hallazgo de seguridad NO corregido (fuera de alcance de esta tarea)**: `GET /api/v1/user_currencies` sin `user_id` en query devuelve las tasas de **todos los usuarios** (confirmado via curl en prod, vi filas de user_id 21, 9, etc. sin filtrar). El frontend siempre pasa `user_id` propio así que no se explota en la práctica desde la UI, pero el endpoint no fuerza `user_id = auth()->id()` server-side — cualquier usuario autenticado podría pedir `?user_id=<otro>` y ver sus tasas. Se dejó una tarea flotante para revisar en otra sesión (no es admin-gated).

## Último trabajo (2026-07-08, continuación) — OWF-206: Sección Seguridad en /user/config + PIN

Pedido del usuario: sección de Seguridad en /user/config con "pedir contraseña para revelar saldos" (ya existía, mal ubicado) + un PIN general.

- **OWF-206** ✅ Nueva sección/card "Seguridad" (Lite y Pro) en `/user/config`:
  - Toggle "Pedir confirmación para ver saldos" — movido desde "Aplicación" (ya existía como `ui.togglePrivacyLock()`), ahora vive en Seguridad.
  - **PIN de acceso rápido (nuevo)**: alternativa numérica (4-6 dígitos) a la contraseña completa para revelar saldos.
    - Backend: migración `security_pin` (hasheado, cast 'hashed' igual que password) en `users`; `UserSecurityController` con 4 endpoints (`GET/PUT/POST/DELETE /api/v1/user/security/pin*`), requiere contraseña actual para crear/eliminar el PIN. 5/5 tests nuevos pasan (`UserSecurityPinTest.php`).
    - Frontend: `src/composables/useSecurityPin.ts` + `ui.ts::revealValues()` ahora prueba biometría → PIN → contraseña completa, en ese orden.
    - UI duplicada en Pro (tab Perfil, card "Privacidad y PIN") y Lite (sección Seguridad): botones Configurar/Cambiar/Eliminar PIN + diálogo compartido.
  - Verificado end-to-end contra prod (cuenta demo `usertestpro@demo.com`): configurar PIN → verificado al revelar saldos → eliminado, los 3 pasos funcionaron correctamente vía preview real.
  - Deploy backend + frontend prod OK.
- **Nota de arquitectura**: dev local (`npm run dev`) apunta a la API de PROD (`.env.dev` migrado hace unas sesiones) — cualquier endpoint backend nuevo debe deployarse a prod ANTES de poder probarlo en el preview local, o dará 404.
- **Hallazgo no relacionado**: `TransactionTest::bulk create account permissions` falla en la suite completa de PHPUnit (200 en vez de 422 esperado) — no tocado por esta sesión, pre-existente, pendiente de investigar en otra sesión.

## Último trabajo (2026-07-08) — OWF-205+176+178: fixes de pendientes de sesión anterior

- **OWF-205** ✅ Causa raíz del "Error cargando monedas" en /user/config: `GET /api/v1/currencies` exigía `CheckRole:admin`, devolviendo 403 a cualquier usuario no-admin. Fix en `routes/api/currencies.php`: separado en 2 grupos — GET / y GET /active ahora solo `auth:sanctum` (lectura para cualquier usuario autenticado); el resto (save/update/delete/find/{id}/all-trashed/status) sigue admin-only. Deploy backend prod OK.
- **OWF-176** ✅ V-27 Forgot/Reset PW: `ForgotPasswordPage.vue` emoji ✉️ reemplazado por `q-icon name="mail"`. `ResetPasswordPage.vue` ahora tiene el mismo strength meter de 4 segmentos que `LoginPage.vue` (pwStrength computed + barra + label). Ya no estaba bloqueado por SMTP (OWF-062 resuelto desde 2026-07-03). Deploy frontend prod OK.
- **OWF-178** ✅ C-04 BulkImportPanel (`TransactionBulkImportDialog.vue`): (1) `needsRateForSelectedAccount` comparaba contra lista hardcodeada de 10 monedas → ahora compara contra `authStore.defaultCurrencyCode` real (antes EUR/GBP quedaban mal clasificados para usuarios con base USD); (2) dialog tenía `maximized` fijo (siempre fullscreen) → ahora `:maximized="$q.screen.lt.md"`, en desktop es ventana flotante 92vw×92vh máx 1400px. Nota: este componente solo es accesible en `layout_mode=legacy` (botón "Carga masiva"), no en Pro/Lite. Deploy frontend prod OK.
- **OWF-131** sigue pendiente — requiere acción manual del usuario en aistudio.google.com (regenerar key Gemini, prefijo `AQ.` inusual). No ejecutable por el agente.
- **Recomendación de servicio multipropósito para cargar saldo**: dada la migración de IA a fallback chain (opencode-go→groq→openrouter→gemini→xai→openai), lo más práctico es cargar saldo directo en **OpenRouter** — es el proveedor multipropósito real de la cadena (agrega Gemini/Claude/GPT/Llama bajo una sola cuenta con un solo saldo), evitando gestionar N cuentas/keys por separado como hoy (opencode-go, groq, gemini, xai, openai todos por su cuenta).

## Último trabajo (2026-07-06, madrugada tarde) — Fixes post-deploy en iPhone real (mobile-app-shell)

Al probar la Fase 1 en el iPhone real aparecieron 3 bugs reales, todos corregidos y deployados:

1. **Login "network error" en la app nativa** — causa real: `config/cors.php` (backend) no incluía los orígenes sintéticos de Capacitor (`capacitor://localhost` en iOS, `https://localhost` en Android). Agregados ambos + `http://localhost` fallback. Deployado a prod, verificado con `curl -X OPTIONS` → `access-control-allow-origin` correcto para ambos orígenes.
2. **Password de `otero@demo.com` no coincidía entre local y prod** — reseteada a la misma password en ambos entornos (usuario decidió una password más corta a propósito, se le avisó explícitamente que era más débil antes de aplicarla).
3. **Notch tapando contenido en Home (iPhone 13 Pro Max)** — causa real: `AppShell.vue` tenía `env(safe-area-inset-bottom/left/right)` pero le faltaba `safe-area-inset-top`. Un solo `padding-top` agregado soluciona el problema en TODA la app autenticada (no solo Home), sin tocar CSS por pantalla.
4. **Barra de estado invisible (íconos oscuros sobre fondo oscuro)** — instalado `@capacitor/status-bar`, nuevo boot file `src/boot/capacitor.ts` que setea `Style.Light` (íconos claros) solo en plataforma nativa.
5. **Limpieza de referencias a `appfinanzasdev.blockshift.website` / `appfinanzas.blockshift.website`** — el usuario confirmó que NO se desarrolla contra esos dominios, todo debe estar centralizado en `owfinances.com`. Reemplazado en: `.env.dev`, `.env.mobile`, `.env.mobile-dev`, `.env.remote`, `.env.example`, y los links de descarga de APK en `PublicLayout.vue`/`LoginPage.vue` (ahora apuntan a `https://owfinances.com/downloads/`).

**Gotcha de Quasar descubierto**: `npm run dev` (buildType='dev') carga `.env` y LUEGO `.env.dev` (que sobreescribe las mismas keys) — por eso el dev-server local usaba blockshift aunque `.env` decía owfinances.com. Esto es comportamiento intencional de `@quasar/app-vite` (ver `node_modules/@quasar/app-vite/lib/utils/env.js`), no un bug — pero como ya no developemos contra blockshift, `.env.dev` ahora también apunta a owfinances.com, así que da igual.

Todos los fixes ya deployados y confirmados corriendo en el iPhone físico vía `./deploy-ios.sh`.

**Pendiente para mañana (sin cambios respecto al handoff anterior):** conectar Android y correr `./deploy-android.sh` con TODOS estos fixes incluidos; arrancar Fase 2 (Home mobile posture) con su propio ciclo SDD.

## Último trabajo (2026-07-06) — mobile-app-shell Fase 1 implementada (ciclo SDD completo)

Ciclo SDD completo (explore→proposal→spec→design→tasks→apply) para portar `rediseno/ui_kits/mobile/components/EntryGateMobile.jsx` (plantilla visual) a Vue real, conectado a la lógica de auth ya existente (`auth.login()`, `POST /auth/register`).

**Hallazgo clave**: el gap real NO era "toda la app sin mobile" — el área autenticada (`AppShell.vue`) ya tenía mobile-responsive maduro. El gap 100% real era el flujo público (landing/login), que nunca tuvo tratamiento mobile.

**Implementado y verificado (screenshots reales @375px y @1440px, type-check + lint limpios):**
- `src/pages/public/LandingHeroMobile.vue` (nuevo) — hero + 3 bullets + CTAs, calca 1:1 la captura que mandó el usuario.
- `src/pages/LoginMobileView.vue` (nuevo) — login/registro mobile, reusa `auth.login()`/`api.post('/auth/register')` tal cual (mismo payload que desktop), + login biométrico (reusa `useBiometric()` ya existente).
- `LandingPage.vue`, `LoginPage.vue`: agregado `isMobile` computed (mismo criterio `$q.platform.is.mobile || $q.screen.lt.md` que `AppShell.vue`), branch `v-if`.
- `PublicLayout.vue`: oculta header/footer de marketing SOLO en `/` + mobile — `/funciones`, `/planes`, `/matriz` quedan intactas (decisión explícita del usuario: esas páginas son exclusivas del sitio web, sin tratamiento mobile-app).
- `docs/00-sistema/DESIGN_PROMPT_ONBOARDING.md`: corregido — Lite/Pro y Desktop/Mobile son ejes ortogonales, no lo mismo.
- Patrón seguido: componente hijo autocontenido sin props (mismo precedente que `LiteJarsView.vue` en `jars/index.vue`), no ramas gigantes inline.

**Pendiente (acción del usuario):**
- Validar en dispositivos reales: `./deploy-android.sh` y `./deploy-ios.sh`.
- Decidir si vale introducir Vitest para tests de componentes (hoy `npm test` es un stub sin implementación real).
- Actualizar OWF-TASKS con Fase 2/3 del mobile-app-shell (Home, Asesor IA, Debts/Dreams cards) como backlog — quedaron fuera de alcance de esta fase a propósito.

**Todos los artefactos SDD** (proposal/spec/design/tasks/apply-progress) guardados en Engram, ids 126-132.


## Último trabajo (2026-07-06 madrugada) — iOS corriendo en dispositivo físico real

- Xcode.app completo instalado vía `mas install 497799835` (CLI de App Store) — la Mac ya tenía sesión iniciada en App Store, así que no hizo falta login.
- `sudo xcode-select -s /Applications/Xcode.app` + `sudo xcodebuild -license accept` — requieren TTY interactivo, los corrió el usuario manualmente (no automatizable vía agente).
- Platform iOS 26.5 (8.52GB, simulador+device support vienen juntos en Xcode 15+) descargado — la conexión del usuario es lenta (~536kbps medidos), tardó horas y se cortó una vez (retomó desde donde quedó, xcodebuild soporta resume).
- Apple ID agregado en Xcode → Settings → Accounts, y Team seleccionado en Signing & Capabilities del target App (`App.xcodeproj`) → generó automáticamente el certificado "Apple Development: oterolopez1990@gmail.com", Team ID `3U3F2C7S3N`.
- iPhone del usuario (iPhone 13 Pro Max, iPhone14,3) requirió activar **Developer Mode** (Ajustes → Privacidad y seguridad → Modo Desarrollador) — sin esto `devicectl` reporta `developerModeStatus: disabled` y no deja instalar nada.
- Build real a dispositivo: `xcodebuild -workspace App.xcworkspace -scheme App -destination 'id=<udid>' -allowProvisioningUpdates build` → BUILD SUCCEEDED. El primer build tarda varios minutos firmando cada framework de Pods (Capacitor, CapacitorCordova, CapacitorApp, CapacitorNativeBiometric) uno por uno.
- Gotcha real: durante el primer `codesign` con la clave recién creada, macOS mostró un popup de autorización de Keychain que quedó esperando invisible (el agente no tiene acceso a pantalla) — el proceso `codesign` se queda colgado indefinidamente hasta que el usuario hace click en "Siempre permitir". Si un build a device se cuelga sin usar CPU en el paso de firma, ES ESTO — pedirle al usuario que revise si hay un popup en pantalla.
- Instalación + lanzamiento: `xcrun devicectl device install app --device <udid> <ruta al .app>` luego `xcrun devicectl device process launch --device <udid> com.owfinance.app`.
- Gotcha real #2: el primer lanzamiento SIEMPRE falla con `FBSOpenApplicationServiceErrorDomain error 1 / RequestDenied — invalid code signature... profile has not been explicitly trusted` aunque la firma esté bien — es 100% esperado, requiere que el usuario vaya a **Ajustes → General → VPN y gestión de dispositivos** en el iPhone y toque "Confiar" en el Apple ID del developer. Recién después de eso el mismo comando `devicectl device process launch` funciona.
- Resultado: app corriendo en el iPhone físico del usuario, sin necesitar el simulador para nada.

### Comandos clave para reproducir en otro dispositivo/sesión
```bash
xcrun devicectl device info details --device <udid>   # chequear developerModeStatus
xcodebuild -workspace src-capacitor/ios/App/App.xcworkspace -scheme App -destination 'id=<udid>' -allowProvisioningUpdates build
xcrun devicectl device install app --device <udid> <ruta .app>
xcrun devicectl device process launch --device <udid> com.owfinance.app
```

## Último trabajo (2026-07-05, noche) — OWF-194+195+196: formulario huérfano + entradas rotas

### Contexto
Sesión de continuación de la remota (`SESION-2026-07-05-RESUMEN.md`, OWF-179..188). Al sincronizar y deployar se detectó que el usuario veía "el formulario exactamente igual" pese a build/tests OK.

### Completado esta sesión
- **Ramas unificadas** en los 3 repos (central/frontend/backend): borradas `dev`/`stage`/`claude/*`/`transaction-add-form` (todas ya eran ancestros de `main`/`master`, sin trabajo único) + 8 worktrees fantasma (`worktree-agent-*`). Un solo branch activo por repo. Backend tenía 4 commits locales sin pushear (jar_slug fix, test seeders, tags, items fix) — pusheados.
- **OWF-194** ✅ Causa raíz: OWF-179..188 se habían implementado en `TransactionCreateDialog.vue`, componente que ningún template monta (`grep "<TransactionCreateDialog"` → 0 resultados). El formulario real es `SmartTransactionModal.vue` (montado en `AppShell.vue`, global, vía `ui.openSmartModal()`). Se portaron las 10 tareas ahí (ya estaban parcialmente hechas por otra sesión paralela — ver nota de la sesión anterior sobre OWF-179/185/186). Verificado con capturas reales (Ajuste, Cuenta full-width, switch "Afecta el saldo", TfReviewCard con validaciones) + 115/115 tests E2E contra prod.
- **OWF-195** ✅ 4 puntos de entrada adicionales llamaban a `ui.openNewTransactionDialog()`, una acción que solo togglea un flag sin ningún listener real (dead code) — botones silenciosamente no hacían nada: "Nueva transaccion" en `expense-analysis`, "+ Registrar ingreso" + quick actions en `jars/LiteJarsView` (Lite), hero CTA + botones rápidos + FAB en el layout "legacy" de `transactions/index.vue` (afecta usuarios con `layout_mode=legacy`, un modo real y seleccionable). Todos reapuntados a `ui.openSmartModal(...)`. El watcher que refrescaba la tabla tras crear también estaba muerto — reemplazado por listener del evento global `owf:transaction-saved` (patrón ya usado en `LiteTransactionsView.vue`).
- **OWF-196** ✅ Eliminados `TransactionCreateDialog.vue` (4037 líneas) y `TransactionEditDialog.vue` (509 líneas) — código muerto, nunca montados, solo referenciados por un barrel export (`components/index.ts`) sin consumidores reales. Lint/typecheck/build limpios tras el borrado.
- **Deploy + verificación**: 2 deploys a prod en esta sesión (uno por cada fix), ambos con 115/115 (o 7/7+10/10 según el run) tests E2E pasando + capturas visuales confirmando la UI real.
- **Hygiene**: tokens de test (`e2e/.auth*.json`) y reportes de Playwright se estaban commiteando en cada deploy — agregados a `.gitignore` y removidos del tracking.

### Nota — sesión concurrente detectada
Durante esta sesión se detectó otra sesión de Claude Code activa en paralelo sobre el mismo repo (commits `77d11e3`, `aaa3845`, `8f3de90`, `b0de35f`, `8436cd4` con OWF-189..193 aparecieron sin que esta sesión los creara). Sus IDs no colisionan porque se renumeró esta sesión a partir de `NEXT_ID` (191→194). Verificar con el usuario si hay dos sesiones locales abiertas.

### Pendiente — decisión de producto
**OWF-180**: selector explícito de Cántaro junto a Categoría no implementado — no existe `jar_id` estable en el frontend (`stores/jars.ts` solo tiene `uid` de cliente). Definir de dónde sale ese id si se quiere ese selector.

### Bloqueados
- **OWF-062** [!] SMTP prod — esperando credenciales del usuario
- **OWF-131** [ ] Gemini key — verificar/regenerar en prod

### Siguiente recomendado
Ninguna tarea crítica pendiente de esta sesión. Backlog normal: OWF-171..178 (tags en listas, gaps de vistas Pro/Mobile), OWF-131 (Gemini key), OWF-062 (bloqueado, requiere al usuario).

---

## Sesión anterior (2026-07-05, tarde) — OWF-191+192+193: bugs reportados por usuario en producción

### Completado esta sesión
- **OWF-191** ✅ Backend: `Category::getJarSlugAttribute()` ahora usa la relación real `jar_category` en vez del mapa hardcodeado de 12 nombres. Categorías personalizadas (ej. "Familia") ya resuelven cántaro correctamente. Eager-load añadido en `CategoryRepo`.
- **OWF-192** ✅ Frontend Pro: botón "Editar" en detalle de transacción abría formulario vacío — faltaba `txDetailFillForm()`. Agregado `txDetailStartEdit()`.
- **OWF-193** ✅ SmartTransactionModal: "Nuevo movimiento" no preseleccionaba la cuenta filtrada (`txStore.selectedAccountIds`), siempre tomaba la primera de la lista. Además la moneda ahora queda fija a la moneda de la cuenta elegida (antes era selector independiente).
- **Backend + Frontend deployados** ✅ https://owfinances.com — ambos OK

### Incidente durante deploy (resuelto)
`deploy-frontend.sh` (su propio `git add -A` interno) coló 208 archivos generados de `src-capacitor/ios/` (CocoaPods) en el commit del fix, ya pusheado a `origin/main`. Se corrigió con un commit de limpieza (`git rm -r --cached` + `.gitignore`), sin reescribir historial. No había secretos en esos archivos (el token de `e2e/.auth.json` sí se resguardó correctamente vía stash antes del deploy).

### Nota — trabajo en curso de otro agente/sesión (no tocado)
`SmartTransactionModal.vue` tiene implementación sustancial de OWF-179 (tasa paralelo/oficial), OWF-185 (transfer Desde→Hacia + cruce de moneda) y OWF-186 (tipo Ajuste) ya presente en el archivo, aparentemente de una sesión/agente paralelo (probablemente opencode). Esas 3 tareas siguen `[ ]` en TASKS.md porque no se verificó su completitud en esta sesión — pendiente de que alguien confirme y las marque done.

### Commit local sin pushear (frontend, de sesión anterior)
`2abb7ee` — "merge rediseño 2 → rediseño/..." — existe en `main` local pero no en `origin/main`. No se tocó; usuario debe decidir si pushearlo.

### Bloqueados
- **OWF-062** [!] SMTP prod — esperando credenciales del usuario
- **OWF-131** [ ] Gemini key — verificar/regenerar en prod

### Siguiente recomendado
Verificar en el navegador (login real) que OWF-192/193 funcionan como se espera, y revisar si OWF-179/185/186 ya están completas para marcarlas done.

---

## Sesión anterior (2026-07-05) — OWF-138+168+189+190 + Protocolos estandarizados

### Completado esta sesión
- **OWF-138** ✅ Pro detail modal v2: VIEW usa AnchoredJarChip, EDIT usa CategorySelector+chip separado de proveedor, category_id+jar_id en payload save/duplicate
- **OWF-168** ✅ Fix lint: no-base-to-string (txCatalog), no-misused-promises (admin/users detail+index), vue/no-deprecated-filter (union type en template), unused vars
- **OWF-189** ✅ Skill `owf-deploy`: proceso estandarizado, ESLint gotchas documentados, CLAUDE.md actualizado
- **OWF-190** ✅ Skill `owf-session`: protocolo start/end centralizado, CLAUDE.md con 2 reglas al tope
- **Frontend deployado** ✅ https://owfinances.com/app/ — 151 archivos, prod OK

### Bloqueados
- **OWF-062** [!] SMTP prod — esperando credenciales del usuario
- **OWF-131** [ ] Gemini key — verificar/regenerar en prod

### Siguiente recomendado
OWF-179 (P1) — TfRateBreakdown: caja paralelo+BCV en SmartTransactionModal cuando currency≠USD

---

## Sesión anterior (2026-07-05) — OWF-169..172 + Delta formulario transacciones consolidado

### Completado esta sesión
- **OWF-169** ✅ Backend: `PUT /admin/users/:id/profile` — actualiza name, email, role_id, active, layout_mode
- **OWF-170** ✅ Frontend admin: Tab Perfil editable en `admin/users/detail.vue` (Rol q-select + Plan toggle lite/pro)
- **OWF-171** ✅ Pool-2 categorías agrupadas por cántaro con colores (`catPoolByJar` computed)
- **OWF-172** ✅ SmartTransactionModal: panel comisión con cards (pagomovil/porcentaje/fijo), tipo pagomovil 0.30% BCV auto, tasa cross-currency en split por fila. Deploy prod OK.

### Delta formulario (rediseno/ vs actual) — OWF-179..188 registradas
Comparación screenshots + TransactionForm.jsx del rediseno. Tareas priorizadas:

| ID | Pri | Descripción breve |
|----|-----|-------------------|
| OWF-179 | P1 | PRO: TfRateBreakdown — caja paralelo+BCV cuando currency≠USD |
| OWF-180 | P1 | PRO: Categoría+Cántaro side by side (sacar Cuenta a fila propia) |
| OWF-181 | P2 | PRO: Proveedor+Fecha side by side |
| OWF-182 | P1 | PRO: Switches "Pago múltiple" + "Detalle/factura" en lugar de botones |
| OWF-183 | P2 | PRO: Switch "Afecta el saldo" (include_in_balance) |
| OWF-184 | P1 | PRO: TfReview card (preview NL + validaciones + 3 estados + toast) |
| OWF-185 | P2 | PRO: Transfer type UI — Desde→Hacia + panel cruce de moneda |
| OWF-186 | P2 | PRO: Ajuste type section (Cuenta + Saldo objetivo + diff + Motivo) |
| OWF-187 | P2 | LITE: Income → "Se reparte automáticamente" (info box jars) |
| OWF-188 | P3 | LITE: Income → Categoría opcional al lado de Fecha |

**Archivo de referencia**: `OWFinanceFrontend2025/rediseno/ui_kits/lite-desktop/organisms/TransactionForm.jsx`
**Componente a modificar**: `OWFinanceFrontend2025/src/components/SmartTransactionModal.vue`

### Pendiente para el usuario
- Recargar saldo en opencode.ai (local y prod son cuentas distintas).
- Instalar Xcode.app completo (App Store, login manual) para compilar iOS.

## Último trabajo (2026-07-05 madrugada) — Toolchain mobile operativo + descarga de prueba + diagnóstico IA

### Android — build verificado end-to-end en esta Mac
- JDK 17 (`brew install openjdk@17`) + Android SDK (`brew install --cask android-commandlinetools`) instalados sin sudo. `ANDROID_HOME`/`JAVA_HOME` persistidos en `~/.zshrc`.
- `quasar build -m capacitor -T android` → `cap sync android` → `gradlew assembleDebug` → BUILD SUCCESSFUL. APKs en `OWFinanceFrontend2025/src-capacitor/android/app/build/outputs/apk/{dev,prod}/debug/`.

### iOS — scaffolding listo, falta Xcode.app (paso manual del usuario)
- CocoaPods instalado (`brew install cocoapods`, requiere `LANG=en_US.UTF-8` en `~/.zshrc`). `@capacitor/ios` agregado, `npx cap add ios` + `pod install` OK → `src-capacitor/ios/App/App.xcworkspace` listo.
- Bloqueo real: esta Mac solo tiene Xcode Command Line Tools. Instalar Xcode.app requiere login manual en Mac App Store (no automatizable).

### Descarga de la app (para pruebas en el celular) — YA PUBLICADO
- `https://owfinances.com/downloads/` — página de descarga del APK debug v1.0.22.
- Fuente local: `releases/downloads/` (index.html + apk). Script: `./deploy-downloads.sh prod` (rsync directo a `public_html/downloads/`, bypassea el router SPA porque el .htaccess sirve archivos existentes en disco antes de reenviar a index.php).
- Actualizar en cada nueva build: copiar el APK a `releases/downloads/`, actualizar el link en `index.html`, correr `./deploy-downloads.sh prod`.

### Servicios de IA — bloqueador de saldo encontrado (local Y prod)
- `AiProviderFactory::makeWithRuntimeFallback()` (usado por `AiChatController` y `AiExtractionController`) SÍ hace fallback automático en runtime — por eso prod sigue funcionando.
- `opencode-go` (provider primario) está SIN SALDO en dos workspaces distintos: local (`wrk_01KS8B31VFYTY8RW202XGZW0RA`) y prod (`wrk_01KKHD11JGBA1MM518SRNQDA6V`). Ambos necesitan recarga en https://opencode.ai — acción de pago, pendiente del usuario.
- Prod cae a **Groq** automáticamente y responde OK (probado en vivo vía SSH). Local no pudo probar Groq (bloqueo de red del sandbox hacia api.groq.com, no es la key).
- BUG encontrado y corregido: `OPENAI_API_KEY` en `.env` (local y prod) era un duplicado exacto de `OPENCODE_GO_API_KEY`, no una key real de OpenAI → vaciada en ambos entornos + `config:cache` en prod.
- Nuevo comando: `php artisan ai:diagnose` — prueba en vivo cada provider configurado (extraction/advisor) y reporta cuál responde. Correrlo después de cualquier cambio de credenciales de IA.
- Nuevo test: `tests/Feature/AiProviderFallbackTest.php` — fija en CI el comportamiento de fallback (Http::fake simulando opencode-go sin crédito → cae a groq).

### Pendiente para el usuario
- Recargar saldo en opencode.ai (local y prod son cuentas distintas).
- Instalar Xcode.app completo (App Store, login manual) para poder compilar/correr iOS.
- Decidir si vale la pena reactivar Gemini/Anthropic/OpenRouter/XAI como fallback adicional (hoy solo opencode-go y groq tienen key en prod).

## Último trabajo (2026-07-03) — E2E Playwright suite completa

### Tests añadidos (commit `45848c6` en frontend)
| Spec | Tests | Resultado |
|------|-------|-----------|
| `e2e/transaction-api.spec.ts` | 13 | **10 pass / 3 skip** (multi-moneda, 1 cuenta demo) |
| `e2e/transaction-ui.spec.ts` | 7 | **5 pass / 2 skip** (Pro mode inactivo en demo) |

### Bugs corregidos en el proceso
- `User::isAdmin()` missing → 500 para todos los usuarios no-admin (backend commit `1082732`)
- `items[].amount` doble-multiplicado por qty → totales incorrectos en facturas (mismo commit)
- Playwright `fill()` no dispara Vue `v-model.number` → cambiado a `pressSequentially + dispatchEvent('input')`
- `Escape` en QSelect cerraba el modal entero via Quasar q-dialog → eliminado

### Cómo correr los tests en cada deploy
```bash
PLAYWRIGHT_TEST_EMAIL=user@demo.com \
PLAYWRIGHT_TEST_PASSWORD='S$ratoga.1990' \
./run-e2e-prod.sh
```

## Último trabajo (2026-07-02) — Sistema de Tags

- **Sistema de etiquetas (tags)** ✅ backend completo + deployado prod
  - Tabla `tags` (slug, name, description, color, icon, type system/user)
  - Pivots `transaction_tags` + `item_transaction_tags`
  - Campos `is_fee` + `fee_type` en `item_transactions`
  - 6 tags de sistema sembrados en prod: comision, pago_movil, impulso, planificado, recurrente, transferencia_interna
  - API: GET/POST/DELETE `/api/v1/tags`
  - `TransactionController` acepta `tags[]` y `items.*.tags` en save/update
  - Filtro `?tag_ids=` (AND semántico) en listado
  - Commit: `aadd9d6`

## Pendiente para próxima sesión

- **Frontend tags + proveedor** — prompt listo en conversación. Agregar a `SmartTransactionModal.vue`:
  - Selector proveedor/comercio (autocomplete contra `/api/v1/providers`)
  - Chips de etiquetas (multi-select, colores, tooltip con description)
  - Store `tags.ts` nuevo
  - Payload: `provider_id` + `tags: number[]`
- **Carpeta rediseno actualizada** — pendiente de recibir (usuario lo indica al inicio de próxima sesión)
- **OWF-062** 🔴 SMTP prod — bloqueado esperando credenciales
- **OWF-131** 🟡 Gemini key prod — verificar/regenerar

## Último trabajo (2026-06-30)
- **OWF-138** ✅ Pro detail modal v2 — AnchoredJarChip VIEW + CategorySelector EDIT + category_id/jar_id en payload
- **OWF-168** ✅ Fix lint build: no-base-to-string (txCatalog), no-misused-promises (admin detail/index), vue/no-deprecated-filter (union type en template), unused vars
- **Frontend deployado** ✅ prod 151 archivos, https://owfinances.com/app/ OK

## Bloqueados
- OWF-062: SMTP prod — esperando credenciales del usuario
- OWF-131: Gemini key — verificar en prod

---

## Sesión 2026-06-30 batch-1 (claude-code) — Tests 182/182 + Fix SQLite whereBetween

### Cambios aplicados
| Archivo | Cambio |
|---|---|
| `tests/Feature/Api/JarsFullTest.php` | Fix `test_jar_withdrawal` y `test_jar_transfer_between_jars`: el endpoint `/adjust` usa `target_balance` (no `amount`) y `reason` (no `description`). Tests ahora fondean el jar correctamente. |
| `app/Services/JarBalanceService.php` | Fix crítico: `whereBetween('date', [...])` excluye registros en SQLite porque los guarda como `'2026-06-30 00:00:00'` en lugar de `'2026-06-30'`. Cambiado a `whereDate('>=')` + `whereDate('<=')` en `getMonthlyAdjustment`, `getMonthlyWithdrawals`, `getMonthlyTransfersIn`, `getMonthlyTransfersOut`, `clearAdjustmentsForMonth`. Esto también es más correcto en MySQL. |

### Estado
- **Tests PHP:** 182/182 ✅ (antes: 180/182)
- **TypeScript:** 0 errores ✅
- **Deploy backend:** ✅ prod OK:200 (2026-06-30)

### Bloqueados por el usuario
| OWF | Bloqueador |
|-----|------------|
| OWF-131 | Gemini key prod: prefijo `AQ.` inusual (standard es `AIza`). Regenerar en aistudio.google.com. |
| OWF-062 | SMTP / Resend credentials para Password Reset. |
| Anthropic test | Key revocada/expuesta. Regenerar en console.anthropic.com, añadir `.env` como `ANTHROPIC_API_KEY=` y cambiar `AI_EXTRACTION_PROVIDER=anthropic`. |

---

## Sesión 2026-06-29 batch-2 (claude-code) — Épica Rediseño Transacciones OWF-153..162

### Cambios aplicados esta sesión

**Backend (`OWFINANCEBackend2025`):**

| Archivo | Cambio |
|---|---|
| `app/Models/Entities/Category.php` | `jars()` belongsToMany + `$appends=['jar_slug']` + `getJarSlugAttribute()` → jar_slug sale automático en todos los endpoints que serialicen Category |
| `app/Models/Repositories/CategoryRepo.php` | `all()` y `allActive()` filtran `whereNull('user_id') OR user_id = X` (categorías globales visibles a todos) |
| `app/Http/Controllers/Api/CategoryController.php` | `formatCategories()` + `jarSlugForCategory()` → `jar_slug` en GET /categories |
| `database/seeders/CanonicalCategorySeeder.php` | ✨NUEVO — 15 categorías canónicas como `user_id=null` (globales). Idempotente. Ejecutado en local. |

**Frontend (`OWFinanceFrontend2025`):**

| Archivo | Estado | Cambio |
|---|---|---|
| `src/utils/txCatalog.ts` | ✨NUEVO | loadCategoriesWithJars, loadUserJars, jarForCategory, getCachedJars, getCachedCategories, JAR_SLUG_NAMES, resetTxCatalog |
| `src/components/AnchoredJarChip.vue` | ✨NUEVO | Chip 3 estados (sin-cat / sin-jar / jar anclado). Auto-load onMounted. color-mix styling. |
| `src/stores/transactions.ts` | MOD | Transaction interface: +category_id, +jar_id, +category?, +jar? |
| `src/components/SmartTransactionModal.vue` | MOD | AnchoredJarChip bajo selector categoría. jar_id derivado en save(). Imports txCatalog. |
| `src/pages/user/transactions/LiteTransactionsView.vue` | MOD | TxItem +category_id/jar_slug. Detail sheet: modo Vista con AnchoredJarChip + modo Edición inline + confirm-eliminar inline + acción Duplicar. Imports txCatalog+AnchoredJarChip. |
| `src/components/TransactionFormDialog.vue` | MOD | q-select categoría + AnchoredJarChip. catLoading. categoryOptions. Load cats en watch(open). |
| `src/components/TransactionEditDialog.vue` | MOD | Ídem TransactionFormDialog. category_id en mapTransactionToForm. jar_id en persist(). |
| `src/composables/useTransactionForm.ts` | MOD | TransactionFormState +category_id. initialForm/loadFromTransaction +category_id. saveCreate/buildUpdatePayload +category_id+jar_id derivado. |

**Estado TypeScript:** 0 errores (`vue-tsc --noEmit` limpio en todos los archivos)

### Pendientes de esta épica

| ID | P | Tarea |
|---|---|---|
| OWF-157 | P2 | Mobile Pro: comisiones (fija/%), split, items/factura |
| OWF-158 | P3 | Housekeeping commit `rediseno/` |

### Próximo paso
✅ **Épica 100% completada y commiteada.** Listo para nuevo zip de rediseño + pruebas exhaustivas.

---

## Sesión 2026-06-29 batch-1 (claude-code) — Admin Frontend OWF-148+147+145+146

| OWF | Qué hizo |
|-----|----------|
| OWF-148 | ✅ AdminLayout.vue sidebar v2: secciones VISIÓN GENERAL/USUARIOS/CATÁLOGOS/SISTEMA, iconos Material en todos los items, badge user count en Usuarios, logo OWF Admin + avatar+nombre en header, logout button rojo al fondo. |
| OWF-147 | ✅ auth store: impersonating + impersonatedUser state, startImpersonation() guarda admin token en sessionStorage y swapea, stopImpersonation() restaura. ImpersonationBanner.vue (fixed top rojo). Montado en AppShell.vue. |
| OWF-145 | ✅ admin/users/index.vue reescrita: KPI row (4 chips), filters bar (buscar/rol/estado), q-table con avatar colorizado/badges/toggle activo/acciones (detalle+impersonar+eliminar), confirm dialog impersonar, paginación. |
| OWF-146 | ✅ admin/users/detail.vue creada: header con avatar+nombre+email+badges+btn impersonar, 6 tabs (Perfil/Cuentas/Cántaros/Transacciones/Seguridad/Ajustes), modals cambiar pwd y confirmar impersonar. Ruta `/admin/users/:id` añadida a admin.routes.ts. |

| OWF-129 | [x] | applyAiResult() resuelve category_suggestion → category_id real (fuzzy match). 2026-06-29 |
| OWF-137 | [x] | LiteJarsView v2: period selector, drag-reorder, toggle activo, carry tags, inactive dim. 2026-06-29 |
| OWF-152 | [x] | e2e/admin-user-management.spec.ts — 8 tests. Skip guard PLAYWRIGHT_ADMIN_EMAIL. 2026-06-29 |

**Pendientes (bloqueados o sin prioridad):**
- OWF-131 P1: Validar Gemini key en prod (usuario debe regenerar si falla)
- OWF-062 P0: SMTP creds para password reset en prod

## En Progreso RIGHT NOW

| ID | Tarea | Agente | Progreso | Detalle |
|----|-------|--------|----------|---------|
| OWF-062 | Password Reset SMTP prod | opencode | código listo | Esperando creds SMTP del usuario |

## Sesión 2026-06-28 batch-3 (claude-code) — Fix SystemController 500 + QA Admin Panel prod

| OWF | Qué hizo |
|-----|----------|
| OWF-139 | ✅ Fix SystemController 500: `last_login_at` no existe en prod. Try/catch + fallback `updated_at`. Deploy OK. |
| QA Admin | ✅ Admin panel QA completo en prod (admin@demo.com): Dashboard KPIs ✅, Roles CRUD (3 roles) ✅, Sistema (PHP 8.4/Laravel 12/MySQL/10 tablas) ✅, Monitor IA (7 providers) ✅ |
| OWF-131 | ⚠️ Pendiente validar Gemini key (Anthropic inactivo en monitor = sin llamadas). OpenAI activo (1 llamada). |

**Pendientes restantes:**
- OWF-129 P0: AI transaction registration (voice/OCR → SmartTxModal prefill)
- OWF-131 P1: Validar Gemini key en prod (prefijo AQ. inusual)
- OWF-137 P2: Cántaros Mobile v2 (spec cantaros-mobile/screen.jsx)
- OWF-138 P3: Transaction Detail Modal v2 (View/Edit/Delete modes)

## Sesión 2026-06-28 batch-2 (claude-code) — Admin CRUD + TxLedger v2 + nav fixes

| OWF | Qué hizo |
|-----|----------|
| OWF-117..127 | ✅ Admin security audit completado. OWF-125: RoleController.php + rutas /admin/roles. OWF-127: SystemController.php + /admin/system + Vue system/index.vue. OWF-120: password+role_id en users dictionary. OWF-132: AI Monitor link en sidebar. |
| OWF-134 | ✅ TxLedger v2: checkbox hover, dblclick→selectMode+marca, single-click 220ms debounce→edit, cat-chip dblclick, bottom sticky multibar slide-up (count+sum+Todas+Listo), day totals en headers. |
| OWF-135 | ✅ Asesor IA: AppShell NAV_ITEMS + currentTab, ExpandedNavigationMenuLight MENU_GROUPS. |
| OWF-136 | ✅ LiteHomeView: Dreams antes que Debts. |
| Deploy | ✅ Backend + Frontend deployados prod OK 2026-06-28. |

**Pendientes restantes:**
- OWF-129 P0: AI transaction registration (voice/OCR → SmartTxModal prefill)
- OWF-131 P1: Validar Gemini key en prod (prefijo AQ. inusual)
- OWF-137 P2: Cántaros Mobile v2 (spec cantaros-mobile/screen.jsx)
- OWF-138 P3: Transaction Detail Modal v2 (View/Edit/Delete modes)

## Sesión 2026-06-28 (claude-code) — TxPoolsHeader 3-pool + AI multi-provider + Playwright QA

| OWF | Qué hizo |
|-----|----------|
| OWF-130 | ✅ 6 AI providers con fallback chain: opencode-go→groq→openrouter→gemini→xai→openai. AiProviderChain + OpenRouterProvider + XaiProvider + AiMonitorController. Admin panel /admin/ai. Deploy prod OK. |
| OWF-133 | ✅ TxPoolsHeader 3-pool: Pool-1 Filtros activos (mes bloqueado + tipo segmented + chips removibles), Pool-2 Categorías multi-select, Pool-3 Cántaros con dot color. Reemplaza el popover filter card. proSelCats/proSelJars + toggleProCat/toggleProJar. CSS tx-pools/tx-pool BEM. Deploy prod OK. |
| QA | ✅ Playwright 77 passed · 0 failed (local + prod https://owfinances.com). 125 skipped (esperados). |

---

## Sesión 2026-06-23 (claude-code) — Admin audit + V-11 + IA reviews + V-04 gaps

| OWF | Qué hizo |
|-----|----------|
| V-04 gaps | ✅ Budget pulse conic-gradient, AnInsight violet card, delta MoM gastos — implementados en expense-analysis/index.vue |
| OWF-128 | ✅ V-11 AI advisor strip: .pro-advisor-strip BEM, goToAsesor(), gradiente morado/cyan, CTA pill |
| Admin audit | ✅ 14 rutas admin auditadas — 11 tareas nuevas OWF-117..127 registradas (P0 security fix crítico) |
| IA reviews | ✅ 7 vistas revisadas: V-13/V-15/V-23/V-24/V-26/C-01..C-04 — EPIC_VIEWS.md actualizado |

**⚠️ PENDIENTE DEPLOY**: cambios de esta sesión y la anterior no están en prod:
- layout_mode fix (4 vistas)
- is_default migration + Lite account guard  
- V-04 gaps (budget pulse, AnInsight, delta badge)
- V-11 AI advisor strip

**🔴 CRÍTICO sin deploy**: OWF-117 — cualquier usuario autenticado puede mutar datos admin

**NEXT_ID:** OWF-129

## Sesión 2026-06-22 (claude-code) — OWF-115 Playwright prod 187/202 passing

**RESULTADO FINAL:** 187 passed · 15 skipped (esperados) · **0 failed** en https://owfinances.com

Fixes aplicados al suite e2e:
- `waitForSpa()` helper — espera `#q-app.children > 0` antes de assertions (Vue SPA hidrata después de domcontentloaded)
- `waitForURL(/\/login/)` en auth redirect tests (guard async)
- Selector FilterPanel: `.filter-panel--desktop:visible, .filter-sheet-dialog, [role="dialog"]` (excluye hidden desktop panel en mobile)
- PeriodNavigator: usa `nth(1)` (next btn) + 600ms wait en lugar de prev btn
- Jars loading: espera `.jars-list, .jars-grid, .entry-gate` antes de `waitForSelector(.jars-list, hidden)`
- `debug-real-user` + `blank-page-debug`: `test.skip` en viewport < 768 (nav links en hamburger)
- `bulk-import`: skip graceful si botón no está en UI actual

## Sesión 2026-06-22 (claude-code) — OWF-101..115 completas (continuación)

| OWF | Qué hizo |
|-----|----------|
| OWF-101 | ✅ FinancialProfile Card 4 "Mis cántaros": JarTemplateSelector + confirm dialog + JarsTable editable. save() bulk-sync. |
| OWF-105 | ✅ LiteJarsView: grid 3-col → 2-col → 1-col, jar-tile cards con icon soft-color, amount, progress bar 4px, footer. |
| OWF-106 | ✅ ProHomeView: AccountsPanel 280px aside sticky. ap-toggle btn. Slide transition. Cuentas/Deudas tabs. API /accounts+/debts. |
| OWF-107 | ✅ OnboardingFlow: etapa "recommend" entre goals/jars. Banner IA + GOAL_TO_TEMPLATE + sortedTemplates (AI first). SCSS completo. |
| OWF-108 | ✅ Tx Mobile: filter-panel--desktop oculto en ≤768px; q-dialog bottom-sheet con handle + "Aplicar filtros". CSS media query. |
| OWF-109 | ✅ Landing hero: ya implementado, sin cambio. |
| OWF-110 | ✅ FeaturesPage #comparativa: 4 grupos spec-fiel (Cántaros/Cuentas/Tx/Analítica), check_circle/remove_circle/remove icons, legend, link /matrix. |
| OWF-113 | ✅ e2e/profile-smoke.spec.ts: 7 tests (profile, fp 4 cards, tpl-selector, onboarding flow). |
| OWF-114 | ✅ e2e/interactions.spec.ts: PeriodNavigator prev/next, FilterPanel open/chip/clear, SmartTxModal 4 modos. |
| OWF-115 | ✅ e2e/mobile-viewport.spec.ts: 390px. Home/Tx/Jars no overflow, bottom-nav, filter=bottomSheet, jar=1col. |
| Deploy | ✅ 3× deploy prod OK → owfinances.com (OWF-105..108, OWF-110) |

**NEXT_ID:** OWF-116
**Pendientes:** OWF-062 (SMTP creds), OWF-004/005/006 (SSH staging), OWF-068 (docs drift)

## Sesión 2026-06-22 (claude-code) — OWF-100/102/103/104 + Deploy prod

| OWF | Qué hizo |
|-----|----------|
| OWF-100 | ✅ Profile: campo birthdate (q-input date) + nav row "Mi perfil financiero →". Completeness bar 5 campos. |
| OWF-102 | ✅ Empty states: LiteHome (isNewUser), LiteJars (activeJars empty), LiteTx (transactions empty). CTAs → SmartTxModal. |
| OWF-103 | ✅ Config: "Repetir configuración inicial" (restart_alt → OnboardingFlow) + toggle "Presupuesto estricto" (overBudget). |
| OWF-104 | ✅ LiteHome: delta MoM real (Promise.allSettled 2 meses), pill verde/rojo, timestamp "Actualizado · HH:MM". |
| Deploy | ✅ 134 archivos → owfinances.com, frontend=OK:200 |

**NEXT_ID:** OWF-116
**Pendientes P1:** OWF-101 (JarTemplateSelector en FinancialProfile)
**Pendientes P2:** OWF-105..110, OWF-113..115

## Sesión 2026-06-22 (claude-code) — Revisión IA 18/36 vistas + CORS fix local

**EPIC_VIEWS.md:** `.owf/EPIC_VIEWS.md` creado — tabla viva con 3 cols de verificación (🤖 PW / 🔍 IA / 👤 VB).
- 🔍 IA: 18/36 vistas verificadas en preview (V-01..10, V-14, V-16..22, V-25, C-05)
- CORS backend: añadidos localhost:3000/3000 a `config/cors.php` para dev local
- Pendiente IA: V-11..13 Pro, V-23..24 Onboarding modal, V-26..30 públicas, C-01..C-04

**Sistema dual-check activo:**
- Para marcar VB usuario: escribir "✅ VB V-XX" en el chat
- Para revisar IA las vistas Pro: necesita usuario con plan='pro' en DB local

## Sesión 2026-06-22 (claude-code) — Épica completa + OWF-100..115 registradas

**Épica de vistas:** 30 pantallas inventariadas (V-01..V-30) + 6 componentes globales (C-01..C-06).
- ✅ Cercanas al spec: V-05 Sueños, V-06 Deudas, V-12 Análisis Pro, V-18 Deudas Mobile, V-19 Sueños Mobile, V-25 Login
- 🔶 Implementadas con gaps: V-01..V-04, V-07..V-11, V-13..V-17, V-20..V-24, V-26..V-30
- 🔴 No implementadas: C-03 AccountsPanel Pro, C-06 EntryGate/Empty States
- OWF-100..115: tareas nuevas registradas en TASKS.md (P1: 100-102; P2: 103-107,113-114; P3: 108-110,115)
- NEXT_ID = OWF-116

## Sesión 2026-06-22 (claude-code) — Continuación: OWF-097/098/099

| OWF | Que hizo |
|-----|----------|
| OWF-097 | ✅ OnboardingFlow.vue: modal centrado 540px (no maximized), stage "intro" con avatar IA animado + fases preview + badges, auto-advance chips 280ms, done con completeness ring (SVG %) + level badge (Semilla/Brote/Árbol). TypeScript clean. |
| OWF-098 | ✅ PeriodNavigator.vue (nuevo): grain dropdown agrupado (Cortos/Estándar/Largos/Especiales), prev/next steps, label pill con picker adaptativo por grain (mes grid / quarter grid / semester grid / year grid / date input), "Hoy" button solo cuando no es current. + setAnchor() en period.ts. |
| OWF-099 | ✅ LiteTransactionsView: reemplaza MonthBar+TypeChipsRow con PeriodNavigator. Tipo (Todas/Ingresos/Gastos) ahora dentro del panel como segmented control. loadTransactions usa buildPeriodParams() derivado del period store. watch(period.signature) reactivo. Eliminado tipo "Cántaros" (no está en spec). |
| NEXT_ID | OWF-100 |

## Sesión 2026-06-22 (claude-code) — Completadas

| OWF | Que hizo |
|-----|----------|
| OWF-087 | ✅ LiteHomeView: greeting header "Hola, {nombre}" + toggle ocultar saldos + botón notificaciones. CSS icon-btn. |
| OWF-088 | ✅ Config: "Cuentas vinculadas" rota a /user/accounts. "Divisa predeterminada" en sección Visualización con chevron a Cuentas. |
| OWF-089 | ✅ Profile: avatar cam button (UI), badge Verificado (email_verified_at), secciones separadas (Datos / Contacto+Ubicación / Seguridad), campos city/country/occupation añadidos. |
| OWF-090 | ✅ LiteJarsView: indicador ⚠️ en jar-row cuando balance<0 o progress>100. Edit sheet (nombre/%, color). Delete con confirm dialog. |
| OWF-091 | ✅ Dreams: gradient ya estaba implementado (rgba purple/pink). Verificado sin cambio. |
| OWF-092 | ✅ Debts: status badge con ícono (warning/check_circle) en summary card hero. CSS debts-status-badge. |
| OWF-093 | ✅ Financial Profile: timestamp "Actualizado hace X días" visible bajo subtitle. |
| OWF-094 | ✅ Expense Analysis Pro: hero narrativo "En {mes} registraste X movimientos. Gastaste $Y". Eliminados heroTitle/heroCopy. |
| NEXT_ID | OWF-095 |

## Sesión 2026-06-21 (claude-code) — Completadas

| OWF | Que hizo |
|-----|----------|
| OWF-086 | ✅ ProAnalisis: 3-col grid (280px Vista sidebar | 1fr donut+toplist | 340px budget+insight). budgetRows + insightJar computeds. CSS pro-nav-grid, pro-card, budget-list, top-list, pro-insight. Deploy prod OK. |

## Sesión 2026-06-20 (claude-code — continuación 2) — Completadas

| OWF | Que hizo |
|-----|----------|
| OWF-080 | ✅ Config Pro: heading reemplazado (t-eyebrow + h1 "Preferencias"), q-tabs restaurados. Stitch pill tabs revertidos. Deploy prod OK. |
| OWF-081 | ✅ LiteTransactionsView: type chips (Todas/Ingresos/Gastos/Cántaros) movidos a fila inline siempre visible. MonthBar prev/next navigation. Tipo "Cántaros" nuevo (category=Jar). Deploy prod OK. |
| OWF-082 | ✅ Análisis: Pro heading "Navegador financiero" (t-eyebrow+h1). Lite donut CSS conic-gradient de distribución por cántaro con leyenda. Deploy prod OK. |
| OWF-083 | ✅ Stitch archivado: todo en _archive/stitch-NO-USAR/ (carpeta + zip + skill + docs + html-exports). _archive/ en .gitignore. |

## Sesión 2026-06-20 (claude-code — continuación) — Completadas

| OWF | Que hizo |
|-----|----------|
| OWF-070 backend | ✅ DreamController + DebtController: soporte `per_page`, `sort_by`, `descending` query params. Meta siempre calculado sobre ALL (no el subset paginado). 92 tests pasan. Deploy prod OK. |
| CHECK | ✅ Auditoría completa Dreams+Debts: DebtCard.vue verifica todos los campos (provider icon, status chip, installments, next_due). Nav (BottomNavMobile + LiteNavPill) tiene `/user/dreams` y `/user/debts`. |

## Sesión 2026-06-20 (claude-code) — Completadas

| OWF | Que hizo |
|-----|----------|
| OWF-077 | ✅ LiteHomeView: Dreams+Debts previews con datos reales del API (preview cards, progress bars, status chips). Deploy prod OK. |
| OWF-078 | ✅ Dreams page: redesign completo (hero violeta gradiente, grid cards BEM, progress bars, token-driven). Deploy prod OK. |
| OWF-079 | ✅ AsesorPage: redesign completo (header custom, chat bubbles BEM, typing dots, CTA pills, input bar token-driven, settings sheet). Deploy prod OK. |
| OWF-064 | ✅ Bulk Import: account_name → account_id resuelto en TransactionBulkService antes de validación. 92 tests pasan. Deploy prod OK. |
| OWF-069 | ✅ SmartTransactionModal global: modal Escribir/Voz/Foto/AutoIA montado en AppShell. QuickActionSheet ya no navega a /transactions. Fix P0 raíz. |
| OWF-070 | ✅ Página Deudas completa: backend (migración debts, Debt model, DebtController CRUD+pay, rutas API) + frontend (DebtCard, index.vue con summary card roja, grupos Cashea/Otras, dialogs add/edit/pago/delete). Deploy prod OK. |
| OWF-071 | ✅ Transacciones Lite: goToDetail() corregida → openDetail(tx) + TxDetailSheet (hero amount, tipo, categoría, cántaro, fecha, editar/eliminar). Auto-reload en owf:transaction-saved. Deploy prod OK. |
| OWF-072 | ✅ Cántaros Lite: grid → lista vertical (spec), distribution strip, jar detail sheet (stats 2x2: %, asignado, disponible, uso), "Nuevo cántaro" inline form. Deploy prod OK. |
| OWF-073 | ✅ Configuración: secciones Notificaciones (3 toggles → preferences.notifications), Seguridad (→ /user/profile), Cerrar sesión (destructivo), Exportar datos, section-labels agrupadores. Deploy prod OK. |
| OWF-074 | ✅ Análisis Pro: jar strip (scroll horizontal gasto por cántaro, seleccionable), metric-grid 4-col en Pro mode. Deploy prod OK. |
| OWF-075 | ✅ Exchange Rates widget en ProHomeView: carga /user_currencies → filas editables (rate update vía PUT). Solo visible si hay tasas configuradas. Deploy prod OK. |
| OWF-076 | ✅ Notifications panel: bell → popover desktop (380px anclado) / bottom-sheet mobile. Items con tono (expense/income/warning/info), unread dot, mark-all-read. Montado en AppShell. Deploy prod OK. |

---

## Sesión 2026-06-20 — Auditoría funcional + de-drift board

**Agente:** opencode. **Qué hizo:**
- De-drift TASKS.md: OWF-019 (i18n), OWF-021 (Sentry+FF), OWF-022 (Android) confirmados en código y marcados `[x]`.
- Auditoría funcional profunda (6 áreas) vía subagente. Hallazgos registrados como OWF-061..068.
- **Resueltos y verificados esta sesión** (92 backend tests + vue-tsc + eslint limpios):
  - OWF-061 (CRÍTICA) JARS race → `JarPercentLock` service + 8 sitios + 2 tests regresión
  - OWF-063 (ALTA) Asesor IA → system prompt ahora inyecta jars+perfil (corrige OWF-049)
  - OWF-065 Auth → ensureDefaultAccount idempotente en login
  - OWF-066 JARS updateJar → guard willBeActive restaurado + test
  - OWF-067 MonthlyIncomePanel/useCalculatedIncome → guards NaN
  - OWF-062 (CRÍTICA) Password Reset → ResetPasswordNotification (URL→SPA) + config. **Código listo; falta creds SMTP en prod .env**
- **Rediseño Stitch:** ya sustancialmente integrado (AppShell.vue + design-system.css tokens navy/cyan/Satoshi + Lite*View + LiteHeaderDesktop/NavPill). NO está pendiente desde cero. Lo que falta es fidelidad visual pixel-perfect + de-drift de docs (OWF-068).
- **OWF-018 responsive:** infra confirmada (Playwright proyecto "Mobile Chrome"/Pixel 5 393px + e2e/lite-shell.spec.ts). NaN guard (OWF-067) ya aplicado.

### Hallazgos auditoría (severidad)

| OWF | Sev | Área | Hallazgo | Estado |
|-----|-----|------|----------|--------|
| OWF-061 | 🔴 CRÍTICA | Jars | Race condition suma %: 0 lockForUpdate → concurrent requests persisten >100% | ✅ resuelto |
| OWF-062 | 🔴 CRÍTICA | Auth | Password reset: MAIL_MAILER=log → email nunca llega en prod | 🟡 código listo, falta creds SMTP |
| OWF-063 | 🟡 ALTA | Asesor IA | Contexto rico (jars+perfil) en cache pero NO en system prompt | ✅ resuelto |
| OWF-064 | ⚪ MEDIA | Bulk import | account_name ignorado en income/expense | ✅ resuelto |
| OWF-065 | ⚪ MEDIA | Auth | createDefaultAccount solo en register, no en login | ✅ resuelto |
| OWF-066 | ⚪ MEDIA | Jars | updateJar validación willBeActive comentada | ✅ resuelto |
| OWF-067 | ⚪ BAJA | UI | formatCurrency sin guard NaN | ✅ resuelto |
| OWF-068 | ⚪ BAJA | Docs | docs ui-ux referencian archivos borrados | pendiente |

### Rediseño Stitch — estado real

- **Integrado:** AppShell.vue (shell único), tokens navy `#1E3A8A`/cyan `#0EA5E9`/Satoshi/DM Sans en `src/css/design-system.css`+`theme.scss`, vistas Lite (`LiteHomeView`, `LiteJarsView`, `LiteTransactionsView`), `LiteHeaderDesktop`, `LiteNavPill`, `ExpandedMenu`.
- **Pendiente/incierto:** fidelidad pixel-perfect vs kit (requiere correr app), vistas Pro, mobile kit parity.
- **Stale:** docs `08-11` citan `UserLayout.vue`/`user_dashboard.vue`/`DynamicRoleLayout.vue` (borrados en OWF-056/060).

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

> 061/063/065/066/067 ya resueltos — ver "Sesión 2026-06-20 — Auditoría" arriba.
> 069–076 resueltos por claude-code (verificados contra git commits 58222f3→c00a02f).

| ID | Pri | Tarea | Type |
|----|-----|-------|------|
| OWF-062 | P0 | Password Reset SMTP prod (código listo, falta creds) | fix |
| OWF-004 | P0 | Deploy Staging (bloqueado SSH dev/stage) | infra |
| OWF-005 | P1 | GitHub Secrets por entorno | infra |
| OWF-006 | P1 | Probar deploy stage end-to-end | infra |
| OWF-020 | P2 | Sincronizar DB Stage → Dev | infra |
| OWF-068 | P3 | De-drift docs ui-ux | docs |
| OWF-068 | P3 | De-drift docs ui-ux | docs |
| OWF-018 | P3 | Responsive testing mobile (infra confirmada) | feat |

---

## Blocked

| ID | Razon | Desbloquea |
|----|-------|------------|
| OWF-001 | SSH keys — prod OK. Dev/stage pendientes | OWF-005, OWF-006 |

---

## Stats

| Métrica | Valor |
|---------|-------|
| **Total** | 96 tareas (excluye 7 sub-tareas de OWF-002) |
| **Completadas** | 90 (~94%) |
| **En progreso** | 1 (OWF-062 espera creds SMTP) |
| **Bloqueadas** | 3 (OWF-004/005/006 — SSH dev/stage) |
| **Pendientes** | 4 (OWF-129, 131, 137, 138) |
| **Progreso** | ██████████████████░░ 94% |

---

## Next Up (por prioridad)

1. **OWF-062** — Password Reset: proveer creds SMTP/Resend → set MAIL_MAILER≠log en prod .env (1 línea)
2. **OWF-068** — De-drift docs ui-ux (08-11) a estructura AppShell actual
3. **OWF-064** — Bulk Import: account_name por fila (o documentar UX)
4. **OWF-004/005/006** — Deploy Staging (bloqueado por SSH dev/stage)
5. **Fidelidad visual Stitch** — comparar AppShell+Lite*View pixel-perfect vs kit (correr app)
6. **OWF-018** — correr `npx playwright test --project="Mobile Chrome"` con dev server

---

## Historial Reciente

| Fecha | Agente | OWF | Que hizo |
|-------|--------|-----|----------|
| 2026-06-20 | opencode | reconciliación | Verificó 069-076 contra git (commits 58222f3→c00a02f): todos ✅. Reconcilió TASKS+STATE (071-076 [~]/[ ]→[x]), Stats 60→66 (89%). Sync engram. |
| 2026-06-20 | claude-code | OWF-069..076 | SmartTransactionModal, Deudas, Transacciones Lite detail, Cántaros Lite, Config secciones, Análisis Pro, Exchange Rates, Notifications — todos deployados prod |
| 2026-06-20 | opencode | OWF-061..067 | Auditoría funcional: JARS race (JarPercentLock), Asesor IA contexto, Auth idempotente, NaN guards, Password Reset (código listo, falta creds) |
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
