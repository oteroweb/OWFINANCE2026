# Inventario Técnico: App en Vivo (OwFinance)

Este documento es el resultado de la exploración automatizada de la aplicación en vivo (`https://appfinanzasdev.blockshift.website/`), sirviendo como verdad absoluta (Single Source of Truth) para contrastar con los requerimientos teóricos.

## 1. Elementos Estructurales Globales (Main Layout)
Presentes a través de todas las vistas autenticadas.

*   **Top Navigation Bar (Header):**
    *   **Sección de Usuario (Izquierda):** Avatar circular, Nombre del usuario, Email, y un Chip o pastilla indicadora de la Moneda Activa (ej. `USD`), la cual es interactiva.
    *   **Menú de Navegación Principal (Centro/Derecha):** Botones planos con ícono y texto:
        *   `dashboard` Inicio
        *   `receipt_long` Transacciones
        *   `water_drop` Cántaros
        *   `settings` Configuración
    *   **Íconos de Utilidad (Extremo Derecho):**
        *   `visibility`: Alternar la visibilidad de datos sensibles (ofuscar/revelar montos).
        *   `logout`: Cerrar sesión.
        *   **Version Badge:** Pastilla pequeña (ej. `v1.0.22`) indicando la versión de la app.

*   **Barra Secundaria de Filtros e Información:**
    *   **Chips de Cambio de Divisa (Currency Exchange):** Elementos interactivos que muestran la tasa actual de monedas secundarias (ej. `VES: 530`, `EUR: 0.92`).
    *   **Barra Horizontal de Cántaros:** Fila desplazable horizontalmente (Scrollable) que lista las categorías principales y sus respectivos balances disponibles (ej. `Sociales: $-409.51`, `Ahorro: $310`).
    *   **Selector Multi-Pestaña de Periodos:** Grupo de botones horizontales: `Todo | Anual | Semestral | Trimestral | Mensual (activo) | Quincenal | Semanal | Diario | Personalizado`.
    *   **Navegador de Mes:** Íconos de flecha (`chevron_left`, `chevron_right`) rodeando la etiqueta del mes/año actual (ej. `Marzo 2026`).

*   **Floating Action Button (FAB):** Botón azul cuadrado con esquinas redondeadas y un ícono `add` persistente en la esquina inferior derecha.

---

## 2. Vista: 'Inicio' (Home Dashboard)
Enfocada en resúmenes y métricas globales.

*   **Header de Saludo:** Texto grande "Hola, [Nombre]" acompañado de un subtítulo descriptivo.
*   **Botones de Acción Rápida (Top Actions):**
    *   **Nueva transacción:** Botón blanco elevado con ícono `add` y texto principal.
    *   **Analizar gastos:** Botón blanco delineado (outlined) con ícono `insights`.
*   **Fila de Widgets de Balance:**
    *   **Tarjeta: Total todas las cuentas:** Muestra la suma de todas las cuentas activas con filtros/chips de moneda (USD, VES, EUR).
    *   **Tarjeta: Balance global configurado:** Muestra el balance considerando únicamente las cuentas permitidas para el consolidado global.
*   **Gráficos / Visualizaciones (Analítica):**
    *   **Gráfico de Distribución Horizontal:** Muestra la distribución por cántaros y el comportamiento en el periodo con ejes etiquetados y nombres de categorías.

---

## 3. Vista: 'Transacciones' (Data Grid)
Diseñada para la gestión densa de datos e interacciones complejas.

*   **Diseño de Dos Columnas:**
    *   **Barra Lateral Izquierda (Cuentas/Carpetas):**
        *   **Ítems de Carpeta:** Elementos interactivos con ícono `folder`, título y suma total de los contenidos.
        *   **Ítems de Cuenta (Anidados):** Elementos indentados con ícono `account_balance`, nombre de la cuenta, balance individual, botón de opciones múltiples `more_vert` y un `checkbox`.
    *   **Grid de Datos Central (Derecha):**
        *   **Header Interactivo:** Checkbox máster para "seleccionar todo".
        *   **Tabla Desplazable:** Columnas clave incluyen ID, Descripción (con soporte a múltiples líneas), y Destino/Cuenta. Las filas resaltan al pasar el cursor (hover event).
        *   **Controles del Grid:** Selector de "Registros por página" y controles de paginación rígidos (`first_page`, `chevron_left`, `chevron_right`, `last_page`).
*   **Fila de Resumen (Footer):**
    *   Tarjetas de métricas para la ventana de datos actual: **Nº Movimientos**, **Total Gastos**, **Total Ingresos**, **Impuesto Gastado**.

---

## 4. Vista: 'Cántaros' (Gestión de Jarras)
Vista de alta densidad de datos para las asignaciones presupuestarias.

*   **Tabla de Rendimiento de Cántaros:**
    *   Múltiples puntos de datos agrupados por fila:
        *   Ícono representativo (Color/Emoji) + Nombre del cántaro.
        *   **% Asignación:** Porcentaje del presupuesto total establecido.
        *   **Indicadores de Tendencia:** Íconos (Arriba/Abajo) mostrando estatus de superávit o déficit.
        *   **Columnas Financieras:** Presupuesto Inicial, Ajustes/Arrastre (Carry-over), Presupuesto Ajustado, Gastos Actuales, Total Disponible, y Total Restante.
        *   **Acciones en Línea:** Ícono de lápiz `edit` para la configuración individual de ese cántaro.
*   **Fila Resumen (Footer):** Totales matemáticos agregados para todas las métricas de los cántaros visibles.
*   **Sección de Configuración Global:** Bloque al final de la vista para definir comportamientos como fechas de inicio contable y políticas sobre límites negativos.
