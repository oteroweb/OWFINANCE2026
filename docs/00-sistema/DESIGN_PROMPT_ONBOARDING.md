# DESIGN PROMPT — Onboarding Financiero + Mi Perfil + Cántaros

> Para Claude Design / Agente de diseño UI.
> El backend ya existe. Este prompt cubre el look & feel, componentes y flujo visual completo.

---

## Contexto del producto

**OWFINANCE** es una app de finanzas personales con un asesor IA integrado.
Tiene dos modos: **Lite** (móvil, minimalista) y **Pro** (escritorio, denso).
Stack: Quasar 2 + Vue 3 + TypeScript. Design System ya establecido (tokens en `app.scss`).

### Paleta actual

```
--primary:   #0a2540   (navy oscuro)
--secondary: #00bcd4   (cyan)
--accent:    #1D9E75   (verde teal)
--info:      #185FA5   (azul medio)
```

---

## Parte 1 — Onboarding Wizard (primera vez, post-login)

### Comportamiento
- Aparece **una sola vez** tras el primer login (cuando `onboarding_profile_completed === false`).
- Es un modal fullscreen tipo **slide-up** (ya existe `OnboardingModal.vue` como referencia).
- **5 pasos** secuenciales. Los pasos 1–3 son opcionales (botón "Saltar"). El paso 4 es opcional.
- Al completar o saltar todo → `PUT /api/v1/user/financial-profile` con `onboarding_profile_completed: true`.

### Pasos

| # | Título | Subtítulo | Contenido |
|---|--------|-----------|-----------|
| 0 | _(ya existe)_ | — | Elegir Lite o Pro |
| 1 | **Cuéntanos sobre ti** | "El asesor IA usará esto para consejos personalizados" | Chips: ocupación, rango de ingreso, convivencia |
| 2 | **Tu situación actual** | "Honestidad = mejores consejos" | Chips: deudas, fondo de emergencia, relación con el dinero |
| 3 | **Tus metas y sueños** | "Lo que quieres lograr guía todo el plan" | Chips: meta principal · Input libre: sueño a largo plazo · Chips: palabra emocional |
| 4 | **Dale propósito a tus cántaros** | "El asesor sabrá para qué es cada uno" | Lista de cántaros activos del usuario + selector de plantilla + textarea por cántaro |
| 5 | **¡Todo listo!** | — | Resumen del perfil guardado + botón "Ir al inicio" |

### Selector de plantilla de cántaros (paso 4)

El usuario puede elegir **cambiar su esquema de cántaros** antes de escribir las descripciones.
Las plantillas vienen de `/api/v1/jar-templates` (ya existen en backend).

Plantillas disponibles (vienen de `GET /api/v1/jar-templates`, slug en paréntesis):

| Nombre | Slug | Cántaros | Distribución clave | Para quién |
|--------|------|----------|--------------------|------------|
| **Bases + Sueños** | `bases-y-suenos` | 11 | 12% necesidades · 31% ahorro · 3×8% sueños | Emprendedor con proyectos activos y metas de vida concretas |
| **Conservador** | `conservador` | 6 | 60% necesidades · 15% ahorro · 10% educación | Perfil de estabilidad, prioriza seguridad sobre experiencias |
| **Moderado** | `moderado` | 6 | 55% necesidades · 10% ahorro · 10% diversión | Equilibrio clásico (base T. Harv Eker adaptado) |
| **Avanzado** | `avanzado` | 8 | 50% necesidades · dividido en 8 categorías | Usuario con ingresos mayores que quiere granularidad |
| **Arriesgado** | `arriesgado` | 6 | 40% necesidades · 20% diversión | Más énfasis en experiencias y metas, menor colchón |

**Plantilla recomendada por defecto**: `Moderado` (la más universal)
**Plantilla destacada**: `Bases + Sueños` — mostrar con badge "⭐ Popular entre emprendedores"

**UI del selector**: tarjetas horizontales tipo "pill group" o "tab switcher" con:
- Nombre del esquema
- Preview visual: mini barra segmentada (colores proporcionales a %)
- Número de cántaros
- Al seleccionar → muestra modal de confirmación "¿Reemplazar tus cántaros actuales?" (destructivo)

### Tabla de cántaros (paso 4) — editable inline

Tabla con columnas: **Color · Nombre · % · Propósito (textarea)**
- Filas editables inline
- Botón "+ Agregar cántaro" al final (añade fila vacía)
- Icono de eliminar por fila (soft-delete si tiene transacciones)
- Los % deben sumar ≤ 100. Badge de error si exceden.

### Componentes requeridos

