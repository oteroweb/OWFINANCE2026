# LiquidHeader Component Usage Guide

## Component Path
```
src/components/liquid/LiquidHeader.vue
```

## Basic Import & Usage

### Vue 3 with Composition API

```vue
<template>
  <div class="app">
    <!-- LiquidHeader at top of layout -->
    <LiquidHeader
      :balance-amount="userBalance"
      :balance-currency="activeCurrency"
      :user="currentUser"
      :currency-options="supportedCurrencies"
      :is-loading="isLoadingBalance"
      @menu-click="handleMenuClick"
      @balance-toggle="handleBalanceToggle"
      @currency-change="handleCurrencyChange"
      @avatar-click="handleAvatarAction"
    />

    <!-- Main content area -->
    <main class="mt-16">
      <!-- Page content goes here -->
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import LiquidHeader from '@/components/liquid/LiquidHeader.vue'

// State management
const userBalance = ref<number>(12450.50)
const activeCurrency = ref<string>('CHF')
const isLoadingBalance = ref<boolean>(false)
const supportedCurrencies = ref<string[]>(['CHF', 'USD', 'EUR', 'GBP', 'CAD', 'MXN'])

// User data (typically from auth store or API)
const currentUser = ref({
  name: 'John Doe',
  avatar: 'https://api.example.com/avatars/john-doe.jpg',
  initials: 'JD'
})

// Event handlers
const handleMenuClick = (): void => {
  console.log('Menu button clicked')
  // Open sidebar/drawer
  // emit('menu:open') to parent layout
}

const handleBalanceToggle = (): void => {
  console.log('Balance visibility toggled')
  // Persist user preference to localStorage or API
  // localStorage.setItem('hideBalance', 'true')
}

const handleCurrencyChange = (currency: string): void => {
  console.log(`Currency changed to: ${currency}`)
  activeCurrency.value = currency
  // Update global app state
  // store.commit('setCurrency', currency)
  // Fetch balance in new currency
  fetchBalance(currency)
}

const handleAvatarAction = (action: string): void => {
  console.log(`Avatar action: ${action}`)
  switch (action) {
    case 'profile':
      navigateTo('/settings/profile')
      break
    case 'settings':
      navigateTo('/settings')
      break
    case 'logout':
      performLogout()
      break
    default:
      console.warn(`Unknown action: ${action}`)
  }
}

// Helper functions
const fetchBalance = async (currency: string): Promise<void> => {
  isLoadingBalance.value = true
  try {
    const response = await fetch(`/api/balance?currency=${currency}`)
    const data = await response.json()
    userBalance.value = data.amount
  } catch (error) {
    console.error('Failed to fetch balance:', error)
  } finally {
    isLoadingBalance.value = false
  }
}

const navigateTo = (path: string): void => {
  // Use Vue Router
  // router.push(path)
}

const performLogout = async (): Promise<void> => {
  // Clear auth state, redirect to login
  // await store.dispatch('logout')
  // router.push('/login')
}
</script>

<style scoped>
/* Adjust main content top margin to account for fixed header */
main {
  @apply mt-16 p-4;
}

/* Optional: Add safe area padding for sidebar/nav under header */
@supports (padding: max(0px)) {
  main {
    @apply pt-[calc(4rem+max(0px,env(safe-area-inset-top)))]
  }
}
</style>
```

## Props Examples

### Minimal Configuration (Using Defaults)
```vue
<LiquidHeader />
<!-- Uses: balance=0, currency=CHF, user=null, etc. -->
```

### Complete Configuration
```vue
<LiquidHeader
  :balance-amount="5432.10"
  balance-currency="USD"
  :show-balance="true"
  :user="{
    name: 'Jane Smith',
    avatar: 'https://example.com/jane.jpg',
    initials: 'JS'
  }"
  :currency-options="['USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD']"
  :is-loading="false"
/>
```

### Dynamic Props with Reactive Data
```vue
<template>
  <LiquidHeader
    :balance-amount="store.balance.amount"
    :balance-currency="store.settings.currency"
    :user="store.auth.user"
    :currency-options="store.balance.availableCurrencies"
    :is-loading="store.balance.isLoading"
  />
</template>

<script setup>
import { useAppStore } from '@/stores/app'
const store = useAppStore()
</script>
```

## Event Handling

### All Events Example
```vue
<template>
  <LiquidHeader
    @menu-click="onMenuClick"
    @balance-toggle="onBalanceToggle"
    @currency-change="onCurrencyChange"
    @avatar-click="onAvatarClick"
  />
</template>

<script setup>
const onMenuClick = () => {
  // Handle menu button click
  console.log('Hamburger menu clicked')
}

const onBalanceToggle = () => {
  // Handle balance visibility toggle
  console.log('Balance visibility toggled')
}

const onCurrencyChange = (currency: string) => {
  // Handle currency selection
  console.log(`New currency: ${currency}`)
}

const onAvatarClick = (action: string) => {
  // Handle avatar menu actions: 'profile', 'settings', 'logout'
  console.log(`Avatar menu action: ${action}`)
}
</script>
```

## Layout Integration Example

### Complete Page Layout
```vue
<template>
  <div class="app-wrapper">
    <!-- Fixed Header -->
    <LiquidHeader
      :balance-amount="balance"
      :balance-currency="currency"
      :user="user"
      @menu-click="toggleSidebar"
      @currency-change="updateCurrency"
      @avatar-click="handleUserMenu"
    />

    <!-- Sidebar/Drawer -->
    <nav
      class="fixed left-0 top-16 h-[calc(100vh-4rem)] w-64 bg-gray-900 text-white transition-transform duration-300"
      :class="{ '-translate-x-full': !sidebarOpen }"
    >
      <!-- Navigation items -->
    </nav>

    <!-- Main Content -->
    <main class="ml-0 pt-16 md:ml-64">
      <div class="container mx-auto p-4">
        <!-- Page content -->
        <router-view />
      </div>
    </main>

    <!-- Mobile Overlay -->
    <div
      v-if="sidebarOpen && isMobile"
      class="fixed inset-0 bg-black/50 z-30 mt-16"
      @click="toggleSidebar"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useWindowSize } from '@vueuse/core'
import LiquidHeader from '@/components/liquid/LiquidHeader.vue'

const router = useRouter()
const { width } = useWindowSize()
const isMobile = computed(() => width.value < 768)

const sidebarOpen = ref(false)
const balance = ref(12450.50)
const currency = ref('CHF')
const user = ref({
  name: 'John Doe',
  avatar: '/avatars/john.jpg'
})

const toggleSidebar = () => {
  sidebarOpen.value = !sidebarOpen.value
}

const updateCurrency = (newCurrency: string) => {
  currency.value = newCurrency
}

const handleUserMenu = (action: string) => {
  if (action === 'logout') {
    router.push('/logout')
  } else if (action === 'settings') {
    router.push('/settings')
  }
}
</script>
