# Sistema de Layouts Dinámicos OWFINANCE

**Fecha**: 2026-04-06  
**Autor**: Documentación técnica del proyecto  

## 📋 Resumen Ejecutivo

OWFINANCE usa un sistema de **layouts dinámicos** que se adapta según las preferencias del usuario. Existen 3 modos principales:

1. **Lite** - Diseño mobile-first, minimalista, enfocado en usuarios casuales
2. **Pro** - Diseño avanzado con sidebar, múltiples paneles (en desarrollo)
3. **Legacy** - Diseño clásico con topbar y drawer, máxima compatibilidad

El selector de layout está controlado por `DynamicRoleLayout.vue` que carga el layout correspondiente según `auth.settings.layout_mode`.

---

## 🏗️ Arquitectura General

### Flujo de Selección de Layout

```
Usuario accede → /user/* routes
  ↓
Router carga: DynamicRoleLayout.vue
  ↓
DynamicRoleLayout lee: auth.settings.layout_mode
  ↓
Carga dinámicamente uno de:
  • LiteMobileLayout (si lite + mobile)
  • LiteDesktopLayout (si lite + desktop)
  • ProLayout (si pro)
  • LegacyLayout (si legacy o null)
  ↓
Layout renderiza: <router-view /> con la página solicitada
```

### Código del Selector (`DynamicRoleLayout.vue`)

```vue
<template>
  <!-- El router-view está dentro de cada layout hijo, no aquí -->
  <component :is="activeLayout" />
</template>

<script setup lang="ts">
import { computed, defineAsyncComponent } from 'vue';
import { useAuthStore } from 'stores/auth';
import { useQuasar } from 'quasar';

const LiteMobileLayout = defineAsyncComponent(() => import('./LiteMobileLayout.vue'));
const LiteDesktopLayout = defineAsyncComponent(() => import('./LiteDesktopLayout.vue'));
const ProLayout = defineAsyncComponent(() => import('./ProLayout.vue'));
const LegacyLayout = defineAsyncComponent(() => import('./LegacyLayout.vue'));

const auth = useAuthStore();
const $q = useQuasar();

const activeLayout = computed(() => {
  const mode = auth.settings?.layout_mode || 'legacy';
  
  if (mode === 'lite') {
    // Para Lite, elegir según tamaño de pantalla
    return $q.platform.is.desktop || $q.screen.gt.sm 
      ? LiteDesktopLayout 
      : LiteMobileLayout;
  }
  
  if (mode === 'pro') return ProLayout;
  return LegacyLayout; // Fallback por defecto
});
</script>
```

---

## 1️⃣ Layout Lite

### Concepto
Diseño **mobile-first** inspirado en apps financieras modernas (N26, Revolut). Enfoque en visualización clara, bottom navigation, y acciones rápidas con FAB.

### Variantes
- **LiteMobileLayout** - Optimizado para móvil (<768px)
- **LiteDesktopLayout** - Adaptación para escritorio (≥768px)

### Componentes Principales

#### Header
- **Component**: `LiquidHeader.vue`
- **Features**:
  - Avatar de usuario con iniciales
  - Selector de moneda dropdown
  - Balance total con toggle show/hide
  - Botones: AI Coach, Notificaciones, Menú
  - Modo oscuro toggle
- **Props**:
  ```typescript
  {
    balanceAmount: number
    balanceCurrency: string
    showBalance: boolean
    user: { name, avatar, initials }
    currencyOptions: string[]
  }
  ```

#### Bottom Navigation
- **Component**: `LiquidBottomNavNew.vue`
- **Features**:
  - 4 tabs: Inicio, Trans, Cántaros, Ajustes
  - FAB central para acciones rápidas
  - Indicador de tab activo
  - Transiciones suaves
- **Props**:
  ```typescript
  {
    activeTab: 'home' | 'transactions' | 'jars' | 'settings'
  }
  ```
- **Events**: `@tab-change`, `@fab-click`

#### Quick Action Sheet
- **Component**: `QuickActionSheet.vue`
- **Features**:
  - Bottom sheet modal con acciones rápidas
  - Crear ingreso, gasto, transferencia
  - Backdrop blur effect
- **Props**: `v-model` (show/hide)

#### Otros Componentes Liquid
- `LiquidBalanceCard.vue` - Card de balance hero
- `LiquidJarCard.vue` - Card de cántaro con gráfico circular
- `LiquidTransactionItem.vue` - Item de transacción en lista
- `LiquidCategoryChip.vue` - Chip de categoría con color
- `LiquidFAB.vue` - Floating Action Button
- `ExpandedNavigationMenuLight.vue` - Menú expandido (desktop)

