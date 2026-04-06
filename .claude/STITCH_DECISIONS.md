# Stitch Integration Pipeline — Decisiones Arquitectónicas Clave

**Fecha**: 2026-04-05
**Proyecto**: OWFINANCE2026
**Estado**: Documento vivo, revisable cada 2 semanas

---

## DECISIÓN 1: Pipeline Flow Architecture

### Decisión
Pipeline segmentado en 5 fases secuenciales:
1. Diseño & Especificación (equipo de diseño)
2. Generación con Stitch (sub-agent)
3. Implementación en Vue (programador)
4. Testing & Validación (QA)
5. Merge & Deployment (CI/CD)

### Por Qué
- **Separación de responsabilidades**: Cada rol hace lo que mejor sabe
- **Inputs/outputs claros**: Cada fase tiene entrada y salida definida
- **Reducción de trabajo manual**: Stitch genera 90-95%, programador implementa 5-10%
- **Mantenibilidad**: Código generado es limpio, sin cruft

### Tradeoffs
- **Más lento que code from scratch**: Requiere múltiples pasos
- **Requiere disciplina**: El prompt template debe mantenerse actualizado
- **QA más robusta**: Testing debe cubrir integración Vue + API

### Cuándo Usar
- ✅ Nuevas vistas en Lite/Pro/Legacy layouts
- ✅ Componentes complejos con múltiples secciones
- ✅ Cambios visuales significativos
- ❌ Cambios menores (colores, spacing) — editar CSS directo
- ❌ Lógica pura (métodos, helpers) — código manual

---

## DECISIÓN 2: Reusable Prompt Template Structure

### Decisión
Template de 4 bloques reutilizables:
```
[CONTEXTO_APP] ← Precompilado 1x, reutilizable en TODOS los prompts
[DISEÑO_SISTEMA] ← Precompilado 1x, reutilizable en TODOS los prompts
[VISTA_A_GENERAR] ← Variable, cambia por cada vista
[INSTRUCCIONES] ← Constante, igual para todos
```

### Por Qué
- **Eficiencia**: No redactar contexto 50 veces
- **Consistencia**: Mismo context = resultados similares de Stitch
- **Mantenibilidad**: Actualizar CONTEXTO_APP en un lugar afecta todas las vistas
- **Copy-paste ready**: Cualquiera puede generar vista sin expertise

### Dónde Guardar
- `docs/stitch-prompts/` (carpeta en repo)
- Archivo por vista: `dashboard-home.md`, `transactions-list.md`, etc.
- Cambios en template → new commit

### Validación
Template actualizado en `STITCH_INTEGRATION_PIPELINE.md` sección 2

---

## DECISIÓN 3: Vue Component Naming & Organization

### Decisión
Componentes Stitch-generados van en estructura clara:
```
src/components/views/
  ├── LiteHomeView.vue          (Stitch-generated)
  ├── LiteTransactionsView.vue  (Stitch-generated)
  ├── LiteJarsView.vue          (Stitch-generated)
  └── ...

src/pages/user/
  ├── DynamicHomePage.vue       (Router dispatcher, selecciona layout)
  └── ...
```

### Nombrado
- **Prefix**: `Lite*` / `Pro*` / `Legacy*` según layout
- **Suffix**: `View` para componentes de página
- **Ubicación**: `components/views/` para reutilizables
- **Naming Convention**: PascalCase, descriptivo

### Por Qué
- Diferencia visual → qué layout es
- Fácil encontrar: `Lite*` agrupa todas las vistas Lite
- Escalable: Cuando llegue Pro, mismo pattern

---

## DECISIÓN 4: Data Binding Patterns — Mocks vs Real API

### Decisión
Tres modos de desarrollo, switcheables:
1. **Mock Mode**: Datos hardcodeados durante desarrollo inicial
2. **Real API**: Fetch de endpoints `/api/v1/*` con Sanctum
3. **Hybrid**: Mocks por defecto, API con feature flag

