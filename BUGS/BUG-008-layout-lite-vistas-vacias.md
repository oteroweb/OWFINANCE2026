# Fix: Layout Lite no renderizaba vistas (páginas vacías)

**Fecha**: 2026-04-06  
**Commit**: 0f53812  
**Entorno**: DEV  

## 🐛 Problema

Las URLs del layout Lite funcionaban correctamente (sin duplicaciones `/app/app/`) pero las páginas se mostraban **completamente vacías**:

- ✅ URL correcta: `https://appfinanzasdev.blockshift.website/app/user/home`
- ❌ Vista vacía: No se renderizaba el contenido de `user_dashboard.vue`

Lo mismo ocurría en:
- `/user/transactions` - vacío
- `/user/jars` - vacío  
- `/user/config` - vacío

## 🔍 Causa Raíz

**DynamicRoleLayout** tenía un `<router-view />` duplicado que causaba anidamiento incorrecto:

```vue
<!-- ❌ ANTES (incorrecto) -->
<template>
  <component :is="activeLayout">
    <router-view />  <!-- Este router-view está de más -->
  </component>
</template>
```

**Flujo incorrecto**:
```
routes.ts: /user -> DynamicRoleLayout
  └─> DynamicRoleLayout: <router-view /> (primer nivel)
       └─> LiteMobileLayout: <router-view /> (segundo nivel) 
            └─> user_dashboard.vue (NUNCA SE RENDERIZA)
```

El router-view duplicado causaba que Vue Router no supiera en qué nivel renderizar el componente final.

## ✅ Solución

Eliminar el `<router-view />` de **DynamicRoleLayout** porque los layouts hijos ya lo tienen:

```vue
<!-- ✅ DESPUÉS (correcto) -->
<template>
  <!-- El router-view está dentro de cada layout hijo, no aquí -->
  <component :is="activeLayout" />
</template>
```

**Flujo correcto**:
```
routes.ts: /user -> DynamicRoleLayout
  └─> DynamicRoleLayout carga dinámicamente: LiteMobileLayout
       └─> LiteMobileLayout: <router-view />
            └─> user_dashboard.vue (SE RENDERIZA CORRECTAMENTE ✅)
```

## 📋 Archivos Modificados

**OWFinanceFrontend2025/src/layouts/DynamicRoleLayout.vue**:
- Removido `<router-view />` del template
- Añadido comentario explicativo

## 🧪 Validación

Después del fix, las vistas se renderizan correctamente:

```bash
# Test manual en navegador
https://appfinanzasdev.blockshift.website/app/user/home
✅ Muestra el dashboard completo con balance, cántaros, movimientos

https://appfinanzasdev.blockshift.website/app/user/transactions
✅ Muestra la tabla de transacciones

https://appfinanzasdev.blockshift.website/app/user/jars
✅ Muestra los cántaros

https://appfinanzasdev.blockshift.website/app/user/config
✅ Muestra la configuración
```

## 🏗️ Arquitectura de Layouts

Layouts que tienen su propio `<router-view />`:
- ✅ **LiteMobileLayout** (líneas 16-22)
- ✅ **LiteDesktopLayout** (línea 14)
- ✅ **ProLayout** (línea 21)
- ✅ **LegacyLayout** (líneas 130-134)
- ✅ **AdminLayout** (líneas 61-65)
- ✅ **MainLayout** (línea 10)

Layout que NO debe tener `<router-view />`:
- ✅ **DynamicRoleLayout** - solo carga dinámicamente los layouts hijos

## 📝 Lecciones Aprendidas

1. **Un solo `<router-view />` por nivel de anidamiento**
   - DynamicRoleLayout es un "selector de layout", no un layout en sí
   - Solo los layouts finales deben tener `<router-view />`

2. **Síntoma clave**: URL correcta pero página vacía
   - Indica problema de renderizado, no de routing
   - Revisar anidamiento de `<router-view />`

3. **Debugging**:
   ```bash
   # Verificar anidamiento de router-view
   grep -n "router-view" src/layouts/*.vue
   ```

## 🚀 Deploy

```bash
# Build
cd OWFinanceFrontend2025
rm -rf dist/spa .quasar
npx quasar build -m spa

# Deploy a DEV
./deploy-frontend.sh dev "Fix: eliminar router-view duplicado"
```

## 🔗 Relacionado

- BUG-007: Duplicaciones `/app/app/` (resuelto previamente)
- Layout Lite: Diseño mobile-first con navigation bar
- DynamicRoleLayout: Sistema de selección de layout según usuario
