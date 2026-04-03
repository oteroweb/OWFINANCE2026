# Design System Specification: Liquid Editorial

## 1. Overview & Creative North Star
**Creative North Star: The Ethereal Vault**
This design system rejects the "boxed-in" nature of traditional fintech. Instead of rigid grids and harsh dividers, it treats the UI as a fluid, high-end editorial experience. It is "The Ethereal Vault"—an environment that feels both impenetrably secure and physically light. 

We break the "template" look through **intentional asymmetry**, where large typographic displays overlap glass surfaces, and **tonal depth**, where hierarchy is defined by light and blur rather than lines. The goal is a premium, immersive interface that feels like looking through layers of polished obsidian and frosted glass.

---

## 2. Colors & Surface Logic
The palette is rooted in deep oceanic tones, punctuated by high-vibrancy "liquid" accents. 

### Core Palette
- **Background Base:** `#0b1326` (Deep Navy)
- **Primary (Cyan):** `#89ceff` (Surface-tint) / `#0ea5e9` (Container)
- **Secondary (Green):** `#4edea3` (Success)
- **Tertiary (Gold):** `#f9bd22` (Warning/Premium)
- **Error (Red):** `#ffb4ab`

### The "No-Line" Rule
**1px solid borders are strictly prohibited.** Boundaries must be defined solely through background color shifts or tonal transitions.
- To separate sections, transition from `surface` to `surface_container_low`.
- To highlight importance, use `surface_bright` for interactive elements.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. Depth is achieved by "stacking" the surface-container tiers:
1.  **Level 0 (Base):** `surface` (`#0b1326`) - The foundation.
2.  **Level 1 (Sections):** `surface_container_low` (`#131b2e`) - For large structural groupings.
3.  **Level 2 (Cards):** `surface_container` (`#171f33`) - The primary interactive surface.
4.  **Level 3 (Pop-overs):** `surface_container_highest` (`#2d3449`) - For the highest point of focus.

### The "Glass & Gradient" Rule
Floating elements (Modals, Navigation Bars, and Hero Cards) must utilize **Glassmorphism**:
- **Fill:** `surface_variant` at 60% opacity.
- **Backdrop Blur:** 16px.
- **Signature Texture:** Primary CTAs should use a subtle linear gradient from `primary` to `primary_container` (Top-Left to Bottom-Right) to provide a "liquid" sheen that flat colors cannot replicate.

---

## 3. Typography
The typographic voice is authoritative yet approachable. We use **Manrope** for data-heavy "Impact" moments and **Inter** for high-legibility "Utility" moments.

- **Display & Headline (Manrope Bold):** Used for currency amounts, main titles, and hero statements. The bold weight conveys financial stability.
- **Body & Labels (Inter):** Used for descriptions, inputs, and micro-copy. 
- **The Editorial Scale:** Utilize `display-lg` (3.5rem) for account balances to create a clear "Hero" moment on every screen. Use `label-sm` (all caps, 0.5px letter spacing) for category headers to create an editorial feel.

---

## 4. Elevation & Depth
In this system, elevation is a function of **light and translucency**, not just shadows.

### The Layering Principle
Stacking tiers creates a soft, natural lift. Place a `surface_container_lowest` card on a `surface_container_low` section to create "recessed" depth (inner-shadow feel) without actual shadow effects.

### Ambient Shadows
For floating elements (Pills, FABs), use **Ambient Shadows**:
- **Color:** `#001e2f` (Tinted version of Primary Dark).
- **Properties:** 0px Offset Y, 40px Blur, 8% Opacity.
- This creates a soft glow rather than a muddy grey drop shadow.

### The "Ghost Border" Fallback
If contrast is legally required for accessibility, use a **Ghost Border**:
- **Stroke:** `outline_variant` at 15% opacity. 
- **Rule:** It must never be 100% opaque. It should look like a "catch-light" on the edge of glass.

---

## 5. Components

### Buttons
- **Primary:** Pill-shaped (`rounded-full`). Gradient fill (`primary` to `primary_container`). White text (`on_primary`).
- **Secondary:** Pill-shaped. `surface_container_high` fill. No border.
- **Tertiary:** Text-only with `primary` color. High horizontal padding (Spacing 6).

### Cards & Lists
- **Cards:** Border-radius of `xl` (3rem/48px) or `lg` (2rem/32px). 16px Backdrop blur.
- **The No-Divider Rule:** Forbid the use of divider lines in lists. Use `Spacing 4` (1.4rem) of vertical white space or a subtle shift to `surface_container_low` for zebra-striping if necessary.

### Input Fields
- **Surface:** `surface_container_lowest`.
- **Shape:** Pill-shaped or `rounded-md` (1.5rem).
- **State:** On focus, the background shifts to `surface_bright`. No "focus ring" lines; use a soft glow (Ambient Shadow).

### Chips (Transaction Tags)
- Small, pill-shaped.
- Use `secondary_container` for positive cash flow and `error_container` for negative, but keep the `on_container` text high-contrast for readability.

---

## 6. Do’s and Don'ts

### Do:
- **Use Extreme Rounding:** Every corner should feel "liquid" and soft.
- **Embrace White Space:** Use `Spacing 12` (4rem) between major sections to let the typography breathe.
- **Overlap Elements:** Allow a Glassmorphic card to slightly overlap a large `display-lg` headline to create depth.

### Don’t:
- **Don't use 1px borders:** They break the "Liquid" illusion and look "out-of-the-box."
- **Don't use pure black:** Use `#0b1326` (surface) to maintain the premium navy depth.
- **Don't use standard Drop Shadows:** If it looks like a "box shadow," it's too heavy. It should look like "ambient occlusion."
- **Don't crowd the data:** Finance is stressful; the UI should be the opposite. One primary action per screen.