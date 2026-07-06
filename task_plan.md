# Task Plan — Épica de Transacciones OWFinance
**Iniciado:** 2026-06-29  
**Estado:** PLANIFICACIÓN  
**OWF IDs:** OWF-153 a OWF-162

---

## Objetivo

Implementar el rediseño completo del módulo de transacciones según los archivos del zip `rediseno/` (2026-06-29).

**Principio central no negociable:**
> El cántaro NUNCA se elige a mano. Entra anclado a la categoría.  
> `categoría seleccionada → jarForCategory() → chip read-only con 🔒`

---

## Estado actual del código (diagnóstico)

### Backend
| Elemento | Estado actual | Necesita |
|---|---|---|
| `categories` tabla | Tiene `user_id`, `icon`, `type` — NO tiene `jar_id` directo | — |
| `jar_category` tabla | ✅ Existe (pivot M:N jar↔category) | Exponer via API |
| `Category` model | Sin relación `jars()` | Agregar belongsToMany |
| `GET /categories` response | Devuelve categorías SIN jar_id | Incluir jar_id del pivot |
| `CategorySeeder` | 10 categorías de factory (ficticias) | Seed 15 categorías canónicas |
| `POST /transactions` | ✅ Acepta `category_id` | Aceptar también `jar_id` derivado |
| Transaction API response | Devuelve `category_id` + relación `category` | ✅ OK |

### Frontend  
| Componente | Líneas | Estado actual | Necesita |
|---|---|---|---|
| `SmartTransactionModal.vue` | 827 | category_id en form ✅, sin AnchoredJarChip, sin jar_id en submit | Chip + jar_id |
| `LiteTransactionsView.vue` | 1140 | Detail sheet básico (view+delete+edit), editar abre dialog legacy | Upgrade sheet completo |
| `TransactionFormDialog.vue` | ~400 | Form completo SIN category ni jar | Category + chip |
| `TransactionEditDialog.vue` | ~600 | Edit form SIN category ni jar | Category + chip |
| `TransactionForm.vue` | 60 | Skeleton vacío (name/amount/date) | Reemplazar o ignorar |
| `transactions.ts` store | 300+ | Transaction interface sin category_id typed | Agregar category_id |
| `AnchoredJarChip.vue` | — | NO EXISTE | Crear desde cero |
| `src/utils/txCatalog.ts` | — | NO EXISTE | Crear desde cero |

### Puntos clave descubiertos
1. El `tx-detail-sheet` en `LiteTransactionsView` ya muestra `detailTx.jarName` y `detailTx.jarColor` — pero solo si la TX tiene esos datos. El API actualmente NO devuelve jar en la respuesta de transacciones.
2. Al hacer clic en "Editar" desde el detail sheet, se abre `TransactionFormDialog` (legacy). Esto hay que cambiar a edición inline en el sheet.
3. `jar_category` ya existe en el backend — solo hay que exponerlo en la API.
4. Categorías con `user_id = null` son globales (el endpoint `tree()` lo respeta). Las 15 canónicas deben ir como globales.

---

## Bloques de trabajo

```
BLOQUE A (Backend)      BLOQUE B (Foundation)
    ↓                       ↓
BLOQUE C (SmartModal)   
    ↓
BLOQUE D (Detail Sheet) ← mayor impacto usuario
    ↓
BLOQUE E (Form Dialog)  BLOQUE F (Mobile Pro)
    ↓
BLOQUE G (Housekeeping)
```

---

## Fases del plan

### FASE 0 — Backend prerequisito `[P0]`

**OWF-159** — Backend: exponer jar_id en GET /categories  
- Agregar `jars()` belongsToMany a `Category` model (via tabla `jar_category`)
- Modificar `CategoryRepo::all()` y `allActive()` para eager-load primer jar
- Modificar `CategoryController::all()` — respuesta incluye `jar_id: int|null, jar_name: string|null, jar_color: string|null`  
- Modificar `CategoryController::allActive()` igual
- **Archivo:** `app/Models/Entities/Category.php`, `CategoryRepo.php`, `CategoryController.php`
- **Test:** `GET /api/v1/categories` devuelve `[{ id, name, jar_id, jar_name, jar_color, ... }]`
- **Estimado:** 1 hora

**OWF-160** — Backend: seed de 15 categorías canónicas con jar links  
- Crear `CanonicalCategorySeeder.php` con las 15 categorías de `tx-catalog.js`
- Cada categoría: `user_id = null` (global), `icon` del catálogo, `type = 'category'`
- Después de crear cada categoría: insertar en `jar_category` el jar correspondiente
- Jars se buscan por `name` (ej. "Necesidades básicas" → jar_id)
- Idempotente: si ya existe la categoría por nombre, solo actualizar/vincular el jar
- Ejecutar `php artisan db:seed --class=CanonicalCategorySeeder` en prod
- **Archivo:** `database/seeders/CanonicalCategorySeeder.php`
- **Estimado:** 1.5 horas

---

### FASE 1 — Foundation Frontend `[P1]`

