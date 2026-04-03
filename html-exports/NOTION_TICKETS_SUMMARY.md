# Implementation Tickets - Stitch Layout Components

**Generated:** April 3, 2026
**Mission:** Extract HTML layouts from Stitch and create Notion tickets for component implementation

---

## Summary

Successfully extracted 4 HTML layout files from OWFinance Stitch design system and created 4 corresponding implementation tickets in Notion.

### HTML Layouts Extracted

#### Lite Version (Mobile)

1. **STITCH_LAYOUTS_LITE_HEADER.html** (5.2 KB)
   - Location: `html-exports/STITCH_LAYOUTS_LITE_HEADER.html`
   - Purpose: Top navigation header for Lite version
   - Features:
     - Global balance display with currency badge
     - Balance visibility toggle (eye icon)
     - Currency selector dropdown (USD, EUR, GBP, MXN)
     - User avatar menu
     - Responsive layout (mobile-first)
   - Component: `LiteHeader.vue`
   - Applicable Screens: Dashboard Lite, Transactions Lite, Jars Lite, Settings Lite

2. **STITCH_LAYOUTS_LITE_FOOTER.html** (7.8 KB)
   - Location: `html-exports/STITCH_LAYOUTS_LITE_FOOTER.html`
   - Purpose: Bottom navigation bar for Lite version
   - Features:
     - 4-tab navigation: Home, Transactions, Jars, Settings
     - Floating Action Button (FAB) for quick transaction add
     - Active tab indicator (underline)
     - Safe area padding for notch/home indicator
     - Mobile device optimized
   - Component: `LiteBottomNav.vue`
   - Applicable Screens: All Lite version screens

#### Pro Version (Desktop)

3. **STITCH_LAYOUTS_PRO_HEADER.html** (7.1 KB)
   - Location: `html-exports/STITCH_LAYOUTS_PRO_HEADER.html`
   - Purpose: Top navigation topbar for Pro desktop version
   - Features:
     - Logo with branding icon
     - Global search input (debounced)
     - Notification bell with badge counter
     - Settings/utility button
     - User avatar with dropdown menu
     - Optional breadcrumb navigation
     - Sticky positioning
     - Responsive breakpoints (desktop optimized)
   - Component: `ProTopbar.vue`
   - Applicable Screens: Dashboard Pro, Transactions Pro, Jars Pro, Analytics Pro, Settings Pro

4. **STITCH_LAYOUTS_PRO_SIDEBAR.html** (9.3 KB)
   - Location: `html-exports/STITCH_LAYOUTS_PRO_SIDEBAR.html`
   - Purpose: Left sidebar navigation for Pro desktop version
   - Features:
     - Primary navigation: Home, Transactions, Jars, Analytics
     - Secondary management section: Accounts, Categories
     - Drag & drop reorderable items (with handle ⋮)
     - Active item indicator (left border highlight)
     - User profile card (avatar, name, email)
     - Settings link in footer
     - Collapsible section support
     - Drag order persistence (localStorage)
   - Component: `ProSidebar.vue`
   - Applicable Screens: All Pro version screens

---

## Notion Tickets Created

All 4 tickets created as workspace-level pages with comprehensive details:

### Ticket 1: Implementar Header/Top Bar - Version Lite
- **Notion URL:** https://www.notion.so/337e7ace97678127bcf0f04a89f9607f
- **Status:** Ready to implement
- **Priority:** High
- **Type:** Component
- **Design Reference:** `html-exports/STITCH_LAYOUTS_LITE_HEADER.html`

**Key Components:**
- Balance display with visibility toggle
- Currency selector
- Avatar menu
- Responsive layout

**Acceptance Criteria:** 8 checkpoints
- Header responsive (mobile first)
- Balance visibility toggle
- Currency selector with all options
- Avatar dropdown functionality
- Sticky positioning
- Safe area padding
- Stitch design match
- Works on all Lite screens

---

### Ticket 2: Implementar Bottom Navigation - Version Lite
- **Notion URL:** https://www.notion.so/337e7ace97678141b660c629c6f5706d
- **Status:** Ready to implement
- **Priority:** High
- **Type:** Component
- **Design Reference:** `html-exports/STITCH_LAYOUTS_LITE_FOOTER.html`

