<template>
  <header
    class="fixed top-0 left-0 right-0 h-16 bg-white border-b border-gray-200 z-50 pt-safearea"
    :class="{ 'opacity-75': isLoading }"
  >
    <!-- Main container with 3 sections -->
    <div class="flex items-center justify-between h-full px-4 sm:px-6">
      <!-- Section 1: Menu (Left) -->
      <button
        class="flex items-center justify-center w-10 h-10 rounded-lg hover:bg-gray-100 transition-colors active:bg-gray-200"
        :aria-label="$t('menu.toggle', 'Toggle menu')"
        @click="emit('menu-click')"
      >
        <q-icon name="menu_outlined" size="24px" color="#1E3A8A" />
      </button>

      <!-- Section 2: Balance (Center) -->
      <div class="flex-1 flex flex-col items-center mx-4 sm:mx-8">
        <span class="text-xs sm:text-sm font-medium text-gray-500 uppercase tracking-wide">
          {{ $t('header.balance', 'Total Balance') }}
        </span>
        <div class="flex items-baseline gap-2 mt-1">
          <span
            class="text-2xl sm:text-3xl font-bold text-gray-900 transition-all duration-200"
            :class="{ 'blur-sm': !showBalance && isBalanceVisible }"
          >
            {{ formattedBalance }}
          </span>
          <button
            class="p-1.5 rounded-full hover:bg-gray-100 transition-colors active:bg-gray-200"
            :aria-label="isBalanceVisible ? 'Hide balance' : 'Show balance'"
            @click="toggleBalanceVisibility"
          >
            <q-icon
              :name="isBalanceVisible ? 'visibility_outlined' : 'visibility_off_outlined'"
              size="20px"
              color="#666"
            />
          </button>
        </div>
      </div>

      <!-- Section 3: Avatar + Currency (Right) -->
      <div class="flex items-center gap-3">
        <!-- Currency Selector Dropdown -->
        <q-menu
          anchor="bottom right"
          self="top right"
          :offset="[0, 8]"
          transition-show="scale"
          transition-hide="scale"
        >
          <template #default="scope">
            <q-list style="min-width: 120px">
              <q-item
                v-for="currency in availableCurrencies"
                :key="currency"
                v-ripple
                clickable
                @click="selectCurrency(currency, scope)"
              >
                <q-item-section>
                  <span
                    class="font-medium"
                    :class="currency === balanceCurrency ? 'text-blue-600' : 'text-gray-700'"
                  >
                    {{ currency }}
                  </span>
                </q-item-section>
                <q-item-section avatar v-if="currency === balanceCurrency">
                  <q-icon name="check" color="blue-600" />
                </q-item-section>
              </q-item>
            </q-list>
          </template>

          <button
            class="flex items-center justify-center w-10 h-10 rounded-lg hover:bg-gray-100 transition-colors active:bg-gray-200 text-sm font-semibold text-gray-700"
            :aria-label="`Select currency, currently ${balanceCurrency}`"
          >
            {{ balanceCurrency }}
          </button>
        </q-menu>

        <!-- User Avatar -->
        <q-menu
          anchor="bottom right"
          self="top right"
          :offset="[0, 8]"
          transition-show="scale"
          transition-hide="scale"
        >
          <template #default="scope">
            <q-list style="min-width: 180px">
              <q-item v-if="user?.name" clickable disabled>
                <q-item-section>
                  <span class="font-semibold text-gray-900">{{ user.name }}</span>
                </q-item-section>
              </q-item>
              <q-separator v-if="user?.name" />
              <q-item clickable @click="handleAvatarMenuClick('profile', scope)">
                <q-item-section avatar>
                  <q-icon name="person_outlined" />
                </q-item-section>
                <q-item-section>
                  {{ $t('menu.profile', 'Profile') }}
                </q-item-section>
              </q-item>
              <q-item clickable @click="handleAvatarMenuClick('settings', scope)">
                <q-item-section avatar>
                  <q-icon name="settings_outlined" />
                </q-item-section>
                <q-item-section>
                  {{ $t('menu.settings', 'Settings') }}
                </q-item-section>
              </q-item>
              <q-item clickable @click="handleAvatarMenuClick('logout', scope)">
                <q-item-section avatar>
                  <q-icon name="logout" />
                </q-item-section>
                <q-item-section>
                  {{ $t('menu.logout', 'Logout') }}
                </q-item-section>
              </q-item>
            </q-list>
          </template>

          <q-avatar
            size="40px"
            class="cursor-pointer hover:shadow-md transition-shadow"
            :class="{ 'ring-2 ring-blue-400': isLoading }"
            :text-color="getInitialsTextColor"
            :background-color="getInitialsBgColor"
          >
            {{ displayInitials }}
            <template #default>
              <img v-if="user?.avatar" :src="user.avatar" :alt="user.name || 'User'" />
            </template>
          </q-avatar>
        </q-menu>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { QMenu } from 'quasar'

/**
 * Props interface for LiquidHeader component
 * @interface LiquidHeaderProps
 * @property {number} balanceAmount - The balance amount to display
 * @property {string} balanceCurrency - ISO 4217 currency code (default: 'CHF')
 * @property {boolean} showBalance - Whether balance is visible by default (default: true)
 * @property {object} user - User information object
 * @property {string} user.name - User's full name
 * @property {string} user.avatar - URL to user's avatar image
 * @property {string} user.initials - User's initials for fallback display
 * @property {string[]} currencyOptions - Array of available currency codes
 * @property {boolean} isLoading - Loading state indicator
 */
