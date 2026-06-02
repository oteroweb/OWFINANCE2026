# Modos LITE vs PRO — OWFINANCE 2026

> Documento de producto + especificación funcional. Define la distinción entre los dos modos
> de uso de la app y qué debe funcionar en cada uno. Es la referencia para implementar el
> "gating" (qué se muestra/permite por modo).
> Última actualización: 2026-06-02. Estado: **borrador para validación de producto**.

---

## 1. Filosofía

| | **LITE** | **PRO** |
|---|----------|---------|
| Audiencia | Usuario que quiere simplicidad | Usuario que quiere control total |
| Mental model | "Tengo cántaros con saldo" | "Tengo cuentas y cántaros, y trackeo todo" |
| Prioridad | **Facilidad y velocidad** de registro | **Precisión y trazabilidad** |
| Forma | Mobile-first, compacto | Desktop denso, analítico |
| Trackeo de cuentas | ❌ No (solo saldo de cántaros) | ✅ Sí (multi-cuenta, multi-moneda) |

> Mismo design system, misma base de datos. PRO = LITE + capas de cuentas, transacciones
> avanzadas y analítica. **LITE es un subconjunto de PRO**, no un producto distinto.

---

## 2. Estado en el código (punto de partida)

Ya existe infraestructura de modo (hoy es **densidad visual**, se reutiliza para **gating funcional**):

| Pieza | Archivo | Rol |
|-------|---------|-----|
| Enum de modo | `src/utils/layoutMode.ts` | `'legacy' \| 'pro' \| 'lite'` |
| Persistencia | `auth` store → `layout_mode` | Guarda el modo del usuario (backend `user_settings`) |
| Selección | `OnboardingModal.vue` | El usuario elige LITE o PRO al entrar |
| Ruteo de layout | `DynamicRoleLayout.vue` | lite→`LiteMobile/LiteDesktopLayout`, pro→`ProLayout` |
| Home dinámico | `DynamicHomePage.vue` | lite→`LiteHomeView`; **ProHomeView pendiente** |
| Shells | `LiteMobileLayout`, `LiteDesktopLayout`, `ProLayout`, `LegacyLayout` | — |

**Brechas actuales**: `ProHomeView` no construido; el gating LITE es solo visual (recorta menú a
4 items, oculta secciones en `jars/index.vue`), **no** limita funcionalmente las transacciones.

---

## 3. Matriz funcional (qué hace cada modo)

✅ disponible · ⚠️ simplificado · ❌ oculto/no disponible

### Cántaros
| Capacidad | LITE | PRO |
|-----------|:----:|:---:|
| Ver cántaros con saldo | ✅ | ✅ |
| Crear/editar cántaros (% o fijo) | ✅ | ✅ |
| Plantilla 55/10/10/10/10 | ✅ | ✅ |
| Meta de ahorro (`target_amount`) | ✅ | ✅ |
| Transferir entre cántaros | ⚠️ básico | ✅ |
| Ajustes manuales de cántaro | ❌ | ✅ |
| Apalancamiento entre cántaros | ❌ | ✅ |
| Ciclos / histórico mensual | ⚠️ resumen | ✅ detalle |
| Base por categorías (`base_scope`) | ❌ (solo all_income) | ✅ |

### Cuentas
| Capacidad | LITE | PRO |
|-----------|:----:|:---:|
| Trackeo de cuentas | ❌ | ✅ |
| Multi-moneda (USD/EUR/VES) | ❌ (1 moneda) | ✅ |
| Tipos de cuenta (banco, tarjeta, efectivo, cashea) | ❌ | ✅ |
| Carpetas de cuentas | ❌ | ✅ |
| Cuentas compartidas | ❌ | ✅ |
| Impuestos por cuenta | ❌ | ✅ |

