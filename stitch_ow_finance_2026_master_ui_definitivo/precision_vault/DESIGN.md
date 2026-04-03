# Design System Specification: The Precision Vault

## 1. Overview & Creative North Star
**Creative North Star: The Precision Vault**
This design system is engineered for the elite wealth management tier—where high-density data meets high-end luxury. We are moving away from the "SaaS-standard" look of boxes and lines. Instead, we treat the interface as a physical high-security vault: a series of nested, illuminated chambers.

The aesthetic is **Editorial Finance**. We achieve this through:
*   **Intentional Asymmetry:** Breaking the grid for hero data points to create a "custom-tailored" feel.
*   **Atmospheric Depth:** Using light and blur rather than strokes to define space.
*   **Weightless Authority:** Combining the heavy security of dark tones with the lightness of glassmorphism.

---

## 2. Colors & Surface Architecture
The palette is rooted in deep obsidian and oceanic blues, designed to reduce eye strain while projecting institutional stability.

### The "No-Line" Rule
**Explicit Instruction:** Prohibit the use of 1px solid borders for sectioning. Boundaries must be defined solely through background color shifts or tonal transitions.
*   **Surface Hierarchy:**
    *   `surface` (#0b1326): The "floor" of the vault.
    *   `surface-container-low` (#131b2e): The sidebar and navigation foundation.
    *   `surface-container` (#171f33): Standard card backgrounds.
    *   `surface-container-highest` (#2d3449): Active states or "popped" modal elements.

### The Glass & Gradient Rule
To move beyond "flat" UI, use Glassmorphism for floating widgets. 
*   **Formula:** Apply `surface-container` at 60% opacity with a `backdrop-blur` of 20px–40px.
*   **Signature Textures:** For primary CTAs and high-level trend lines, use a subtle linear gradient from `primary` (#89ceff) to `primary-container` (#0ea5e9).

---

## 3. Typography: The Editorial Voice
We use **Manrope** for its technical precision and modern geometric forms. It bridges the gap between a monospaced "data" font and a luxury brand typeface.

*   **Display (Large/Medium):** Reserved for portfolio totals and net worth. These should feel like headlines in a premium financial journal.
*   **Headline & Title:** Used for section headers. Use `on-surface` (#dae2fd) for maximum clarity.
*   **Body (Large/Medium):** All functional data and descriptions.
*   **Label (Medium/Small):** For micro-data, timestamps, and secondary metadata. Use `on-surface-variant` (#bec8d2) to create a clear visual hierarchy.

**Hierarchy Note:** Always pair a `display-lg` metric with a `label-md` descriptor in all-caps with 0.05rem letter-spacing to achieve that "Bloomberg-terminal-meets-Vogue" aesthetic.

---

## 4. Elevation & Depth: Tonal Layering
In this system, depth is not "shadows on white"—it is "light within the dark."

*   **The Layering Principle:** Stacking is the primary way to show hierarchy. Place a `surface-container-lowest` card inside a `surface-container-low` area to create a "recessed" look, or a `surface-container-high` card on a `surface` background to create "lift."
*   **Ambient Shadows:** For floating modals, use a diffuse shadow: `offset: 0 20px, blur: 40px, color: rgba(6, 14, 32, 0.5)`. The shadow must feel like a natural occlusion of light, not a black smudge.
*   **The Ghost Border Fallback:** If a divider is functionally required for accessibility, use the `outline-variant` (#3e4850) at **15% opacity**. It should be felt, not seen.

---

## 5. Components

### Buttons
*   **Primary:** Solid `primary-container` (#0ea5e9). No border. `rounded-3xl`. Text: `on-primary` (#00344d).
*   **Secondary:** Glass-style. `surface-container-highest` at 40% opacity. 
*   **Tertiary:** Ghost style. No background. `primary` text.

### Cards (The "Vault" Module)
*   **Visuals:** Use `rounded-3xl` (2rem). No borders. 
*   **Spacing:** Use `spacing-8` (1.75rem) for internal padding to ensure the data has "room to breathe," reflecting the luxury of space.
*   **Interaction:** On hover, shift the background from `surface-container` to `surface-container-high`.

### Input Fields
*   **Style:** Recessed. Use `surface-container-lowest` (#060e20) with a `rounded-md` (1.5rem) shape.
*   **Focus State:** A 2px "Ghost Border" of `primary` at 40% opacity. Do not use high-contrast rings.

### Data Tables & Lists
*   **No Dividers:** Prohibit the use of horizontal lines.
*   **Alternating Tones:** Separate rows by alternating between `surface` and `surface-container-low`.
*   **Micro-Interactions:** A subtle `primary` vertical sliver (2px width) on the far left of a row to indicate the "Active" or "Selected" state.

---

## 6. Do’s and Don’ts

### Do:
*   **Do** use asymmetrical layouts for dashboards (e.g., a large 70% width chart paired with a 30% width vertical list of assets).
*   **Do** lean into `rounded-3xl` for all large surfaces to soften the "industrial" feel of finance.
*   **Do** use `tertiary` (#4edea3) for all positive financial trends. It is more sophisticated than a standard neon green.

### Don’t:
*   **Don’t** use pure black (#000000). It kills the depth and makes glassmorphism impossible.
*   **Don’t** use standard "Drop Shadows" on cards. Rely on color-stepping (Tonal Layering).
*   **Don’t** crowd the interface. If a screen feels busy, increase the spacing from `spacing-4` to `spacing-8`. In wealth management, white space (or dark space) equals "calm."

---

## 7. Spacing & Grid
The system relies on a generous 8px-based scale, but translated into the following semantic tokens:
*   **Internal Card Padding:** `10` (2.25rem).
*   **Component Gap:** `4` (0.9rem).
*   **Section Margin:** `16` (3.5rem).

By adhering to these generous spacing values, we ensure that even data-dense screens feel curated and manageable rather than overwhelming.