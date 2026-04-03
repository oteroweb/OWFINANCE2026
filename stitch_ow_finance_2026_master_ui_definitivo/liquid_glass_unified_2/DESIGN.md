# Design System Strategy: The Luminous Ledger

## 1. Overview & Creative North Star
The Creative North Star for this design system is **"The Digital Sanctuary."** In the high-stress world of personal finance, our UI must act as a calming, high-end editorial experience that prioritizes clarity over clutter. 

We break the "standard SaaS" look by moving away from rigid, boxy grids. Instead, we embrace **Soft Minimalism**—an approach where data feels like it is floating on layers of frosted glass. By utilizing extreme corner radii (`xl: 3rem`) and intentional asymmetry in layout, we create a signature aesthetic that feels more like a luxury lifestyle magazine than a spreadsheet. The goal is to make the user feel "wealthy" through the interface itself: expansive breathing room, authoritative typography, and a tactile sense of depth.

---

## 2. Colors & Tonal Depth
Our palette is anchored in a crisp, daytime sky. It uses light-refracting neutrals to define structure rather than harsh lines.

### The Palette
- **Primary (`#006591` / Container `#0EA5E9`):** Our "Sky Blue" is the beacon of action. Use the `primary_container` for high-visibility cards and the deeper `primary` for high-contrast text on light backgrounds.
- **Surface Hierarchy:** 
    - `surface_container_lowest` (#FFFFFF): Reserved for primary interaction cards.
    - `surface` (#F7F9FB): The base canvas.
    - `surface_container_low` (#F2F4F6): Used for secondary grouping or "inset" areas.

### The "No-Line" Rule
Standard 1px borders are prohibited for sectioning. Structural boundaries must be achieved through **Background Shifts**. To separate the navigation from the feed, or a sidebar from the main stage, transition from `surface` to `surface_container_low`. This creates a sophisticated, "molded" look rather than a "sketched" one.

### The Glass & Gradient Rule
To achieve the "Liquid Glass" effect, floating elements (like Modals or Floating Action Buttons) should use a semi-transparent `surface_container_lowest` (80% opacity) with a `backdrop-blur` of 20px. For primary CTAs, apply a subtle linear gradient from `primary_container` (#0EA5E9) to `primary` (#006591) at a 135-degree angle to provide a "jewel-like" polish.

---

## 3. Typography
We use a high-contrast typographic pairing to signal both modern tech and financial authority.

- **Display & Headlines (Manrope):** Bold, geometric, and spacious. Use `display-lg` (3.5rem) for account balances to make wealth feel substantial.
- **Body & Labels (Inter):** Highly legible and neutral. Inter handles the "work" of the UI, ensuring that even dense transaction histories remain readable.

**Editorial Intent:** Use `headline-lg` for section headers, but pair them with a `label-md` "kicker" above the headline in all-caps with 5% letter spacing. This mimics high-end financial reporting.

---

## 4. Elevation & Depth
In this system, depth is a functional tool, not just an ornament.

- **The Layering Principle:** Avoid shadows for static content. Instead, "nest" surfaces. A white card (`surface_container_lowest`) sitting on a grey-tinted base (`surface_container_low`) provides all the visual affordance needed.
- **Ambient Shadows:** When a card must "float" (e.g., a draggable transaction or a hover state), use a highly diffused shadow: `0 4px 24px rgba(15, 23, 42, 0.06)`. Note the use of our `on_surface` color for the shadow tint rather than pure black; this ensures the shadow feels like natural light falling on the `surface`.
- **The Ghost Border:** For accessibility in form fields, use the `outline_variant` token at 20% opacity. It should feel like a suggestion of a border, not a cage.

---

## 5. Components

### Buttons
- **Primary:** Pill-shaped (`full` roundedness). Use the Sky Blue gradient. Padding: `3.5` (top/bottom) and `6` (left/right).
- **Secondary:** Transparent background with a `Ghost Border` and `primary` colored text.
- **Tertiary:** No background or border. Use `primary` text with a bold weight.

### Cards & Lists
- **The "No-Divider" Mandate:** Lists must never use horizontal lines. Separate transactions using vertical white space (Scale `3` or `4`).
- **Nesting:** All cards must use `xl` (3rem) or `lg` (2rem) corner radius. Large cards should house smaller, "low-profile" cards inside them using a tonal shift (White card containing Light Grey sub-sections).

### Input Fields
- Avoid "Box" inputs. Use "Underline" style with a 2px `outline_variant` at the bottom, or a "Pill" style with `surface_container_high` background and no border. Labels should always be `label-md` in `secondary` text color (#64748B).

### Signature Component: The "Wealth Orb"
A specialized decorative element for the personal finance context. A large, blurred gradient orb (using `primary_container` at 10% opacity) that sits behind the main balance display to create a sense of glowing "liquid" light.

---

## 6. Do's and Don'ts

### Do:
- **Use "Extreme" White Space:** If you think there is enough padding, add 20% more. Premium design requires "room to breathe."
- **Use Color Semantically:** Only use `success` (#10B981) for positive cash flow. 
- **Asymmetric Balance:** Align large headlines to the left, but place secondary actions (like "View All") floating to the right without a container.

### Don't:
- **Don't use 100% Black:** Never use `#000000`. Use `on_background` (#191C1E) for text to maintain the "daytime" softness.
- **Don't use Sharp Corners:** Even "small" components like checkboxes must have at least a `sm` (0.5rem) radius.
- **Don't Over-Shadow:** If more than two elements on a screen have shadows, the "Liquid Glass" effect is lost. Use tonal layering first.