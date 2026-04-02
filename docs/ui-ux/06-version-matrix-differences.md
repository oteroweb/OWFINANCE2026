# Matrices de Versiones: Lite vs Pro (Mobile & Desktop)

La filosofía de OW Finance 2026 dicta que la interfaz debe escalar desde una experiencia *cero fricción* (Lite) hasta un *centro de mando financiero avanzado* (Pro), adaptándose al contexto y dispositivo del usuario.

## 1. Diferencias de Filosofía General
*   **Lite:** Enfocado en la entrada veloz de datos, entender el balance global de inmediato y ver el cumplimiento de metas de un vistazo (Happy Jar approach). Diseñado para mitigar la ansiedad financiera del día a día.
*   **Pro:** Enfocado en la conciliación bancaria exhaustiva, configuración algorítmica de cántaros (Arrastres, Déficits) y analítica de gastos multidimensional. Ideal para cierres de mes, power-users o freelancers.

## 2. Elementos y Funcionalidades por Variante

| Característica / Módulo | Mobile Lite | Mobile Pro | Desktop / Tablet Lite | Desktop / Tablet Pro |
| :--- | :--- | :--- | :--- | :--- |
| **Navegación Principal** | *Bottom Navigation Bar* sencilla (4 íconos base). | *Bottom Nav* con accesos secundarios (Analytics, Cuentas). | *Sidebar* Izquierdo (Mínimo, colapsado en íconos). | *Sidebar* Izquierdo (Expandido con texto y sub-menús). |
| **Balance Global (Hero)** | Tarjeta Hero inmensa (Ocupa 40% de pantalla). | Encabezado integrado compacto para dar espacio a datos. | Tarjeta Hero enorme centrada-izada. | Distribuido en widgets analíticos (Derecha/Top). |
| **Vista de Transacciones** | Lista minimalista: solo últimos 3-5 gastos. | Lista densa deslizable con *swipe-to-edit* / *swipe-to-delete*. | Panel lateral o lista flotante de últimos movimientos. | **Super-Grid** central (tipo hoja de cálculo) con *Inline Editing* y casillas de selección masiva. |
| **Acción Principal (Add)** | Gigantesco **FAB** (Floating Action Button) azul centrado. | Toca un Drawer inferial. **Incluye FAB Flotante constante** en la esquina inferior derecha. | Botón FAB fijado en esquina inferior derecha. | **Caja de Texto IA** en Header + **FAB Primario (+) anclado en esquina inferior derecha**. |
| **Estructura de Cuentas** | Suma consolidada transparente para el usuario. | *Dropdown* en header para saltar entre cuentas. | Tarjetas resumen por cuenta agrupadas. | Panel Izquierdo: **Árbol Jerárquico** de Carpetas y Cuentas con Drag & Drop. |
| **Gestión de Cántaros (Jars)** | Gráfico simple (Anillo/Donut) con progreso visual. | Lista desglosada con porcentajes y montos restantes. | Gráfico visual avanzado y tarjetas resumen. | Panel Derecho Completo: Edición de Topes, Reglas de Arrastre, y **Drag & Drop monetario** (Mover dinero sobrante). |
| **AI Coach & Perfil** | Botón modal para chatear con IA rápidamente. | Cintas Alertas. **Botón Chat AI anclado** justo arriba del FAB en esquina Der. | Ícono persistente en Top Bar. | Panel Analítico + **Botón Flotante Chat AI** arriba del FAB inferior derecho. |
| **Personalización (Dark Mode)**| Toggle rápido en Header. | Adopta perfil de sistema OS. | Toggle simple en Header. | Skins completas, paletas y densidad de datos configurable. |

## 3. Lógica de Componentes Reutilizables (Architecture)
A nivel de código (Vue/Quasar), **NO se desarrollarán 4 apps distintas**. 
Se utilizará composición técnica:
*   Componentes base agnósticos (`TransactionRow.vue`, `JarProgress.vue`).
*   Inyección de layouts dinámicos (`MobileLiteLayout.vue`, `DesktopProLayout.vue`).
*   Uso agresivo de CSS Grid/Flexbox y librerías de estado (Pinia) para transicionar vistas si el usuario hace "upgrade" temporal a la vista Pro desde su perfil.
