# OFB-001: Implementar Header/Top Bar - Versión Lite

**Ticket Notion:** https://www.notion.so/337e7ace9767812483b5d7081b4410f3

---

## 📋 Resumen Ejecutivo

Implementar el componente **LiquidHeader.vue** que será el header superior fijo para la versión LITE del layout. Este componente es crítico ya que aparecerá en todas las pantallas mobile (Dashboard, Transacciones, Jarras, Configuración).

---

## 🎯 Objetivo

Crear un header responsive (mobile-first) que muestre:
- Balance global del usuario con toggle de visibilidad
- Selector de moneda
- Avatar del usuario con dropdown menu

---

## 📁 Ubicación del Archivo

```
src/components/liquid/LiquidHeader.vue
```

---

## 🏗️ Especificaciones Técnicas

### Dimensiones
- **Height:** 64px (h-16)
- **Position:** Fixed top
- **Safe Area:** Support para notch/home indicator (pt-safearea)

### Layout (3 Secciones)
```
┌─────────────────────────────────────────────────┐
│  Menu  │      Balance Display       │  Avatar   │
│ (16px) │  (Flexible, centered)      │ (40px)    │
└─────────────────────────────────────────────────┘
```

### Sección 1: Menu (Izquierda)
- Hamburger icon (menu_outlined)
- Size: 24x24
- Color: Brand primary (#1E3A8A)
- Emit event: `@menu-click`

### Sección 2: Balance (Centro)
- **Display:** Número grande (balance global)
- **Formato:** Currency format (CHF 1,234.56)
- **Toggle:** Eye icon para ocultar/mostrar balance
- **Estados:**
  - Visible: Mostrar balance real
  - Oculto: Mostrar asteriscos (*****)
- **Emit event:** `@balance-toggle`

### Sección 3: Avatar + Moneda (Derecha)
- **Avatar:** Imagen de usuario o iniciales
- **Fallback:** Primer nombre (inicial)
- **Dropdown:** Click abre selector de moneda
- **Monedas soportadas:** CHF, USD, EUR, GBP, CAD, MXN
- **Emit events:** `@currency-change`, `@avatar-click`

---

## 💾 Props

```typescript
interface LiquidHeaderProps {
  /** Balance amount to display (number) */
  balanceAmount?: number;

  /** Currency code for balance display (e.g., 'CHF') */
  balanceCurrency?: string;

  /** Whether to show the balance or hide it with asterisks */
  showBalance?: boolean;

  /** User data object with name, avatar, initials */
  user?: {
    name?: string;
    avatar?: string;
    initials?: string;
  };

  /** List of available currency options */
  currencyOptions?: string[];

  /** Loading state (show spinner during fetch) */
  isLoading?: boolean;
}
```

---

## 🎪 Eventos (Emits)

```typescript
emits: {
  'balance-toggle': () => true,
  'currency-change': (currency: string) => true,
  'avatar-click': () => true,
  'menu-click': () => true,
}
```

---

## 🎨 Estilos

### Colores (Frozen Design System)
- **Background:** White (#FFFFFF)
- **Border:** Light gray (#E2E8F0)
- **Text Primary:** Dark navy (#1E3A8A)
- **Text Secondary:** Gray (#64748B)
- **Primary Action:** Brand navy (#1E3A8A)

### Responsive
- Mobile: Todos los elementos visibles
- Tablet+: Puede ajustar spacing

### Safe Area
- Usar Tailwind: `pt-safearea`
- Quasar: `q-safe-area-top` class

---

## 🧪 Criterios de Aceptación

- [ ] Header fixed en top, h-16 (64px)
- [ ] Layout de 3 secciones responsive
- [ ] Balance display con currency format
- [ ] Eye icon toggle para visibilidad
- [ ] Avatar con fallback a iniciales
- [ ] Currency dropdown con 6 opciones
- [ ] Todos los eventos emitidos funcionan
- [ ] Safe area para notch/home indicator
- [ ] Colores validados contra design system
- [ ] TypeScript strict sin errores
- [ ] Responsive en breakpoints: xs, sm, md
- [ ] Validado visualmente contra `html-exports/STITCH_LAYOUTS_LITE_HEADER.html`
- [ ] Sin dependencies innecesarias (Vue 3, Quasar, Tailwind)
- [ ] JSDoc comments completos

---

## 📚 Referencias

### Stitch Design
- Screen: `OW Finance Dashboard Lite - Home`
- HTML Reference: `html-exports/STITCH_LAYOUTS_LITE_HEADER.html`

### Design System
- Documento: `docs/ui-ux/08-frozen-canonical-design-system-brief.md`
- Colores: Light baseline per frozen specification

### Componentes relacionados
- Integración en: `src/layouts/LiteMobileLayout.vue`
- Usa: Quasar, Material Symbols icons, Tailwind

---

## 💡 Notas de Implementación

1. **Icons:** Usar Material Symbols icons de Quasar (`q-icon`)
   - Menu: `menu_outlined` o `menu`
   - Visibility: `visibility` / `visibility_off`
   - Avatar: Letra inicial o imagen

2. **Moneda:** Usar `Intl.NumberFormat` para format
   ```typescript
   new Intl.NumberFormat('es-CH', {
     style: 'currency',
     currency: 'CHF'
   }).format(balance)
   ```

3. **Dropdown:** Usar Quasar `q-menu` para currency selector
   - Click en avatar abre dropdown
   - 6 opciones de moneda
   - Emit `currency-change` con la moneda seleccionada

4. **Layout:** Usar Flexbox
   ```html
   <div class="flex items-center justify-between h-16 px-4">
     <!-- Menu -->
     <!-- Balance -->
     <!-- Avatar -->
   </div>
   ```

5. **Safe Area:**
   ```html
   <q-header class="pt-safearea">
   ```

---

## 🚀 Stack Técnico

- **Framework:** Vue 3 (Composition API, TypeScript)
- **UI:** Quasar Framework
- **Styles:** Tailwind CSS
- **Icons:** Material Symbols (via Quasar)
- **State:** Props + Events (parent manages state)

---

## 📖 Ejemplo de Uso

```vue
<LiquidHeader
  :balance-amount="1234.56"
  :balance-currency="'CHF'"
  :show-balance="true"
  :user="{ name: 'José', avatar: '', initials: 'JL' }"
  :currency-options="['CHF', 'USD', 'EUR', 'GBP', 'CAD', 'MXN']"
  @balance-toggle="showBalance = !showBalance"
  @currency-change="onCurrencyChange"
  @avatar-click="onAvatarClick"
  @menu-click="onMenuClick"
/>
```

---

## 🔗 Tickets Relacionados

- **OFB-002:** Bottom Navigation (implementación paralela)
- **OFB-003:** Integración en LiteMobileLayout.vue
- **OFB-004:** Validación final LITE

---

## 📝 Notas Adicionales

- Este componente es el primero del layout LITE
- Aparecerá en todas las pantallas mobile
- Su calidad visual impacta directamente la experiencia del usuario
- Validar especialmente en dispositivos con notch (iPhone X, etc.)
- Probar con balance muy largo (ej: 999,999.99) y muy corto (1)

---

**Status:** ✅ Ready to Implement
**Priority:** Alta
**Role:** Frontend
**Effort:** 4-6 horas
