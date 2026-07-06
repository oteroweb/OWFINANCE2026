# Prompt para Claude Design — OWF-140 Admin User Management

> **Para:** Claude Design (diseñador IA)  
> **Proyecto:** OWFINANCE 2026 — Panel Administrativo / Módulo Usuarios  
> **Fecha:** 2026-06-28

---

## Contexto del producto

OWFINANCE es una app de finanzas personales con dos modos de usuario:
- **Lite** (usuarios finales): UI mobile-first, dark navy, tokens de diseño navy `#1E3A8A`, cyan `#0EA5E9`, tipografía Satoshi + DM Sans
- **Admin** (administradores): panel de gestión interna accedido por `role=admin`

El Admin panel actual tiene un `AdminLayout.vue` con sidebar básico (sin íconos, sin secciones) y páginas CRUD genéricas. Necesitamos **rediseñar el módulo de gestión de usuarios** del admin para que sea profesional y funcional.

---

## Lo que necesita diseño

### 1. Lista de Usuarios `/admin/users`

**Estado actual:** tabla HTML básica con CrudPage genérico  
**Estado deseado:** vista de gestión moderna

**Elementos que debe incluir el diseño:**
- **KPI row** en la parte superior: 4 chips/cards con → Total usuarios / Activos hoy / Registros este mes / Usuarios Pro
- **Barra de filtros** horizontal: campo de búsqueda (nombre/email) + select de Rol + select de Estado + select de Plan
- **Tabla de usuarios** con columnas:
  - Avatar (círculo con iniciales del nombre)
  - Nombre + email (dos líneas)
  - Badge de rol: `admin` = rojo oscuro, `user` = azul
  - Pill de plan: `Pro` = morado degradado, `Lite` = gris
  - Toggle activo/inactivo (inline, sin modal)
  - Último acceso (fecha relativa: "hace 2 días")
  - Acciones: botón "Ver detalle" (icon person) + botón "Impersonar" (icon manage_accounts) + menú "..." con Eliminar
- **Paginación** en la parte inferior

