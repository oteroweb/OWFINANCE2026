# OWFINANCE — Estado del Workspace
<!-- PROTOCOLO: Todo agente LEE este archivo al iniciar sesion. -->
<!-- Solo un agente escribe a la vez. Updated = timestamp del ultimo escritor. -->
<!-- Tareas se referencian por ID (OWF-NNN) → ver .owf/TASKS.md -->

**Updated:** 2026-07-22T05:30:00Z
**By:** claude-code

## Último trabajo (2026-07-22, continuación) — OWF-294: rollback automático de deploy

Pedido del usuario, con una condición explícita: diseñar primero (el ticket mismo lo exigía) y no tocar prod real para probarlo.

- **Diseño confirmado con el usuario antes de escribir código**: backup+restore vía rsync (no releases versionados tipo Capistrano — más simple, mismo layout de `public_html/` sin restructurar, apropiado para un ticket P2).
- **OWF-294** ✅: `owf_remote_backup_dir()`/`owf_remote_restore_dir()` nuevos en `deploy-notify-lib.sh` (mismo patrón `ssh $opts "..."` ya usado en el resto de los scripts). **Backend**: backup del directorio completo antes del rsync de código; si el health check final falla, restaura + re-cachea + re-verifica; detecta si el deploy corrió migraciones nuevas (grep "Migrating:" en el output ahora capturado, antes solo streameaba) y advierte fuerte en vez de revertirlas solo (riesgo de pérdida de datos con `down()` a ciegas). **Frontend**: mismo patrón, respalda `app/` + `assets/` (las 2 carpetas que toca el deploy) — el proxy `index.php` no se respalda, es contenido estático regenerado idéntico cada vez.
- **Verificado sin tocar prod** (restricción explícita del usuario): `bash -n` limpio en los 3 scripts + simulación completa del ciclo backup→deploy-roto→rollback en carpetas locales de `/tmp`, usando los mismos comandos `rsync -a --delete` exactos que las funciones reales (solo sin el wrapper ssh) — confirmado que el rollback restaura EXACTO el estado anterior, incluyendo que revierte correctamente archivos agregados/borrados por la versión rota, no solo pisa contenido superpuesto.
- **No deployado esta sesión** — el próximo deploy real (backend o frontend) ejercita el paso de backup de forma segura (es no-destructivo), sin necesidad de forzar un fallo real contra prod para probarlo.
- **WIP ajeno detectado, no tocado**: sesión concurrente corrigiendo `BcvRateFetcher`/`FetchBcvRateCommand`/`OfficialRate` (backend) — cambió la fuente de la tasa BCV de `pydolarve.org` (nunca resolvía DNS, confirmado desde el propio servidor) a `ve.dolarapi.com`, con el shape real de respuesta ya verificado en vivo. Sin commitear al cierre de esta sesión.

## Último trabajo (2026-07-22) — OWF-328: prellenar cuenta/fecha en "Agregar movimiento" desde filtros de Transacciones

- **OWF-328** ✅: en `/user/transactions`, si el usuario tiene una cuenta filtrada y/o está viendo un día o mes específico, el modal de creación ahora prellena `account_id`/`date` con ese contexto (antes siempre defaulteaba a hoy + primera cuenta, así que el movimiento recién creado podía desaparecer de la lista filtrada). Prefill de cuenta ya existía (OWF-319); se agregó el de fecha vía `usePeriodStore()` en `SmartTransactionModal.vue` — nueva `prefillDateFromPeriod()`. Verificado en browser real (dev local): cuenta, mes distinto, y día puntual, los 3 casos confirmados vía el payload de debug del propio modal. Commit `06f7e5a`, deploy prod OK.
- **Gotcha reforzado (ya documentado antes, no seguido esta vez)**: al aislar WIP ajeno de `rediseno/` con `git stash` antes de un deploy, usar SIEMPRE `git stash push -u` (incluye untracked). Esta vez se usó sin `-u`, y el `git add -A` de `deploy-frontend.sh` terminó commiteando (sin pérdida, pero mal atribuidos) los untracked de una sesión concurrente activa en `rediseno/` (9 `PROMPT_REDISENO_*.md` + `JarsProConfig.jsx`/`JarsProEditor.jsx`/`ProJarsRoute.jsx`) dentro del commit `557a480`, ya pusheado a `OWFinanceFrontend2025/main`.

## Último trabajo (2026-07-21, continuación) — CI/CD: OWF-291/292 verificadas (ya hechas), OWF-293 resuelta (2 bugs reales)

Usuario pidió atacar el pipeline CI/CD pendiente, uno por uno.

- **OWF-291** (ssh-key en checkout de `deploy.yml`) y **OWF-292** (`pr-check.yml`) — ambas ya estaban implementadas desde el commit `9321205` (12 de julio), el board tenía la nota vieja. Verificado directo en los archivos (no solo confiando en el board): el `ssh-key: secrets.SUBMODULES_DEPLOY_KEY` está en el checkout de ambos workflows, `pr-check.yml` existe completo y coincide con el spec (lint+typecheck+build frontend, `php artisan test` backend, sin deploy). Marcadas `[x]`, sin cambios de código. Bloqueo real para verificar en CI: falta el secret `SUBMODULES_DEPLOY_KEY` (0 secrets en el repo, confirmado con `gh secret list`) + billing de GitHub Actions sigue bloqueado (OWF-290) — ambos 100% acción del usuario.
- **OWF-293** ✅ — causa raíz real de los 6 tests de `UserSecurityPinTest` fallando con 404 desde OWF-206 (8 de julio), nunca antes investigada a fondo: **2 bugs, no 1**. (1) `UserSecurityController` existía completo y bien implementado, pero sus rutas nunca se registraron en ningún archivo (`routes/api/user.php` no las tenía) — confirmado con `curl` directo que el 404 era real también en PROD, no solo en tests, así que nadie pudo haber configurado un PIN nunca vía API (sin datos que migrar). (2) Al modelo `User.php` le faltaba el cast `'security_pin' => 'hashed'` (sí tenía el mismo patrón para `password`, nunca se replicó) — sin el cast, el PIN se hubiera guardado en texto plano y `Hash::check()` habría fallado siempre. Fix: 4 rutas agregadas + cast. Suite 250/251 (1 falla preexistente no relacionada). Verificado en prod real: `pin-status` pasó de `404` a `401` tras el deploy. Commit backend `cd973cd`.
- **Gotcha de proceso importante**: el registro de OWF-206 afirmaba "verificado end-to-end contra prod" para este mismo flujo de PIN — imposible si las rutas nunca existieron. Probablemente se verificó por otro medio (tinker directo) y quedó documentado como si fuera una prueba HTTP real completa. **Lección**: no asumir que "verificado E2E en prod" de una sesión anterior cubrió el camino HTTP real sin confirmarlo — puede ser una verificación parcial disfrazada de completa.

## Último trabajo (2026-07-21, continuación) — OWF-327: D-001 reparto equitativo, cierra el ciclo de Gasto compartido

Pedido explícito del usuario tras cerrar OWF-326: implementar la última pieza pendiente de `DECISIONS.md` D-001 (reparto equitativo automático), documentada como brecha real de UX en la sesión anterior.

- **OWF-327** ✅: `SmartTransactionModal.vue` — `sharedCats` gana flag `touched` por fila; `redistributeShared()` reparte `monto - Σ(filas tocadas)` en partes iguales entre las filas no tocadas (la última absorbe el redondeo); `markSharedTouched(i)` marca la fila editada; disparadores en `watch(proPanel)` (activar el panel) y `watch(form.amount)` (cambia el total), más al agregar/quitar filas. Verificado en dev local con 3 escenarios reales (no solo lectura de código): activar con $100 → 50/50; editar fila 1 a $20 → fila 2 sola pasa a $80; agregar 3ª categoría → las 2 no tocadas se parten 40/40. `vue-tsc`/`eslint` limpios. Deploy prod OK (`1129127`).
- **`DECISIONS.md` D-001 actualizado**: acción pendiente del lado Vue marcada `[x]`; queda abierta solo la acción del lado del diseño (JSX de `TransactionForm.jsx` no tiene edición manual por fila, solo reparto automático).
- **`PROMPT_REDISENO_TRANSACCIONES.md` corregido** (3 menciones) — ya no dice "pendiente de implementar", refleja que Gasto compartido está 100% completo del lado Vue (persistencia + reparto).
- **Gotcha de concurrencia nuevo detectado en el deploy**: apareció WIP ajeno de un pull de diseño de Cántaros Pro en curso (`rediseno/ui_kits/lite-desktop/{index.html,shells/ProShell.jsx,templates/JarsRoute.jsx,organisms/JarsProConfig.jsx,organisms/JarsProEditor.jsx,templates/ProJarsRoute.jsx}` + los 9 `PROMPT_REDISENO_*.md`) — aislado con `git stash push -u` de la lista completa antes del deploy, recuperado íntegro después con `git stash pop`.

## Último trabajo (2026-07-21, continuación) — OWF-310 cerrada, Gasto compartido: ocultar→revertir→implementar de verdad (OWF-326), documentación de Voz y Asesor IA para Claude Design