### Implementación
```typescript
const IS_MOCK_MODE = import.meta.env.VITE_USE_MOCKS === 'true'

if (IS_MOCK_MODE) {
  transactions.value = mockData
} else {
  const response = await api.get('/transactions')
  transactions.value = response.data.data
}
```

### Por Qué
- **Desarrollo rápido**: No esperar backend antes de empezar
- **Testing fácil**: Datos predecibles = QA más rápido
- **Production safe**: Mocks no llegan a producción (env var previene)

### Cuándo Cambiar
- Local development → `VITE_USE_MOCKS=true`
- CI/CD testing → `VITE_USE_MOCKS=false`
- Production → `VITE_USE_MOCKS=false` (no incluir)

---

## DECISIÓN 5: Validación de Respuestas API

### Decisión
Todas las respuestas API validadas con tipos TypeScript **mínimo**, Zod si es complejo.

### Obligatorio
```typescript
// SIEMPRE
if (!response.data?.data?.transactions) {
  transactions.value = []
} else {
  transactions.value = response.data.data.transactions
}
```

### Por Qué
- **Type safety**: TypeScript atrapa errores compile-time
- **Runtime safety**: Fallbacks previenen crashes
- **API changes**: Si backend cambia, sabemos en qué punto falló
- **Data integrity**: No mostrar datos parciales/incorrectos

### Herramientas
- TypeScript interfaces para tipos simples
- Zod para schemas complejos
- Type guards para datos inciertos

---

## DECISIÓN 6: Error Handling & Auth Lifecycle

### Decisión
Centralizar manejo de errores comunes:

```typescript
if (err.response?.status === 401) {
  // Token expirado → logout + redirect
  auth.logout()
  router.push('/login')
} else if (err.response?.status === 403) {
  // Permiso denegado
  router.push('/forbidden')
} else if (err.response?.status >= 500) {
  // Error servidor
  error.value = 'Error del servidor. Intenta más tarde.'
} else {
  // Genérico
  error.value = err.response?.data?.message || 'Error desconocido'
}
```

### Por Qué
- **UX consistente**: Mismo comportamiento en todas las vistas
- **Security**: 401 cierra sesión automáticamente
- **Debuggable**: Logs diferenciados por tipo de error

### Aplicar A
- Todos los `try-catch` en `loadData()` y async methods
- Boot/axios.ts ya tiene interceptores base, esto es capa de componente

---

## DECISIÓN 7: Qué Stitch PUEDE y NO PUEDE Hacer

### Stitch GENERA (90-95% correcto)
✅ HTML limpio, válido, estructurado
✅ CSS responsivo, mobile-first, breakpoints
✅ Glassmorphism styling
✅ ARIA labels y roles básicos
✅ Animaciones CSS suaves

### Stitch NO GENERA (requiere Vue)
❌ Data binding (v-bind, {{ }})
❌ Event handlers (@click, @submit)
❌ Conditional rendering (v-if, v-show)
❌ Loops (v-for)
❌ API calls, fetch, axios
❌ State management (ref, reactive, computed)
❌ Formulario validation (Vee-Validate)

### Implicación
**Rule**: Aceptar HTML de Stitch casi tal cual. El trabajo está en Vue script.

---

## DECISIÓN 8: Testing & QA Checklist

### Antes de Merge
- [ ] Responsive: 320px, 768px, 1024px+
- [ ] Accessibility: WCAG AA (contrast 4.5:1, buttons 44x44px)
- [ ] Data binding: valores correctos, formateo OK
- [ ] Error states: loading, error, empty
- [ ] Auth: token validation, 401 logout
- [ ] API: endpoints correctos, payload estructura validada
- [ ] TypeScript: sin `any`, types completos
- [ ] CSS: variables usadas, no colors hardcodeados
- [ ] No console.logs, no debugger statements

### Roles
- **Programador**: Tests 1-7, implementa fixes
- **QA/Equipo**: Tests 8-10, user testing
- **DevOps**: Tests 11 (linting, build)

