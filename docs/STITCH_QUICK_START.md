# Stitch Integration — Quick Start Guide

**Para**: Desarrolladores y diseñadores que necesitan una nueva vista rápido
**Duración**: Leer en 3 minutos, implementar en 1-2 horas

---

## TL;DR: El Pipeline en 5 Pasos

```
1. Diseño define vista      (30 min)
2. Stitch genera HTML       (10 min)
3. Programador implementa   (60-90 min)
4. QA valida               (30 min)
5. Merge & deploy          (automatic)
```

---

## Paso 1: Solicitar Vista a Stitch

**Quién**: Programador o diseñador
**Dónde**: Conversación con Claude/Stitch
**Tiempo**: 10 minutos

### Checklist
- [ ] Abrir `/docs/STITCH_INTEGRATION_PIPELINE.md` sección 2 (templates)
- [ ] Copiar bloques CONTEXTO_APP, DISEÑO_SISTEMA, INSTRUCCIONES (precompilados)
- [ ] Escribir tu VISTA_A_GENERAR (qué quieres que genere)
- [ ] Pegar prompt completo a Claude
- [ ] Copiar HTML generado

### Ejemplo Minimal
```markdown
# VISTA: Dashboard Home Lite

[CONTEXTO_APP: copiar de sección 2.2]
[DISEÑO_SISTEMA: copiar de sección 2.3]

## VISTA A GENERAR

- **Nombre**: Home Dashboard
- **Layout**: Hero balance card → Jars grid → Transactions list
- **Data Points**: user.name, globalBalance, incomeTotal, expenseTotal, jars[], transactions[]
- **Interactions**: Click filtro → recarga datos; click jar → modal; click tx → detalles

[INSTRUCCIONES: copiar de sección 2.5]
```

---

## Paso 2: Crear Componente Vue

**Quién**: Programador
**Dónde**: Crear archivo `src/components/views/[TuComponente].vue`
**Tiempo**: 60-90 minutos

### Estructura Base
```vue
<template>
  <!-- Pega aquí el HTML de Stitch -->
</template>

<script setup lang="ts">
// Imports estándar
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from 'stores/auth'
import { api } from 'boot/axios'

// Types
interface MyData { id: number; name: string }

// State
const isLoading = ref(false)
const error = ref<string | null>(null)
const data = ref<MyData[]>([])

// Methods
async function loadData() {
  isLoading.value = true
  try {
    const res = await api.get('/endpoint')
    data.value = res.data?.data || []
  } catch (err: any) {
    error.value = 'Error cargando datos'
    console.error(err)
  } finally {
    isLoading.value = false
  }
}

// Lifecycle
onMounted(() => {
  if (!useAuthStore().token) {
    useRouter().push('/login')
    return
  }
  loadData()
})
</script>

<style lang="scss" scoped>
/* CSS de Stitch va aquí */
</style>
```

### Checklist Implementación
- [ ] Props definidas con tipos
- [ ] Auth verificada en onMounted
- [ ] API call con try-catch
- [ ] Loading state (mostrar spinner)
- [ ] Error handling (mostrar mensaje)
- [ ] Empty state ("No hay datos")
- [ ] Formateo de datos (currency, dates)
- [ ] Event handlers conectados (@click, etc)
- [ ] Sin console.logs
- [ ] TypeScript sin `any`

---

## Paso 3: Testing Rápido

**Quién**: QA o programador
**Dónde**: DevTools + `/dev`
**Tiempo**: 30 minutos

### Responsive Check
```bash
# Terminal
npm run dev

# Browser DevTools → Device Toolbar
# Probar: 320px (mobile), 768px (tablet), 1024px (desktop)
```

### Data Binding Check
- [ ] Valores aparecen correctamente
- [ ] Formateo OK (currency, dates)
- [ ] Loading state aparece
- [ ] Error state visible
- [ ] Empty state visible (si falta data)

### A11y Check
- [ ] Botones >= 44x44px
- [ ] Contrast >= 4.5:1
- [ ] Aria-labels en iconos
- [ ] Keyboard navigation (Tab, Enter)

### API Check
- [ ] Endpoint correcto en DevTools (Network tab)
- [ ] Token Bearer en Authorization header
- [ ] Respuesta estructura correcta
- [ ] Error handling funciona (fuerza 401, desconecta)

---

## Paso 4: Pull Request

**Quién**: Programador
**Dónde**: GitHub
**Checklist**:

```markdown
## Checklist

- [ ] Responsive: 320px, 768px, 1024px
- [ ] A11y: WCAG AA
- [ ] Data binding funciona
- [ ] Auth verificada
- [ ] Errors manejados
- [ ] TypeScript: sin `any`
- [ ] CSS variables usadas
- [ ] No console.logs
- [ ] Tests pasan (if applicable)

## Screenshots
[Adjunta screenshot mobile si es nueva vista]

## Related
Closes #123 (issue number if applicable)
```