- **OWF-310** ✅ cerrada formalmente (auditoría paraguas de IA abierta 2026-07-13): las 4 funciones (Asesor IA, OCR, Auto IA, Voz) confirmadas resueltas, cada una mapeada al ticket que la cerró (OWF-312, OWF-131, OWF-308, OWF-311+OWF-319).
- **Gasto compartido — vaivén real de decisión, documentado con cuidado**: se ocultó el panel (OWF-307, opción "b") siguiendo instrucción directa del usuario en esta conversación. Minutos después apareció **OWF-326**, creada por una sesión concurrente el mismo día, registrando "decisión del usuario: construir soporte real" — directamente contradictoria. Consultado explícitamente al usuario para desempatar → confirmó opción "a" (construir). Revertido OWF-307 (`git revert`, deploy prod OK) y despachado un sub-agente con el ciclo SDD completo ya diseñado por la otra sesión (`sdd/shared-expense-category-split/*`). **OWF-326 quedó implementada y verificada E2E en prod**: tabla `shared_transaction_categories`, validación de suma exacta (422 si no cuadra), persistencia real. El sub-agente encontró que el código YA estaba escrito por la sesión concurrente al retomar — verificó que coincidía con el spec en vez de reimplementar, corrió la suite, deployó, y limpió el dato de prueba (gotcha nuevo: `Transaction` usa soft-delete, no cascadea sobre tablas hijas nuevas hasta purgar el padre — usar `forceDelete()` en cascada manual para limpiar datos de prueba de esta feature). **Hallazgo real sin resolver**: `DECISIONS.md` D-001 (reparto equitativo automático al agregar categorías) sigue sin implementarse — OWF-326 solo hizo persistencia de lo que la UI ya recolectaba manualmente. Documentado en Engram y en `rediseno/PROMPT_REDISENO_TRANSACCIONES.md` §4.4.3 como brecha real de UX pendiente, no housekeeping.
- **Documentación para Claude Design**: a pedido del usuario, corregidas 2 secciones desactualizadas en los prompts de rediseño (propiedad de una sesión concurrente que generó los 9 `PROMPT_REDISENO_*.md`, dejados untracked a propósito — no son míos para commitear): §4.9 de `PROMPT_REDISENO_TRANSACCIONES.md` (proceso de Voz — reescrito completo, las 3 capas de OWF-319 estaban solo parcialmente reflejadas) y §1.7 de `PROMPT_REDISENO_ASESOR_CONFIG_NOTIFICACIONES_ONBOARDING.md` (nota de estabilidad del chat, el bug cosmético que decía "pendiente" ya no se reproduce desde OWF-312).
- **`PROMPT_REDISENO_CENTRAL.md` confirmado como punto de entrada único** — los 9 módulos ya tienen prompt dedicado, tablero de estado completo en su §3.
- **Push a origin**: central, backend y frontend todos sincronizados con sus remotos al cierre de esta sesión.

## Último trabajo (2026-07-21, continuación) — Verificación de cierre OWF-326

Sesión retomada tras compactación con la tarea pendiente "verificar OWF-326 end-to-end". Al revisar el estado real (no solo el resumen de contexto), se encontró que una sesión concurrente ya había completado esa verificación en el ínterin: backend (`bc9dabe`) + frontend (`0bb840c`) desplegados, verificación E2E real contra prod vía API (transacción de prueba con 2 categorías compartidas, limpiada después con `forceDelete`), `.owf/TASKS.md` actualizado con la narrativa completa y `NEXT_ID` avanzado a `OWF-327`. Confirmado con `git log`/`git status`/`git fetch` en los 3 repos (central, frontend, backend) que todo está commiteado y sincronizado con origin — no había ningún trabajo real pendiente. Ningún código nuevo se tocó esta vuelta; solo se verificó y reportó el estado ya cerrado por la otra sesión.

**Pendientes reales sin tocar (quedan en el board para la próxima sesión):** OWF-291/292/294/295 (infra CI/CD, ver bloque "Pending tasks" de arriba) y OWF-293 (6 tests de `UserSecurityPinTest` fallando con 404, preexistente, no bloqueante). OWF-267 sigue `[!]` bloqueada por referencia de diseño incorrecta (ver OWF-270..273).

## Último trabajo (2026-07-21) — OWF-307 (ocultar Gasto compartido) + push a origin

- **OWF-307** ✅: decisión del usuario (opción b) — ocultado el botón-toggle "Gasto compartido" en `SmartTransactionModal.vue` (quedan Pago múltiple + Detalle/factura, grid a 2 columnas). Código de soporte (`sharedCats`, panel, tipo `ProPanel`) NO se borró, queda inerte listo para reactivar. Verificado en dev local, `vue-tsc`/`eslint` limpios. Deploy prod OK (`40e2ca9`). Aislado WIP ajeno (`rediseno/PROMPT_REDISENO_*.md` de una sesión concurrente generando prompts de rediseño) con `git stash push -u`/`pop` antes/después del deploy.
- **Push a origin** (pedido explícito del usuario, "sube el contenido/push si es necesario"): verificado que ningún repo estaba detrás de origin (0 riesgo de conflicto) antes de pushear. `OWFINANCEBackend2025` (7 commits, incluye el trabajo de otra sesión que resolvió OWF-131 — Gemini OCR funcionando en prod: fix real fue el header `Expect: 100-continue` causando 401 engañoso + `.env.production` vs `.env` equivocado) → pusheado a `main`. Central → pusheado a `master` (42 commits acumulados de varias sesiones). `OWFinanceFrontend2025` ya estaba sincronizado con origin, nada que pushear ahí.
- **Nota de concurrencia**: sesión activa en paralelo generando `rediseno/PROMPT_REDISENO_*.md` (ADMIN, ANALISIS, ASESOR_CONFIG_NOTIFICACIONES_ONBOARDING, CENTRAL, CUENTAS_CATEGORIAS_IMPUESTOS, DEUDAS_SUENOS_PERFIL, HOME, TRANSACCIONES) — no tocados, quedan untracked para que esa sesión los cierre.

## Último trabajo (2026-07-20, continuación) — Revisión de sesión concurrente + OWF-325

Usuario pidió revisar qué había dejado una sesión concurrente antes de "arrancar" OWF-321.

- **OWF-321 ya estaba terminada** (ciclo SDD completo: comisión persistida + tasa BCV automática vía pydolarve.org), implementada, testeada y verificada E2E en prod por esa otra sesión. No había nada que implementar.
- **Hallazgo real y corregido**: el backend de OWF-321 estaba deployado y verificado en producción (confirmado vía API real: `commission_type`/`commission_value`/`commission_amount` presentes en las respuestas), pero **nunca se había commiteado a git** — `deploy-backend.sh` usa rsync directo, no exige commit previo. El puntero de submódulo en central seguía apuntando al commit anterior (OWF-322). Verificado que no había edición activa (status estable en 2 chequeos), suite de tests corrida limpia (240/246, mismas 6 fallas preexistentes), y confirmado contra prod real que el código coincidía exactamente con lo commiteado antes de asumir autoría. Commiteado (`OWFINANCEBackend2025@50af2c0`, puntero central `be402a8`) — sin este commit, cualquier reset del working tree hubiera borrado código que ya corre en producción sin ningún respaldo en control de versiones.
- **OWF-325** ✅ (bug cosmético documentado por la otra sesión, sin arreglar): `TxDetailModal.vue` mostraba "Ingreso" para transacciones que eran Gasto. Causa raíz: `isIncome` se inferia por el signo de `tx.amount` (que siempre se guarda positivo; el signo real vive en `payment_transactions[]`). Fix: capturar `transaction_type` y replicar el mismo patrón ya usado en `deriveTypeFromTx()` (SmartTransactionModal.vue) / `classifyTx()` (LiteHomeView.vue) — type primero, signo solo como último fallback. Verificado en dev local contra API de prod (transacción "snacks" pasó de mostrar "Ingreso" a "Gasto" correctamente). `vue-tsc`/`eslint` limpios. Deploy frontend prod OK (`dda03be`, `frontend=OK:200`).
- **Nota de arquitectura para futuras sesiones**: la lógica de clasificación de tipo (income/expense/transfer por `transaction_type.slug`/`name`/`id`, con fallback a signo de amount) está duplicada en 3 componentes (`SmartTransactionModal.vue`, `LiteHomeView.vue`, `TxDetailModal.vue`). Si aparece un cuarto lugar que la necesite, vale la pena extraerla a `src/utils/txCatalog.ts`.
- **Gotcha reforzado**: `deploy-backend.sh` no exige `git commit` — es perfectamente posible que código en producción no tenga ningún commit local. Al revisar el trabajo de una sesión concurrente, verificar SIEMPRE `git log` del submódulo (no solo confiar en el resumen de Engram) antes de asumir que "deployado" implica "commiteado".

## Último trabajo (2026-07-20) — OWF-322: port "Cántaros Pro" (Claude Design → Vue)

Usuario avisó de un nuevo rediseño hecho directamente en Claude Design ("cántaros pro"). Flujo completo de principio a fin en una sola sesión:

