# OFB-003: Actualizar LiteMobileLayout.vue - Integración

**Ticket Notion:** https://www.notion.so/337e7ace976781f9b236cf69ac34cde5

---

## 📋 Resumen Ejecutivo

Integrar completamente los componentes **LiquidHeader** (OFB-001) y **LiquidBottomNavNew** (OFB-002) en el layout principal **LiteMobileLayout.vue**. Este ticket se enfoca en la orquestación, estado compartido, y sincronización correcta de eventos.

---

## 🎯 Objetivo

Crear un layout LITE completamente funcional que:
- Integre ambos componentes de forma fluida
- Maneje estado compartido (balance, moneda, tab activo, etc.)
- Sincronice router con navegación
- Gestione QuickActionSheet (modal de agregar)
- Mantenga transiciones suaves entre pantallas

---

## 📁 Ubicación del Archivo

```
src/layouts/LiteMobileLayout.vue
```

---

## 🏗️ Estructura del Layout

```
┌─────────────────────────────────────┐
│        LiquidHeader (OFB-001)       │  Fixed top (64px)
├─────────────────────────────────────┤
│                                     │
│                                     │
│       Page Container (router-view)  │  pt-16 (offset para header)
│    + Transiciones suave             │  pb-20 (offset para footer)
│                                     │
│                                     │
├─────────────────────────────────────┤
│    LiquidBottomNavNew (OFB-002)     │  Fixed bottom (80px + safe)
│         + FAB Button                │
└─────────────────────────────────────┘

QuickActionSheet (modal, z-index alto)
```

---

## 💾 Estado Local (Composables/Refs)

```typescript
// UI State
const showQuickActions = ref(false);
const showBalance = ref(true);
const currentCurrency = ref('USD');

// Currency options
const currencyOptions = ['USD', 'EUR', 'GBP', 'CHF', 'CAD', 'MXN'];

// User data (from Pinia store)
const userData = computed(() => ({
  name: authStore.user?.name || 'User',
  avatar: authStore.user?.avatar || '',
  initials: authStore.user?.name?.substring(0, 2).toUpperCase() || 'U'
}));

// User balance (from store or API)
const userBalance = ref(0);

// Active tab sync with route
const activeTab = ref<'home' | 'transactions' | 'jars' | 'settings'>('home');
```

---

## 🎪 Event Handlers

### Balance Toggle
```typescript
function onBalanceToggle() {
  showBalance.value = !showBalance.value;
}
```

### Currency Change
```typescript
function onCurrencyChange(currency: string) {
  currentCurrency.value = currency;
  // TODO: Emit a Pinia action to update globally
  // store.setCurrency(currency);
}
```

### Tab Navigation
```typescript
function onTabChange(tabId: string) {
  activeTab.value = tabId;
  const routes = {
    home: '/app/home',
    transactions: '/app/transactions',
    jars: '/app/jars',
    settings: '/app/config'
  };
  router.push(routes[tabId]).catch(() => {});
}
```

### Avatar Click
```typescript
function onAvatarClick() {
  // TODO: Open user profile menu or sheet
  // Posible: navigate to /app/config
}
```

### Menu Click
```typescript
function onMenuClick() {
  // TODO: Open mobile menu/drawer if exists
}
```

### FAB Click
```typescript
function onFabClick() {
  showQuickActions.value = true;
}
```

---

## 🔄 Router Synchronization

### On Mount: Sincronizar tab con ruta actual
```typescript
onMounted(() => {
  syncActiveTabWithRoute();
});

function syncActiveTabWithRoute() {
  const path = route.path;
  if (path.includes('/transactions')) activeTab.value = 'transactions';
  else if (path.includes('/jars')) activeTab.value = 'jars';
  else if (path.includes('/config') || path.includes('/settings')) activeTab.value = 'settings';
  else activeTab.value = 'home';
}
```

### Watch Route: Mantener sincronización
```typescript
watch(() => route.path, () => {
  syncActiveTabWithRoute();
});
```

---

## 📦 Props Pasadas a Componentes

### Para LiquidHeader
```vue
<LiquidHeader
  :balance-amount="userBalance"
  :balance-currency="currentCurrency"
  :show-balance="showBalance"
  :user="userData"
  :currency-options="currencyOptions"
  @balance-toggle="showBalance = !showBalance"
  @currency-change="onCurrencyChange"
  @avatar-click="onAvatarClick"
  @menu-click="onMenuClick"
/>
```

### Para LiquidBottomNavNew
```vue
<LiquidBottomNavNew
  :active-tab="activeTab"
  @fab-click="onFabClick"
  @tab-change="onTabChange"
/>
```

### Para QuickActionSheet
```vue
<QuickActionSheet v-model="showQuickActions" />
```

---

## 🧪 Criterios de Aceptación