interface LiquidHeaderProps {
  balanceAmount?: number
  balanceCurrency?: string
  showBalance?: boolean
  user?: {
    name?: string
    avatar?: string
    initials?: string
  }
  currencyOptions?: string[]
  isLoading?: boolean
}

/**
 * Emits interface for LiquidHeader component
 * @interface LiquidHeaderEmits
 * @property {void} balance-toggle - Emitted when balance visibility is toggled
 * @property {string} currency-change - Emitted with currency code when currency is changed
 * @property {string} avatar-click - Emitted with menu action when avatar menu item is selected
 * @property {void} menu-click - Emitted when menu button is clicked
 */
interface LiquidHeaderEmits {
  'balance-toggle': []
  'currency-change': [currency: string]
  'avatar-click': [action: string]
  'menu-click': []
}

// Define component props
const props = withDefaults(defineProps<LiquidHeaderProps>(), {
  balanceAmount: 0,
  balanceCurrency: 'CHF',
  showBalance: true,
  currencyOptions: () => ['CHF', 'USD', 'EUR', 'GBP', 'CAD', 'MXN'],
  isLoading: false,
  user: () => ({
    name: undefined,
    avatar: undefined,
    initials: 'U'
  })
})

// Define component emits
const emit = defineEmits<LiquidHeaderEmits>()

/**
 * Internal state for balance visibility
 * Separate from prop to track local toggle state
 */
const isBalanceVisible = ref(props.showBalance)

/**
 * Formatted balance string with currency formatting
 * Uses Intl.NumberFormat for locale-aware formatting
 * @returns {string} Formatted balance (e.g. "CHF 1,234.56")
 */
const formattedBalance = computed((): string => {
  if (!isBalanceVisible.value) {
    return '••••••'
  }

  try {
    const formatter = new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: props.balanceCurrency || 'CHF',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    })

    return formatter.format(props.balanceAmount || 0)
  } catch {
    // Fallback for invalid currency codes
    return `${props.balanceCurrency} ${(props.balanceAmount || 0).toFixed(2)}`
  }
})

/**
 * Available currency options
 * Defaults to standard 6 currencies if none provided
 * @returns {string[]} Array of currency codes
 */
const availableCurrencies = computed((): string[] => {
  return props.currencyOptions || ['CHF', 'USD', 'EUR', 'GBP', 'CAD', 'MXN']
})

/**
 * User's display initials for avatar fallback
 * Extracts first letters from name or uses provided initials
 * @returns {string} User initials (max 2 characters)
 */
const displayInitials = computed((): string => {
  if (props.user?.initials) {
    return props.user.initials.toUpperCase().slice(0, 2)
  }

  if (props.user?.name) {
    const parts = props.user.name.trim().split(/\s+/)
    if (parts.length >= 2) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
    }
    return parts[0].slice(0, 2).toUpperCase()
  }

  return 'U'
})

/**
 * Background color for avatar initials
 * Uses primary color or computed based on initials hash
 * @returns {string} Tailwind/Quasar color class
 */
const getInitialsBgColor = computed((): string => {
  const colors = ['blue', 'cyan', 'teal', 'green', 'lime', 'yellow', 'orange', 'red', 'pink', 'purple']
  const hash = displayInitials.value.charCodeAt(0) % colors.length
  return colors[hash]
})

/**
 * Text color for avatar initials
 * Ensures contrast with background
 * @returns {string} Tailwind/Quasar color class
 */
const getInitialsTextColor = computed((): string => {
  return 'white'
})

/**
 * Toggles balance visibility and emits event
 * Updates internal state and notifies parent component
 */
const toggleBalanceVisibility = (): void => {
  isBalanceVisible.value = !isBalanceVisible.value
  emit('balance-toggle')
}

/**
 * Handles currency selection from dropdown
 * @param {string} currency - Selected currency code
 * @param {object} scope - Quasar menu scope object
 */
const selectCurrency = (currency: string, scope: { hide: () => void }): void => {
  emit('currency-change', currency)
  scope.hide()
}

/**
 * Handles avatar menu item click
 * Emits action and closes menu
 * @param {string} action - Action identifier (profile, settings, logout, etc.)
 * @param {object} scope - Quasar menu scope object
 */
const handleAvatarMenuClick = (action: string, scope: { hide: () => void }): void => {
  emit('avatar-click', action)
  scope.hide()
}
</script>

<style scoped>
/* Safe area padding support for notched devices */
.pt-safearea {
  @apply pt-[max(1rem,env(safe-area-inset-top))];
}

/* Responsive adjustments */
@media (max-width: 640px) {
  /* Mobile: reduce padding and font sizes slightly */
  header {
    @apply px-3;
  }

  :deep(.q-icon) {
    font-size: 20px !important;
  }
}

/* Loading state animation */
@keyframes pulse-opacity {
  0%,
  100% {
    opacity: 0.75;
  }
  50% {
    opacity: 0.5;
  }
}

header.opacity-75 {
  animation: pulse-opacity 1.5s ease-in-out infinite;
}

/* Q-menu customization for better integration */
:deep(.q-menu__paper) {
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

:deep(.q-item__label) {
  @apply text-sm;
}

/* Avatar hover effect */
:deep(.q-avatar) {
  transition: all 0.2s ease;
}

:deep(.q-avatar:hover) {
  transform: scale(1.05);
}
</style>