**OWF-153** — `src/utils/txCatalog.ts` (revisado)  
- Composable que carga categorías desde `GET /categories` con jar_id ya incluido
- Cachea en memoria: `Map<categoryId, { jarId, jarName, jarColor, jarIcon, jarPercent }>`
- Expone: `jarForCategory(categoryId: number) → JarRef | null`
- Expone: `loadCategoriesWithJars()` (llama API si no cacheado)
- NO mantiene estado propio de los jars — los jars se leen de las categorías
- **Archivo:** `src/utils/txCatalog.ts`
- **Estimado:** 1 hora

**OWF-154** — `AnchoredJarChip.vue`  
- Props: `categoryId: number | null`, `size?: 'sm' | 'md'` (default 'md')
- Estado 1 (sin categoría): placeholder dashed con texto "El cántaro entra con la categoría"
- Estado 2 (categoría sin jar): "Esta categoría no aporta a ningún cántaro" (bloque)
- Estado 3 (con jar): chip coloreado con `jar.color`, ícono, nombre, `%`, ícono 🔒
- Internamente llama `jarForCategory(categoryId)` de txCatalog
- **Archivo:** `src/components/AnchoredJarChip.vue`
- **Estimado:** 1 hora

---

### FASE 2 — SmartTransactionModal `[P1]` — PRIORIDAD ALTA

**OWF-155** — SmartTransactionModal: cántaro anclado + jar en submit  
Sub-tareas:
- **155a** — Import y usar `AnchoredJarChip` bajo el q-select de `category_id` en la tab "Escribir"
- **155b** — En `save()`: derivar `jar_id = jarForCategory(form.category_id)?.jarId ?? null` antes del POST
- **155c** — Incluir `jar_id` en el payload del POST `/transactions`
- **155d** — En `applyAiResult()`: ya resuelve `category_id` — también derivar jar_id al aplicar
- **Archivo:** `src/components/SmartTransactionModal.vue`
- **Estimado:** 1.5 horas

---

### FASE 3 — Transaction Detail/Edit Sheet `[P1]` — MAYOR IMPACTO

**OWF-156** — Upgrade tx-detail-sheet en LiteTransactionsView  
Sub-tareas:
- **156a** — Mostrar `AnchoredJarChip` en el detail sheet (reemplaza la fila simple jarName/jarColor)
- **156b** — El API de transacciones necesita incluir jar en la respuesta: añadir `with('category.jars')` en TransactionController (backend mínimo adicional)  
- **156c** — Agregar modo edición INLINE en el sheet (sin abrir TransactionFormDialog):
  - Toggle view ↔ edit dentro del mismo bottom sheet
  - Campos editables: concepto, monto, tipo, categoría (+ AnchoredJarChip), cuenta, fecha
  - Botón "Guardar" → PATCH /transactions/:id con jar_id derivado
  - Botón "Cancelar" → vuelve a vista
- **156d** — Acción "Duplicar":
  - POST con misma data + concepto " (copia)"
  - Toast + refresh de lista
- **156e** — Confirm de eliminación INLINE (no q-dialog separado) — botón "Eliminar" → confirm en el pie del sheet
- **Archivo:** `src/pages/user/transactions/LiteTransactionsView.vue`
- **Backend toque:** `TransactionController` → cargar jar via `category.jars` en response
- **Estimado:** 3 horas (la tarea más grande)

---

### FASE 4 — TransactionFormDialog & EditDialog `[P2]`

**OWF-161** — TransactionFormDialog + TransactionEditDialog: category picker + jar anclado  
Sub-tareas:
- **161a** — Agregar campo `category_id` al `useTransactionForm` composable (o al form state del dialog)
- **161b** — Agregar q-select de categoría en `TransactionFormDialog.vue` (fila junto a Provider)
- **161c** — Agregar `<AnchoredJarChip :category-id="form.category_id" />` bajo el selector
- **161d** — Incluir `jar_id` derivado en el payload del saveCreate / saveUpdate
- **161e** — En `TransactionEditDialog.vue`: cargar `category_id` de la TX al abrir (loadFromTransaction)
- **Archivo:** `TransactionFormDialog.vue`, `TransactionEditDialog.vue`, composable `useTransactionForm.ts`
- **Estimado:** 2 horas

---

### FASE 5 — Mobile Pro features `[P2]`

**OWF-157** — Mobile TransactionFormSheet Pro (comisiones, split, items)  
Contexto: Solo se muestra en `layout_mode === 'pro'` en mobile.  
Sub-tareas:
- **157a** — Toggle "Comisión": fija ($), porcentaje (%), pago móvil (BCV 0.30%)
  - Muestra comisión calculada + total (monto + comisión)
  - Se incluye en el payload del POST como campo adicional o en `items`
- **157b** — Toggle "Pago compuesto" (split):
  - N filas de cuenta + monto; suma debe igualar monto total
  - Genera `payments: [{ account_id, amount }, ...]` (ya soportado en backend)
- **157c** — Toggle "Monto por artículos" (factura):
  - Lista de ítems: nombre + cantidad + precio unitario
  - Total sube al monto principal
  - Genera `items: [{ name, quantity, amount }]` (ya soportado en backend)