- [ ] LiquidHeader integrado y funcionando
- [ ] LiquidBottomNavNew integrado y funcionando
- [ ] Balance toggle cambia visibilidad
- [ ] Currency selector actualiza moneda
- [ ] Tab navigation funciona (router.push)
- [ ] Active tab se sincroniza con ruta actual
- [ ] QuickActionSheet abre/cierra con FAB
- [ ] Estado de activeTab persiste en rutas
- [ ] Transiciones suaves entre páginas (fade + slide)
- [ ] Safe areas correctas (pt-16, pb-20, pb-safearea)
- [ ] No hay prop/event conflicts
- [ ] TypeScript strict sin errores
- [ ] Responsive en todos breakpoints
- [ ] Ningún componente queda sin usar
- [ ] Accesibilidad completa

---

## 📚 Referencias

### Componentes dependientes
- **OFB-001:** LiquidHeader.vue
- **OFB-002:** LiquidBottomNavNew.vue
- **QuickActionSheet:** Ya existe en codebase

### Estructura actual
- Archivo: `src/layouts/LiteMobileLayout.vue`
- Router: `src/router/routes.ts`
- Stores: Pinia (useAuthStore, etc.)

### Rutas esperadas
- `/app/home` → Home tab
- `/app/transactions` → Transactions tab
- `/app/jars` → Jars tab
- `/app/config` → Settings tab

---

## 💡 Notas de Implementación

1. **Imports necesarios:**
   ```typescript
   import { ref, computed, onMounted, watch } from 'vue';
   import { useRouter, useRoute } from 'vue-router';
   import { useAuthStore } from 'stores/auth';
   import LiquidHeader from 'components/liquid/LiquidHeader.vue';
   import LiquidBottomNavNew from 'components/liquid/LiquidBottomNavNew.vue';
   import QuickActionSheet from 'components/liquid/QuickActionSheet.vue';
   ```

2. **Layout view:**
   ```html
   <q-layout view="lHh lpr lFf" class="bg-[#F8FAFC]">
   ```

3. **Page container:**
   ```html
   <q-page-container class="pt-16 min-h-screen">
   ```

4. **Transiciones:**
   ```vue
   <transition name="lite-page" mode="out-in">
     <component :is="Component" />
   </transition>
   ```

5. **Estilos de transición:**
   ```scss
   .lite-page-enter-active,
   .lite-page-leave-active {
     transition: opacity 250ms cubic-bezier(0.23, 1, 0.32, 1),
                 transform 250ms cubic-bezier(0.23, 1, 0.32, 1);
   }
   .lite-page-enter-from {
     opacity: 0;
     transform: translateY(8px);
   }
   .lite-page-leave-to {
     opacity: 0;
     transform: translateY(-8px);
   }
   ```

---

## 🚀 Stack Técnico

- **Framework:** Vue 3 (Composition API, TypeScript)
- **Routing:** Vue Router 4
- **UI:** Quasar Framework 2
- **State:** Pinia (stores)
- **Styles:** Tailwind CSS
- **Transiciones:** Vue Transition built-in

---

## 📖 Estructura Final Esperada

```vue
<template>
  <q-layout view="lHh lpr lFf" class="bg-[#F8FAFC]">
    <LiquidHeader
      :balance-amount="userBalance"
      :balance-currency="currentCurrency"
      :show-balance="showBalance"
      :user="userData"
      :currency-options="currencyOptions"
      @balance-toggle="showBalance = !showBalance"
      @currency-change="onCurrencyChange"
      @avatar-click="onAvatarClick"
      @menu-click="onMenuClick"
    />

    <q-page-container class="pt-16 min-h-screen">
      <router-view v-slot="{ Component }">
        <transition name="lite-page" mode="out-in">
          <component :is="Component" />
        </transition>
      </router-view>
    </q-page-container>

    <LiquidBottomNavNew
      :active-tab="activeTab"
      @fab-click="showQuickActions = true"
      @tab-change="onTabChange"
    />

    <QuickActionSheet v-model="showQuickActions" />
  </q-layout>
</template>

<script setup lang="ts">
// ... código completo ...
</script>

<style lang="scss" scoped>
// ... estilos de transición ...
</style>
```

---

## 🔗 Tickets Relacionados

- **OFB-001:** Header (debe estar completo)
- **OFB-002:** Bottom Navigation (debe estar completo)
- **OFB-004:** Validación final LITE

---

## 📝 Notas Adicionales

- Este ticket une todo el trabajo anterior
- Es crítico para que el layout LITE sea funcional
- Probar navegación en todos los browsers
- Validar que no hay memory leaks en watchers
- Probar que el router.push maneja errores correctamente
- Validar performance con React DevTools

---

**Status:** ✅ Ready to Implement
**Priority:** Alta
**Role:** Frontend
**Effort:** 2-3 horas
**Depende de:** OFB-001, OFB-002 (completados)
**Bloqueado por:** Ninguno (ambas dependencias listas)