### Rutas de Navegación (Bottom Nav)
```typescript
const routes = {
  home: '/user/home',          // Dashboard principal
  transactions: '/user/transactions', // Lista de movimientos
  jars: '/user/jars',          // Gestión de cántaros
  settings: '/user/config'     // Ajustes y configuración
};
```

### Paleta de Colores Lite
```css
:root {
  --app-bg: #F8FAFC;           /* Fondo principal */
  --card-bg: #FFFFFF;          /* Cards */
  --primary: #1E3A8A;          /* Azul marino */
  --accent: #0EA5E9;           /* Azul cielo */
  --text-main: #1E293B;        /* Texto principal */
  --text-muted: #64748B;       /* Texto secundario */
}
```

### Fonts
- **Display/Headers**: `Satoshi` (bold, medium)
- **Body/UI**: `DM Sans` (400, 500, 700)
- **Icons**: `Material Symbols Outlined`

### Estados del Usuario
El layout Lite se activa cuando:
```typescript
auth.settings.layout_mode === 'lite'
```

Para activar:
```typescript
await auth.setLayoutMode('lite')
```

---

## 2️⃣ Layout Pro

### Concepto
Diseño **avanzado** para usuarios power/empresariales. Incluye sidebar de navegación, múltiples paneles, vistas complejas.

### Estado Actual
⚠️ **EN DESARROLLO** - Actualmente es un placeholder con sidebar básico.

### Estructura Prevista
```
┌─────────────────────────────────────┐
│ Header (compacto)                   │
├───────────┬─────────────────────────┤
│           │                         │
│ Sidebar   │  Main Content Area      │
│ (240px)   │  (flex)                 │
│           │                         │
│ - Home    │  Router View            │
│ - Trans   │                         │
│ - Jars    │                         │
│ - Reports │                         │
│ - Stats   │                         │
│           │                         │
└───────────┴─────────────────────────┘
```

### Componentes Principales (pendientes)
- `ProSidebar.vue` - Sidebar de navegación (actualmente existe como componente legacy)
- `ProTopbar.vue` - Topbar compacto (actualmente existe como componente legacy)
- `ProDashboard.vue` - Dashboard multi-panel
- `ProStatsPanel.vue` - Panel de estadísticas avanzadas
- `ProReportsPanel.vue` - Panel de reportes

### Activación
```typescript
auth.settings.layout_mode === 'pro'
```

### Notas de Implementación
- Requiere diseño UX completo antes de implementar
- Priorizar sidebar navigation pattern
- Considerar múltiples workspaces/vistas simultáneas
- Integración con gráficos avanzados (Chart.js, Recharts)

---

## 3️⃣ Layout Legacy

### Concepto
Diseño **clásico** tipo admin panel con drawer lateral, topbar con menú horizontal, y rates strip.

### Estructura
```
┌─────────────────────────────────────┐
│ Topbar:                             │
│ Avatar | Shell Selector | Menu | ⏏  │
├─────────────────────────────────────┤
│ Rates Strip (tasas de cambio)      │
├───────────┬─────────────────────────┤
│           │                         │
│ Drawer    │  Main Content           │
│ (toggle)  │  (q-page-container)     │
│           │                         │
│ - Home    │  Router View            │
│ - Trans   │                         │
│ - Jars    │                         │
│ - Config  │                         │
│           │                         │
├───────────┴─────────────────────────┤
│ Bottom Nav Mobile (< 768px)        │
└─────────────────────────────────────┘
```

### Componentes Principales
- **Topbar** (integrado en LegacyLayout):
  - Avatar + nombre + email
  - Shell selector (Pro/Lite/Legacy)
  - Menú horizontal (desktop)
  - Toggle visibility de valores
  - Logout button

- **Drawer** (q-drawer):
  - Se abre con botón menú en móvil
  - Navegación principal
  - Oculto en desktop (menú va a topbar)

- **Rates Strip**:
  - Muestra tasas de cambio activas
  - Scroll horizontal en móvil

- **Bottom Navigation** (móvil):
  - Similar a Lite pero estilo legacy
  - 4 tabs + FAB central

### Componentes Compartidos
Legacy usa muchos componentes compartidos:
- `AccountsSidebarWidget.vue`
- `JarsBalanceBar.vue`
- `MonthlyIncomePanel.vue`
- `OnboardingModal.vue`
- `TransactionCreateDialog.vue`
- `TransactionEditDialog.vue`
- `CrudPage.vue`

### Rutas de Navegación
Desktop menu links (topbar):
```typescript
const desktopMenuLinks = [
  { to: '/user/home', icon: 'home', title: 'Inicio' },
  { to: '/user/transactions', icon: 'receipt_long', title: 'Movimientos' },
  { to: '/user/jars', icon: 'savings', title: 'Cántaros' },
  { to: '/user/config', icon: 'settings', title: 'Ajustes' }
];
```

