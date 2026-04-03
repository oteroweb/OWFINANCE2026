# OFB-005: Implementar Header/Topbar - Version Pro (Desktop)

**Ticket Notion:** https://www.notion.so/337e7ace976781dab147c0e91d39e6c8

---

## 📋 Resumen Ejecutivo

Implementar el componente **ProTopbar.vue** que será el header superior fijo para la versión PRO del layout en escritorio. Este componente es crítico como se muestra en todas las pantallas desktop (Dashboard, Transacciones, Reportes, Configuración).

---

## 🎯 Objetivo

Crear un topbar desktop responsive que muestre:
- Logo y branding con nombre de la aplicación
- Barra de búsqueda global con debounce
- Notificaciones con badge de contador
- Menú de utilidades (settings)
- Avatar del usuario con dropdown de perfil/logout

---

## 📁 Ubicación del Archivo

```
src/components/ProTopbar.vue
```

---

## 🏗️ Especificaciones Técnicas

### Dimensiones
- **Height:** 64px (h-16)
- **Position:** Fixed top / Sticky
- **Width:** Full (100vw)
- **Breakpoints:** 900px+ (responsive: 900px, 1200px+)

### Layout (5 Secciones)
```
┌────────────────────────────────────────────────────────────────┐
│  Logo  │  Search Input  │ [Notifications] [Settings] [Avatar]  │
│ (200px)│   (Flexible)   │                                       │
└────────────────────────────────────────────────────────────────┘
```