- **Qué existente tocar:** `QuickActionSheet.vue` (mobile Pro) o crear `ProTransactionSheet.vue`
- **Estimado:** 3 horas

---

### FASE 6 — Housekeeping `[P3]`

**OWF-158** — Commit rediseno + DS sync  
- `git add rediseno/` y commit con mensaje referenciando OWF-153..162
- Verificar tokens nuevos en `_ds_bundle.js` vs `src/css/app.scss`
- Actualizar/eliminar `rediseno.zip` del repo
- **Estimado:** 30 min

---

## Orden de ejecución

```
FASE 0: OWF-159 → OWF-160   (backend, prerequisito)
    ↓
FASE 1: OWF-153 → OWF-154   (foundation frontend)
    ↓
FASE 2: OWF-155              (SmartModal — el más usado)
    ↓
FASE 3: OWF-156              (Detail/Edit sheet — mayor impacto UX)
    ↓
FASE 4: OWF-161    FASE 5: OWF-157   (paralelo, independientes)
    ↓
FASE 6: OWF-158              (housekeeping)
```

---

## Riesgos y decisiones

| Riesgo | Mitigación |
|---|---|
| Categorías canónicas pueden colisionar con categorías existentes del usuario | Seed como `user_id=null` (global); si el usuario ya tiene categorías propias, las globales se suman sin reemplazar |
| Transaction API no devuelve jar → detail sheet no puede mostrar chip | Añadir `with('category.jars')` mínimo en el TransactionController list endpoint (OWF-156b) |
| `jar_category` puede estar vacío en prod (no hay links aún) | OWF-160 lo siembra; hasta que se ejecute el seeder, el chip muestra "sin cántaro" (graceful) |
| `TransactionFormDialog` legacy puede romper si le añadimos category | Testear en screen > md (desktop) y en mobile — son dos contextos distintos |
| Usuarios con layout_mode=lite no deben ver comisiones/split | Feature flag por `auth.settings.layout_mode === 'pro'` antes de montar el bloque |

---

## Criterio de done por fase

| Fase | Criterio |
|---|---|
| FASE 0 | `GET /api/v1/categories` en prod devuelve `jar_id` en cada item. Seed ejecutado. |
| FASE 1 | `txCatalog.jarForCategory(1)` devuelve el jar correcto. Chip se renderiza en los 3 estados. |
| FASE 2 | Abrir SmartModal → seleccionar categoría → chip aparece → guardar → tx tiene jar_id en DB. |
| FASE 3 | Clic en tx de la lista → sheet muestra chip de jar correcto → editar inline → guardar → lista se actualiza → duplicar funciona. |
| FASE 4 | Abrir TransactionFormDialog → seleccionar categoría → chip aparece → guardar. |
| FASE 5 | En Pro mobile, toggle comisión → total correcto. Toggle split → se puede distribuir en N cuentas. |
| FASE 6 | `git status` limpio en rediseno/. |

---

## Progress tracker

| ID | Fase | Estado | Notas |
|----|------|--------|-------|
| OWF-159 | 0 | [x] done | Backend: jar_slug en GET /categories — formatCategories() con mapa canónico |
| OWF-160 | 0 | [x] done | Backend: CanonicalCategorySeeder.php creado y ejecutado en local |
| OWF-153 | 1 | [x] done | txCatalog.ts — loadCategoriesWithJars, loadUserJars, jarForCategory |
| OWF-154 | 1 | [x] done | AnchoredJarChip.vue — 3 estados, auto-load, TypeScript limpio |
| OWF-155 | 2 | [~] in_progress | SmartTransactionModal |
| OWF-156 | 3 | [ ] pending | LiteTransactionsView detail sheet |
| OWF-161 | 4 | [ ] pending | TransactionFormDialog + EditDialog |
| OWF-157 | 5 | [ ] pending | Mobile Pro features |
| OWF-158 | 6 | [ ] pending | Housekeeping |

---

## Archivos clave por tarea

| Tarea | Archivos backend | Archivos frontend |
|---|---|---|
| OWF-159 | `Category.php`, `CategoryRepo.php`, `CategoryController.php` | — |
| OWF-160 | `CanonicalCategorySeeder.php` (nuevo) | — |
| OWF-153 | — | `src/utils/txCatalog.ts` (nuevo) |
| OWF-154 | — | `src/components/AnchoredJarChip.vue` (nuevo) |
| OWF-155 | — | `src/components/SmartTransactionModal.vue` |
| OWF-156 | `TransactionController.php` (toque mínimo) | `src/pages/user/transactions/LiteTransactionsView.vue` |
| OWF-161 | — | `TransactionFormDialog.vue`, `TransactionEditDialog.vue`, `useTransactionForm.ts` |
| OWF-157 | — | `src/components/liquid/QuickActionSheet.vue` o nuevo `ProTransactionSheet.vue` |
| OWF-158 | — | `rediseno/` (commit) |

---

## Errores conocidos (actualizar aquí si ocurren)

| Error | Intento | Resolución |
|---|---|---|
| — | — | — |