---

## DECISION 9: Convención de Componentes Stitch

### Estructura Estándar
```vue
<template>
  <!-- HTML de Stitch sin modificaciones estructurales -->
</template>

<script setup lang="ts">
// Imports
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from 'stores/auth'
import { api } from 'boot/axios'

// Types
interface MyDataType { ... }

// Props & Emits
const props = withDefaults(...)
const emit = defineEmits(...)

// State
const isLoading = ref(false)
const error = ref<string | null>(null)
const data = ref<MyDataType[]>([])

// Computed
const formattedData = computed(() => ...)

// Methods
async function loadData() { ... }
function handleEvent() { ... }

// Lifecycle
onMounted(() => { ... })
</script>

<script lang="ts">
import { defineComponent } from 'vue'
export default defineComponent({ name: 'ComponentName' })
</script>

<style lang="scss" scoped>
/* CSS de Stitch va aquí */
</style>
```

### Por Qué Este Orden
- Imports agrupados (legibilidad)
- Types antes de usarlos
- Props/emits claros (contrato del componente)
- State reactivo juntos
- Methods después
- Hooks al final
- Styles en su lugar

---

## DECISIÓN 10: Revisión & Actualización de Pipeline

### Frecuencia
- **Semanal**: Team sync, feedback rápido
- **Biweekly**: Revisar este doc, actualizar gotchas
- **Monthly**: Métricas (tiempo medio por vista, issues encontrados)

### Feedback Loop
1. Implementador reporta gotchas/mejoras
2. QA reporta testing issues
3. Equipo discute en standup
4. Documentar en STITCH_INTEGRATION_PIPELINE.md y este archivo
5. Next week, aplicar learnings en nuevas vistas

### Métrica de Éxito
- Tiempo de implementación por vista: < 2 horas (Stitch + Vue)
- Zero production bugs relacionados a binding/API
- Team satisfacción con clarity del pipeline

---

## Gotchas Conocidos

### 1. Stitch puede generar CSS sobrante
- **Problema**: Stitch genera estilos para todos los estados, a veces innecesarios
- **Solución**: Revisar CSS, borrar lo no usado
- **Prevención**: En prompt, ser específico sobre qué estados mostrar

### 2. Responsive puede necesitar ajustes
- **Problema**: Breakpoints de Stitch pueden no alinear con Quasar (768px vs 600px)
- **Solución**: Editar media queries post-Stitch
- **Prevención**: Especificar breakpoints en prompt (320px, 768px, 1024px)

### 3. Colores pueden necesitar ajuste post-Stitch
- **Problema**: Stitch usa colores genéricos, no siempre match a tokens
- **Solución**: Find/replace o SCSS variables
- **Prevención**: En prompt, mencionar colores específicos y valores hex

### 4. Sin componentes Quasar en output Stitch
- **Problema**: Stitch no conoce q-btn, q-card, etc.
- **Solución**: Convertir HTML nativo a componentes Quasar manualmente (5-10% esfuerzo)
- **Prevención**: Aceptar esto como costo, no expects Quasar en output

### 5. API endpoint puede cambiar
- **Problema**: Backend cambia `/dashboard` a `/user/dashboard`
- **Solución**: Actualizar endpoint en componente, TypeScript atrapa errores
- **Prevención**: Mantener doc de endpoints actualizada

---

## Próximos Pasos Recomendados

1. **Piloto**: Usar pipeline en 1 vista pequeña (Settings o About)
2. **Validar**: ¿Proceso smooth? ¿Tiempo razonable? ¿Código mantenible?
3. **Iterar**: Refinar prompt template con learnings
4. **Documentar**: Actualizar este archivo con gotchas nuevos
5. **Escalar**: Aplicar a todas las vistas nuevas

---

**Responsable**: Arquitecto de Sistemas
**Revisión**: Próxima 2026-04-19
**Versión**: 1.0