```
OnboardingWizard.vue          — wizard principal, maneja paso actual
  ├── StepProgress.vue        — barra de progreso con dots/pasos
  ├── ProfileStep.vue         — pasos 1, 2, 3 (chip groups + input libre)
  │     └── ChipGroup.vue     — selector de opciones tipo chip, single-select
  ├── JarsStep.vue            — paso 4
  │     ├── JarTemplateSelector.vue  — cards de plantillas con preview
  │     └── JarsTable.vue            — tabla editable inline de cántaros
  └── OnboardingComplete.vue  — paso 5: resumen + CTA
```

### UX / Micro-interacciones

- Chips: al seleccionar → feedback inmediato (background accent, checkmark sutil)
- Input libre (sueño): placeholder animado con ejemplos rotativos
- Transición entre pasos: slide horizontal suave (Vue `<Transition>`)
- Barra de progreso: dots que se rellenan al avanzar
- Step 5: animación de confetti ligera (solo primera vez)
- Mobile-first: en móvil, chips en grid 2 columnas. En desktop, row flex-wrap.

---

## Parte 2 — Mi Perfil Financiero (en Settings, editable siempre)

### Ruta
`/user/config` → sección **"Mi perfil financiero"** dentro de la página de configuración existente.

### Layout

Sección con título "Mi perfil financiero" + subtítulo "El asesor IA usa esta información para personalizar sus consejos".

Subsecciones colapsables o en cards:

**Card 1 — Quién soy**
- Ocupación (chip selector)
- Rango de ingreso (chip selector)
- Convivencia (chip selector)

**Card 2 — Situación financiera**
- Deudas (chip selector)
- Fondo de emergencia (chip selector)
- Relación con el dinero (chip selector)

**Card 3 — Metas y sueños**
- Meta principal (chip selector)
- Sueño a largo plazo (input text, max 500 chars, con contador)
- Palabra emocional (chip selector)

**Card 4 — Mis cántaros**
- Mismo `JarsTable.vue` del wizard (reutilizable)
- Incluye el `JarTemplateSelector.vue` para cambiar esquema

Botón **Guardar perfil** (sticky footer o al final de la sección).
Indicador de última actualización: "Actualizado hace 3 días".

---

## Parte 3 — Vista de Cántaros mejorada

### Ruta
`/user/jars` — vista ya existe (`LiteJarsView.vue` + `index.vue` Pro)

### Mejoras requeridas

**En modo Lite** (`LiteJarsView.vue`):
- Cada jar card muestra `description` debajo del nombre (si existe), en texto muted pequeño
- Icono de lápiz al hacer tap → abre bottom sheet con textarea para editar descripción
- Si no tiene descripción → texto placeholder clickeable "Agregar propósito..."

**En modo Pro** (tabla existente `index.vue`):
- Nueva columna **"Propósito"** en la tabla de resumen (texto truncado a 60 chars + tooltip)
- Editable inline: click en celda → textarea inline con auto-save

---

## Restricciones técnicas importantes

- No modificar `config/database.php` líneas 61/81
- No modificar `bootstrap/app.php`
- `description` ya existe en el modelo `Jar` (fillable) y en la tabla (migración aplicada)
- Campos de perfil ya existen en `ai_user_settings` (migración aplicada)
- Endpoints disponibles:
  - `GET /api/v1/user/financial-profile`
  - `PUT /api/v1/user/financial-profile`
  - `PUT /api/v1/user/financial-profile/jar-descriptions`
  - `GET /api/v1/jar-templates` (plantillas existentes)
  - `POST /api/v1/jars` / `PUT /api/v1/jars/{id}` (CRUD cántaros existente)

## Chips con descripción — diseño de opciones

Cada chip muestra label + descripción corta en tooltip o subtexto (en mobile: solo label).

### Paso 1 — ¿Quién eres?

**Ocupación** (`occupation`)
| Valor | Label | Descripción del chip |
|-------|-------|----------------------|
| `employee` | Empleado / asalariado | Ingreso mensual fijo o quincenal |
| `freelancer` | Freelancer | Proyectos independientes, ingreso variable |
| `entrepreneur` | Emprendedor | Negocio propio, ingresos mixtos |
| `student` | Estudiante | Aprendiendo, ingresos limitados o nulos |
| `retired` | Jubilado / pensionado | Ingreso fijo de pensión |
| `other` | Otra situación | Situación no listada arriba |

**Rango de ingreso** (`income_range`)
| Valor | Label | Descripción del chip |
|-------|-------|----------------------|
| `<500` | Menos de $500 | Presupuesto ajustado, cada centavo cuenta |
| `500-1500` | $500 – $1,500 | Ingreso moderado, margen de maniobra |
| `1500-4000` | $1,500 – $4,000 | Ingreso cómodo, capacidad de ahorro real |
| `>4000` | Más de $4,000 | Ingreso alto, optimización es la prioridad |

