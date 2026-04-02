# Reglas de Diseño Unificadas (OW Finance)

Este documento define el "punto medio" entre la estética premium y optimizada para móviles de *Happy Jar Habit*, y la robustez del sistema actual de OW Finance, apoyado por las recomendaciones de `ui-ux-pro-max` (Liquid Glass Pattern).

## 1. Tema y Estética (Liquid Glass + Happy Jar)

*   **Paleta Principal (Light Mode):**
    *   **Background:** Gris titanio ultra claro (`#F8FAFC`) para dar profundidad a las tarjetas blancas.
    *   **Tarjetas (Cards):** Blanco puro (`#FFFFFF`) con efecto de elevación (Glassmorphism sutil). Usa `shadow-xl` difuminado (`rgba(0,0,0,0.05)`).
    *   **Acción Principal (Brand):** Azul Vibrante (`#3B82F6`) transicionando al Navy premium (`#1E3A8A`) para estados *hover* o elementos Pro de escritorio.
    *   **Ingresos / Gastos:** `#10B981` (Verde Esmeralda) y `#EF4444` (Rojo).
*   **Formas y Bordes:**
    *   **Móvil / Lite:** Adopta al 100% las esquinas extremadamente redondeadas (`rounded-3xl` o `24-32px`) para modales y paneles. Botones redondos tipo pastilla (`rounded-full`).

## 2. Tipografía y Jerarquía

*   **Fuentes recomendadas:** *Satoshi* o *DM Sans*. Son geométricas, legibles en móvil y transmiten elegancia financiera.
*   **Jerarquía de texto:**
    *   Los **Montos de Dinero** deben ser masivos (`text-4xl` o superior en balances principales) y en *bold* (`font-semibold`).
    *   El texto de soporte debe tener bajo contraste (ej. `#64748B` o `text-slate-500`) para no competir visualmente.

## 3. UI Móvil Primera (Touch & Interaction)

*   **Zonas de Interacción:** Mínimo `48x48px` para iconos, botones modales y filas transaccionales.
*   **Navegación:**
    *   **Lite:** Uso estricto de una *Bottom Navigation Bar* flotante. Sidebar oculto o eliminado.
    *   **Pro:** Interfaz adaptable; Bottom Nav en móvil, pero expansible a *Sidebar* complejo en Desktop.
*   **Iconografía:** 
    *   *Prohibido el uso de Emojis nativos* en interfaces estáticas para mantener el look profesional. Reemplazar por librerías SVG fluidas (Lucide, Heroicons). (Excepción: Las "Jarras" creadas por el usuario sí pueden conservar el emoji para personalización rápida).
*   **Transiciones:** Todos los modales deben deslizar desde abajo (Bottom Sheets) en móvil, con transiciones fluidas de `300ms`.

## 4. Aplicación a Componentes (Punto Medio)

### Tablero Principal (Dashboard)
*   **Lite:** Una sola tarjeta gigante con el saldo, y debajo las Jarras apiladas. Botón central grande (Primary) estilo FAB (Floating Action Button) de `+ Añadir`. No mostrar jerarquía de cuentas, todo es un consolidado.
*   **Pro:** Tarjeta de saldo subdividida en gráficas (`ExpenseDistributionChart.vue`). Árbol visual de cuentas visible (Cash vs Bancos).

### Creación de Transacciones
*   Unificar los formularios gigantes actuales en una interfaz tipo *Wizard* de 1 solo toque (One-Tap).
*   **Input gigante centrado** como primer elemento ("¿Cuánto gastaste?").
*   Luego seleccionar la Categoría mediante grid de íconos redondeados en lugar de selectores de texto.

---
**Regla mandatoria para nuevos componentes Quasar/Vue:**
Validar siempre en vista de 375px de ancho primero. El contenedor debe evitar tener `padding` si colisiona con el *safe area* de iOS/Android.
