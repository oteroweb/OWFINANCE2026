# 🏦 Master Project Context: OWFINANCE 2026 (Onboarding Doc)

Este documento es la **Fuente Única de Verdad (Single Source of Truth - SSOT)** administrativa, funcional y técnica para todo el personal y agentes involucrados en el proyecto OWFINANCE 2026. Léelo detenidamente antes de planificar o ejecutar cualquier modificación.

---

## 🎯 1. Visión Administrativa y Propósito
**OWFINANCE 2026** es una plataforma Premium de tipo B2C/B2B (FinTech personal y empresarial) "todo en uno". Se distribuye como **Web App (PWA)** y aplicación móvil nativa a través de **iOS/Android**.

A diferencia de los rastreadores de gastos contables tradicionales, OWFINANCE utiliza una metodología radicalmente distinta llamada **"Sistema de Cántaros" (Jars)**, la cual obliga al usuario a dividir matemáticamente cada centavo ingresado en fondos predeterminados, garantizando un presupuesto disciplinado al 100%.

### 🏗 Ecosistema y Estructura Organizacional
El proyecto está desacoplado en dos repositorios principales (coordinados mediante scripts de consola en el directorio raíz):
1. **Backend (API Base):** `OWFINANCEBackend2025/`
2. **Frontend (App Visual):** `OWFinanceFrontend2025/`

---

## 🚀 2. Arquitectura Técnica y Stack

### 🖥️ Backend (La Máquina Lógica)
- **Tecnología:** Laravel 12.0 / PHP 8.x.
- **Autenticación:** Base por tokens granulares (Sanctum Auth). Todos los endpoints deben estar detrás de `auth:sanctum`.
- **Ruteo y Contratos:** Toda la API activa está dimensionada en la URI remota y local `/api/v1/` (`appfinanzas.blockshift.website/api/v1`).
- **Respuesta Estándar (Envelope):** `{ status, code, message, data }`.
- **Bases de Datos:** Soporte para SQLite (pruebas locales rápidas) y MySQL (producción).
- **Prevención N+1:** Implementación agresiva de *Eager Loading* `->with([...])` a través de Repositorios (ej. `TransactionRepo.php`) para consultas pesadas (muchas transacciones).

### 📱 Frontend (El Producto Final)
- **Tecnología:** Framework Quasar 2 impulsado por Vue 3 (Composition API / Script Setup) y TypeScript estricto.
- **Estado Global:** Administrado a lo largo de componentes a través de *Pinia* (`src/stores/*`).
- **Navegación:** Vue Router, configurado en modo historia (no hash).
- **Comunicaciones (HTTP Client):** Axios (`src/boot/axios.ts`) pre-configurado para captar URIs automáticas basadas en el entorno (`.env.local / .env.dev / .env.production`).

### 📲 Aplicación Móvil Híbrida
- **Motor:** Capacitor.js incrustado en `src-capacitor/`.
- La adaptabilidad está dada por *Flexbox Grid Classes* propias de Quasar, no hay código distinto (responsive puro). El teclado e insets gestionan los bordes nativos ("safe areas") transparentemente.

---

## 💎 3. Sistema de Diseño Premium UI/UX
Hemos abandonado el "Material Design Clásico" en pro de modernidad pura. Todas las vistas deben acoplarse y desarrollarse bajo estas reglas:
- **Estética Eje:** *Glassmorphism* (Efecto cristal semitransparente con `backdrop-filter: blur(16px)`).
- **Tipografía Institucional:** *Outfit* (Debe sentirse tecnológica y nítida).
- **Paleta de Colores "Deep Ocean":**
  - **Primary:** Azul Cielo vibrante / Cyan (`#0ea5e9`).
  - **Secondary:** Morado acento (`#8b5cf6`).
  - **Dark Mode Backgrounds:** Tonos de Pizarra oscura (`#0f172a` y `#020617`); cero negros puros (`#000000`).
  - **Feedbacks:** Verdes (`#10b981`) y Rojos (`#ef4444`) iluminados, legibles en fondos oscuros.
- **Elementos Globales:** Tarjetas (`.glass-panel`) con bordes muy redondeados (`var(--radius-lg) = 24px`) y sombras flotantes pronunciadas. Gráficos interactivos de entrada suavizada con `vue-echarts`.

---

## 🧩 4. Mapa Funcional del Sistema (Features Completas)

### 📊 Plataforma de Usuario Final (User Dashboard)
1. **Sistema de Cántaros (El Core de la App):**
   - Entidades lógicas (Jars) que atrapan los ingresos en modo *Fixed* (una cuota fija al mes, ej $50) o en modo *Percent* (ej. 30% del salario).
   - *Scopes:* Control granular sobre ciertos cántaros (ej. el Cántaro "Comida" toma un 20% aplicable sólo sobre ingresos provenientes de la categoría "Sueldo").
   - *Conciliación Inteligente:* El sistema recalcula en cascada de acuerdo a las fechas de los ingresos y los gastos con cierre mensual (`jars:materialize-cycles`).