**Convivencia** (`living_situation`)
| Valor | Label | Descripción del chip |
|-------|-------|----------------------|
| `solo` | Vivo solo | Todas las decisiones son mías |
| `pareja` | En pareja | Finanzas compartidas o coordinadas |
| `familia` | Con mi familia | Gastos del hogar divididos |
| `roommates` | Con roommates | Renta compartida, vida independiente |

### Paso 2 — Tu situación actual

**Deudas** (`debt_situation`)
| Valor | Label | Descripción del chip |
|-------|-------|----------------------|
| `none` | Sin deudas 🎉 | Libre de compromisos financieros |
| `credit_card` | Tarjeta de crédito | Pago mínimo o saldo acumulado |
| `personal_loan` | Préstamo personal | Cuota mensual fija |
| `mortgage` | Hipoteca / crédito hipotecario | La inversión más importante |
| `multiple` | Varias deudas | Tarjeta + préstamo + otros |

**Fondo de emergencia** (`emergency_fund`)
| Valor | Label | Descripción del chip |
|-------|-------|----------------------|
| `none` | No tengo aún | El primer objetivo a construir |
| `<3m` | Menos de 3 meses | Colchón inicial, sigo construyendo |
| `3-6m` | 3 a 6 meses | Zona de seguridad estándar |
| `>6m` | Más de 6 meses | Totalmente protegido |

**Relación con el dinero** (`money_relationship`)
| Valor | Label | Descripción del chip |
|-------|-------|----------------------|
| `want_improve` | Quiero mejorar mis hábitos | Sé que puedo hacerlo mejor |
| `organized` | Soy bastante ordenado | Tengo control, quiero optimizar |
| `hard_to_save` | Me cuesta ahorrar | El dinero se va sin darme cuenta |
| `day_to_day` | Vivo al día | Cubrir el mes es el reto |

### Paso 3 — Metas y sueños

**Meta principal ahora** (`main_goal`)
| Valor | Label | Descripción del chip |
|-------|-------|----------------------|
| `debt_free` | Salir de deudas | Liquidar lo que debo y respirar |
| `emergency_fund` | Crear fondo de emergencia | 3-6 meses de gastos guardados |
| `saving_goal` | Ahorrar para algo concreto | Viaje, carro, casa, negocio |
| `invest` | Empezar a invertir | Hacer que el dinero trabaje |
| `survive` | Llegar a fin de mes | Cubrir lo básico, sin agobios |

**Palabra emocional** (`emotional_keyword`)
| Valor | Label | Descripción del chip |
|-------|-------|----------------------|
| `tranquilo` | Tranquilo | Sin angustia financiera |
| `libre` | Libre | Sin ataduras de deudas ni dependencias |
| `seguro` | Seguro | Con red de seguridad real |
| `control` | En control | Sabiendo exactamente qué entra y qué sale |
| `prospero` | Próspero | Creciendo, no solo sobreviviendo |

**Input libre — sueño a largo plazo** (max 500 chars)
Placeholder rotativo:
- "Tener mi propio negocio que funcione solo..."
- "Comprar mi apartamento y no pagar renta..."
- "Retirarme a los 50 con ingresos pasivos..."
- "Viajar 2 meses al año sin preocuparme por el dinero..."
- "Dar a mis hijos una educación sin límites..."

---

## Valores permitidos por campo (TypeScript)

```typescript
type Occupation     = 'employee' | 'freelancer' | 'entrepreneur' | 'student' | 'retired' | 'other'
type IncomeRange    = '<500' | '500-1500' | '1500-4000' | '>4000'
type LivingSit      = 'solo' | 'pareja' | 'familia' | 'roommates'
type DebtSituation  = 'none' | 'credit_card' | 'personal_loan' | 'mortgage' | 'multiple'
type EmergencyFund  = 'none' | '<3m' | '3-6m' | '>6m'
type MoneyRel       = 'want_improve' | 'organized' | 'hard_to_save' | 'day_to_day'
type MainGoal       = 'debt_free' | 'emergency_fund' | 'saving_goal' | 'invest' | 'survive'
type EmotionalKw    = 'tranquilo' | 'libre' | 'seguro' | 'control' | 'prospero'
```

---

## Entregables esperados

1. `OnboardingWizard.vue` (reemplaza/extiende `OnboardingModal.vue`)
2. `ChipGroup.vue` — componente reutilizable
3. `JarTemplateSelector.vue` — cards con preview mini-barra
4. `JarsTable.vue` — tabla editable inline
5. `ProfileStep.vue` — pasos 1–3 del wizard
6. `JarsStep.vue` — paso 4 del wizard
7. `OnboardingComplete.vue` — paso 5
8. Actualización de `src/pages/user/config/index.vue` — sección "Mi perfil financiero"
9. Actualización de `LiteJarsView.vue` — description en cards + edición
10. Actualización de `src/pages/user/jars/index.vue` (Pro) — columna Propósito
