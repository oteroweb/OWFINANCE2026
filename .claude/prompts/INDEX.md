# OWFINANCE2026 Prompt Index

**Last Updated:** 2026-04-03
**Total Tickets:** 9
**Tickets with Prompts:** 7 (78%)
**Status:** Mostly Complete

---

## 📊 Overview

This index catalogs all implementation prompts for the OWFINANCE2026 project organized by layout type and implementation phase. Each prompt is self-contained and executable in isolation.

**Key Progress:**
- LITE layout: 100% (OFB-001 to OFB-004 + OFB-029)
- PRO layout: 100% (OFB-005, OFB-006)
- Infrastructure: 100% (OFB-027, OFB-028)

---

## 🏗️ Layout-Based Organization

### LITE Layout (Mobile-First) — 5 Tickets

#### OFB-001: Implementar Header/Top Bar - Versión Lite
- **File:** `OFB-001-HEADER-LITE.md`
- **Status:** ✅ Prompt Complete
- **Priority:** Alta
- **Effort:** 4-6 horas
- **Role:** Frontend
- **Component:** `src/components/liquid/LiquidHeader.vue`
- **Description:** Mobile-first header with balance display, currency selector, and avatar menu
- **Acceptance Criteria:** 10 items
- **Key Features:** Safe area support, eye icon toggle, currency dropdown

#### OFB-002: Implementar Bottom Navigation - Versión Lite
- **File:** `OFB-002-BOTTOM-NAV-LITE.md`
- **Status:** ✅ Prompt Complete
- **Priority:** Alta
- **Effort:** 4-6 horas
- **Role:** Frontend
- **Component:** `src/components/liquid/LiquidBottomNavNew.vue`
- **Description:** Bottom navigation with 4 tabs (Home, Transactions, Jars, Settings) + FAB button
- **Acceptance Criteria:** 7 items
- **Key Features:** FAB button central, safe area, tab indicators

#### OFB-003: Actualizar LiteMobileLayout.vue - Integración
- **File:** `OFB-003-LAYOUT-INTEGRATION.md`
- **Status:** ✅ Prompt Complete
- **Priority:** Alta
- **Effort:** 3-4 horas
- **Role:** Frontend
- **Component:** `src/layouts/LiteMobileLayout.vue`
- **Description:** Integrate LiquidHeader and LiquidBottomNavNew into main layout
- **Dependencies:** OFB-001, OFB-002
- **Key Features:** State synchronization, event propagation, QuickActionSheet integration

#### OFB-004: Validar LiteMobileLayout - Testing Final
- **File:** `OFB-004-VALIDATION.md`
- **Status:** ✅ Prompt Complete
- **Priority:** Alta
- **Effort:** 2-3 horas
- **Role:** Frontend, QA
- **Description:** Comprehensive validation and testing of LITE layout
- **Dependencies:** OFB-001, OFB-002, OFB-003
- **Key Validations:** Visual regression, responsive testing, accessibility, performance

#### OFB-029: Implementar FAB Bottom Sheet con Opciones Rápidas (Lite)
- **File:** `OFB-029-FAB-SHEET-LITE.md`
- **Status:** ✅ Prompt Complete
- **Priority:** Alta
- **Effort:** 4-6 horas
- **Role:** Frontend, UI/UX
- **Component:** `src/components/liquid/QuickActionSheet.vue`
- **Description:** Glassmorphic bottom sheet with 4 quick action options
- **Dependencies:** OFB-002 (FAB trigger)
- **Key Features:** Spring animation, backdrop blur, 2x2 grid layout
- **Current Status:** In Progress

---

### PRO Layout (Desktop) — 2 Tickets

#### OFB-005: Implementar Header/Topbar - Version Pro (Desktop)
- **File:** `OFB-005-HEADER-PRO.md`
- **Status:** ✅ Prompt Complete
- **Priority:** Alta
- **Effort:** 6-8 horas
- **Role:** Frontend
- **Component:** `src/components/ProTopbar.vue`
- **Description:** Desktop topbar with logo, global search, notifications, settings, user menu
- **Acceptance Criteria:** 17 items
- **Key Features:** Sticky positioning, search debounce, notification badge, user dropdown
- **Breakpoints:** 900px, 1200px+

