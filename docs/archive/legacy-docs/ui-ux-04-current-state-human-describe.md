# Estado Actual: Descripción y Elementos (Requerimientos Core Expandidos)

Este documento estructura exhaustivamente las funcionalidades, componentes clave y **dinámicas de interacción avanzadas** que posee o requerirá el sistema actual. Sirve como base analítica profunda para los agentes de IA que desarrollen la nueva interfaz (Lite/Pro).

El sistema funciona fundamentalmente como un **coach o asesor financiero personal inteligente**.
*Directriz de Configuración Dinámica:* Al registrar el perfil financiero del usuario (onboarding), el sistema adapta algorítmicamente las Categorías, Jarras (Cántaros) disponibles y los niveles de complejidad de la interfaz según el expertise financiero detectado en dicho perfil.

## 1. Lógica Financiera Subyacente (Engine Rules)

Antes de definir las vistas, es vital entender el motor de reglas de negocio que gobierna la aplicación:

*   **Tipología Estructural de Cuentas:** Las cuentas no son un simple listado plano. Tienen **Tipos de Cuenta** (Efectivo, Tarjetas de Crédito, Bancos, Activos de Inversión, Pasivos/Préstamos). 
    *   *Carpetas y Visibilidad:* Se agrupan jerárquicamente en **Carpetas** (`account-folders`). El sistema usa esta estructura para calcular qué dinero es "Líquido" (disponible hoy para gastar) frente a qué dinero es "Patrimonio" (como un carro o una inversión a plazo fijo) o "Deuda", permitiendo al usuario decidir exactamente qué impacta su Balance Principal consolidado.
*   **Lógica Avanzada de Cántaros (Jars & Budgeting):** El motor de cántaros sigue la filosofía de "cada dólar tiene un trabajo":
    *   **Tope Porcentual (`<= 100%`):** La asignación de todas las jarras sumadas nunca puede superar el 100% de la "Meta de Ingreso" o "Ingreso Esperado" definido por el usuario para ese mes.
    *   **Exclusividad Categórica:** Las relaciones son estrictas. Una transacción pertenece a una sola 'Categoría' (ej. Supermercado), y esa Categoría está atada de forma exclusiva a un solo 'Cántaro' (ej. Necesidades Básicas). Gastar en una categoría automáticamente erosiona el presupuesto de su cántaro padre.
    *   **Arrastre y Cierres (Sync/Batching):** El backend ejecuta ciclos de cierre de mes. Si un cántaro gastó menos de su asignación (Superávit), ese remanente ("Carry-over") se transfiere como bono extra al presupuesto del siguiente mes. Si gastó de más (Déficit / "Excedido"), el sistema obliga al usuario a reajustar tomando fondos de otra jarra o del *Dinero Ocioso* para nivelar.

## 2. Layout Global (Constantes Interactivas en todas las vistas)

*   **Selector Multimoneda Dinámico (Header):** 
    *   Barra o menú superior que muestra las divisas habilitadas de la cuenta en formato de "píldoras" (chips). 
    *   *Micro-interacción:* Al hacer clic en un chip, se despliega un modal o pop-over inmediato que permite editar la tasa de cambio vigente al vuelo, aplicando la conversión matemática a todo el sistema visual en tiempo real sin recargar la página.
*   **Menú de Navegación (Sidebar fluido / Bottom Nav):** 
    *   Accesos principales para transicionar entre pantallas (Inicio, Transacciones, Jarras, Reportes). En la versión Pro (escritorio), el sidebar permite **Drag & Drop** para reordenar las secciones según la prioridad del usuario.
*   **Barra de Jarras (Resumen Global Flotante):** 
    *   Componente siempre accesible visualmente que indica los montos disponibles en cada jarra estratégica.
*   **Control de Periodo Histórico Global (Period Bar):** 
    *   Barra matriz para filtrar absolutamente toda la información mostrada en pantalla según un intervalo temporal: `[Todo | Anual | Semestral | Trimestral | Mensual | Quincenal | Semanal | Diario | Personalizado]`.
    *   *Navegación Táctil/Click:* Incluye controles direccionales (`<-` anterior, `->` siguiente) para saltar ágilmente. Soporta *swipe* horizontal en móvil.
*   **Asistente Inteligente (AI Chat Floating Button):** 
    *   Botón flotante persistente para acceder a un chatbot que actúa como analista financiero. 
    *   *Capacidades:* Solicitar estatus de jarras, detectar anomalías de gasto, o agregar transacciones dictándolas.
