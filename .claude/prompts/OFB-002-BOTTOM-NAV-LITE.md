# OFB-002: Implementar Bottom Navigation - Versión Lite

**Ticket Notion:** https://www.notion.so/337e7ace976781b6b533fcf464806b50

---

## 📋 Resumen Ejecutivo

Implementar el componente **LiquidBottomNavNew.vue** que será la navegación inferior fija para la versión LITE. Incluye 4 tabs principales y un FAB (Floating Action Button) central para agregar transacciones rápidamente.

---

## 🎯 Objetivo

Crear una bottom navigation responsive (mobile-first) que proporcione:
- 4 tabs navegables (Home, Transactions, Jars, Settings)
- Indicador visual del tab activo
- FAB central para Quick Add (agregar transacción)
- Integración con Vue Router

---

## 📁 Ubicación del Archivo

```
src/components/liquid/LiquidBottomNavNew.vue
```

---

## 🏗️ Especificaciones Técnicas

### Dimensiones
- **Height:** 80px (h-20) + safe area pb-safearea
- **Position:** Fixed bottom
- **Safe Area:** Support para home indicator (pb-safearea)

### Layout (5 Elementos)
```
┌─────────────────────────────────────────────────┐
│ Tab1 │ Tab2 │      FAB      │ Tab3 │ Tab4      │
│      │      │   (Circle)    │      │           │
└─────────────────────────────────────────────────┘
```

### 4 Tabs

#### Tab 1: Home
- **Label:** "Home" o "Inicio"
- **Icon:** `home_outlined`
- **Route:** `/app/home`
- **Active indicator:** Bottom border 3px blue

#### Tab 2: Transactions
- **Label:** "Transacciones"
- **Icon:** `receipt_outlined`
- **Route:** `/app/transactions`
- **Active indicator:** Bottom border 3px blue

#### Tab 3: Jars (Cántaros)
- **Label:** "Jarras"
- **Icon:** `savings_outlined`
- **Route:** `/app/jars`
- **Active indicator:** Bottom border 3px blue

#### Tab 4: Settings
- **Label:** "Config"
- **Icon:** `settings_outlined`
- **Route:** `/app/config`
- **Active indicator:** Bottom border 3px blue

