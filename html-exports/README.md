# OWFinance Components Storybook

**Generated:** 2026-04-02
**Project:** OWFinance Frontend 2025
**Stack:** Vue 3 + Quasar Framework + TypeScript + Vite

---

## Files

### 1. `COMPONENTS_STORYBOOK.html` (45 KB)
**Interactive, self-contained HTML documentation.**

- **Features:**
  - Responsive sidebar navigation with search/filter
  - Light/dark mode toggle (preference saved in localStorage)
  - 12+ documented components with full prop tables, events, and features
  - Visual mockups for key components
  - Code examples (Vue + TypeScript)
  - Related views cross-reference
  - Tailwind CSS + Prism.js for syntax highlighting

- **Components Documented:**
  - **Jars:** JarCard, JarsBalanceBar, BigJarSidebar
  - **Charts:** ExpenseDistributionChart
  - **Forms:** TransactionForm
  - **Dialogs:** TransactionCreateDialog, AccountDialog, CategoryDialog
  - **Trees:** AccountsTree, CategoriesTree
  - **Filters:** PeriodFilterBar
  - **Panels:** MonthlyIncomePanel, CrudPage
  - **UI:** VersionBadge

- **How to Use:**
  - Open in any web browser (no server required)
  - Search components using the sidebar input
  - Click component names to jump to sections
  - Toggle dark mode with the button in top-right

---

### 2. `component-structure.json` (19 KB)
**Machine-readable component inventory and architecture reference.**

- **Structure:**
  ```json
  {
    "project": "OWFinance Frontend 2025",
    "stack": "Vue 3 + Quasar Framework + TypeScript + Vite",
    "generated": "2026-04-02",
    "components": [
      {
        "name": "JarCard",
        "path": "src/components/JarCard.vue",
        "category": "Jars",
        "description": "...",
        "props": [...],
        "events": [...],
        "slots": [...],
        "relatedViews": [...],
        "keyFeatures": [...]
      },
      ...
    ],
    "summary": {
      "totalComponents": 42,
      "byCategory": {...},
      "keyArchitecturalPatterns": [...]
    }
  }
  ```

- **Use Cases:**
  - API documentation generation
  - Component dependency analysis
  - Automated testing setup
  - IDE integration for autocomplete
  - Component inventory tracking

---

## Component Categories

| Category | Count | Components |
|----------|-------|------------|
| **Jars** | 3 | JarCard, JarsBalanceBar, BigJarSidebar |
| **Charts** | 1 | ExpenseDistributionChart |
| **Forms** | 1 | TransactionForm |
| **Dialogs** | 8 | TransactionCreateDialog, AccountDialog, CategoryDialog, etc. |
| **Trees** | 2 | AccountsTree, CategoriesTree |
| **Pages** | 1 | CrudPage |
| **Filters** | 1 | PeriodFilterBar |
| **Panels** | 1 | MonthlyIncomePanel |
| **Sidebars** | 1 | AccountsSidebarWidget |
| **UI Components** | 5 | glass-fluid-card, glass-fab, spring-button, swipeable-bottom-sheet, simple-css-chart |
| **Liquid Design** | 10 | LiquidFAB, LiquidBalanceCard, LiquidTransactionItem, LiquidJarCard, LiquidCategoryChip, LiquidHeader, LiquidBottomNav, LiquidBottomNavNew, QuickActionSheet, LiteHomeView |
| **Transactions** | 1 | TransactionPalette |
| **Examples** | 1 | ExampleComponent |

**Total: 42 components**

---

## Key Architectural Patterns Identified

1. **Component Composition with Quasar**
   - Heavy use of Quasar components (Q-Dialog, Q-Table, Q-Tree, Q-Card, etc.)
   - Consistent with Quasar conventions and style

2. **TypeScript Props & Event Typing**
   - All props use TypeScript interfaces or generic types
   - Strong type safety across the board

3. **Pinia Store Integration**
   - `useAuthStore` – User, currency, authentication
   - `usePeriodStore` – Date range filtering (Day/Week/Month/Year/Custom)
   - `useJarsStore` – Jar definitions and aggregated balances

4. **Dialog-Wrapper Pattern**
   - Dialog components wrap forms (e.g., `TransactionCreateDialog` wraps `TransactionForm`)
   - Clean separation of concerns

5. **Drag & Drop Support**
   - AccountsTree and CategoriesTree use HTML5 drag events
   - Complex drop-zone calculations for nested structures
   - Insert-before/insert-after positioning indicators

6. **Responsive Design**
   - Mobile-first approach with Quasar breakpoints
   - Conditional rendering for mobile/desktop (e.g., PeriodFilterBar)
   - Flexbox and grid-based layouts