*   **Botón de Acción Rápida (Smart Add / Super Button):** 
    *   Posicionado estratégicamente. Al presionarlo, despliega un menú inferior con transiciones fluidas:
    *   **Acciones Básicas:** Añadir Gasto, Ingreso o Transferencia.
    *   **Gestión de Deudas:** "Nueva Deuda" (Abre un wizard para configurar a quién se debe, cuotas y vincula a un tipo de cuenta pasiva).
    *   **Inputs Inteligentes basados en IA:** Gravar Nota de Voz, Escáner Óptico (OCR) para facturas, o Texto Plano para auto-completado del formulario transaccional.

## 3. Vista: Inicio (Home Dashboard - Altamente Personalizable)

*   **Balance Total Global Inteligente:** 
    *   Por defecto oculto (`*****`). Funciona mediante un *toggle* de visibilidad. Reacciona al momento según el tipo de cuentas marcadas como líquidas o consolidadas.
*   **Balance Desglosado por Cuentas:** 
    *   *Interacción Drag & Drop:* El usuario puede arrastrar una cuenta y soltarla temporalmente fuera de la zona de "Cálculo global" para visualizar simulaciones de balance sin afectar el backend definitivamente.
*   **Reordenamiento de Widgets (Drag & Drop):** 
    *   El usuario puede hacer un toque prolongado (Long Press) en el Dashboard para activar edición y **arrastrar libremente los widgets** y decidir qué gráficas o resúmenes ve primero.
*   **Gráfica de Jarras (Distribución):** 
    *   Gráfico de anillo (Donut Chart) ilustrando porcentajes de asignación (`<= 100%`). Al hacer *hover* o *tap*, resalta detalles exactos del presupuesto vs gasto.
*   **Widget: Asignado vs Gastado:** 
    *   Barras de progreso por meta fijada contra gasto en tiempo real.
*   **Widget: Dinero Ocioso (Idle Money Analyzer):** 
    *   Módulo que audita las cuentas "Líquidas" e identifica dinero disponible pero NO asignado a la matemática de ningún Cántaro, sugiriendo invertirlo o asignarlo a metas.
*   **Navegador/Evaluador de Gasto (Experimental):** 
    *   Herramienta gamificada para puntuar la utilidad o emocionalidad de compras fuertes antes de realizarlas o tras loguearlas.

## 4. Vista: Transacciones (Transaction Data Grid & Manager)

Vista optimizada para resolución ancha en versión Pro, actuando como un centro de mando tipo hoja de cálculo.

*   **Panel Columna Izquierda (Cuentas) - ~20% Width:**
    *   Árbol jerárquico de Cuentas organizadas en Carpetas estructurales.
    *   *Drag & Drop:* Permite arrastrar cuentas entre carpetas para reestructurar la visibilidad y suma de balances.
    *   *Gestión In-line:* Acciones al hacer hover: Ajustar saldo manual y checkboxes para aislamiento de datos.
*   **Área Principal (Data & Actions) - ~80% Width:**
    *   **Nube de Categorías Dinámicas:** Etiquetas que destacan categorías problemáticas o de alto gasto, aplicables como filtros instantáneos.
    *   **Controles del Grid:**
        *   Usuario puede configurar usando checkboxes qué columnas ver. Permite **Drag & Drop de cabeceras** de columnas para reorganizarlas.
    *   **Tabla Transaccional (Super Grid):**
        *   Fila Top: Balance Inicial dinámico.
        *   *Interacciones Avanzadas:* 
            *   Edición de celda (Inline-editing) rápida (ej. corregir un monto) con doble clic.
            *   **Drag & Drop de filas**: Arrastrar una transacción errónea visualmente hacia el sidebar de cuentas de la izquierda para reasignarle el origen instantáneamente.
            *   Edición/Borrado masivo vía casillas de selección.
        *   Fila Bottom: Balance Actualizado y un *Footer Matemático* persistente con recuento total de impuestos y comisiones extraídas en la vista en curso.

## 5. Vista: Cántaros / Jarras (Budget & Goal System)

*   **Panel de Métricas Maestras (Top Bar):** 
    *   Indica si el "Ingreso Esperado" (Plan Mensual) cuadra perfectamente con la distribución del 100% asignado a los distintos cántaros.