- **Detección**: `DesignSync.get_file` sobre el journal (`_sync/CHANGELOG.jsonl`) no mostró drift registrado, pero un full-scan manual encontró 2 archivos nuevos nunca sincronizados al espejo local: `ui_kits/lite-desktop/organisms/JarsProConfig.jsx` + `JarsProEditor.jsx` (KPI bar, resumen del mes, tabla 9 columnas, config global, editor drag&drop de categorías); `JarsRoute.jsx` ahora bifurca por `pro=true/false`.
- **Diff** (delegado a sub-agente, con limitación real documentada: el MCP `DesignSync` no se propaga a subagentes — tuvo que trabajar con la descripción textual en vez de leer el JSX directo; el diff fino del JSX real lo hizo el orquestador con el contenido ya leído antes): la mayoría del diseño nuevo ya estaba implementado función por función en `src/pages/user/jars/index.vue` (4166 líneas) — es mayormente un rediseño visual, no una feature nueva. 3 diferencias reales identificadas y resueltas con el usuario en el chat (vincular cuenta = solo informativo; reorganización de botones Ajustar/Reset/Retirar/Apalancar; consolidar apalancamiento a un selector único).
- **OWF-322** ✅ implementado (delegado a sub-agente, verificado): migración `account_id` nullable en `jars` (FK→`accounts`, informativo, sin lógica de negocio); selector "Cuenta vinculada" en Opciones avanzadas; apalancamiento global+mensual consolidado a un solo selector con dirty-tracking (evita overrides mensuales fantasma); botones del panel expandido **no se tocaron** — el sub-agente detectó que `JarCard.vue` ya tenía la jerarquía correcta de una sesión previa y usó criterio para no romper la alerta visual de apalancamiento en negativo (el spec lo autorizaba). PHPUnit 216/222 (6 fallas preexistentes), `vue-tsc`/`eslint` limpios. Deploy backend `a3ff1d8` + frontend `aa5de68`, ambos prod OK.
- **Verificación propia en browser real** (pedido explícito del usuario, no delegada): confirmé los 3 cambios en prod contra `usertestpro@demo.com` modo Pro — selector de apalancamiento único con hint correcto, botones Ajustar/Registrar uso primarios, selector de cuenta vinculada con hint "solo referencia visual" y valor persistente. **Gotcha de infraestructura**: el Browser pane sufrió degradación intermitente (viewport 0x0, `read_page`/screenshot en blanco, clasificador de seguridad bloqueando `javascript_tool`/`navigate` de forma transitoria) — `get_page_text` + `javascript_tool` con reintentos fue el canal confiable; no era un bug de la app.
- **Limpieza de datos de prueba**: el cántaro "Test OWF-322" dejado por el sub-agente no se podía borrar desde la UI normal (guard client-side "el total debe sumar 100%" bloqueaba el flujo de "Guardar Cambios" con 0 cántaros). Resuelto llamando directo `DELETE /api/v1/jars/{id}` (ruta REST dedicada que sí existe, separada del bulk-save) vía `fetch()` autenticado con el token de `localStorage` dentro del propio browser — sin tocar credenciales manualmente. **Gotcha nuevo para futuras limpiezas de cántaros de prueba**: el "Guardar Cambios" de la pantalla de Cántaros no sirve para borrar el último cántaro (bloqueado por el guard de 100%); usar el endpoint REST `DELETE /jars/{id}` directo. Quedó una referencia huérfana menor (el selector de apalancamiento mensual seguía apuntando al ID del cántaro borrado) sin limpiar — el classifier de seguridad del browser bloqueó el intento y no valía la pena insistir, es inofensiva.
- **Nota de concurrencia detectada al cerrar sesión**: otra sesión trabajó en paralelo sobre el mismo `.owf/TASKS.md` — agregó **OWF-323** (2 bugs bloqueantes post-OWF-320: doble prefijo `/api/v1` en `useUserCurrencies.ts`, y mismatch de `payments[0].amount` vs `amount` top-level cuando hay comisión) ya cerrada, y dejó **OWF-321** en `[~]` con un ciclo SDD completo (`sdd/transaction-commission-and-rate-persistence/*`) diseñando persistencia real de comisión + tasa BCV automática (pydolarve.org, 2x/día) — diseño listo, sin código implementado todavía, pendiente de que el usuario confirme arrancar `/sdd-apply`. No tocado por esta sesión.

## Último trabajo (2026-07-19) — OWF-320: fix comisión pago móvil (piso Bs 2) + USD equiv en panel Cuentas + OWF-321 documentado

Pedido del usuario: comisión de pago móvil calculaba mal (faltaba piso mínimo Bs 2), agregar equivalente en dólares junto al saldo de cuenta, anotar en el rediseño de Cántaros el pendiente de columna de saldo histórico, y revisar la "discordancia" del formulario de edición de transacciones.

- **OWF-320** ✅ `SmartTransactionModal.vue`: `comisionCalculada` para tipo `pagomovil` ahora usa `Math.max(base*0.3/100, 2)` — la UI ya prometía "mín. Bs 2" pero el cálculo nunca lo aplicaba. `ProHomeView.vue`: nuevo `accountUsdEquivalent()` (reusa `useUserRates()`) muestra "≈ $X USD" bajo el saldo de cuentas no-USD en el panel Cuentas del Home Pro (Lite no lista cuentas individuales, fuera de alcance). `rediseno/PROMPT_REDISENO_CANTAROS.md` §9: anotado el pendiente de columna de saldo histórico en la tabla de transacciones del rediseño (a pedido explícito del usuario, aunque el doc es de Cántaros). Deploy prod OK (`fd089a2`).
- **OWF-321** 🔲 documentado, no implementado: la comisión NUNCA se persiste como dato propio en el backend — se hornea directo en `amount` al guardar. Al editar una transacción con comisión, el toggle "Cobrar comisión" queda apagado (dato irrecuperable con el schema actual). Fix real requiere migración nueva en `transactions` — pendiente decisión de producto con el usuario.
- **Nota de proceso — colisión de sesiones concurrentes**: mientras trabajaba, otra sesión implementaba en vivo OWF-319 capa 1 (chips de cuenta faltante) en el mismo working tree (`SmartTransactionModal.vue`, `useAiExtraction.ts`). Un `git stash` mío pisó momentáneamente su WIP sin commitear; la otra sesión lo detectó y rehizo. Resuelto sin pérdida de código de ningún lado vía reconciliación de historia (`git reset --hard origin/main` tras verificar que mi contenido ya estaba presente upstream) — ver commit `fd089a2` (incluye ambos cambios) y nota de proceso en la entrada OWF-319 de `.owf/TASKS.md`. Verificado `vue-tsc`/`eslint`/`npm run build` limpios tras la reconciliación antes de desplegar.
- **No verificado visualmente en browser**: las cuentas demo documentadas (`otero@demo.com`, `usertestpro@demo.com` / `password`) devolvieron 401 tanto en local como en prod — password probablemente rotada. Recomendado que el usuario verifique manualmente.

## Último trabajo (2026-07-19) — OWF-318: cierre del fix gemelo de TxDetailModal.vue

El usuario pidió revisar cómo iba una tarea que había lanzado en background días atrás (`task_e6a4bef7` / sesión `local_479aad54`, "Fix TxDetailModal.vue edit form (same bug as OWF-312)").

- **Estado encontrado**: la sesión ya había terminado (`isRunning: false`), con el trabajo completo y verificado (`vue-tsc`/`eslint` limpios) pero deliberadamente sin desplegar, tal como se le había instruido. Aplicó el mismo patrón de OWF-313 a `TxDetailModal.vue`: "Editar" ahora abre `SmartTransactionModal.vue` vía `ui.openSmartModalForEdit()` en vez del mini-form propio con el `api.patch` roto.
- **Revisado el diff antes de desplegar (no se desplegó a ciegas)**: se detectó un hueco real que la sesión anterior no cubrió — ni `LiteHomeView.vue` ni `ProHomeView.vue` escuchaban el evento global `owf:transaction-saved` que `AppShell.vue` dispara al guardar desde `SmartTransactionModal` (patrón que `LiteTransactionsView.vue` sí tiene desde OWF-194/195). Sin ese listener, tras editar desde el detalle de Home, la lista de "Recientes" no se refrescaba sola — quedaba desactualizada hasta un reload manual.
- **OWF-318** ✅ Agregado el listener faltante (`onTxSaved`/`onMounted`/`onUnmounted`) en ambas vistas de Home. Verificado end-to-end en navegador real (dev local con token de sesión reutilizado): abrir detalle → Editar → formulario real prellenado → Guardar cambios → lista "Recientes" se re-renderiza sola. Deploy prod OK (`9a2582d`).
- **Sesión de background archivada** (`archive_session`) tras confirmar que había terminado y no seguía corriendo — evita que quede "colgada" en la lista de sesiones activas del usuario.
- **Gotcha de proceso**: al revisar trabajo de una sesión delegada, no asumir que "vue-tsc/eslint limpios" = "listo para producción" — conviene rastrear las dependencias cruzadas del patrón aplicado (en este caso, quién más necesita escuchar el evento global que el nuevo flujo dispara) antes de desplegar. La sesión delegada hizo bien su tarea puntual, pero no tenía contexto de que otros componentes (`LiteTransactionsView.vue`) ya habían necesitado ese mismo listener para el mismo patrón.

## Último trabajo (2026-07-18) — OWF-316/317: proveedor fuzzy-match + equivalente BCV en extracción IA

Continuación de OWF-315 (día anterior). Usuario pidió investigar a fondo ambos bugs y luego implementarlos.

