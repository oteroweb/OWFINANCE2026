# OFB-006: Implementar Sidebar Navigation - Version Pro (Desktop)

**Ticket Notion:** https://www.notion.so/337e7ace9767814f916eec4d809955bf

---

## 📋 Resumen Ejecutivo

Implementar el componente **ProSidebar.vue** que será la navegación lateral izquierda para la versión PRO del layout en escritorio. Este componente incluye drag & drop reordering, collapsible sections, y persistent user profile card.

---

## 🎯 Objetivo

Crear un sidebar desktop que permita:
- Navegación principal a secciones core
- Drag & drop reordering con persistencia
- Collapsible sections
- User profile card
- Active state indicator

---

## 📁 Ubicación del Archivo

```
src/components/ProSidebar.vue
```

---

## 🏗️ Especificaciones Técnicas

### Dimensiones
- **Width:** 260px (responsive: 240px en <1200px)
- **Position:** Fixed / Sticky left
- **Height:** 100vh
- **Breakpoints:** 900px (full), <900px (collapse option)

### Structure

```
┌──────────────────────┐
│   OWFinance Logo     │  24px padding top
├──────────────────────┤
│ ⋮ Home               │  Primary nav items
│ ⋮ Transactions       │  (Drag handle: ⋮)
│ ⋮ Jars               │
│ ⋮ Analytics          │
├──────────────────────┤
│ ⋮ Accounts           │  Secondary nav (collapsible)
│ ⋮ Categories         │
├──────────────────────┤
│                      │  Spacer (flex-grow)
├──────────────────────┤
│  🔐 José Luis        │  User profile card
│  jose@example.com    │
│  Settings | Logout   │
└──────────────────────┘
```

### Navegación Principal (Primary Items)
1. **Home** (dashboard)
   - Icon: home
   - Label: "Dashboard"
   - Route: `/`

2. **Transactions**
   - Icon: receipt_long
   - Label: "Transactions"
   - Route: `/transactions`

3. **Jars** (savings pots)
   - Icon: savings
   - Label: "Jars"
   - Route: `/jars`

4. **Analytics** (reportes)
   - Icon: trending_up
   - Label: "Analytics"
   - Route: `/analytics`

### Navegación Secundaria (Secondary Items - Collapsible)
- **Management Section Header** (collapsible)
  - Accounts
    - Icon: account_balance
    - Label: "Accounts"
    - Route: `/accounts`

  - Categories
    - Icon: label
    - Label: "Categories"
    - Route: `/categories`

### User Profile Card (Bottom)
- Avatar image or initials (32x32px)
- User name (bold)
- User email (secondary text)
- Divider line
- Settings link
- Logout link

### Drag & Drop Features
- Drag handle (⋮ icon) visible on hover
- Only primary items are draggable
- Drop target indicators (blue line)
- Smooth animations (150ms)
- Persist to localStorage with key: `sidebar-nav-order`

---

## 💾 Props

```typescript
interface ProSidebarProps {
  /** List of navigation items (can be reordered) */
  navItems?: NavItem[];

  /** User data object with profile info */
  user?: {
    name?: string;
    avatar?: string;
    initials?: string;
    email?: string;
  };

  /** Current active route */
  activeRoute?: string;

  /** Whether sidebar is collapsed on mobile */
  isCollapsed?: boolean;

  /** Show drag handles */
  isDraggable?: boolean;

  /** Collapsible sections state */
  collapsibleState?: Record<string, boolean>;
}

interface NavItem {
  id: string;
  icon: string;
  label: string;
  route: string;
  children?: NavItem[];
}
```

---

## 🎪 Eventos (Emits)

```typescript
emits: {
  'nav-reorder': (items: NavItem[]) => true,
  'nav-click': (route: string) => true,
  'section-toggle': (section: string) => true,
  'settings-click': () => true,
  'logout': () => true,
  'profile-click': () => true,
  'collapse-toggle': () => true,
}
```

---

## 🎨 Estilos