7. **ECharts Integration**
   - ExpenseDistributionChart uses Vue-ECharts with Canvas renderer
   - Currency formatting with custom tooltip formatters

8. **Glassmorphism UI Design System**
   - Multiple "glass" components (glass-fluid-card, glass-fab)
   - Layered background colors with transparency

9. **Liquid Design Variant**
   - Separate design system for Lite version
   - 10+ "Liquid" components (LiquidJarCard, LiquidBalanceCard, etc.)
   - Suggests A/B testing or version-specific UX

10. **Currency & Localization**
    - Intl API for currency formatting
    - Spanish labels throughout (es-ES)
    - Multi-currency support via user settings

---

## Component Dependencies

### Most Connected Components
1. **JarCard** – Used in Dashboard, JarsView (core jar display)
2. **PeriodFilterBar** – Used in Dashboard, Transactions, Analytics (date filtering)
3. **CrudPage** – Generic CRUD template for all management views
4. **ExpenseDistributionChart** – Dashboard analytics visualization

### Store Dependencies
- **useAuthStore** – All components need user context (currency, version)
- **usePeriodStore** – Dashboard, analytics, and time-series views
- **useJarsStore** – Jar-related components (JarCard, JarsBalanceBar, BigJarSidebar)

### External Dependencies
- **Vue 3** – Composition API, reactivity
- **Quasar Framework** – UI components (Q-*)
- **TypeScript** – Type safety
- **vue-echarts** – Charting library
- **Pinia** – State management

---

## Feature Highlights by Component

### JarCard (Most Complex)
- **17 Props** covering all jar scenarios:
  - Jar type (percent vs fixed)
  - Balance tracking (assigned, spent, adjustments)
  - Carry-over handling (accumulative mode)
  - Real vs expected income preview
  - Leverage tracking
- **5 Events** for user actions (adjust, withdraw, leverage, reset)
- **Dynamic styling** based on balance status
- **Expandable breakdown** of all transactions and adjustments

### AccountsTree & CategoriesTree (Drag & Drop)
- HTML5 drag/drop with visual feedback
- Folder nesting and reordering
- Insert-before/after positioning
- Hover state for action buttons
- Rollup calculations (folder totals)

### MonthlyIncomePanel (Inline Editing)
- Dual income view (expected vs real)
- Inline edit mode without modal
- Live fulfillment % calculation
- Keyboard shortcuts (Enter/Escape)

### CrudPage (Generic Template)
- Server-side pagination
- Dynamic filters from dictionary
- Many-to-many relationship rendering
- CSV export
- Dialog-based CRUD operations

---

## Best Practices Observed

✅ **Strong Typing** – All props/events use TypeScript interfaces
✅ **Composition API** – Modern Vue 3 with `<script setup>`
✅ **Slot Support** – Components designed for flexibility
✅ **Accessibility** – ARIA labels, keyboard support
✅ **Responsive** – Mobile-first design with breakpoints
✅ **Dark Mode** – CSS variables for theme switching
✅ **Performance** – Virtual scrolling in trees, Canvas renderer in charts
✅ **Error States** – Loading, error, and empty states handled
✅ **Validation** – Form validation and submission guards

---

## Next Steps

1. **Component Library Generation**
   - Use JSON to auto-generate Storybook or VitePress docs
   - Create interactive playground for component testing

2. **Type Generation**
   - Export TypeScript definitions from component-structure.json
   - Auto-generate mock data for testing

3. **Dependency Analysis**
   - Build component graph for impact analysis
   - Identify unused components for refactoring

4. **Testing Coverage**
   - Generate unit test templates from props/events
   - Create E2E test scenarios from examples

5. **Design System Integration**
   - Extract design tokens (colors, spacing, typography)
   - Create token documentation from component usage

---

## Quick Reference

| Component | Complexity | Type | Key Props |
|-----------|-----------|------|-----------|
| JarCard | ⭐⭐⭐ | Display | jar, balance, useRealIncome |
| JarsBalanceBar | ⭐ | Display | (auto-loads from API) |
| ExpenseDistributionChart | ⭐⭐ | Display | rows, currencyCode |
| TransactionForm | ⭐⭐ | Form | form, editMode |
| AccountsTree | ⭐⭐⭐ | Interaction | (drag & drop) |
| CategoriesTree | ⭐⭐⭐ | Interaction | isReadonly, columnsCount |
| CrudPage | ⭐⭐⭐ | Template | dictionary |
| PeriodFilterBar | ⭐⭐ | Filter | (uses usePeriodStore) |
| MonthlyIncomePanel | ⭐⭐ | Display | (inline editing) |
| BigJarSidebar | ⭐ | Display | (uses useJarsStore) |

---

## Document Versions

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-04-02 | Initial extraction of 42 components |

---

**For questions or updates, check the project documentation in `/docs/ui-ux/`**