2. **Centro Transaccional:**
   - Creación de Ingresos, Gastos y Transferencias (multicuenta).
   - Creación de Ajustes manuales (Balance Adjustment).
   - Herramienta avanzada de Análisis y filtros (Expense Analysis).
3. **Gestión Multicuenta (Accounts & Currencies):**
   - Soporta cuentas E-Wallet, Cripto, BancARIAS o EfecTIVO; CADA CUENTA atada opcionalmente a divisas distintas a la moneda base del usuario.
   - El sistema unifica automáticamente el equivalente calculando tasas oficiales interbancarias o manuales del usuario para mostrar un *Balance Global Armonizado*.
4. **Motor "Bulk Import" en dos fases:**
   - **Paso 1 (Dry-Run):** El usuario sube un archivo bancario (`.csv`) y el sistema emula su resultado contable (Pre-visualizando un posible descuadre).
   - **Paso 2 (Execute):** Se asientan a bases de datos si son autorizadas por el usuario.

### 🛡️ Dashboard Principal y Analíticas
- Tarjetas financieras (balances, ahorros teóricos, "dinero ocioso" al reiniciar los cántaros de un mes a otro).
- Gráficas de Echarts detallando Peso Esperado vs Asignación Activa vs Gasto y Balance remanente por Cáractaro.

### ⚙️ Panel de Control y Administración (Admin Access)
(Se accede tras iniciar sesión con rol de Administrador)
- **Gestión de Cuentas Universales:** Alta o baja de tipos de moneda soportados, tasas globales oficiales, Tipos de Cuenta Global, y bases de impuestos nacionales.
- **Gestores Multi-Entidad:** Control de tablas de Clientes, Proveedores y Usuarios completos con métricas de salud y soporte técnico.

---

## 🛠 5. Reglas y Directrices de Desarrollo (Flujo de Trabajo)
Todo nuevo empleado (o agente autónomo) debe acatar los siguientes comandos para no destrozar el despliegue de las apps:

### A) Scripts de Orquestación Local (Raíz)
Siempre ejecutarlos desde el la carpeta donde se unen los repositorios (`/OWFINANCE2026/`):
- `./switch-env.sh local` → Prepara rápidamente tu entorno copiando los `.env.local` a sus ubicaciones internas.
- `./dev-start.sh` → Enciende Docker, la BBDD, Artisan serve (`localhost:8000`), Vue dev server (`localhost:3000`) y corre migraciones. Todo en un solo comando.
- `./dev-stop.sh` → Limpia procesos huerfanos.

### B) Reglas Base para Inserción de Nuevas Funciones
- **Siempre** comprobar en `AGENTS.md` y `PROJECT_CONTEXT.md` antes de codear lógica troncal (Jars, Auth, etc).
- **No inventes utilidades de UI:** Antes de crear estilos `div style="..."`, busca utilidades de Quasar (ej. `q-px-md`, `text-h6`) y el archivo base `.glass-panel` que hemos creado para componentes unificados. Comprueba componentes compartidos en `src/components/*`.
- **Uso estricto de Tipos (TypeScript):** En el Frontend usar interfaces de Pinia bien tipadas, evitando tipos `any` cuando interactues con respuestas JSON estructuradas del backend.

### C) Protocolo de Despliegues (CI/CD)
El proyecto ha sido *Hardened* (Fortalecido) mediante flujos que chequean activamente la salud antes de confirmar la versión (`.github/workflows/deploy.yml` implementa `curl` healthcheck en vivo).

Solamente deben llevar los cambios a staging/produccion con los siguientes comandos ejecutados en consola, donde el argumento dictamina si va a la rama `dev` o a `prod`:
- `./deploy-backend.sh dev` -> Sincroniza archivos vía Rsync y corre `composer install`, limpiar caches, de forma nativa en el servidor sin caídas operativas.
- `./deploy-frontend.sh dev "Tu mensaje de commit"` -> Compila `npx quasar build -m spa` con `.env` del entorno y sube la distruibución por ssh al public path (`/app/`).

---

## 📈 6. Planeamiento Futuro: RoadMap "View by View"
Con los cimientos y flujos listos, el avance estricto planeado es un recorrido (optimización de Reactividad y UX Glassmorphism a fondo) dividido en:
- **Fase 1:** Transacciones (Paginación suave y modal Bulk-Import).
- **Fase 2:** Cuentas Bancarias y Ajustes.
- **Fase 3:** Sistema Interno de Cántaros (Progresos y Edición de Scopes).
- **Fase 4:** Reportes y Análisis E-Charts Interactivos Split-Pane.
- **Fase 5:** Consolidación de tablas del Administrador y Autoevaluación de accesibilidad.