### FAB (Floating Action Button)
- **Position:** Centro, elevado (elevation 8)
- **Size:** 56x56 (w-14 h-14)
- **Icon:** `add_outlined` o `add`
- **Color:** Brand primary (#1E3A8A)
- **Shadow:** Sombra elev 8
- **Emit event:** `@fab-click`
- **Tooltip:** "Agregar transacción"

---

## 💾 Props

```typescript
interface LiquidBottomNavProps {
  /** Currently active tab ID */
  activeTab?: 'home' | 'transactions' | 'jars' | 'settings';

  /** Show/hide the entire bottom nav */
  modelValue?: boolean;

  /** Tab configuration (can be extended) */
  tabs?: Array<{
    id: string;
    label: string;
    icon: string;
    route: string;
  }>;
}
```

---

## 🎪 Eventos (Emits)

```typescript
emits: {
  'fab-click': () => true,
  'tab-change': (tabId: string) => true,
  'update:modelValue': (visible: boolean) => true,
}
```

---

## 🎨 Estilos

### Colores (Frozen Design System)
- **Background:** White (#FFFFFF)
- **Border:** Light gray (#E2E8F0)
- **Text Primary:** Dark navy (#1E3A8A)
- **Text Secondary:** Gray (#94A3B8)
- **Active Indicator:** Brand blue (#1E3A8A)
- **FAB:** Brand primary (#1E3A8A)
- **FAB Text:** White (#FFFFFF)

### Responsive
- Mobile: Layout completo visible
- Tablet+: Puede colapsar labels si es necesario

### Safe Area
- Usar Tailwind: `pb-safearea`
- Quasar: `q-safe-area-bottom` class

---

## 🧪 Criterios de Aceptación

- [ ] Bottom nav fixed en bottom, h-20 + safe area
- [ ] 4 tabs navegables con routers
- [ ] FAB central flotante con elevation
- [ ] Active tab indicator (bottom border 3px)
- [ ] Icons + labels por tab
- [ ] FAB emite evento `@fab-click`
- [ ] Tab change emite evento `@tab-change`
- [ ] Safe area para home indicator
- [ ] Colores validados contra design system
- [ ] TypeScript strict sin errores
- [ ] Responsive en breakpoints: xs, sm, md
- [ ] Validado visualmente contra `html-exports/STITCH_LAYOUTS_LITE_FOOTER.html`
- [ ] Sin dependencies innecesarias
- [ ] JSDoc comments completos
- [ ] Accesibilidad: ARIA labels en tabs y FAB

---

## 📚 Referencias

### Stitch Design
- Screen: `OW Finance Dashboard Lite - Home`
- HTML Reference: `html-exports/STITCH_LAYOUTS_LITE_FOOTER.html`

### Design System
- Documento: `docs/ui-ux/08-frozen-canonical-design-system-brief.md`
- Colores: Light baseline per frozen specification

### Componentes relacionados
- Integración en: `src/layouts/LiteMobileLayout.vue`
- Pares con: `LiquidHeader.vue` (OFB-001)
- Usa: Quasar, Vue Router, Material Symbols, Tailwind

---

## 💡 Notas de Implementación

1. **Icons:** Usar Material Symbols icons de Quasar
   - Home: `home_outlined`
   - Transactions: `receipt_outlined`
   - Jars: `savings_outlined`
   - Settings: `settings_outlined`
   - FAB: `add_outlined`

2. **Router Integration:**
   ```typescript
   const router = useRouter();
   function onTabClick(tabId: string) {
     const routes = {
       home: '/app/home',
       transactions: '/app/transactions',
       jars: '/app/jars',
       settings: '/app/config'
     };
     router.push(routes[tabId]);
     emit('tab-change', tabId);
   }
   ```

3. **Active Tab:** Sincronizar con ruta actual
   ```typescript
   const activeTab = computed(() => {
     const path = route.path;
     if (path.includes('/transactions')) return 'transactions';
     if (path.includes('/jars')) return 'jars';
     if (path.includes('/config')) return 'settings';
     return 'home';
   });
   ```

4. **Layout:** Usar Flexbox con distribución espaciada
   ```html
   <div class="flex items-center justify-between h-20 pb-safearea">
     <!-- 2 tabs | FAB | 2 tabs -->
   </div>
   ```

5. **FAB Elevation:** Usar Quasar shadow classes
   ```html
   <button class="shadow-lg elevation-8">
   ```

6. **Active Indicator:** Bottom border 3px blue
   ```css
   .tab.active::after {
     content: '';
     position: absolute;
     bottom: 0;
     left: 0;
     right: 0;
     height: 3px;
     background-color: #1E3A8A;
   }
   ```

---

## 🚀 Stack Técnico

- **Framework:** Vue 3 (Composition API, TypeScript)
- **Routing:** Vue Router
- **UI:** Quasar Framework
- **Styles:** Tailwind CSS
- **Icons:** Material Symbols (via Quasar)
- **State:** Computed + Props (reactive)

---

## 📖 Ejemplo de Uso

```vue
<LiquidBottomNavNew
  :active-tab="activeTab"
  @fab-click="handleFabClick"
  @tab-change="handleTabChange"
/>

<script setup>
const handleFabClick = () => {
  showQuickActions.value = true;
};

const handleTabChange = (tabId) => {
  // Router push ya se hace en el componente
};
</script>
```

---

## 🔗 Tickets Relacionados

- **OFB-001:** Header (implementación paralela)
- **OFB-003:** Integración en LiteMobileLayout.vue
- **OFB-004:** Validación final LITE

---

## 📝 Notas Adicionales

- Este es el segundo componente crítico del layout LITE
- La navegación es el corazón de la experiencia mobile
- Probar especialmente en dispositivos con home indicator (iPhone)
- Validar que el FAB no se superpone con contenido de la página
- Probar ripple effect al hacer click en tabs
- Verificar que no hay flicker al cambiar de tab

---

**Status:** ✅ Ready to Implement
**Priority:** Alta
**Role:** Frontend
**Effort:** 4-6 horas
**Depende de:** OFB-001 (opcional, pueden ser paralelos)