**Key Components:**
- BottomNav container
- NavItem (icon + label)
- Floating Action Button
- Active state indicator

**Acceptance Criteria:** 8 checkpoints
- 4 navigable tabs
- FAB for transaction creation
- Active tab indicator
- Safe area padding
- Smooth transitions
- Clear icons
- Stitch design match
- Mobile device compatibility

---

### Ticket 3: Implementar Header/Topbar - Version Pro (Desktop)
- **Notion URL:** https://www.notion.so/337e7ace976781dab147c0e91d39e6c8
- **Status:** Ready to implement
- **Priority:** High
- **Type:** Component
- **Design Reference:** `html-exports/STITCH_LAYOUTS_PRO_HEADER.html`

**Key Components:**
- Logo with branding
- Global search input
- Notification bell
- Settings button
- User avatar dropdown
- Breadcrumb navigation (optional)

**Acceptance Criteria:** 10 checkpoints
- Logo and branding
- Global search functionality
- Notification badge with count
- Notification dropdown
- Settings menu
- User profile dropdown
- Desktop responsive
- Sticky positioning
- Stitch design match
- Works across Pro screens

---

### Ticket 4: Implementar Sidebar Navigation - Version Pro (Desktop)
- **Notion URL:** https://www.notion.so/337e7ace9767814f916eec4d809955bf
- **Status:** Ready to implement
- **Priority:** High
- **Type:** Component
- **Design Reference:** `html-exports/STITCH_LAYOUTS_PRO_SIDEBAR.html`

**Key Components:**
- Sidebar container
- Navigation items with icons
- Drag & drop handles
- Collapsible sections
- User profile card
- Settings link

**Acceptance Criteria:** 10 checkpoints
- Primary navigation (4 items)
- Management section (2 items)
- Drag & drop reordering with persistence
- Active item indicator
- Hover state drag handles
- User profile card
- Settings link
- Responsive sizing
- Collapsible persistence
- Stitch design match

---

## Project Context

**Stitch Project ID:** 5968657237763273187
**OWFinance Version:** 2026
**Application Structure:**
- **Lite Version:** Mobile-first design with bottom navigation
- **Pro Version:** Desktop-optimized with sidebar and topbar

---

## Technical Dependencies

### Lite Components
- Quasar Framework (QBtn, QSelect, QTabs, QRouteTab)
- Vue 3 Composition API
- Tailwind CSS
- Vue Router
- Icon library (SVG or emoji)
- CSS animations

### Pro Components
- Quasar Framework (QInput, QBtn, QMenu, QList, QItem)
- Vue 3 Composition API
- Tailwind CSS
- Vue Router
- Drag & Drop library (@vue-dnd/core or Sortable.js)
- localStorage API
- Icon library

---

## Next Steps

1. **Component Implementation:** Developers should start with tickets in priority order (all marked High)
2. **Stitch Validation:** Cross-reference implementation against provided HTML layouts
3. **Integration:** Wire up navigation to routing and state management
4. **Testing:** Test responsive behavior and drag & drop functionality
5. **Review:** Validate against Stitch design specifications

---

## Files Generated

```
html-exports/
├── STITCH_LAYOUTS_LITE_HEADER.html      (5.2 KB)
├── STITCH_LAYOUTS_LITE_FOOTER.html      (7.8 KB)
├── STITCH_LAYOUTS_PRO_HEADER.html       (7.1 KB)
├── STITCH_LAYOUTS_PRO_SIDEBAR.html      (9.3 KB)
└── NOTION_TICKETS_SUMMARY.md            (this file)
```

**Total HTML Size:** ~30 KB (comprehensive, self-contained reference layouts)

---

## Validation Checklist

- [x] HTML layouts extracted and documented
- [x] 4 Notion tickets created with detailed specifications
- [x] Acceptance criteria defined for each ticket
- [x] Component locations identified
- [x] Design references linked
- [x] Dependencies documented
- [x] Related screens specified
- [x] Ready for development team handoff

---

**Status:** Complete - Ready for Implementation