**Tono visual:** Interface administrativa limpia, tipografía sans-serif legible, paleta neutral/slate con acentos azul (#1E3A8A) para acciones primarias y rojo (#EF4444) solo para destrucción/alertas.

---

### 2. Detalle de Usuario `/admin/users/:id`

**Estado actual:** no existe  
**Estado deseado:** pantalla completa de administración de un usuario específico

**Estructura de la página:**

**Header:**
- Avatar grande (72px, círculo con iniciales + color suave derivado del nombre)
- Nombre completo (h2)
- Email (caption)
- Badge de rol + Badge de plan en la misma línea
- Toggle activo/inactivo con label "Cuenta activa"
- Fila de acciones primarias (botones pill):
  - 🔑 "Iniciar sesión como" (botón warning/amber)
  - 🔒 "Cambiar contraseña" (botón neutral)
  - ❌ "Revocar tokens" (botón destructivo, outlined)
  - 📧 "Enviar reset" (botón ghost)

**Tabs (con indicadores de dato):**
| Tab | Ícono | Descripción |
|---|---|---|
| Perfil | person | Datos personales editables |
| Cuentas | account_balance | Lista readonly de cuentas bancarias/wallets |
| Cántaros | water_drop | Lista readonly de jars |
| Transacciones | receipt_long | Últimas 20 transacciones |
| Configuración | settings | Preferencias de la app |
| Tasas | currency_exchange | Tipos de cambio personales |
| Seguridad | security | Tokens, accesos, contraseña |

**Tab Perfil:**
- Secciones agrupadas: "Datos personales" / "Contacto y ubicación" / "Cuenta y rol"
- Campos: nombre, email, teléfono, ciudad, país (select), ocupación, fecha de nacimiento
- Sección "Cuenta y rol": moneda base (select), Rol (select: user/admin), Plan (select: lite/pro)
- Botón "Guardar cambios" al final

**Tab Cuentas (readonly):**
- Cards o lista: nombre de la cuenta + tipo + moneda + balance + estado activo chip
- Sin botones de acción (solo observación)

**Tab Transacciones:**
- Lista compacta: fecha (DD/MM) + nombre + monto (positivo=verde, negativo=rojo) + categoría chip
- "Ver todas las transacciones" → link a `/admin/transactions?user_id=:id`

**Tab Seguridad:**
- Stat: "N tokens activos"
- Stat: "Último acceso: [fecha]"
- Sección "Cambiar contraseña": campo nueva contraseña + confirmar + botón
- Botón "Revocar todos los tokens" (destructivo, con confirm dialog)
- Botón "Enviar link de restablecimiento" (secondary)

---

### 3. AdminLayout Sidebar v2

**Estado actual:** lista de links sin íconos, sin secciones  
**Estado deseado:** sidebar estructurado y visual

**Estructura del sidebar:**
```
[Logo OWFINANCE]
[Avatar admin + nombre + "Administrador"]

─── VISIÓN GENERAL ───
📊  Dashboard

─── USUARIOS ───
👥  Usuarios         [badge: 127]
🎭  Roles

─── CATÁLOGOS ───
💰  Monedas
🏦  Tipos de cuenta
🏷️  Impuestos
📂  Categorías
📦  Ítems
🏪  Proveedores
↔️  Tipos de Tx
👔  Clientes
📈  Tasas

─── SISTEMA ───
❤️  Estado del sistema
🤖  Monitor IA

[Cerrar sesión]
```

Visual: sidebar de 240px, fondo blanco o slate-50, links con hover slate-100, ítem activo con background azul suave (`#EFF6FF`) y texto azul (`#1E3A8A`), texto de sección en slate-400 uppercase.

---

### 4. Banner de Impersonación

Elemento fijo en el top de toda la UI cuando el admin está impersonando un usuario.

- Altura: 44px
- Fondo: `#EF4444` (rojo alerta) con gradiente sutil
- Ícono: `manage_accounts` en blanco
- Texto: "Estás viendo la cuenta de **[Nombre de usuario]** — impersonando"
- Botón derecho: "← Volver al Admin" (outline blanco, pequeño)
- El contenido del resto de la app baja 44px para no quedar oculto bajo el banner

---

## Design tokens del proyecto (respetar)

```css
--owf-navy: #1E3A8A;      /* primario oscuro */
--owf-cyan: #0EA5E9;       /* acento */
--owf-slate-50: #F8FAFC;
--owf-slate-100: #F1F5F9;
--owf-slate-400: #94A3B8;
--owf-slate-700: #334155;
--owf-error: #EF4444;
--owf-success: #10B981;
--owf-warning: #F59E0B;
--owf-pro: #7C3AED;        /* plan Pro */
--owf-radius: 12px;
--font-main: 'Satoshi', 'DM Sans', sans-serif;
```

---

## Deliverables esperados del diseñador

1. **Mockup de la Lista de Usuarios** — vista completa con KPIs, filtros, tabla, paginación
2. **Mockup del Detalle de Usuario** — header + tabs con contenido de cada tab
3. **Mockup del Sidebar Admin v2** — estado normal + estado con ítem activo
4. **Mockup del Banner de Impersonación** — posicionado en la UI con contenido de ejemplo
5. **Especificaciones de componentes** para el developer:
   - Colores exactos, tamaños, espaciados
   - Estados hover/active/disabled
   - Comportamiento responsive (¿se colapsa el sidebar en tablet?)

---

## Restricciones y notas para el diseñador

- El admin panel NO necesita ser responsive para mobile (solo desktop ≥1024px)
- Quasar 2 ya provee q-table, q-tabs, q-dialog — el diseño debe ser compatible con esos componentes
- No inventar patrones de UX nuevos que rompan con el sistema de componentes Quasar
- Los badges de rol deben ser claramente distinguibles entre `admin` y `user` en un vistazo rápido
- La acción de impersonar debe tener confirmación antes de ejecutar (dialog modal)
- El plan "Pro" debe lucir premium (morado/gradiente) vs "Lite" (gris/neutral)

---

## Pantallas a NO rediseñar (fuera de scope)

- `/admin/transactions`, `/admin/currencies`, etc. (mantienen el CrudPage genérico actual)
- La UI de usuario final (AppShell, vistas Lite/Pro) — es un sistema distinto
- Login page — no cambia

---

## Referencia visual sugerida

El estilo visual de referencia: **dashboard de administración tipo Linear, Vercel o Supabase** — limpio, denso en información pero bien jerarquizado, paleta slate/neutral con acentos de color solo para estado y acciones.
