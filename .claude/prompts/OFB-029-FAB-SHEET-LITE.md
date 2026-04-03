# OFB-029: Implementar FAB Bottom Sheet con Opciones Rápidas (Lite)

**Ticket Notion:** https://www.notion.so/336e7ace976781c59e6dd93d71358f82

---

## 📋 Resumen Ejecutivo

Implementar el componente **QuickActionSheet.vue** que se abre desde el botón FAB central de la navegación inferior en la versión LITE. Este bottom sheet proporciona acceso rápido a las 4 acciones principales: Agregar Gasto, Agregar Ingreso, Transferencia, e Importar.

---

## 🎯 Objetivo

Crear un glassmorphic bottom sheet que:
- Se abre desde el FAB del `LiquidBottomNavNew` con animación spring
- Presenta 4 opciones de acción rápida
- Se cierra al tocar backdrop o botón X
- Emite eventos que permiten al parent navegar a las pantallas respectivas

---

## 📁 Ubicación del Archivo

```
src/components/liquid/QuickActionSheet.vue
```

---

## 🏗️ Especificaciones Técnicas

### Dimensiones
- **Width:** Full (100vw)
- **Height:** Auto (fit content)
- **Position:** Bottom sheet modal
- **Max Height:** 50vh
- **Border Radius:** 32px top corners
- **Safe Area:** Considerar home indicator (pb-safearea)

### Layout Structure

```
┌─────────────────────────────────────┐
│  Glassmorphic Background Blur       │  Backdrop
├─────────────────────────────────────┤
│                X                    │  Close button (top right)
│      Quick Actions                  │  Title
├─────────────────────────────────────┤
│                                     │
│  ❌  Remove  │  ✅  Add             │  Row 1: Expense & Income
│     Gasto   │   Ingreso            │
│   #EF4444   │   #10B981            │
│                                     │
│  ↔️  Transfer│  📤  Import           │  Row 2: Transfer & Import
│            │   CSV/Foto            │
│  #1E3A8A   │   #F59E0B             │
│                                     │
└─────────────────────────────────────┘
```

### Backdrop
- Color: rgba(0, 0, 0, 0.5)
- Blur: 16px (glassmorphic effect)
- Clickable: Closes sheet

### Bottom Sheet Container
- Background: surface-glass rgba(255, 255, 255, 0.92)
- Border Radius: 32px (top only)
- Backdrop Filter: blur(16px)
- Shadow: 0 20px 25px rgba(0, 0, 0, 0.15)
- Padding: 24px (horizontal), 20px (vertical)

### Action Items Layout (2 Rows x 2 Columns)

