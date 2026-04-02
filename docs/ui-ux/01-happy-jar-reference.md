# Análisis de Diseño y Elementos: Happy Jar Habit

Basado en la exploración de la aplicación web de referencia (https://happy-jar-habit.lovable.app/), aquí tienes las normas de diseño globales (Design System) y el desglose de elementos y funcionalidades por cada vista.

## Normas de Diseño Globales (Design System)

*   **Paleta de Colores:**
    *   **Acción Principal (Primary):** Azul vibrante (`#3B82F6`), usado en botones clave (como "Añadir"), la tarjeta de balance principal y estados activos de navegación.
    *   **Fondo de la App (Background):** Gris/blanco muy claro (`#F8F9FC`) para dar contraste a los elementos superpuestos.
    *   **Gastos (Expenses):** Rojo (`#EF4444`).
    *   **Ingresos (Income):** Verde Esmeralda (`#10B981`).
    *   **Contenedores (Cards):** Blanco puro (`#FFFFFF`) con sombras muy suaves (`shadow-card`) para dar un sutil efecto de elevación profunda sin bordes duros.
    *   **Texto:** Tipografía de alto contraste (negro/gris oscuro) para encabezados, y gris opaco/suave (`#6B7280`) para información secundaria o de soporte.
*   **Tipografía:**
    *   Fuente moderna sin serifa (sans-serif), idealmente *Inter* o *Geist*.
    *   Uso de pesos variados: Encabezados en negrita (bold) con espaciado de letras generoso. Los montos dinerarios tienen el tamaño más prominente de la vista para establecer jerarquía visual.
*   **Formas y Bordes (Border Radius):**
    *   Bordes extremadamente redondeados en todos los contenedores y modales (aprox. `24px` a `32px`, equivalente a `rounded-3xl` en Tailwind).
    *   Botones en forma de píldora (pill-shaped) y fondos completamente circulares para íconos.
*   **Convenciones UI y UX:**
    *   **Retroalimentación visual:** Amplio uso de barras de progreso dinámicas, tanto para comparar ingresos contra gastos, como para mostrar el avance individual del presupuesto en cada categoría ("Jarra").
    *   **Navegación:** Barra de navegación fija en la parte inferior (Bottom Navigation) con 5 ítems estructurados con un ícono arriba y etiqueta de texto abajo.

---

## Desglose por Vistas (Views & Layout)

### Vista 1: Inicio (Dashboard)
*   **Descripción:** Pantalla de inicio de la aplicación que proporciona un resumen financiero rápido y una vista general de las "Jarras" (categorías de presupuesto).
*   **Elementos UI:**
    *   **Encabezado:** Saludo al usuario ("Hola 👋") y un botón para notificaciones (ícono de campana).
    *   **Tarjeta Principal (Balance):** Tarjeta destacada en azul con "Balance total" en formato grande y texto blanco. Contiene indicadores compactos de "Ingresos" vs "Gastos" con micro-íconos.
    *   **Filtros de Tiempo:** Botones tipo píldora (Tabs) para cambiar entre "Este Mes", "Este Año" e "Histórico".
    *   **Grid de Categorías (Jarras):** Listado de tarjetas de presentación vertical (Necesidades, Educación, Ahorros, Diversión, Dar) acompañadas de un emoji representativo y el balance actual asignado.
    *   **Movimientos Recientes:** Sección de "Últimos Movimientos" con un enlace rápido a "Ver todos" y una pequeña lista de las 5 transacciones más recientes.
*   **Funcionalidad:** Dar un vistazo rápido de la salud financiera del usuario y proveer acceso directo a los detalles de una categoría o al historial transaccional completo.

### Vista 2: Movimientos (Historial de Transacciones)
*   **Descripción:** Un listado exhaustivo de todas las transacciones históricas registradas.
*   **Elementos UI:**
    *   **Encabezado:** Título de sección "Movimientos" con un subtítulo descriptivo "Historial de transacciones".
    *   **Tarjetas Resumen (Mini-Cards):** Dos recuadros pequeños lado a lado mostrando el total de Ingresos y Gastos en el periodo filtrado, usando colores temáticos de fondo tenues.
    *   **Buscador:** Campo de entrada (Input) muy redondeado con ícono de lupa para búsqueda por texto (ej. por nombre de transacción).
    *   **Filtros de Categoría:** Lista horizontal deslizante (Scrollable) de botones tipo píldora (ej. "Todos", "🏠 Necesidades", "🎉 Diversión").
    *   **Lista de Transacciones:** Listado de tarjetas anchas donde se observa: Nombre de la transacción, fecha, ícono o emoji de la categoría y el monto coloreado en rojo o verde según el tipo (ingreso/gasto).
*   **Funcionalidad:** Búsqueda, filtrado y revisión del historial económico en detalle.

### Vista 3: Reportes (Analítica)
*   **Descripción:** Entorno analítico para ver los hábitos de ahorro y analizar cómo se están distribuyendo los fondos.
*   **Elementos UI:**
    *   **Tarjeta de Tasa de Ahorro:** Muestra de "Tasa de ahorro" con un porcentaje destacado en color verde, acompañado de un mensaje inspirador o descriptivo (ej. "¡Excelente!").
    *   **Gráfico de Barras de Distribución:** Una barra horizontal segmentada o apilada (Stacked Bar Chart) multicolor, donde cada color representa la proporción asignada a una "Jarra" específica.
    *   **Listado de Rendimiento por Categoría:** Despliegue de cada "Jarra" comparando la *Meta (Goal %)* con el gasto *Real*, todo visualizado mediante barras de progreso y un desglose numérico de ingresos/gastos por categoría.
*   **Funcionalidad:** Análisis financiero de alto nivel sobre cuán alineado o desviado está el gasto frente a las reglas (metas) preestablecidas.

### Vista 4: Nueva Transacción (Vista Modal o Formulario)
*   **Descripción:** La vista o formulario dedicado a la entrada de nueva información financiera. Accesible desde la barra de navegación principal (+).
*   **Elementos UI:**
    *   **Selector de Tipo (Toggle):** Segmented control grande o dos pestañas claras para alternar la transacción entre "Gasto" (rojo) e "Ingreso" (verde).
    *   **Input de Monto:** Campo numérico enorme, muy prominente, posicionado en el centro-superior, con un prefijo tipográfico "$".
    *   **Campo de Descripción:** Un área de texto simple para poner el nombre/detalle de la compra o ingreso.
    *   **Grid de Selección de Categoría:** Un conjunto de tarjetas o botones cuadriculados que obligan al usuario a asociar la transacción a una "Jarra" mediante un toque. Presentan emojis de alto reconocimiento.
*   **Funcionalidad:** Es el principal flujo de control de entradas/salidas (inputs de datos financieros).

### Vista 5: Detalle de Jarra (Drill-down de Categoría)
*   **Descripción:** Un vistazo enfocado en una "Jarra" particular individual, al hacer tap sobre ella desde el Inicio o Reportes.
*   **Elementos UI:**
    *   **Encabezado Dedicado:** Flecha para volver (Back), título con el emoji de la categoría y el porcentaje de distribución objetivo en una píldora visible (ej. "55%").
    *   **Tarjeta Principal de Categoría:** Balance exacto, consolidado de dinero que entró al jarro vs cuánto se gastó en el periodo, junto a una barra de progreso que indica el porcentaje agotado respecto al límite.
    *   **Historial Localizado:** Sub-sección muy similar a "Movimientos", pero que sólo renderiza los ítems correspondientes a esta Jarra específica.
*   **Funcionalidad:** Gestión exhaustiva y micro-seguimiento del balance de un "sobre de presupuesto" concreto.

### Vista 6: Ajustes (Configuración y Perfil)
*   **Descripción:** Pantalla dedicada a la cuenta del usuario y parámetros críticos de la app.
*   **Elementos UI:**
    *   **Tarjeta de Perfil (Profile Card):** Avatar simple, nombre o correo del titular de la cuenta en diseño limpio.
    *   **Tarjeta de Reglas de Distribución:** Un componente clave que enumera cada "Jarra" junto a un control deslizante, input o texto en donde se definen los porcentajes base (ej. "Necesidades: 55%, Ahorros: 10%").
    *   **Links de Menú:** Lista de botones estilo *List Item* con ícono y flecha indicadora a la derecha (`>`) para otras ramas de configuración (seguridad, notificaciones, cerrar sesión).
*   **Funcionalidad:** Ajustar las reglas del presupuesto que gobiernan el cálculo matemático de las jarras y administrar credenciales.