### Activación
```typescript
auth.settings.layout_mode === 'legacy' // o null (default)
```

### Shell Selector
El usuario puede cambiar de layout desde el selector en topbar:
```typescript
const layoutModeOptions = [
  { value: 'legacy', label: 'Clásico' },
  { value: 'lite', label: 'Lite' },
  { value: 'pro', label: 'Pro', disable: true } // Disabled hasta implementar
];
```

---

## 🔧 Gestión de Estado del Layout

### AuthStore (`stores/auth.ts`)

#### Interface de Settings
```typescript
interface UserSettings {
  layout_mode: 'lite' | 'pro' | 'legacy' | null;
  // ...otras settings
}
```

#### Método de Cambio de Layout
```typescript
async setLayoutMode(mode: 'lite' | 'pro' | 'legacy' | null) {
  try {
    // Actualizar en backend
    const response = await api.patch('/user/settings', { layout_mode: mode });
    
    // Actualizar store local
    this.user = { ...this.user, layout_mode: mode };
    this.settings = { ...this.settings, layout_mode: mode };
    
    // Persistir en localStorage
    this.saveToStorage();
    
    // Router refresh automático por reactive computed en DynamicRoleLayout
    
  } catch (error) {
    console.error('Failed to update layout mode:', error);
    throw error;
  }
}
```

### Persistencia
- **Backend**: Columna `layout_mode` en tabla `users` o `user_settings`
- **Frontend**: LocalStorage via `authStore.saveToStorage()`
- **Sincronización**: Al login se carga desde backend, se guarda en store

---

## 📂 Estructura de Archivos

```
src/
├── layouts/
│   ├── DynamicRoleLayout.vue      # Selector de layout (NO tiene router-view)
│   ├── LiteMobileLayout.vue       # Layout Lite móvil
│   ├── LiteDesktopLayout.vue      # Layout Lite desktop
│   ├── ProLayout.vue              # Layout Pro (placeholder)
│   ├── LegacyLayout.vue           # Layout Legacy (clásico)
│   ├── AdminLayout.vue            # Layout admin (separado, no dinámico)
│   └── MainLayout.vue             # Layout login/public
│
├── components/
│   ├── liquid/                    # Componentes del layout Lite
│   │   ├── LiquidHeader.vue
│   │   ├── LiquidBottomNavNew.vue
│   │   ├── QuickActionSheet.vue
│   │   ├── LiquidBalanceCard.vue
│   │   ├── LiquidJarCard.vue
│   │   ├── LiquidTransactionItem.vue
│   │   ├── LiquidCategoryChip.vue
│   │   ├── LiquidFAB.vue
│   │   └── ExpandedNavigationMenuLight.vue
│   │
│   ├── lite/                      # (Vacío - reserved)
│   ├── pro/                       # (Vacío - reserved)
│   │
│   └── [shared components]        # Usados por Legacy y compartidos
│       ├── AccountsSidebarWidget.vue
│       ├── JarsBalanceBar.vue
│       ├── MonthlyIncomePanel.vue
│       ├── OnboardingModal.vue
│       ├── ProSidebar.vue         # Legacy sidebar component
│       ├── ProTopbar.vue          # Legacy topbar component
│       ├── TransactionCreateDialog.vue
│       ├── TransactionEditDialog.vue
│       └── CrudPage.vue
│
├── stores/
│   └── auth.ts                    # Gestión de layout_mode
│
└── router/
    └── routes.ts                  # Rutas con DynamicRoleLayout
```

---

## 🎯 Diferencias Clave Entre Layouts

| Feature | Lite | Pro | Legacy |
|---------|------|-----|--------|
| **Navegación** | Bottom Nav + Header | Sidebar + Header | Drawer + Topbar + Bottom Nav |
| **Mobile-first** | ✅ Sí | ⚠️ Responsive | ⚠️ Móvil adaptado |
| **Desktop UX** | Bottom Nav adaptado | Sidebar avanzado | Topbar horizontal menu |
| **Complejidad** | 🟢 Simple | 🔴 Avanzado | 🟡 Medio |
| **Target User** | Usuario casual | Power user | Usuario legacy/tradicional |
| **FAB** | ✅ Central destacado | ⚠️ Multi-FAB | ✅ Single FAB |
| **Balance Display** | Hero card grande | Panel sidebar | Widget header |
| **Estado** | ✅ Funcional | ⚠️ En desarrollo | ✅ Funcional |
| **Componentes** | `liquid/*` | `pro/*` (pendiente) | Shared + legacy |
| **Dark Mode** | ✅ Soporte | ⚠️ Pendiente | ✅ Soporte |
| **Transiciones** | Smooth page transitions | (pendiente) | Basic transitions |