### Transacciones
| Capacidad | LITE | PRO |
|-----------|:----:|:---:|
| Registrar ingreso | ✅ | ✅ |
| Registrar gasto (imputado a cántaro) | ✅ | ✅ |
| Elegir cuenta de origen | ❌ | ✅ |
| Transferencia entre cuentas | ❌ | ✅ |
| Transferencia cross-currency con tasa | ❌ | ✅ |
| Pago múltiple (varias cuentas) | ❌ | ✅ |
| Ítems por línea + cantidad | ❌ | ✅ |
| Impuestos (IGTF, pago móvil) | ❌ | ✅ |
| Ajuste de saldo | ❌ | ✅ |
| Carga masiva (bulk import) | ❌ | ✅ |
| Saldo inicial de cuenta | ❌ | ✅ |

### Analítica / UI
| Capacidad | LITE | PRO |
|-----------|:----:|:---:|
| Home resumido | ✅ (`LiteHomeView`) | ✅ (ProHomeView — **pendiente**) |
| Análisis de gastos / charts | ⚠️ básico | ✅ completo |
| Menú lateral | ⚠️ 4 items clave | ✅ completo |
| Densidad | compacta (mobile) | densa (desktop) |

---

## 4. Modelo de gasto en LITE ✅ (decidido 2026-06-02)

**Decisión: billetera implícita única (opción A).** En LITE el usuario tiene **una sola
cuenta-billetera** donde está todo su dinero — *dónde* está el dinero "es lo de menos".

- Al crear/activar LITE, se garantiza **1 cuenta única** por usuario (oculta en la UI).
- Un **gasto** baja el saldo del cántaro elegido y se asocia a esa billetera única.
- Un **ingreso** entra a la billetera y se **reparte** entre cántaros según sus %.
- La UI **no pide cuenta**: el foco es siempre el cántaro.
- **Migración a PRO sin pérdida**: al subir a PRO, todo el histórico ya tiene `account_id`
  (la billetera), que pasa a llamarse "Efectivo/General". No hay backfill ni datos huérfanos.

Implicación técnica: `account_id` sigue siendo **NOT NULL** (no hace falta tocar el esquema);
basta con auto-crear/seleccionar la billetera en el flujo LITE.

---

## 5. Reglas de transición LITE ↔ PRO

- LITE → PRO: no se pierde nada (cántaros y movimientos se conservan; se habilitan cuentas).
- PRO → LITE: se **ocultan** (no se borran) cuentas/funciones avanzadas; los saldos se
  consolidan a la vista de cántaros. Reversible.
- El modo se guarda por usuario en `user_settings.layout_mode`.

---

## 6. Criterios de "todo funciona" (checklist de aceptación)

Para considerar el modo dual COMPLETO y funcional:

**LITE**
- [ ] Onboarding permite elegir LITE y persiste el modo.
- [ ] Home LITE muestra cántaros con saldo y un CTA de registro rápido.
- [ ] Registrar ingreso reparte a cántaros por %.
- [ ] Registrar gasto baja el cántaro elegido (sin pedir cuenta) — según decisión §4.
- [ ] Menú reducido; secciones PRO ocultas (cuentas, bulk, impuestos).
- [ ] Transferencia básica entre cántaros disponible.

**PRO**
- [ ] `ProHomeView` construido (hoy pendiente).
- [ ] Todas las opciones del menú de transacciones operativas (ingreso, gasto, transfer,
      transfer cross-currency, pago múltiple, ítems, impuestos, ajuste, saldo inicial).
- [ ] Trackeo de cuentas multi-moneda con saldo correcto.
- [ ] Carga masiva con dry-run sin los BUG-001..005.

**Transversal**
- [ ] Cambiar de modo no pierde datos y es reversible.
- [ ] El gating es funcional (no solo visual): LITE realmente oculta/deshabilita lo avanzado.

---

## 7. Tareas derivadas (van al `TASKS_LEDGER.md`)

| ID | Tarea |
|----|-------|
| TECH-LP-01 | Gating funcional por `layout_mode` (no solo visual) en transacciones y menú |
| TECH-LP-02 | Modelo de gasto LITE según decisión §4 (billetera implícita / account nullable) |
| TECH-LP-03 | Construir `ProHomeView` |
| TECH-LP-04 | Flujo de transición LITE↔PRO sin pérdida de datos |
| TECH-004 | Afinar **modo oscuro y temas** (ver `.pending/TECH-004-dark-mode-temas.md`) |