### Colores (Design System)
- **Background:** White (#FFFFFF)
- **Border Right:** Light gray (#E2E8F0)
- **Text Primary:** Dark navy (#1E3A8A)
- **Text Secondary:** Gray (#64748B)
- **Hover Background:** Light blue (#F0F9FF)
- **Active Indicator:** Brand navy (#1E3A8A)
- **Active Border Left:** 3px solid (#1E3A8A)

### Typography
- **Section Headers:** 12px, uppercase, letter-spacing
- **Nav Items:** 14px, medium weight
- **Secondary Text:** 12px, gray

### Responsive
- Desktop 900px+: Full width (260px)
- Desktop 1200px+: Expanded spacing
- Mobile (<900px): Collapse to icon-only or drawer

### Hover & Active States
- Hover: Light blue background, drag handle appears
- Active: Left border indicator (3px), bold text
- Focus: Blue outline (2px) on keyboard nav

---

## 🧪 Criterios de Aceptación

- [ ] Sidebar fixed/sticky izquierda, 260px width
- [ ] 4 primary nav items con icons
- [ ] Collapsible management section
- [ ] Active item indicator (left border)
- [ ] Drag & drop reordering (primary items only)
- [ ] Drag handles visible on hover
- [ ] Persistence a localStorage
- [ ] User profile card al bottom
- [ ] Settings y Logout links
- [ ] Responsive en 900px y 1200px breakpoints
- [ ] Smooth animations (150ms)
- [ ] Colors validados contra design system
- [ ] TypeScript strict sin errores
- [ ] Validado contra `html-exports/STITCH_LAYOUTS_PRO_SIDEBAR.html`
- [ ] Icons Material Symbols desde Quasar
- [ ] localStorage persistence con clave canonica
- [ ] Keyboard navigation (arrow keys, enter)
- [ ] JSDoc comments completos

---

## 📚 Referencias

### Stitch Design
- HTML Reference: `html-exports/STITCH_LAYOUTS_PRO_SIDEBAR.html`
- Project ID: 5968657237763273187

### Design System
- Documento: `docs/ui-ux/08-frozen-canonical-design-system-brief.md`

### Componentes relacionados
- Integración en: `src/layouts/ProDesktopLayout.vue`
- Companion: `ProTopbar.vue`
- Usa: Quasar, Material Symbols icons, Tailwind

---

## 💡 Notas de Implementación

1. **Drag & Drop Library:**
   ```typescript
   // Use @vue-dnd/core or Sortable.js
   import Sortable from 'sortablejs';

   Sortable.create(navList, {
     handle: '.drag-handle',
     animation: 150,
     onEnd: () => {
       emit('nav-reorder', newOrder);
       localStorage.setItem('sidebar-nav-order', JSON.stringify(newOrder));
     }
   });
   ```

2. **localStorage Persistence:**
   ```typescript
   const loadNavOrder = () => {
     const saved = localStorage.getItem('sidebar-nav-order');
     return saved ? JSON.parse(saved) : DEFAULT_NAV_ORDER;
   };
   ```

3. **Active Route Detection:**
   ```typescript
   import { useRoute } from 'vue-router';
   const route = useRoute();
   const isActive = (itemRoute: string) => route.path === itemRoute;
   ```

4. **Icons:** Material Symbols from Quasar
   - home, receipt_long, savings, trending_up
   - account_balance, label, settings, logout
   - drag_indicator (for drag handle)

5. **Collapsible Sections:**
   ```html
   <div class="nav-section">
     <button @click="toggleSection('management')" class="section-header">
       Management
       <q-icon :name="collapsed ? 'expand_more' : 'expand_less'" />
     </button>
     <div v-if="!collapsed" class="section-items">
       <!-- Items -->
     </div>
   </div>
   ```

6. **User Profile Card:**
   ```html
   <div class="profile-card mt-auto pt-4 border-t">
     <div class="flex items-center gap-3">
       <q-avatar :name="user.initials" />
       <div class="flex-1 min-w-0">
         <p class="font-bold text-sm truncate">{{ user.name }}</p>
         <p class="text-xs text-gray-500 truncate">{{ user.email }}</p>
       </div>
     </div>
     <div class="flex gap-2 mt-3">
       <q-btn flat dense label="Settings" @click="emit('settings-click')" />
       <q-btn flat dense label="Logout" @click="emit('logout')" />
     </div>
   </div>
   ```

---

## 🚀 Stack Técnico

- **Framework:** Vue 3 (Composition API, TypeScript)
- **UI:** Quasar Framework
- **Styles:** Tailwind CSS
- **Icons:** Material Symbols (via Quasar)
- **Drag & Drop:** Sortable.js or @vue-dnd/core
- **Storage:** localStorage API
- **Routing:** Vue Router (integration)

---

## 📖 Ejemplo de Uso

```vue
<script setup lang="ts">
import { ref } from 'vue';
import ProSidebar from '@/components/ProSidebar.vue';

const user = ref({
  name: 'José Luis',
  avatar: 'https://example.com/avatar.jpg',
  initials: 'JL',
  email: 'jose@example.com'
});

const navItems = ref([
  { id: 'home', icon: 'home', label: 'Dashboard', route: '/' },
  { id: 'transactions', icon: 'receipt_long', label: 'Transactions', route: '/transactions' },
  { id: 'jars', icon: 'savings', label: 'Jars', route: '/jars' },
  { id: 'analytics', icon: 'trending_up', label: 'Analytics', route: '/analytics' }
]);

const handleReorder = (newItems) => {
  navItems.value = newItems;
};
</script>

<template>
  <ProSidebar
    :nav-items="navItems"
    :user="user"
    :active-route="$route.path"
    @nav-reorder="handleReorder"
    @logout="handleLogout"
    @settings-click="goToSettings"
  />
</template>
```

---

## 🔗 Tickets Relacionados

- **OFB-005:** ProTopbar (complementario)
- **OFB-007:** Pro Layout Integration
- **OFB-028:** Layout refactoring

---

## 📝 Notas Adicionales

- Drag & drop solo reordena primary items
- Secondary items (Management) no son draggables
- Persistencia use localStorage con reset option
- Validar accesibilidad (keyboard nav, ARIA labels)
- Probar con nombres de usuario muy largos
- Mobile: Considerar drawer en lugar de sidebar fijo

---

**Status:** ✅ Ready to Implement
**Priority:** Alta
**Role:** Frontend
**Effort:** 8-10 horas