---

## 🚀 Flujo de Implementación de un Nuevo Layout

### Paso 1: Crear el Layout Component
```vue
<!-- src/layouts/MyNewLayout.vue -->
<template>
  <div class="my-new-layout">
    <MyHeader />
    <main>
      <router-view /> <!-- IMPORTANTE: Incluir router-view -->
    </main>
    <MyFooter />
  </div>
</template>

<script setup lang="ts">
import MyHeader from 'components/my-layout/MyHeader.vue';
import MyFooter from 'components/my-layout/MyFooter.vue';
</script>
```

### Paso 2: Registrar en DynamicRoleLayout
```typescript
// src/layouts/DynamicRoleLayout.vue
const MyNewLayout = defineAsyncComponent(() => import('./MyNewLayout.vue'));

const activeLayout = computed(() => {
  const mode = auth.settings?.layout_mode || 'legacy';
  
  if (mode === 'my-new') return MyNewLayout;
  // ...resto de lógica
});
```

### Paso 3: Actualizar AuthStore Types
```typescript
// src/stores/auth.ts
interface UserSettings {
  layout_mode: 'lite' | 'pro' | 'legacy' | 'my-new' | null;
}
```

### Paso 4: Crear Componentes Específicos
```
src/components/my-layout/
├── MyHeader.vue
├── MyFooter.vue
├── MyNavigation.vue
└── index.ts
```

### Paso 5: Backend Migration (si aplica)
```sql
ALTER TABLE user_settings 
  MODIFY COLUMN layout_mode ENUM('lite', 'pro', 'legacy', 'my-new') DEFAULT 'legacy';
```

---

## 🐛 Problemas Comunes y Soluciones

### 1. Páginas vacías en layout
**Síntoma**: URL correcta pero contenido no renderiza

**Causa**: `<router-view />` faltante o duplicado

**Solución**:
- ✅ Cada layout hijo DEBE tener `<router-view />`
- ❌ DynamicRoleLayout NO debe tener `<router-view />`

### 2. Layout no cambia al seleccionar
**Síntoma**: Selector cambia pero layout sigue igual

**Causa**: Store no se actualiza o computed no reactivo

**Solución**:
```typescript
// Verificar que el computed sea reactivo
const activeLayout = computed(() => {
  const mode = auth.settings?.layout_mode || 'legacy';
  console.log('Current mode:', mode); // Debug
  // ...
});
```

### 3. Componente no se encuentra
**Síntoma**: `Failed to resolve component: LiquidHeader`

**Causa**: Import path incorrecto o componente no exportado

**Solución**:
```typescript
// Import directo (recomendado para layouts)
import LiquidHeader from 'components/liquid/LiquidHeader.vue';

// NO usar auto-import para componentes de layout
```

### 4. Estilos no se aplican
**Síntoma**: Layout se ve mal, sin estilos

**Causa**: Tailwind classes no compiladas o CSS scoped

**Solución**:
- Verificar `class="bg-[#F8FAFC]"` en template
- Asegurar que Tailwind está configurado
- Revisar que no haya `scoped` bloqueando estilos globales

---

## 📊 Estadísticas de Uso (Ejemplo)

| Layout | % Usuarios | Dispositivo Principal | Engagement |
|--------|-----------|----------------------|-----------|
| Lite | 65% | Mobile (80%) | Alto ⬆️ |
| Legacy | 30% | Desktop (70%) | Medio → |
| Pro | 5% | Desktop (95%) | Muy Alto ⬆️⬆️ |

---

## 🔮 Roadmap

### Q2 2026
- ✅ Lite Layout funcional (mobile + desktop)
- ✅ Legacy Layout mantenido
- ⏳ Pro Layout diseño UX completo
- ⏳ A/B testing Lite vs Legacy

### Q3 2026
- ⏳ Pro Layout implementación completa
- ⏳ Dashboard widgets personalizables
- ⏳ Multi-workspace en Pro
- ⏳ Lite Features: widgets drawer, quick stats

### Q4 2026
- ⏳ Deprecar Legacy gradualmente
- ⏳ Lite como default para nuevos usuarios
- ⏳ Pro como upgrade premium

---

## 📚 Referencias

- **Diseño Lite**: `docs/ui-ux/02-current-ui-inventory-and-architecture.md`
- **Stitch Components**: `stitch_ow_finance_2026_master_ui_definitivo/`
- **Routes**: `src/router/routes.ts`
- **Auth Store**: `src/stores/auth.ts`
- **Skill Testing Routes**: `.agents/skills/owfinance-dev-routes-testing/`

---

**Última actualización**: 2026-04-06  
**Versión**: 1.0  
**Mantenido por**: Equipo OWFINANCE Development