#### OFB-006: Implementar Sidebar Navigation - Version Pro (Desktop)
- **File:** `OFB-006-SIDEBAR-PRO.md`
- **Status:** ✅ Prompt Complete
- **Priority:** Alta
- **Effort:** 8-10 horas
- **Role:** Frontend
- **Component:** `src/components/ProSidebar.vue`
- **Description:** Left sidebar with drag & drop reordering, collapsible sections, user profile
- **Acceptance Criteria:** 18 items
- **Key Features:** Drag & drop persistence, active route indicator, localStorage support
- **Dependencies:** Vue Router, localStorage API

---

### Infrastructure & Setup — 2 Tickets

#### OFB-027: Crear selector de layout Legacy / Pro / Lite con persistencia por usuario
- **File:** N/A (Strategy/Setup ticket)
- **Status:** ✅ Done
- **Priority:** Alta
- **Role:** Product Owner, Frontend, Backend
- **Description:** Layout selector with per-user persistence
- **Key Achievement:** Phase 1 foundation complete
- **Note:** Completed in Phase 1. Followup: OFB-28 (refactoring)

#### OFB-028: Refactorizar Legacy / Pro / Lite en layouts separados
- **File:** N/A (Infrastructure ticket)
- **Status:** ✅ Done
- **Priority:** Alta
- **Role:** Frontend, Architecture
- **Description:** Separate layout files and structures for Legacy, Pro, and Lite
- **Dependencies:** OFB-027
- **Key Achievement:** Clean architecture foundation for parallel development
- **Note:** Base infrastructure for all layout-specific development

---

## 🔗 Dependency Graph

```
OFB-027 (Layout Selector)
    ↓
OFB-028 (Layout Separation)
    ├── OFB-001 (Header Lite) ─┐
    ├── OFB-002 (Bottom Nav)   ├─→ OFB-003 (Integration) ─→ OFB-004 (Validation)
    └── OFB-029 (FAB Sheet) ───┘

OFB-005 (Header Pro)  ┐
OFB-006 (Sidebar Pro) ├─→ OFB-007 (Pro Layout Integration - TODO)
```

---

## 📋 Recommended Execution Order

### Phase 1: LITE Layout (Mobile-First)
1. **OFB-001** → Header component (4-6h)
2. **OFB-002** → Bottom navigation (4-6h)
3. **OFB-029** → FAB bottom sheet (4-6h)
4. **OFB-003** → Layout integration (3-4h)
5. **OFB-004** → Validation & testing (2-3h)

**Total Phase 1:** 17-25 hours
**Parallel Work:** OFB-001 and OFB-002 can run in parallel

### Phase 2: PRO Layout (Desktop)
1. **OFB-005** → Topbar component (6-8h)
2. **OFB-006** → Sidebar component (8-10h)
3. **OFB-007** → Pro layout integration (TODO)

**Total Phase 2:** 14-18 hours
**Parallel Work:** OFB-005 and OFB-006 can run in parallel

### Phase 3: Integration & Cross-Layout
1. OFB-007: Pro layout integration
2. Cross-layout testing (navigation, switching)
3. Final validation

---

## 📁 File Structure

```
.claude/prompts/
├── INDEX.md (this file)
├── OFB-001-HEADER-LITE.md ✅
├── OFB-002-BOTTOM-NAV-LITE.md ✅
├── OFB-003-LAYOUT-INTEGRATION.md ✅
├── OFB-004-VALIDATION.md ✅
├── OFB-005-HEADER-PRO.md ✅
├── OFB-006-SIDEBAR-PRO.md ✅
└── OFB-029-FAB-SHEET-LITE.md ✅
```

---

## 🎯 Key Metrics

| Category | Count | Status |
|----------|-------|--------|
| Total Tickets Found | 9 | ✅ |
| Prompts Generated | 7 | ✅ |
| Coverage | 78% | Good |
| LITE Layout | 5/5 | Complete |
| PRO Layout | 2/2 | Complete |
| Infrastructure | 2/2 | Complete |

---

## 🔍 Ticket Inventory

### Completed/Active in Notion Database