*   **Tabla Listado de Jarras:**
    *   *Interacción Drag & Drop de Jarras:* Arrastrar jarras de arriba hacia abajo altera el orden jerárquico. Si se implementa fondeo automático ("Waterfall"), el sistema llena primero las priorizadas arriba.
    *   **Gestión por Cántaro In-line:** Corrección al instante de la asignación porcentual garantizando no exceder el 100% global.
    *   **Arrastre y Nivelación de Fondos (Drag & Drop Monetario):** En la versión Pro, si un cántaro figura "Excedido" (rojo intermitente), el usuario puede graficamente agarrar un ícono de moneda o "chip" desde una jarra que figura en "Superávit" y soltarlo en la deficitaria. Esto genera automáticamente una transacción de ajuste para sanearla, respetando las reglas contables del backend.

## 6. Vista: Configuración (User Settings & Profile)

Centro de control integral del usuario, subdividido en pestañas para gestionar preferencias, finanzas y estructuras base.

*   **Pestaña: Perfil (Profesional & Seguridad):**
    *   Gestión de datos básicos (Avatar, Nombre, Email) y cambio de credenciales de acceso.
    *   *Integración Futura Inteligente:* Espacio designado para capturar el **Perfil Profesional y Metas del Usuario**. Esta data alimentará directamente al **Coach Financiero (IA)**, dotándolo de contexto para emitir diagnósticos y sugerencias ultra-personalizadas (ej. estrategias de ahorro para un freelancer vs empleado corporativo).
*   **Pestaña: Finanzas (Motor Monetario):**
    *   **Moneda Principal y Tasas Base:** Definición de la moneda de visualización global (pivote) y configuración manual/automática de tasas de conversión contra el dólar.
    *   **Ingreso Mensual Esperado:** Parámetro troncal que habilita la vista de simulaciones híbridas (Sugerido Esperado vs Sugerido Real) en la vista de Jarras, comparando el ideal planificado contra las transacciones de ingreso reales ejecutadas en el mes.
*   **Pestaña: Gestión de Categorías (Drag & Drop Avanzado):**
    *   **Árbol Jerárquico Interactivo:** Las categorías no son planas. Pueden agruparse dentro de "Carpetas de Categoría" creadas por el usuario.
    *   *Interacción Drag & Drop:* Permite arrastrar libremente una categoría y soltarla dentro de otra carpeta organizadora. También permite mover carpetas enteras a la raíz del árbol.
    *   *Filtrado y Mapeo:* Buscador integrado en tiempo real y componentes visuales (`badges`) que explican gráficamente a qué 'Cántaro' está vinculada la categoría, protegiendo las reglas de exclusividad del motor.
*   **Pestaña: Gestión de Cuentas (Estructura de Fondos):**
    *   Árbol jerarquizado (`AccountsTree`) homologado al de categorías. Permite agrupar cuentas bajo carpetas (ej. "Tarjetas", "Efectivo", "Inversiones").
    *   *Impacto Global:* Contiene el *toggle* crítico "Incluir en balance global", el cual dictamina si los fondos de esa cuenta se leen como disponibles y suman matemáticamente al 'Balance Total Global' del Dashboard principal.
*   **Pestaña: Impuestos (Taxes):**
    *   Módulo tabular asíncrono estandarizado para la creación y gestión de tipos de gravámenes o retenciones que aplican a las finanzas locales del usuario.

## 7. Vista: Analítica de Gastos (Expense Analysis)

Navegador financiero especializado para auditar y consolidar movimientos (gastos, ingresos, balance neto) desde múltiples dimensiones analíticas.

*   **Métricas Dinámicas (KPI Grid):** Resume matemáticamente el set de datos filtrado. Todos los montos son renderizados en la moneda base del usuario (conversión matemática dinámica sobre transacciones multi-moneda).
*   **Agrupación Geométrica Avanzada:** No es un simple listado; el usuario decide la raíz del árbol de análisis: "Cántaro > Categoría > Transacción", "Cuenta > Transacción", o "Tipo > Transacción".
*   **Distribución Gráfica:** Gráfico `ExpenseDistributionChart` proyectando estatus de fondos y balances analíticos.
*   **Panel de Filtros:** Herramienta minuciosa de búsqueda por concepto, filtros cruzados (chips), combinada armónicamente con la 'Period Bar' global del sistema.