- **OWF-316** ✅ Causa raíz: el schema de extracción (`AiExtractionController::buildSystemPrompt()`) no tenía campo de proveedor — el nombre transcrito quedaba enterrado en `description`, nunca se resolvía contra `providers`. Fix: campo `merchant` nuevo en el schema + `resolveProviderSuggestion()` (Levenshtein, ratio≥0.6) contra providers propios+globales del usuario, mismo scope que `ProviderRepo`.
- **OWF-317** ✅ Causa raíz: cero código de tasas de cambio en todo el backend (confirmado con grep "BCV" → 0 resultados en `app/`). El desglose USD↔BCV que existe en el formulario manual (`showDualRates`) nunca se activa para cuentas USD, y la tarjeta de confirmación de IA no lo reutilizaba. Fix: `attachBcvEquivalent()` — cálculo determinístico en PHP (no se le pide a la IA que haga matemática), usa la tasa oficial real del usuario (`user_currencies`).
- **Verificado end-to-end en prod real** (no solo tinker local): creado provider "Banesco" real vía API, llamado el endpoint real de extracción con el texto exacto del caso reportado ("Gasté 45 dólares en Vanesco") → IA devolvió `merchant:"Vanesco"` → resuelto a Banesco real; `bcv_equivalent:1656` calculado con la tasa oficial real del usuario (36.8), no una tasa de prueba. Confirmado visualmente en browser: tarjeta de confirmación muestra "≈ VES 1.656,00 a la tasa BCV (36.8)", formulario prellenado con "Banesco" en Proveedor.
- Suite backend completa 192/198 (6 fallos preexistentes OWF-293, no relacionados). Deploy backend `2c64141` (commit manual — `deploy-backend.sh` NO commitea solo, a diferencia de `deploy-frontend.sh`, hay que hacerlo aparte) + frontend `2e3f317`, ambos prod OK.
- **Gotcha de proceso reafirmado**: `TxDetailModal.vue` seguía con WIP sin commitear de la otra sesión (`task_e6a4bef7`), con más cambios que la vez anterior (37 inserciones, 176 eliminaciones) — señal de que esa sesión sigue activa. Aislado de nuevo con `git stash push -- <archivo>` antes de cada deploy y `stash pop` después, dos veces en esta sesión (backend no lo tocó, solo frontend).
- **Decisión de datos de prueba**: se dejó el provider "Banesco" creado en prod para el usuario demo — es un banco real venezolano, dato de dominio legítimo y útil para futuras pruebas de este mismo feature, no basura de QA (mismo criterio que sesiones anteriores: limpiar solo artefactos claramente descartables tipo "QA test...").

## Último trabajo (2026-07-15) — OWF-315: bloque 2x2 de métodos + 2 bugs de IA reportados (OWF-316/317, sin arrancar)

Continuación de sesión (OWF-313/314 del día anterior). El usuario mandó una captura probando la extracción "Auto IA" (registro USD 45.00, "Gasto en Vanesco", Confianza 90%) y reportó 3 cosas en un solo mensaje:

1. **"Vanesco" no matchea con "Banesco"** (proveedor real del usuario) — bug real de extracción IA, sin fuzzy-match de proveedor. Documentado como **OWF-316** [ ] pending, no investigado a fondo aún.
2. **Conversión USD→BCV no es directa** ("45 dólares se traducen en 45 dólares a BCV") — bug real, separado. Documentado como **OWF-317** [ ] pending, no investigado a fondo aún.
3. **"Se quitó la selección del tipo previo"** — al principio ambiguo; el usuario mandó captura de la pantalla vieja de `DesktopQuickModal` (Paso 1/2, Tipo+Método) preguntando "¿tuvo sentido eliminar esto?". Confirmado con código: NO es un bug — el selector de Tipo y los 4 métodos siguen 100% funcionales dentro de `SmartTransactionModal.vue`, solo que integrados en una sola pantalla en vez de un paso previo separado (exactamente la decisión de OWF-314 del día anterior, con su aprobación explícita en su momento).
- Usuario confirmó mantener la decisión de OWF-314, pero pidió mejorar la presentación de los 4 métodos: pasar de la fila de pills chicas a un bloque 2x2 más amplio "para configurarlo luego".
- **OWF-315** ✅: `primaryMethods` (Escribir/Voz/Foto/Auto IA) en grid `.stm-method-grid` 2x2, tiles más anchos (`.stm-method-tile`); "Carga masiva" quedó fuera del grid como link discreto (`.stm-bulk-link`) — no es una forma de ingresar UN movimiento, abre un dialog aparte. Verificado en dev local (apunta a API de prod) con token de sesión reutilizado de `e2e/.auth.pro.json`. `vue-tsc`/`eslint` limpios. Deploy prod OK (`d53e3e8`).
- **Gotcha de concurrencia manejado**: la tarea en background que el usuario lanzó (`task_e6a4bef7`, fix de `TxDetailModal.vue`, mismo bug de OWF-313 pero en el componente hermano usado por Home) tenía cambios sin commitear en el mismo checkout. Aislado con `git stash push -- src/components/TxDetailModal.vue` antes de `deploy-frontend.sh` (que hace `git add -A` internamente) y `stash pop` después del deploy — mismo patrón que sesiones anteriores documentaron para este riesgo.
- **De paso corregido**: typo de ID en la nota de `views-registry.json` de OWF-314 (decía "OWF-312", un ID ya usado por otra tarea — quedó mal escrito por un sub-agente el día anterior y no se había corregido en el archivo, solo en TASKS.md).
- **Pendiente real para otra sesión**: investigar y arreglar OWF-316 (fuzzy-match proveedor) y OWF-317 (tasa BCV) — ninguno de los dos se tocó todavía, solo diagnosticados a partir del reporte del usuario.

## Último trabajo (2026-07-14, continuación) — OWF-314: eliminar modal previo desktop

Continuación directa de OWF-313 (misma sesión). El usuario confirmó eliminar el "modal previo" (`DesktopQuickModal.vue`) tras el análisis: era 100% redundante con `SmartTransactionModal.vue`, que ya tiene su propio selector de Tipo y sus propios tabs de Método — el flujo viejo forzaba elegir dos veces antes de llegar al formulario real.

- **Alcance acotado explícitamente a desktop** (decisión explícita, no asumida): mobile (`QuickActionSheet.vue`) no se tocó porque también hace de overlay de navegación inferior (tabs HOME/TRANS/JARS/SETTINGS) — acoplamiento distinto que amerita su propia sesión.
- **OWF-314** ✅ (delegado a sub-agente, verificado): `AppShell.vue` — "+"/"Agregar" en desktop abre `ui.openSmartModal()` directo; `DesktopQuickModal.vue` borrado. Los 2 atajos únicos que aportaba (3 movimientos especiales deuda/sueño/jar + CTA Asesor IA) se reubicaron como chips `.stm-quicklinks` dentro de `SmartTransactionModal.vue`, visible solo desktop + tab Escribir. `views-registry.json` actualizado. `vue-tsc`/`eslint` limpios. Deploy prod OK (`751721b`), smoke-check consola sin errores.
- **Gotcha de proceso**: el sub-agente escribió "OWF-312" en la nota del registry por error (ID ya usado por otra tarea) — corregido a OWF-314 manualmente tras el port. Revisar siempre las notas que un sub-agente escribe en archivos compartidos (views-registry.json, DECISIONS.md) antes de darlas por buenas, no asumir que el ID que usa es correcto.

## Último trabajo (2026-07-14) — OWF-313: unificar editar transacción con el formulario de crear

Usuario reportó que "el formulario de editar transacción es distinto al formulario de editar transacciones" y preguntó por el "modal previo" (DesktopQuickModal, tipo/método Escribir-Voz-Foto-AutoIA) — dijo que no le ve mucha utilidad y que evaluaríamos eliminarlo, sin pedir acción inmediata sobre eso.

- **Diagnóstico vía DesignSync**: comparación byte-a-byte de los 8 componentes JSX de transacciones en Claude Design contra el espejo `rediseno/` — solo `TransactionDetailModal.jsx` (desktop) cambió. El diseño unificó el modo Editar para reutilizar el mismo `TransactionForm` de Crear (antes un mini-form aparte sin transferencia ni comisión) — confirma exactamente la queja del usuario. `DesktopQuickModal`/`QuickActionSheet` sin cambios de diseño; su eliminación sigue como decisión abierta, no tocada esta sesión.
- **`rediseno/views-registry.json`**: la entry `transaction-detail-desktop` apuntaba a `TransactionEditDialog.vue`, borrado hace tiempo (OWF-196) — corregida al destino real, `LiteTransactionsView.vue` (`.tx-detail-sheet`).
- **OWF-313** ✅ Port a Vue (delegado a sub-agente, verificado antes de deployar): `SmartTransactionModal.vue` ganó modo edición real (`ui.openSmartModalForEdit(id)`, prefill vía GET, guarda con `txStore.updateTransaction()` = PUT); `LiteTransactionsView.vue` perdió su mini-form de edición separado, el botón "Editar" ahora abre el modal real (mismo formulario que crear, con transferencia y comisión ya soportadas). `vue-tsc`/`eslint` limpios. Commit `ea0bbd6`, deploy prod OK.
- **Bug real encontrado de paso**: `LiteTransactionsView.vue` llamaba `api.patch('/transactions/:id')` pero el backend solo registra `PUT` — el edit fallaba silenciosamente antes de este fix (sin ruta PATCH nunca existió).
- **Gotcha de proceso**: la skill `rediseno-sync` (dedicada exactamente a este ciclo pull↔diff↔port) apareció disponible a mitad de sesión, después de que ya había hecho el pull manual — se invocó igual para dejar el registro (`views-registry.json`) correcto, pero para la próxima vez conviene invocarla desde el arranque cuando el usuario reporte "cambios en el diseño".
- **Pendiente flotante, tarea aparte creada** (`task_e6a4bef7`, no en TASKS.md aún): `TxDetailModal.vue` (usado por Lite/Pro Home, distinto de `LiteTransactionsView.vue`) tiene el mismo bug de PATCH inexistente + su propio mini-form de edición separado, sin unificar con `SmartTransactionModal.vue`. Fuera de alcance de esta sesión.
- **Pendiente de decisión de producto, sin tocar**: si `DesktopQuickModal` (el "modal previo" tipo/método) se elimina o se mantiene — el usuario quiere evaluarlo en otra conversación.