#### Item 1: Agregar Gasto (Remove/Expense)
- Icon: remove_circle_outline (Material Symbols)
- Label: "Agregar Gasto"
- Color: Red (#EF4444)
- Size: Large (48x48px icon)
- Font: 14px, medium

#### Item 2: Agregar Ingreso (Add/Income)
- Icon: add_circle_outline
- Label: "Agregar Ingreso"
- Color: Green (#10B981)
- Size: Large (48x48px icon)

#### Item 3: Transferencia (Transfer)
- Icon: swap_horiz
- Label: "Transferencia"
- Color: Blue (#1E3A8A)
- Size: Large (48x48px icon)

#### Item 4: Importar (Import CSV/Photo)
- Icon: upload_file
- Label: "Importar (CSV/Foto)"
- Color: Amber (#F59E0B)
- Size: Large (48x48px icon)

---

## 💾 Props

```typescript
interface QuickActionSheetProps {
  /** Whether the sheet is visible */
  modelValue?: boolean;

  /** Whether to show loading state */
  isLoading?: boolean;

  /** Disable all actions */
  isDisabled?: boolean;

  /** Custom title */
  title?: string;

  /** Animation duration in ms */
  transitionDuration?: number;
}
```

---

## 🎪 Eventos (Emits)

```typescript
emits: {
  'update:modelValue': (isOpen: boolean) => true,
  'add-expense': () => true,
  'add-income': () => true,
  'transfer': () => true,
  'import': () => true,
  'close': () => true,
}
```

---

## 🎨 Estilos

### Animación de Apertura
- **Tipo:** Spring animation
- **Duration:** 250ms (can be adjusted via prop)
- **Easing:** cubic-bezier(0.23, 1, 0.32, 1) [spring easing]
- **Transform Start:** translateY(100%)
- **Transform End:** translateY(0)
- **Opacity Start:** 0 (backdrop)
- **Opacity End:** 1 (backdrop)

### Colores

#### Action Item Colors
| Acción | Color | Hex | Icon |
|--------|-------|-----|------|
| Gasto | Red | #EF4444 | remove_circle_outline |
| Ingreso | Green | #10B981 | add_circle_outline |
| Transferencia | Blue | #1E3A8A | swap_horiz |
| Importar | Amber | #F59E0B | upload_file |

#### Container Colors
- **Glass Background:** rgba(255, 255, 255, 0.92)
- **Backdrop:** rgba(0, 0, 0, 0.5)
- **Text Primary:** #1E3A8A
- **Text Secondary:** #64748B

### Typography
- **Title:** 18px, bold, centered
- **Labels:** 14px, medium weight, centered
- **Secondary:** 12px, gray

### Spacing
- **Container Padding:** 24px horizontal, 20px vertical
- **Gap between items:** 16px
- **Row gap:** 20px

---

## 🧪 Criterios de Aceptación

- [ ] Bottom sheet abre desde FAB con animación spring (250ms)
- [ ] Backdrop blur 16px, 50% opacity
- [ ] Close button (X) en top right funcional
- [ ] 4 opciones de acción en 2x2 grid
- [ ] Icons y colores correctos para cada acción
- [ ] Labels en español
- [ ] Glassmorphic background (surface-glass)
- [ ] Border radius 32px top corners
- [ ] Safe area para home indicator (pb-safearea)
- [ ] Click en backdrop cierra sheet
- [ ] Todos los eventos emitidos funcionan
- [ ] Loading state funcional
- [ ] Disabled state funcional
- [ ] TypeScript strict sin errores
- [ ] Validado contra Stitch design (OFB-4 spec)
- [ ] Animación suave sin jank
- [ ] Responsive en todos los tamaños mobile
- [ ] JSDoc comments completos

---

## 📚 Referencias

### Stitch Design
- Reference: OFB-4 in Notion + Stitch design system (Liquid Glass Unified)
- Visual reference: Desktop mockup en Stitch MCP

### Design System
- Glassmorphic: Documento `docs/ui-ux/08-frozen-canonical-design-system-brief.md`
- Colors: Liquid Glass Unified palette

### Componentes relacionados
- Integración en: `src/layouts/LiteMobileLayout.vue`
- Trigger: `LiquidBottomNavNew.vue` fabClick event
- Usa: Quasar, Material Symbols icons, Tailwind

---

## 💡 Notas de Implementación

1. **Spring Animation con CSS:**
   ```css
   @keyframes slideUp {
     from {
       transform: translateY(100%);
       opacity: 0;
     }
     to {
       transform: translateY(0);
       opacity: 1;
     }
   }

   .sheet-enter-active {
     animation: slideUp 250ms cubic-bezier(0.23, 1, 0.32, 1);
   }

   .backdrop-enter-active {
     animation: fadeIn 250ms ease-out;
   }
   ```

2. **Glassmorphic Effect:**
   ```html
   <div class="fixed inset-0 bg-black/50 backdrop-blur-xl">
     <!-- Backdrop -->
   </div>
   <div class="bg-white/92 backdrop-blur-xl rounded-t-2xl">
     <!-- Sheet content -->
   </div>
   ```

3. **Grid Layout:**
   ```html
   <div class="grid grid-cols-2 gap-4">
     <!-- Action items -->
   </div>
   ```

4. **Action Item Component:**
   ```vue
   <button
     @click="emit('action')"
     class="flex flex-col items-center gap-2 p-4 rounded-lg hover:bg-gray-100"
   >
     <q-icon :name="icon" size="48px" :color="color" />
     <span class="text-sm font-medium">{{ label }}</span>
   </button>
   ```

5. **v-model Integration:**
   ```typescript
   defineProps({
     modelValue: Boolean
   });
   const emit = defineEmits(['update:modelValue']);
   const handleClose = () => {
     emit('update:modelValue', false);
   };
   ```

6. **Icons from Quasar:**
   - remove_circle_outline
   - add_circle_outline
   - swap_horiz
   - upload_file
   - close (para X button)

---

## 🚀 Stack Técnico

- **Framework:** Vue 3 (Composition API, TypeScript)
- **UI:** Quasar Framework
- **Styles:** Tailwind CSS
- **Icons:** Material Symbols (via Quasar)
- **Animation:** CSS transitions + spring easing
- **State:** v-model pattern

---

## 📖 Ejemplo de Uso

```vue
<script setup lang="ts">
import { ref } from 'vue';
import QuickActionSheet from '@/components/liquid/QuickActionSheet.vue';

const isSheetOpen = ref(false);

const handleAddExpense = () => {
  isSheetOpen.value = false;
  // Navigate to new expense form
  router.push('/new-expense');
};

const handleAddIncome = () => {
  isSheetOpen.value = false;
  router.push('/new-income');
};

const handleTransfer = () => {
  isSheetOpen.value = false;
  router.push('/new-transfer');
};

const handleImport = () => {
  isSheetOpen.value = false;
  router.push('/import');
};
</script>

<template>
  <QuickActionSheet
    v-model="isSheetOpen"
    @add-expense="handleAddExpense"
    @add-income="handleAddIncome"
    @transfer="handleTransfer"
    @import="handleImport"
  />
</template>
```

---

## 🔗 Tickets Relacionados

- **OFB-002:** LiquidBottomNavNew (trigger source)
- **OFB-003:** Integración en LiteMobileLayout
- **OFB-004:** Validación final LITE

---

## 📝 Notas Adicionales

- El FAB emite `fabClick` desde `LiquidBottomNavNew`
- El parent (`LiteMobileLayout`) captura el evento y abre esta sheet
- Después de seleccionar una acción, el parent navega a la pantalla correspondiente
- Validar spring animation en todos los dispositivos
- Probar con home indicator en iPhone
- Safe area padding importante para home indicator

---

**Status:** ✅ In Progress (OFB-29)
**Priority:** Alta
**Role:** Frontend, UI/UX
**Effort:** 4-6 horas