### Sección 1: Logo & Branding (Izquierda)
- Logo icon + "OWFinance Pro"
- Width: 200px
- Font: Bold, 18px
- Color: Primary (#1E3A8A)
- Clickable: Navigate to dashboard

### Sección 2: Search Input (Centro, Flexible)
- Global search field
- Placeholder: "Search accounts, transactions, categories..."
- Icon: search (izquierda)
- Width: Flexible (min 300px, max 500px)
- Debounce: 300ms
- Emit event: `@search`
- Results: Modal/dropdown under search

### Sección 3: Notificaciones (Derecha)
- Bell icon with badge
- Badge shows count (1-99, 99+ if more)
- Click opens notification dropdown/modal
- Emit event: `@notification-click`
- Badge color: Red (#EF4444)

### Sección 4: Settings (Derecha)
- Gear/settings icon
- Click opens settings menu
- Options: Display settings, Theme, Language
- Emit event: `@settings-click`

### Sección 5: Avatar + User Menu (Derecha)
- Avatar image or initials
- Fallback: First name initial
- Dropdown menu with:
  - User profile link
  - My account
  - Preferences
  - Logout
- Emit events: `@profile-click`, `@logout`

---

## 💾 Props

```typescript
interface ProTopbarProps {
  /** Application/user name to display */
  appName?: string;

  /** Search input placeholder text */
  searchPlaceholder?: string;

  /** Whether search is loading */
  isSearching?: boolean;

  /** Number of unread notifications */
  notificationCount?: number;

  /** User data object with name, avatar, initials */
  user?: {
    name?: string;
    avatar?: string;
    initials?: string;
    email?: string;
  };

  /** Show breadcrumb navigation (optional) */
  showBreadcrumb?: boolean;

  /** Breadcrumb items */
  breadcrumb?: Array<{ label: string; href?: string }>;

  /** Sticky positioning */
  isSticky?: boolean;
}
```

---

## 🎪 Eventos (Emits)

```typescript
emits: {
  'search': (query: string) => true,
  'notification-click': () => true,
  'settings-click': () => true,
  'profile-click': () => true,
  'logout': () => true,
  'logo-click': () => true,
}
```

---

## 🎨 Estilos

### Colores (Design System)
- **Background:** White (#FFFFFF)
- **Border:** Light gray (#E2E8F0)
- **Text Primary:** Dark navy (#1E3A8A)
- **Text Secondary:** Gray (#64748B)
- **Primary Action:** Brand navy (#1E3A8A)
- **Badge Background:** Red (#EF4444)
- **Badge Text:** White (#FFFFFF)

### Shadows & Elevation
- **Box Shadow:** 0 1px 3px rgba(0, 0, 0, 0.12)
- **Elevation:** 4dp

### Responsive
- Desktop 900px+: Full layout
- Desktop 1200px+: Expanded spacing
- Mobile fallback: Collapse to simplified header

### Focus States
- All interactive elements: Blue outline (2px) on focus
- Search input: Blue shadow on focus

---

## 🧪 Criterios de Aceptación

- [ ] Topbar fixed/sticky en top, h-16 (64px)
- [ ] Logo clickable navega a dashboard
- [ ] Search input con debounce 300ms
- [ ] Search emits event con query string
- [ ] Notification bell con badge count
- [ ] Badge solo visible si count > 0
- [ ] Settings icon abre menu
- [ ] Avatar con fallback a iniciales
- [ ] User dropdown con logout option
- [ ] Todos los eventos emitidos funcionan
- [ ] Colores validados contra design system
- [ ] TypeScript strict sin errores
- [ ] Responsive en breakpoints: sm (900px), md (1200px+)
- [ ] Validado visualmente contra `html-exports/STITCH_LAYOUTS_PRO_HEADER.html`
- [ ] Sin dependencies innecesarias (Vue 3, Quasar, Tailwind)
- [ ] JSDoc comments completos
- [ ] Search results modal integrado

---

## 📚 Referencias

### Stitch Design
- Screen: `Desktop Pro Dashboard Home`
- HTML Reference: `html-exports/STITCH_LAYOUTS_PRO_HEADER.html`
- Project ID: 5968657237763273187

### Design System
- Documento: `docs/ui-ux/08-frozen-canonical-design-system-brief.md`
- Colores: Light baseline per frozen specification

### Componentes relacionados
- Integración en: `src/layouts/ProDesktopLayout.vue`
- Usa: Quasar, Material Symbols icons, Tailwind

---

## 💡 Notas de Implementación

1. **Icons:** Usar Material Symbols icons de Quasar (`q-icon`)
   - Logo: Custom SVG o icon
   - Search: `search`
   - Notifications: `notifications`
   - Settings: `settings`
   - Avatar: Letra inicial o imagen

2. **Search Debounce:**
   ```typescript
   const debouncedSearch = useDebounceFn((query: string) => {
     emit('search', query);
   }, 300);
   ```

3. **Notification Badge:**
   ```html
   <q-badge
     color="red"
     floating
     rounded
     :label="notificationCount"
     v-if="notificationCount > 0"
   />
   ```

4. **Dropdown Menus:** Usar Quasar `q-menu`
   - Settings: icon menu
   - Avatar: user menu con logout

5. **Layout:** Usar Flexbox con spacing
   ```html
   <div class="flex items-center justify-between h-16 px-6 bg-white border-b">
     <!-- Logo -->
     <!-- Search -->
     <!-- Icons -->
   </div>
   ```

---

## 🚀 Stack Técnico

- **Framework:** Vue 3 (Composition API, TypeScript)
- **UI:** Quasar Framework
- **Styles:** Tailwind CSS
- **Icons:** Material Symbols (via Quasar)
- **State:** Props + Events (parent manages state)
- **Search:** v-model with debounce utility

---

## 📖 Ejemplo de Uso

```vue
<ProTopbar
  app-name="OWFinance Pro"
  search-placeholder="Search accounts, transactions..."
  :notification-count="5"
  :user="{ name: 'José Luis', avatar: '', initials: 'JL', email: 'jose@example.com' }"
  :is-sticky="true"
  @search="onSearch"
  @notification-click="showNotifications"
  @settings-click="showSettings"
  @profile-click="showProfile"
  @logout="handleLogout"
  @logo-click="goToDashboard"
/>
```

---

## 🔗 Tickets Relacionados

- **OFB-006:** Sidebar Navigation (complementario)
- **OFB-007:** Pro Layout Integration
- **OFB-028:** Layout refactoring (Pro/Lite separation)

---

## 📝 Notas Adicionales

- Este componente es el header principal del layout PRO
- Aparecerá en todas las pantallas desktop
- Su calidad visual impacta directamente la experiencia del usuario profesional
- Validar sticky positioning en scroll largo
- Probar con nombres de usuario muy largos

---

**Status:** ✅ Ready to Implement
**Priority:** Alta
**Role:** Frontend
**Effort:** 6-8 horas