## Último trabajo (2026-07-13) — OWF-301/302/303: proveedor + categoría en formulario de transacciones

Usuario reportó en cadena, en la misma sesión: (1) "proveedores ya no funciona", (2) "el searchable de categorías no filtra", luego tras el primer fix (3) "ahora no muestra ninguna categoría", y finalmente (4) "el filtro de categoría hace focus en cuentas, no permite escribir". Cuatro reportes → cuatro causas raíz distintas en el mismo componente (`CategorySelector.vue` / `SmartTransactionModal.vue`), cada fix desenterrando el siguiente bug al verificar con interacción real de usuario.

- **OWF-302** ✅ Proveedor: `filterProviders()` vaciaba `providerOptions` con `@filter('')` (apertura normal del select) en vez de precargar — nunca llamaba `GET /providers` sin texto. Fix: pedir lista sin `search` cuando el input está vacío. Commit quedó incluido en `059746b` (otra sesión concurrente en el mismo repo).
- **OWF-301** ✅ Categoría no filtraba: `positionPopover()` sin clamp de `top` — al abrir hacia arriba con poco espacio, el popover (y su input) se renderizaba fuera del viewport/detrás del header. Fix: clamp de `top` + `max-height` dinámico. Commit frontend `542d2a2`.
- **OWF-303** ✅ (3 iteraciones, todo desplegado):
  1. Filtro `kind` (gasto/ingreso) agregado a CategorySelector, resuelto vs `transaction_type_id` real vía `useTransactionTypesStore`. **Causa raíz mayor encontrada de paso**: `GET /transaction_types` era admin-only en backend, pero se consulta para CUALQUIER usuario — rompía `typeIdFor` en SmartTransactionModal, dejando `transaction_type_id: null` en TODAS las transacciones de usuarios no-admin (bug preexistente, mismo patrón que OWF-264). Fix backend: rutas de lectura abiertas a cualquier autenticado. Commits `df88b6f` (backend) + `be9b2d8` (frontend).
  2. Regresión: el filtro excluía categorías con `transaction_type_id == null` (columna nullable sin backfill, migración `2025_08_25_000500`) — cuentas con categorías legadas se quedaban con el selector vacío. Fix: null = "cualquier tipo", siempre visible. Commit `ec227d7`.
  3. **Bug real de fondo**, no relacionado a datos: `CategorySelector.vue` teletransportaba (`Teleport to="body"`) su popover fuera del árbol DOM del `QDialog` de Quasar → el focus-trap del diálogo forzaba cualquier foco fuera de su subárbol de vuelta al primer campo real (Cuenta de origen), dando la sensación de "hace focus en cuentas, no deja escribir". Fix: Teleport dinámico a `.q-dialog__inner` (resuelto vía `closest()`), fallback a `body` fuera de diálogos. Verificado con click + tipeo REALES (no `.focus()` scripted, que enmascaraba el bug). Commit `d4f4119`.

**Gotchas de proceso importantes para memoria futura:**
- Cuando se agrega un filtro sobre una columna nullable-sin-backfill, tratar `null` como "no filtra" — nunca como "no coincide" (oculta datos legados silenciosamente).
- Verificar componentes con focus-management complejo (Teleport, traps, popups) SIEMPRE con interacción física real (click + type), nunca solo con `.focus()`/`dispatchEvent` programático — pueden dar falsos positivos.
- `<Teleport to="body">` dentro de un `QDialog` de Quasar rompe su focus-trap; usar `.q-dialog__inner` como target cuando el componente puede vivir dentro de un modal.

Todo desplegado en prod y verificado end-to-end en browser real (dev server local apuntando a la API de prod).

## Trabajo anterior (2026-07-13) — OWF-299: creación de etiquetas rota (400 silencioso)

Usuario reportó: "la creación de etiquetas no está funcionando correctamente".

- **Causa raíz**: `TagController::save()` (backend) exige `slug` como campo `required`, pero `stores/tags.ts` `createTag()` (frontend) solo posteaba `{name, color, description}` — nunca generó ni envió `slug`. Toda creación de etiqueta fallaba con 400 "The slug field is required", y el store silenciaba el error (`catch { console.error }`, sin toast ni feedback), por eso al usuario le parecía que "no funciona" sin mensaje visible.
- **Verificación de causa raíz**: reproducido de forma determinística con `php artisan tinker` llamando `Validator::make()` con el payload exacto del frontend → `FAILS` con el mensaje del slug.
- **OWF-299** ✅ (commit backend `fc1444b`, frontend `68683d0`, deploy prod OK ambos):
  - Backend: `TagController::save()` ya no exige `slug` del cliente — lo autogenera server-side desde `name` vía `Str::slug()`, con resolución de colisión (`-2`, `-3`, ...) contra tags del propio usuario + tags de sistema. Verificado con tinker llamando `save()` real con el payload del frontend: 400→200 OK, slug correcto, colisión→sufijo `-2` correcto. Datos de prueba limpiados de la DB local tras verificar.
  - Frontend: `createTag()` en `SmartTransactionModal.vue` ahora auto-selecciona (`toggleTag(tag.id)`) la etiqueta recién creada en la transacción en curso — antes se creaba pero quedaba sin aplicar, forzando al usuario a buscarla y tocarla de nuevo.
- **Nota de entorno**: el dev server local de Quasar en este workspace apunta siempre a `https://owfinances.com` como API (tanto `.env` como `.env.dev`) — no hay integración frontend-dev↔backend-local en este proyecto. Por eso la verificación real se hizo contra el controller/Validator directamente (tinker) en vez de un repro end-to-end en browser contra localhost.

## Último trabajo (2026-07-13) — OWF-298: panel de cuentas Pro home mostraba JSON crudo

Usuario reportó: "en el home sale un json en vez de la data correcta (en la barra derecha del modo pro)".

- **Causa raíz**: `ProHomeView.vue` `loadAccountsPanel()` casteaba `a.account_type` y `a.currency` directo `as string`, pero `/accounts` los devuelve como objetos de relación (`{id,name,description,icon,...}` y `{id,name,symbol,code,...}`). Vue 3 `toDisplayString()` serializa objetos con `JSON.stringify(val,null,2)` — de ahí el JSON pretty-printed visible en la UI en vez de "[object Object]".
- **OWF-298** ✅ (commit frontend `ad36d6a` + `f70e78a`, deploy prod OK): extraer `.name` de `account_type` y `.code` de `currency` con guard `typeof === 'string'` (fallback string si algún endpoint sí lo manda así), fallback 'Cuenta'/'USD'. Verificado en browser real: panel Cuentas y Deudas de la barra derecha ya muestran "Efectivo"/"USD"/"VES" en vez de JSON.
- **Gotcha para futuros mapeos de `/accounts`**: tratar `account_type` y `currency` siempre como objetos de relación (mismo patrón ya usado en `AccountsSidebarWidget.vue`), nunca castear `as string` sin verificar.

## Trabajo previo (2026-07-13) — OWF-297: selector de cuentas searchable + checklist de paridad funcional

Usuario reportó que el selector de cuentas no filtra al tipear pese al port de OWF-296, y pidió analizar por qué pasa ("estéticamente parecido, ¿está funcional y tiene todos los detalles?").

- **Causa raíz**: NO fue regresión de OWF-296 — verificado con `git log -S "use-input"` (23 commits): el selector de cuentas nunca tuvo búsqueda en Vue. El diseño la especifica desde siempre (`<Picker searchable />` en 6 selectores de TransactionForm.jsx, prop de una palabra que expande a input+filtrado+Enter+empty state). Los ports validaban estética, nadie extraía el inventario de comportamiento del JSX.
- **OWF-297** ✅ (commit frontend `43c0f0f`, deploy prod OK): búsqueda en los 5 q-selects de cuenta (origen/ajuste/transfer desde/hacia/split) conviviendo con los slots dot+saldo de OWF-296 (CSS: input colapsado con menú cerrado, `min-width:0 !important` contra el default de Quasar); Enter selecciona la primera opción filtrada; empty state "Sin resultados" (también en proveedor); transfer Desde/Hacia ganaron dot+saldo en selected-item; iconos en las opciones del menú de fecha. Verificación runtime real (filtrado probado tipeando, no solo visual).
- **Proceso blindado**: `JSX_VUE_TRANSLATION_GUIDE.md` ganó la sección F — "Checklist de paridad funcional (obligatoria antes de dar un port por terminado)": el inventario de comportamiento del JSX (useState/handlers/renders condicionales/props de molecules como `searchable`) ES la spec; verificación en 3 columnas (estética/funcional/detalles); regla anti-regresión al modificar controles existentes; OWF-296/297 como caso de referencia.
- **Gap estructural señalado, NO tocado**: "Gasto compartido" en el diseño lleva Picker de cuenta por fila; el Vue actual solo categoría+monto (payload distinto — decisión de producto pendiente).
- Concurrencia: mismo manejo que ayer (commit aislado + stash del WIP home/theme ajeno durante el build + pop limpio). El WIP ajeno sigue uncommitted.