---

## Common Issues & Fixes

### "Token is undefined"
```typescript
// ❌ WRONG
const token = auth.token // puede ser undefined

// ✅ RIGHT
if (!auth.token) {
  router.push('/login')
  return
}
const response = await api.get('/endpoint')
```

### "Data shows undefined in template"
```vue
<!-- ❌ WRONG -->
<p>{{ transaction.amount }}</p>

<!-- ✅ RIGHT -->
<p>{{ transaction?.amount || '—' }}</p>
```

### "Colors don't match design"
```scss
// ❌ WRONG
.card { background: #001f3f; } // Hardcoded

// ✅ RIGHT
.card { background: var(--brand-primary); } // From tokens.css
```

### "Button too small on mobile"
```scss
// ❌ WRONG
button { padding: 4px 8px; } // Too small

// ✅ RIGHT
button {
  padding: 12px 16px;
  min-height: 44px;
  min-width: 44px;
}
```

---

## File Reference

| File | Propósito |
|------|-----------|
| `/docs/STITCH_INTEGRATION_PIPELINE.md` | **LEE ESTO**: Guía completa, templates, ejemplos |
| `/.claude/STITCH_DECISIONS.md` | Decisiones arquitectónicas, rationale |
| `/.claude/stitch-prompts/` | Carpeta para guardar prompts por vista |
| `/src/components/views/` | Donde van componentes generados |
| `/src/css/tokens.css` | Variables de diseño (colores, spacing) |
| `/src/boot/axios.ts` | Configuración de API + Sanctum |

---

## Templates Copy-Paste

### Minimal Prompt (copy-paste listo)
```markdown
# VISTA: [Nombre]

CONTEXTO:
[Copiar sección 2.2 de STITCH_INTEGRATION_PIPELINE.md]

DISEÑO:
[Copiar sección 2.3]

VISTA A GENERAR:
- Nombre: [tuVista]
- Layout: [describe brevemente]
- Data: [lista campos que muestra]
- Interacciones: [qué hace usuario]

INSTRUCCIONES:
[Copiar sección 2.5]
```

### Minimal Component (copy-paste listo)
```vue
<template>
  <!-- HTML de Stitch aquí -->
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from 'stores/auth'
import { useRouter } from 'vue-router'
import { api } from 'boot/axios'

const router = useRouter()
const auth = useAuthStore()
const isLoading = ref(false)
const error = ref<string | null>(null)

async function loadData() {
  if (!auth.token) {
    router.push('/login')
    return
  }
  isLoading.value = true
  try {
    const res = await api.get('/api-endpoint')
    // Process data...
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Error'
  } finally {
    isLoading.value = false
  }
}

onMounted(loadData)
</script>

<style lang="scss" scoped>
/* CSS de Stitch aquí */
</style>
```

---

## Key Commands

```bash
# Desarrollo
npm run dev              # Inicia servidor local

# Type checking
npm run type-check      # Verifica TypeScript

# Linting
npm run lint            # ESLint + Prettier

# Build
npm run build           # Vite build para producción

# Testing (if configured)
npm run test:unit       # Unit tests
```

---

## When to Ask for Help

| Situación | Acción |
|-----------|--------|
| "¿Stitch puede generar componentes Quasar?" | No, manualmente después |
| "¿Cómo valido la respuesta API?" | Usa TypeScript interfaces o Zod |
| "¿Qué endpoints existen?" | Ve `/docs/STITCH_INTEGRATION_PIPELINE.md` sección 2.2 |
| "¿Cómo muestro error?" | Error state en template + error.value en state |
| "Stitch output tiene CSS roto" | Normal, tunear post-generación |
| "¿Componente A11y?" | Verifica WCAG AA en DevTools (Lighthouse) |

---

## Metrics

Objetivo: **< 2 horas por vista completamente implementada**

- Stitch generation: 10 min
- Vue implementation: 60-90 min
- Testing: 30 min
- PR review: < 30 min

Si toma más, probablemente:
- Prompt muy vago → especificar más
- API cambió → documentar nuevo endpoint
- Scope creep → dividir en varias vistas

---

## Next Steps After Implementation

1. **Merge**: PR aprobado → merge a `main`
2. **Deploy**: GitHub Actions → build + test + deploy automático
3. **Monitor**: 24 horas post-deploy, mirar logs de errores
4. **Iterate**: User feedback → próxima versión

---

**Versión**: 1.0 | **Última actualización**: 2026-04-05
**Preguntas**: Revisar `/docs/STITCH_INTEGRATION_PIPELINE.md` o preguntar en standup