| Ticket | Title | Status | Type | Role | Priority |
|--------|-------|--------|------|------|----------|
| OFB-001 | Header Lite | To Do | Component | Frontend | Alta |
| OFB-002 | Bottom Nav Lite | To Do | Component | Frontend | Alta |
| OFB-003 | Layout Integration | To Do | Integration | Frontend | Alta |
| OFB-004 | Validation LITE | To Do | Testing | Frontend | Alta |
| OFB-005 | Header Pro | Prompt Ready | Component | Frontend | Alta |
| OFB-006 | Sidebar Pro | Prompt Ready | Component | Frontend | Alta |
| OFB-027 | Layout Selector | Done | Infrastructure | Multi-role | Alta |
| OFB-028 | Layout Refactoring | Done | Infrastructure | Frontend | Alta |
| OFB-029 | FAB Sheet LITE | In Progress | Component | Frontend/UI | Alta |

---

## 💾 Technology Stack (All Prompts)

### Core Framework
- Vue 3 (Composition API)
- TypeScript (strict mode)

### UI Framework
- Quasar Framework
  - QHeader, QBottomNavigation
  - QMenu, QBtn, QIcon
  - QInput, QAvatar
  - QList, QItem

### Styling
- Tailwind CSS
- CSS Transitions & Animations

### Icons
- Material Symbols (via Quasar)

### Routing
- Vue Router 4

### State Management
- Props + Events pattern
- localStorage (for Pro sidebar drag & drop, layout selection)

### Additional Libraries
- Sortable.js (for drag & drop in Pro sidebar)
- Intl.NumberFormat (for currency formatting)

---

## 🚀 Usage Instructions

### For Developers

1. **Select a Ticket:** Pick from the "Recommended Execution Order" above
2. **Open the Prompt:** Read the corresponding `.md` file in this directory
3. **Review Acceptance Criteria:** All checkboxes must pass before PR
4. **Implement:** Follow the technical specifications and implementation notes
5. **Validate:** Test against referenced Stitch HTML files (in `html-exports/`)
6. **Submit:** Create PR with link to prompt file in description

### For Project Managers

1. Use the **Dependency Graph** to understand blocking relationships
2. Use **Recommended Execution Order** for sprint planning
3. Track progress by checking status in this index
4. Refer to **Effort Estimates** for capacity planning

---

## 📖 Stitch Design References

All components reference Stitch design system. HTML exports available:

- `html-exports/STITCH_LAYOUTS_LITE_HEADER.html` → OFB-001
- `html-exports/STITCH_LAYOUTS_LITE_FOOTER.html` → OFB-002, OFB-029
- `html-exports/STITCH_LAYOUTS_PRO_HEADER.html` → OFB-005
- `html-exports/STITCH_LAYOUTS_PRO_SIDEBAR.html` → OFB-006

---

## 🔄 Status Legend

- ✅ **Prompt Complete:** Ready to implement
- 🔄 **In Progress:** Currently being implemented (OFB-29)
- ⏳ **Pending:** Awaiting dependencies
- ❌ **Done:** Implemented and validated
- 📋 **TODO:** Not yet added to prompts

---

## 📞 Questions & Support

For questions about:
- **Specific Prompts:** See the prompt file's "Notas de Implementación" section
- **Design References:** See "Referencias" section in each prompt
- **Dependencies:** See "Tickets Relacionados" section
- **Stack/Technologies:** See "Stack Técnico" section

---

## 🎨 Design System Reference

All prompts follow the **Frozen Canonical Design System** (8-frozen-canonical-design-system-brief.md):

**Color Palette:**
- Primary: #1E3A8A (dark navy)
- Success: #10B981 (green)
- Error: #EF4444 (red)
- Warning: #F59E0B (amber)
- Secondary: #64748B (gray)
- Background: #FFFFFF (white)

**Typography:**
- Headers: Bold, 18-24px
- Body: Regular, 14px
- Labels: Medium, 12-14px
- Secondary: 12px, gray

**Spacing:** 4px base unit (multiples of 4)
**Border Radius:** 8px (sm), 12px (md), 32px (lg)
**Shadows:** Material Design 3 elevation system

---

## 📝 Document History

| Date | Change | Author |
|------|--------|--------|
| 2026-04-03 | Initial index creation | Claude Code |
| 2026-04-03 | Added 3 new prompts (OFB-005, OFB-006, OFB-029) | Claude Code |

---

**Next Steps:**
1. Implement OFB-029 (FAB Sheet) - currently in progress
2. Create OFB-007 prompt for Pro Layout Integration
3. Track implementation progress against acceptance criteria
4. Update status as tickets complete

---

Generated: 2026-04-03 | Project: OWFINANCE2026 | Prompts Version: 1.0
