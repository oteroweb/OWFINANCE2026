# BUG-007 - MenuBar navegación con rutas duplicadas en DEV

## 🐛 Resumen
El MenuBar está generando rutas con prefijo `/app/` duplicado, resultando en URLs malformadas tipo `/app/app/transactions` que producen 404.

## 📍 Severidad
**CRÍTICA** - Bloquea navegación completa en vistas de usuario

## 🔍 Detección
- **Fecha**: 2026-04-06
- **Entorno**: DEV (https://appfinanzasdev.blockshift.website)
- **Usuario**: otero@demo.com (usuario normal)
- **Navegador**: Playwright browser automation

## 🧪 Reproducción

### Pasos
1. Login con `otero@demo.com` / `password`
2. Se redirige correctamente a `/app/user/home`
3. Click en botón "Trans" del MenuBar
4. Se navega a `/app/app/transactions` (duplicado `/app/`)
5. Se muestra página 404 "Oops. Nothing here..."

### URL Esperada vs Actual
| Acción | URL Esperada | URL Actual | Resultado |
|--------|--------------|------------|-----------|
| Click "Trans" | `/app/user/transactions` | `/app/app/transactions` | ❌ 404 |
| Click "Cántaros" | `/app/user/jars` | `/app/app/jars` | ❌ 404 (predicho) |
| Click "Ajustes" | `/app/user/settings` | `/app/app/settings` | ❌ 404 (predicho) |

## 🔎 Análisis Técnico

### Causa Raíz
El MenuBar está usando rutas absolutas que incluyen el prefijo `/app/`, pero el router de Vue ya está montado en `/app/`, causando duplicación.

### Componente Afectado
**MenuBar.vue** (probablemente en `OWFinanceFrontend2025/src/components/MenuBar.vue` o similar)

### Configuración del Router
Según `quasar.config.ts`:
```typescript
publicPath: '/app/'
```

El router Vue está montado en `/app/`, entonces las rutas definidas en `routes.ts` son **relativas a `/app/`**:
```typescript
{
  path: '/user/home',    // Realmente es /app/user/home
  path: '/user/transactions'  // Realmente es /app/user/transactions
}
```

### Problema en MenuBar
Los botones del MenuBar probablemente están haciendo:
```vue
<!-- ❌ INCORRECTO -->
<router-link to="/app/user/transactions">Trans</router-link>

<!-- ✅ CORRECTO -->
<router-link to="/user/transactions">Trans</router-link>
```

## 🛠️ Solución Propuesta

### Opción 1: Rutas Relativas (RECOMENDADA)
Cambiar todas las rutas del MenuBar para que sean relativas al router:

```vue
<!-- MenuBar.vue -->
<template>
  <nav>
    <router-link to="/user/home">Inicio</router-link>
    <router-link to="/user/transactions">Trans</router-link>
    <router-link to="/user/jars">Cántaros</router-link>
    <router-link to="/user/settings">Ajustes</router-link>
  </nav>
</template>
```

### Opción 2: Usar Rutas con Nombre
Si las rutas tienen nombres definidos en `routes.ts`:

```vue
<!-- MenuBar.vue -->
<template>
  <nav>
    <router-link :to="{ name: 'user-home' }">Inicio</router-link>
    <router-link :to="{ name: 'user-transactions' }">Trans</router-link>
    <router-link :to="{ name: 'user-jars' }">Cántaros</router-link>
    <router-link :to="{ name: 'user-settings' }">Ajustes</router-link>
  </nav>
</template>
```

## 🧭 Ubicación del Código

### Archivos a Revisar
1. `OWFinanceFrontend2025/src/components/MenuBar.vue` (o similar)
2. `OWFinanceFrontend2025/src/layouts/*.vue` (si el MenuBar está en un layout)
3. `OWFinanceFrontend2025/src/router/routes.ts` (verificar definición de rutas)
4. `OWFinanceFrontend2025/quasar.config.ts` (confirmar publicPath)

### Comando para Buscar
```bash
cd OWFinanceFrontend2025
grep -r "to=\"/app/" src/components/ src/layouts/
grep -r "router.push.*'/app/" src/
```

## ✅ Validación

### Tests Manuales Post-Fix
1. Login con `otero@demo.com`
2. Click en cada botón del MenuBar:
   - [ ] Inicio → `/app/user/home` ✓
   - [ ] Trans → `/app/user/transactions` ✓
   - [ ] Cántaros → `/app/user/jars` ✓
   - [ ] Ajustes → `/app/user/settings` ✓
3. Verificar que todas las URLs sean correctas (sin duplicación `/app/app/`)

### Tests Automatizados
Agregar tests e2e que verifiquen navegación del MenuBar:

```typescript
test('MenuBar navigation should use correct routes', async ({ page }) => {
  await page.goto('/app/login');
  await page.fill('[name="email"]', 'otero@demo.com');
  await page.fill('[name="password"]', 'password');
  await page.click('button[type="submit"]');
  
  // Verificar navegación a Trans
  await page.click('button:has-text("Trans")');
  await expect(page).toHaveURL(/.*\/app\/user\/transactions$/);
  
  // Verificar navegación a Cántaros
  await page.click('button:has-text("Cántaros")');
  await expect(page).toHaveURL(/.*\/app\/user\/jars$/);
  
  // Verificar navegación a Ajustes
  await page.click('button:has-text("Ajustes")');
  await expect(page).toHaveURL(/.*\/app\/user\/settings$/);
});
```

## 📊 Estado
- **Status**: ✅ RESUELTO
- **Fecha Resolución**: 2026-04-06
- **Prioridad**: P0 (Blocker)
- **Asignado a**: Frontend Team
- **Milestone**: OWFINANCE v1.0.23

---

## ✅ SOLUCIÓN IMPLEMENTADA

### Causa Raíz Final
El MenuBar tenía rutas absolutas con prefijo `/app/` cuando el router ya está montado en `/app/`. Esto causaba duplicación → `/app/app/transactions`.

**Archivos con rutas absolutas incorrectas detectados**:
1. `src/components/shared/LiquidBottomNavNew.vue` - tabs array con `/app/home`, etc.
2. `src/layouts/LiteMobileLayout.vue` - onTabChange con `/app/transactions`, etc.
3. `src/pages/user/config.ts` - userMenuLinks con `/app/config`, etc.

### Cambios Aplicados

#### 1. LiquidBottomNavNew.vue (líneas 82-87)
```diff
const tabs = [
- { icon: 'home', label: 'Inicio', route: '/app/home' },
- { icon: 'receipt_long', label: 'Trans', route: '/app/transactions' },
- { icon: 'savings', label: 'Cántaros', route: '/app/jars' },
- { icon: 'settings', label: 'Ajustes', route: '/app/config' },
+ { icon: 'home', label: 'Inicio', route: '/user/home' },
+ { icon: 'receipt_long', label: 'Trans', route: '/user/transactions' },
+ { icon: 'savings', label: 'Cántaros', route: '/user/jars' },
+ { icon: 'settings', label: 'Ajustes', route: '/user/config' },
];
```

#### 2. LiteMobileLayout.vue (líneas 82-91, 114)
```diff
const onTabChange = (tabName: string) => {
  const routes = {
-   home: '/app/home',
-   transactions: '/app/transactions',
-   jars: '/app/jars',
-   settings: '/app/config',
+   home: '/user/home',
+   transactions: '/user/transactions',
+   jars: '/user/jars',
+   settings: '/user/config',
  };
  
  const route = routes[tabName as keyof typeof routes];
  if (route) {
    void router.push(route).catch(() => { /* handle error */ });
  }
};

const onAvatarClick = () => {
- void router.push('/app/config');
+ void router.push('/user/config');
};
```

#### 3. config.ts (líneas 8-11)
```diff
export const userMenuLinks = [
- { icon: 'home', label: 'Inicio', route: '/app/home' },
- { icon: 'receipt_long', label: 'Transacciones', route: '/app/transactions' },
- { icon: 'savings', label: 'Cántaros', route: '/app/jars' },
- { icon: 'settings', label: 'Configuración', route: '/app/config' },
+ { icon: 'home', label: 'Inicio', route: '/user/home' },
+ { icon: 'receipt_long', label: 'Transacciones', route: '/user/transactions' },
+ { icon: 'savings', label: 'Cántaros', route: '/user/jars' },
+ { icon: 'settings', label: 'Configuración', route: '/user/config' },
] as const;
```

### Deploy Realizado
```bash
cd OWFinanceFrontend2025
quasar build -m spa
rsync -avz --delete dist/spa/ appfinan2@178.156.160.70:~/OWFINANCEBACKEND2025/public/app/
```

**Resultado**: ✔ 113 archivos subidos a DEV

### Validación Completa (Browser Automation)

#### Tests Ejecutados
| Tab | URL Final | Resultado | Nota |
|-----|-----------|-----------|------|
| Inicio | `/app/user/home` | ✅ PASS | Estado `[active]` correcto |
| Trans | `/app/user/transactions` | ✅ PASS | Sin duplicación `/app/app/` |
| Cántaros | `/app/user/jars` | ✅ PASS | Estado `[active]` correcto |
| Ajustes | `/app/user/config` | ✅ PASS | Estado `[active]` correcto |

#### Observaciones
- **Cache Issue**: Primera prueba post-deploy seguía mostrando rutas viejas
- **Solución**: Forzar carga con query string `?nocache={timestamp}` rompió caché del navegador
- **Verificación**: Código compilado en `dist/spa/assets/*.js` contiene rutas corregidas

### Impacto
- ✅ Navegación entre vistas funcional en DEV
- ✅ Tabs activos se destacan correctamente
- ✅ No más errores 404 en navegación del MenuBar
- ✅ Experiencia de usuario restaurada

### Lecciones Aprendidas
1. **Cache Agresivo**: El navegador cachea assets JS incluso con hard reload. Usar query strings o cache busting en producción.
2. **Verificación Multi-Capa**: Siempre verificar código fuente → código compilado → comportamiento en browser.
3. **Router publicPath**: Cuando `publicPath: '/app/'`, todas las rutas relativas en router son relativas a `/app/`, no a la raíz del servidor.

## 🔗 Relacionado
- [BUG-001](BUG-001-reglas-opcionales-tipo-no-aplican.md)
- Skill: [owfinance-dev-routes-testing](../.agents/skills/owfinance-dev-routes-testing/SKILL.md)
- Docs: [Router Configuration](../docs/03-frontend/router-configuration.md)

## 💡 Lecciones Aprendidas
1. Siempre usar rutas relativas al `publicPath` del router
2. Considerar usar rutas con nombre en lugar de strings
3. Agregar tests e2e para navegación crítica
4. La duplicación de prefijos es un problema común en SPAs con `publicPath` no-root