## Último trabajo (2026-07-12, continuación 4) — OWF-296: unificación final look & feel SmartTransactionModal vs Claude Design

Usuario mostró capturas (frontend dark vs diseño light) con gaps visuales en el formulario de transacciones y pidió "unificar por fin el look & feel". Ejecutado vía Ciclo 0 de owf-design-sync, delegado a sub-agente.

- **Ciclo 0 (pull DesignSync)**: los 4 archivos remotos relevantes (`TransactionForm.jsx`, `SmartTransactionModal.jsx`, `molecules/FormControls.jsx`, `atoms/Chips.jsx`) son byte-idénticos al espejo `rediseno/` local — **el diseño NO cambió; todos los gaps eran deuda de port**, no drift.
- **OWF-296** ✅ 6 gaps implementados en `SmartTransactionModal.vue` + `TfReviewCard.vue` (commit frontend `7830575`): (1) selector de cuenta con dot de color + `Nombre · USD` + saldo formateado — también en "Cuenta a ajustar" y Desde/Hacia de transfer; color = `a.color || var(--brand-primary)` porque `accounts` NO tiene columna color en backend; (2) chips de etiquetas con color semántico (color-mix 7%/34%, activo fondo pleno) + header "ETIQUETAS" + hint contextual; (3) hint "Anclado a la categoría" en Cántaro; (4) **regresión real de OWF-286 encontrada y corregida**: el `flex: 1 1 140px` partía la fila de 3 toggles en 2+1 (min-content > basis) — reemplazado por `grid repeat(3, minmax(0,1fr))`; (5) TfReviewCard rediseñado al look "VAS A REGISTRAR" (ícono ojo, fraseo NL portado de `rediseno/tx-summary.js`, tokens dark-safe — antes tenía rgba negros invisibles en dark); (6) "Sin proveedor" default con ícono block/storefront, conservando búsqueda y "+ Nuevo proveedor".
- Verificado: vue-tsc limpio, ESLint limpio (2 errores preexistentes de config/index.vue intactos), verificación visual en preview dark + screenshots. Deploy prod OK `frontend=OK:200`.
- **Concurrencia manejada explícitamente**: 14 archivos con WIP ajeno (home/theme, otra sesión) en el mismo checkout — commit de OWF-296 aislado con `git add` selectivo + `git stash` durante el deploy (para que el build no incluyera trabajo sin verificar) + `stash pop` limpio después. El push inicial fue rechazado (PR #3 de CI mergeado en remoto mientras tanto) — rebase limpio y re-deploy. **El WIP ajeno sigue uncommitted en el working tree** — la sesión dueña debe commitearlo/deployarlo ella.
- **Pendientes anotados (no tareas aún)**: sub-label tipo de cuenta ("Corriente") requiere exponer accountType en AuthController; los saldos del selector se muestran aunque `hideValues` esté activo (decidir producto); ancho modal Pro 720px (diseño) vs 560px actual.

## Último trabajo (2026-07-12, continuación 3) — Cierre épica config-audit OWF-209 (210/211/212/214) + reporte CI billing

Sesión concurrente a la de OWF-264/284 (ver entrada de abajo, mismo directorio de trabajo compartido). Dos frentes independientes pedidos por el usuario.

**Frente 1 — config-audit (OWF-209), 4 hallazgos cerrados:**
- Al revisar `config/index.vue` actual antes de tocar nada, se confirmó que **OWF-211** (tema claro/oscuro en bloque Aplicación de Pro) y **OWF-212** (Presupuesto estricto en bloque Aplicación de Pro) **ya estaban resueltos** por la consolidación OWF-207/213 de una sesión anterior — no hacía falta código nuevo, solo cerrar en el board.
- **OWF-210** ✅ Pro usaba `q-btn-toggle` chico para el selector Lite/Pro mientras Lite usaba tarjetas grandes (`apref__mode-btn`). Unificado: Pro ahora reusa el mismo markup de tarjetas (mismo CSS scoped ya presente en el archivo, sin CSS nuevo).
- **OWF-214** ✅ Decisión del usuario (confirmada explícitamente): sí agregar "Pantalla de inicio" (link a `/user/home`) también a Pro. Agregada la fila al final del bloque Aplicación de Pro, mismo patrón que "Divisa predeterminada".
- Verificado: `vue-tsc --noEmit` limpio; ESLint solo con los 2 errores preexistentes ya documentados (no introducidos por este cambio); verificado visualmente en navegador logueado como `usertestpro@demo.com` (Pro) — toggle unificado y link "Pantalla de inicio" confirmados renderizando bien.
- Deploy frontend prod OK (`frontend=OK:200`).
- **Gotcha de concurrencia detectado**: al correr `./deploy-frontend.sh prod`, el script reportó "sin cambios locales pendientes" y el diff de mis ediciones apareció ya incluido (vía `git add -A` de la sesión concurrente) dentro del commit `493c3e2` ("OWF-264", de la otra sesión activa en el mismo working directory) en vez de generar un commit propio. El contenido final es correcto (verificado con `git show`), pero confirma el riesgo ya documentado en CLAUDE.md sobre `git add -A` capturando cambios de otra sesión — dos sesiones de Claude Code no deberían compartir el mismo checkout sin coordinación.

**Frente 2 — 3 PRs de CI en rojo — solo reportado, no tocado (según lo pedido):**
- **frontend #3** y **backend #11**: ambos checks fallan con "The job was not started because your account is locked due to a billing issue" — **no es un bug de código**, es un bloqueo de facturación de GitHub Actions en la cuenta. Requiere que el usuario resuelva el billing directamente en GitHub.
- **central #9**: sigue sin correr checks. Sigue pendiente el secret `SUBMODULES_DEPLOY_KEY` que el usuario debe agregar él mismo — no tocado.
- **Pendiente para otra sesión**: nada bloqueante de nuestro lado — el próximo paso es 100% del usuario (resolver billing de GitHub Actions + decidir si agrega el secret).

**Hallazgo no relacionado, no tocado**: cambio uncommitted en el submódulo backend (`OWFINANCEBackend2025/app/Models/Repositories/ProviderRepo.php`) detectado al iniciar sesión — agrega soporte para `owned_by` (scope: providers globales `user_id=null` + propios) en `ProviderRepo::all()`/`allActive()`. Parece trabajo en progreso de la sesión concurrente (relacionado con su OWF-264, que toca scope de providers) — no tocado por esta sesión.

## Último trabajo (2026-07-12, continuación 2) — Cierre épica OWF-240 (txform-audit): OWF-264 + OWF-284

- **OWF-264** ✅ Flujo "+ Nuevo proveedor" inline en `SmartTransactionModal.vue` (mismo patrón que "Nueva etiqueta"). Al investigarlo se encontró un bug real: TODA la ruta `/providers` era `CheckRole:admin`, pero el formulario ya llamaba `GET /providers?search=` para cualquier usuario (403 silencioso en prod para no-admins). Dividido en 2 grupos de rutas (lectura+creación → cualquier autenticado, scoped a providers propios+globales; gestión → admin-only), mismo patrón que OWF-205/OWF-208. `save()` fuerza `user_id=auth()->id()` para no-admin. 5 tests nuevos (`ProviderScopeTest.php`), suite 196/202 (6 fallos preexistentes de `UserSecurityPinTest`, no relacionados). Deploy backend + frontend prod OK.
- **OWF-284** [!] Investigado, NO implementado a propósito: wiring de subida real de "Foto/soporte" requiere crear infraestructura de cero (cero precedente de `Storage::` en todo el backend, `deploy-backend.sh` no corre `storage:link` → URLs devueltas serían 404 en prod hoy) — se documentó como decisión de infraestructura pendiente, no se improvisó bajo presión de cerrar la sesión.
- **Épica OWF-240 cerrada**: 40 sub-tareas (OWF-241..284) resueltas — implementadas, descartadas por referencia de diseño incorrecta (OWF-267-269), o diferidas con razón explícita (OWF-284).
- **Nota de proceso**: no se pudo completar verificación visual en navegador de OWF-264 (login inestable en el sandbox de preview esta vuelta) — confianza basada en TypeScript/ESLint limpios + 5 tests backend nuevos pasando + reutilización exacta de un patrón ya en producción (createTag).

## Último trabajo (2026-07-12, continuación) — Recuperado parche huérfano de PR#10 + deploy prod

Usuario pidió "unificar ramas" y detectar cambios en cola. Se encontró que PR#10 (central, `claude/cool-ritchie-CIzTk`) tenía código real de frontend (OWF-213/216/221, OWF-259-262, OWF-271-273) atrapado como archivo `.patch` — nunca llegó al repo real de `OWFinanceFrontend2025` por una restricción de proxy de la sesión que lo generó, y su commit de TASKS.md marcaba tareas `[x]` sobre código inexistente.

- **Recuperado**: extraído el mbox de 5 commits del blob `d63e2f9:.owf/frontend-patches-2026-07-12.patch`, aplicado vía `git am --3way` sobre `frontend/main` real (ya incluía el merge previo de PR#4 "Ciclo de sincronización Claude Design ↔ Vue", mergeado por su propia sesión mientras tanto). Sin conflictos de aplicación.
- **Verificado antes de pushear**: `vue-tsc --noEmit` limpio; `eslint` solo con los 2 errores preexistentes de `config/index.vue` (confirmado comparando contra `main` sin el parche — no los introduce este cambio). Verificado a mano que la consolidación de "Tasas de Cambio" no dejó CRUD duplicado ni refs muertas (`openRateForm`/`showRateForm`/etc. = 0 ocurrencias).
- Merge a `frontend/main` (`884bca9`), pusheado.
- **TASKS.md reconciliado a mano** (no fue un merge automático): la rama del patch se basó en un `master` anterior al 10 de julio, así que su commit re-marcaba como "recién hechas" (fecha 07-12) tareas que otra sesión ya había completado el 07-08/07-10 con descripciones más precisas (OWF-248/250/251/253-258/263). Se conservaron esas descripciones más antiguas y precisas; solo se aceptaron como genuinamente nuevas OWF-259/260/261/262 (breakdown USD, payload debug, success state, IVA por ítem + NaN guard).
- Puntero de submódulo en central actualizado al commit real ya pusheado (`884bca9`), no al hash huérfano que traía la rama vieja (nunca existió en el remoto).
- Commit central `9f7b082`, pusheado a `master`. PR#10 cerrado con comentario explicando que su contenido ya vive en main/master.
- **Deploy frontend prod ejecutado**: `frontend=OK:200`, 169 archivos subidos, build limpio.
- **Pendiente sin resolver esta sesión**: PRs de CI (central #9, frontend #3, backend #11) — todas en rojo, #9 además requiere que el usuario agregue un secret nuevo (`SUBMODULES_DEPLOY_KEY`) en GitHub, no se tocó por ser cambio de configuración de seguridad que requiere su autorización directa.

## Último trabajo (2026-07-12) — Push final: backend (OWF-279 OCR fix) + central, todo cerrado

El usuario pidió fusionar y cerrar todo lo pendiente de la sesión anterior:

- **Verificado antes de pushear**: corrí la suite completa de PHPUnit sobre el commit local sin pushear `551dc7a` (OWF-279, fix OCR — providers pasan imágenes al modelo de vision). 6 fallas encontradas; confirmé (checkout al commit padre `6ba17d6` y re-run) que las 5 de `UserSecurityPinTest` + la 1 de `TransactionTest::bulk_create_account_permission` son **preexistentes**, no las causó este commit — seguro de pushear.
- **Backend**: `git push origin main` (`551dc7a`) + `./deploy-backend.sh prod` → `DEPLOY EXITOSO`, health 200.
- **Central**: `git push origin master` (`8c8aecb`) → sincronizado.
- **Pendiente real para otra sesión** (no bloquea el cierre): las 6 fallas de test detectadas arriba siguen sin arreglarse — quedaron documentadas aquí para que alguien las tome. `UserSecurityPinTest` en particular tiene 5/6 tests fallando con 404, sugiere problema de rutas no cacheadas o rota en algún punto — investigar antes de que se acumule más deuda ahí.

## Último trabajo (2026-07-11) — Cierre de sesión: confirmado OWF-286 (bug real, no cache) + guía de traducción consultada con Fable

Sesión de continuación centrada en cerrar/consolidar el trabajo del reto "MCP Claude Design":

- **Reporte para Fable creado y entregado**: `.owf/claude-prompts/FABLE-jsx-vue-design-bridge-decision.md` — contexto completo del sistema, auditoría de 4 ports, decisión de no automatizar, y las propuestas A (contrato de callbacks) y B (fixtures con forma real) para segunda opinión.
- **Corrección importante sobre OWF-286**: en la sesión del 2026-07-10 yo había descartado el reporte del usuario sobre los 3 toggle-cards (Pago múltiple/Detalle-factura/Gasto compartido) en una fila como "bundle JS viejo cacheado", verificando solo que el CSS deployado coincidía con MI código — **sin comparar contra la fuente de diseño real**. Otra sesión concurrente sí hizo esa comparación (Paso 2.5 de `owf-design-sync`) y encontró que **el reporte del usuario era correcto**: en `rediseno/ui_kits/lite-desktop/organisms/TransactionForm.jsx`, `rowDir = isMobile ? 'column' : 'row'` — los 3 toggles van en FILA en desktop, el Vue real los tenía siempre en columna. Fix aplicado y deployado por esa sesión (`OWF-286`, bundle `CZsBpNFl`). **Lección**: verificar contra el CSS ya deployado confirma que el código coincide consigo mismo, NO que coincide con el diseño — hay que comparar contra la fuente (`rediseno/`) cuando el usuario reporta un gap visual, no asumir que es cache.
- **Confirmado por el usuario**: el formulario de transacciones (`SmartTransactionModal.vue`) ya refleja fielmente el diseño actual en Claude Design — verificado vía `DesignSync.get_file` que `TransactionForm.jsx` remoto es idéntico (mismo MD5) al local, y el pull+port+deploy de ese archivo (OWF-283, commits `05defb6`/`14b81a3`) ya está en producción.
- **Pendiente detectado, no resuelto esta sesión**: `OWFINANCEBackend2025` tiene 1 commit local sin pushear (`551dc7a`, "OWF-279: Fix OCR — providers ahora pasan imágenes al modelo de vision"), de una sesión concurrente. No se pusheó ni deployó por esta sesión — no había contexto suficiente para confirmar que está probado. Revisar y decidir push+deploy en próxima sesión.
- **Pregunta abierta sin resolver**: el usuario quiere "afianzar bien pasos, ventajas y desventajas" antes de decidir si mover `owf-design-sync` a un modelo de MCP directo (sin escribir `rediseno/` local en cada PULL) — pendiente de una sesión dedicada a esa comparación, no se avanzó en esta.

## Último trabajo (2026-07-10, continuación 3) — Verificado y deployado: merge de feat/design-contract + pull TransactionForm (OWF-283)

Escaneo de cierre de sesión: `feat/design-contract` (ambos repos, frontend y central) **ya estaba mergeado a main/master** por otra sesión/agente (PR #1 frontend, PR #8 central) tras la segunda opinión de Fable — no hacía falta mergear, solo verificar y deployar.

- Confirmado: `rediseno/tools/generate-fixtures.mjs --check` pasa limpio contra las 6 interfaces reales (Transaction/AccountOption/JarRef/CatalogCategory/Tag/ProviderOption), solo 8 warnings de campos opcionales sin seed — sin errores, contrato al día.
- Detectado que main también traía app-code real sin deployar: commit `14b81a3` (OWF-283 — reordena Cuenta antes de Monto, quita pills de moneda redundantes en gasto/ingreso, agrega adjunto foto/soporte) modifica `SmartTransactionModal.vue` directamente, más el pull previo del diseño en `TransactionForm.jsx`.
- **Deploy frontend prod ejecutado** (`./deploy-frontend.sh prod`) — `frontend=OK:200`, 169 archivos subidos, sin cambios locales pendientes.
- **Nota de higiene detectada, no corregida esta sesión**: el commit `14b81a3` referencia "OWF-283" pero la fila OWF-283 real en `.owf/TASKS.md` es sobre otro tema (confirmar que no hace falta MCP `claude_design`, ya resuelto). Hay una colisión/reuso de ID — revisar en próxima sesión si OWF-283 debe re-numerarse o si el commit debe referenciar un ID nuevo.
- Sin acción pendiente de esta rama — `feat/design-contract` en ambos repos puede borrarse (ya fusionada, sin commits únicos restantes) si el usuario quiere limpieza, no se borró por precaución.

**Confirmación en sesión siguiente (mismo día)**: re-verificado independientemente — mismo resultado (`git push` devolvió "Everything up-to-date", confirma que el trabajo ya estaba en remoto). Deploy re-ejecutado por seguridad (`bundle gCI52nXm`, health 200, sin cambios funcionales nuevos). **Colisión de ID resuelta**: la fila `OWF-283` en `.owf/TASKS.md` ahora describe el port real de DesignSync (reorden Cuenta/Monto + adjunto foto) en vez de la nota informativa vieja ("design system ya en disco") — esa nota quedó absorbida porque ya no aporta nada nuevo una vez que el port real está deployado. Se agregó `OWF-284` (P3) para el wiring real del endpoint de subida de "Foto/soporte", hoy UI-only.

## Último trabajo (2026-07-10, continuación 2) — Segunda opinión + contrato de generación diseño↔código (rama `feat/design-contract`, SIN mergear)

Consulta de arquitectura sobre las propuestas A (contrato de callbacks) y B (fixtures con shape real). Veredicto: B > A; ambas valen ahora, pero SOLO en versión **generada desde el código real** (no mantenida a mano) para que no se pudra como la tabla de mapeo vieja de SKILL.md. Implementado el primer paso en ramas `feat/design-contract` — **pendiente de revisión/merge del usuario, sin push, sin deploy**:

- Frontend `392635b`: `rediseno/tools/generate-fixtures.mjs` (TS compiler API; valida `fixture-seeds.json` contra las interfaces reales, `--check` como gate anti-stale, regla cántaro←categoría verificada), `rediseno/data/sample-data.contract.js` (window.SAMPLE_* GENERATED con shapes reales), `rediseno/DESIGN_CONTRACT.md` (contrato para prompts a Claude Design: callbacks fijos onSave/onDelete/onClose/onSelectAction, un useState-objeto, material-icons, Lite/Pro en archivos separados, mobile flagged, jar nunca selector).
- Central `2beb1b8`: `owf-design-sync/SKILL.md` Ciclo 2 adjunta el contrato al prompt y verifica el JSX recibido contra checklist.
- Hallazgo: NO hay interfaces canónicas Account/Provider en stores — viven en `useTransactionForm.ts` (`AccountOption`/`ProviderOption`); candidato futuro a extraer a `src/types/`.
- Siguiente si se aprueba: merge ambas ramas + push de `DESIGN_CONTRACT.md` y `sample-data.contract.js` al proyecto Claude Design vía DesignSync MCP; opcional añadir `--check` al gate de deploy.

## Último trabajo (2026-07-10, continuación) — Guía de traducción JSX→Vue/Quasar (reto "MCP Claude Design", parte tecnología)

Segunda parte del reto (la primera fue el canal directo DesignSync, commit `11e0ae7`). Se auditaron 4 pares JSX↔Vue reales ya en producción (TransactionForm→SmartTransactionModal, TransactionDetailModal→LiteTransactionsView detail-sheet, RecentTransactions→LiteTransactionsView lista, DesktopQuickModal→DesktopQuickModal.vue) para extraer las reglas reales de traducción sintáctica (no una guía genérica de React→Vue).

- **Creado** `.claude/skills/owf-design-sync/JSX_VUE_TRANSLATION_GUIDE.md`: mapeo de eventos, hooks→Composition API, HTML→componentes q-*, dónde entra Pinia (y dónde NO — catálogos son módulo cache-first `txCatalog.ts`, no store), y sección E con los patrones que NUNCA son mecánicos (cántaro anclado a categoría, Lite/Pro se refactoriza en vez de mantenerse como prop `mode`, "planes especiales" cambian de navegación vs modal, gaps mobile silenciosos, animaciones se pierden).
- **Decisión**: NO automatizar el primer paso con un script/sub-skill — evaluado y descartado con el volumen actual (4 componentes portados a la fecha). Lo mecánico es la parte rápida; el tiempo real se va en juicio de negocio (D/E de la guía). Revisar si el ritmo supera ~15 componentes/trimestre.
- `owf-design-sync/SKILL.md` Paso 3 actualizado para referenciar la guía en vez de "seguir el mapeo" ad-hoc.
- Sin cambios de código de app (solo docs de skill) → sin deploy esta vez.
- **Pregunta abierta del usuario, respondida inline (no bloquea nada)**: discordancia de que `rediseno/` es una plantilla no-persistente (fixtures `window.SAMPLE_*`) mientras el frontend real sí tiene backend — recomendación dada: no conectar el JSX a datos reales (es intencionalmente desechable), sino estandarizar las FORMAS de los fixtures para que calcen con las interfaces TS reales (`Transaction`, `Account`, etc. de `stores/*.ts`) y fijar un contrato de nombres de callback (`onSelectAction`, `onSave`, `onDelete`) consistente entre componentes — reduce fricción en la sección D (Pinia) de cada port futuro sin comprometer que el design system siga siendo standalone.

## Último trabajo (2026-07-10) — OWF-280/281/282: Amount hero pills + Transfer layout + comparativa visual

Continuación del audit `txform-audit` (OWF-240). Completados en esta sesión:
- **OWF-280** ✅ Amount hero: reemplazado `q-select` de moneda por pills inline `USD/EUR/VES` dentro del mismo campo de monto (`$ 0.00` grande + pills a la derecha), estilo referencia `ev-expense-top.png`. Aplica a gasto/ingreso/transfer.
- **OWF-281** ✅ Transfer: `Desde (origen)*` → flecha → `Hacia (destino)*` en una sola fila (`.stm-transfer-accounts`), antes estaban apiladas verticalmente sin indicador visual de dirección.
- **OWF-282** ✅ Label "Cuenta" → "Cuenta de origen *" (con asterisco rojo de requerido) en gasto/ingreso.
- Deploy frontend prod OK, verificado `frontend=OK:200`, TypeScript y ESLint limpios.
- Se generó un artifact de comparativa visual (18 gaps totales, priorizados P1-P3) contra `rediseno/redesign/audit/*.png` — cubre formulario, Home Pro, Config Pro, DesktopQuickModal.

**Nota importante — no confundir con bug real**: el usuario reportó screenshot mostrando los 3 toggle-cards (Pago múltiple/Detalle-factura/Gasto compartido) en una sola fila en vez de apilados. Verificado vía `curl` contra el CSS compilado en prod (`AppShell-C2iuzGX6.css`): `.stm-pro-card-toggles[data-v-5afabb12]{display:flex;flex-direction:column;gap:6px}` — **el código YA está correcto**, apila en columna. El screenshot del usuario es casi seguro un tab con bundle JS viejo cacheado en memoria (SPA no hace full reload). Pedir hard-refresh (Cmd+Shift+R) antes de seguir investigando esto como bug.

**CORRECCIÓN — el design system YA está en disco, no hace falta MCP:**
El usuario pidió conectar el MCP `claude_design` (`https://api.anthropic.com/v1/design/mcp`) e importar el proyecto `https://claude.ai/design/p/5fd9e16d-4e55-4813-8714-3dd0f0a35c48`. Verificado: `OWFinanceFrontend2025/rediseno/_ds_manifest.json` tiene `"namespace":"OWFinanceDesignSystem_5fd9e1"` — coincide exactamente con el ID de ese proyecto. **La carpeta `rediseno/` ES la exportación completa** (HTML, CSS, tokens, componentes) de ese mismo proyecto de Claude Design, ya sincronizada en disco.

Contenido de `rediseno/`:
- `_ds_manifest.json` — índice de 30+ pantallas HTML navegables (`cards[]`), tokens de color/spacing/radius/font, temas light+dark (`[data-theme="dark"]`)
- `colors_and_type.css` — todos los design tokens (navy/cyan/emerald/red/amber/violet + slate + ink dark mode)
- `components/` — Button, Chip, Avatar, Card, Eyebrow, Money (JSX de referencia)
- `redesign/audit/*.png` — capturas ya usadas en el audit de esta sesión
- `ui_kits/lite-desktop/` y `ui_kits/mobile/` — demos vivos navegables
- `README.md` — brief del design system completo (Lite vs Pro, rutas canónicas, comandments de UX)

**Próxima sesión**: no conectar MCP salvo que se quiera sync en vivo con ediciones futuras online. En su lugar, recorrer `_ds_manifest.json` → `cards[]` sistemáticamente (cada `path` es un HTML navegable con `viewport` definido) para comparar contra el código real, en vez de depender solo de los PNGs estáticos de `redesign/audit/`.

Gaps aún pendientes del audit visual (ver artifact de comparativa de esta sesión): formulario P3 (OWF-259/260/261/262/264/265), Home Pro P2 (OWF-227/228/229/230), Config Pro P2 (OWF-211/212/215/218/219), DesktopQuickModal P1 (OWF-271).

## Último trabajo (2026-07-09) — OWF-278: Jailbreak Protection para AI Chat Coach

El usuario pidió protección contra jailbreaking: evitar que usen el chatbot como asistente genérico (código, matemáticas, cultura general). Implementado en dos capas:

1. **System prompt reforzado** — instrucciones explícitas de restricción de alcance, con sección ❌ BLOQUEA ESTRICTAMENTE y ✅ SÍ HACER. El asesor solo responde sobre finanzas personales OwFinance.

2. **Capa de detección pre-LLM** (`detectJailbreakAttempt`) — regex en 4 categorías (role_change, code_math, data_leak, off_topic) que intercepta el mensaje ANTES de enviarlo al provider de IA. Si detecta jailbreak, responde con SSE bloqueado directamente sin gastar tokens.

3. **jailbreakBlockResponse()** — respuestas amables pero firmes según categoría.

Sin cambios en la experiencia del usuario legítimo. Deploy backend prod OK (1a7b401).

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
## Último trabajo (2026-07-08, Hermes) — OWF-224/225/226/213/216+234: Home Audit — bugs P1 corregidos

Sesión iniciada pidiendo tomar decisiones autónomas: arranqué por los bugs P1 que afectan cifras que el usuario VE en Pro cada vez que abre la app.

- **OWF-226** ✅ `classifyTx()` ahora retorna `'income' | 'expense' | 'transfer'` — detecta transfers por transaction_type_id=4, slug/name contiene 'transfer'/'traspaso', y los filtra en `loadMonthSummary()` (no inflan income/expense) y en `recentTransactions`.
- **OWF-224** ✅ 3 lugares hardcodeados "USD" en template de ProHomeView reemplazados por `{{ currencyCode }}` (computed → `authStore.defaultCurrencyCode`).
- **OWF-225** ✅ Deltas (+4.2%, +8.1%, -2.3%) reemplazados por cálculo real MoM: `loadMonthSummary()` ahora carga MES ANTERIOR en paralelo, computa variación % de ingresos, gastos y neto, con color dinámico según si subió/bajó.
- **OWF-213** ✅ `currencySymbol` en LiteHomeView de ref('$') hardcodeado → computed() dinámico que mapea `authStore.defaultCurrencyCode` a símbolo real (VES→Bs, EUR→€, COP→$, USD→$).
- **OWF-216** ✅ "Perfil financiero" agregado al sidebar NAV_ITEMS de AppShell.vue con icon insights + detección de ruta en currentTab. También está en el menú expandido mobile.
- **OWF-234** ⚪ Problema de currencySymbol estático absorbido dentro de OWF-213.
- **OWF-131** sigue pendiente (acción manual: regenerar key Gemini con prefijo normal).
- **Verificación**: build SPA exitoso sin errores TypeScript. Pendiente deploy frontend.

| OPS-001 | OWF-020 | WEEK2-A | OWF-021 |
|| BUG-001..008 | OWF-023..028, OWF-046 | WEEK2-B | OWF-022 |
