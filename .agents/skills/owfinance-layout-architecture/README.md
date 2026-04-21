# owfinance-layout-architecture

Skill para trabajar con el sistema de layouts dinámicos de OWFINANCE.

## Descripción

Este skill documenta la arquitectura de layouts de OWFINANCE, que permite a los usuarios elegir entre 3 experiencias de interfaz:

1. **Lite** - Mobile-first, bottom navigation, minimalista
2. **Pro** - Sidebar avanzado, multi-panel (en desarrollo)
3. **Legacy** - Topbar + drawer clásico

## Cuándo usar este skill

- Estás modificando o creando un layout
- Necesitas agregar componentes específicos a un layout
- Estás depurando problemas de renderizado (páginas vacías)
- Quieres entender el flujo de selección de layouts
- Necesitas crear un nuevo layout mode
- Estás organizando componentes por layout

## Conceptos clave

### DynamicRoleLayout

Es el **selector** que elige qué layout cargar basándose en:
- `auth.settings.layout_mode` (preferencia del usuario)
- `$q.screen.gt.sm` (tamaño de pantalla)

**IMPORTANTE**: `DynamicRoleLayout` NO tiene `<router-view />`. Solo los layouts hijos lo tienen.

### Organización de Componentes

```
components/
├── liquid/    # Componentes del layout LITE
├── pro/       # Componentes del layout PRO (vacío)
└── [shared]/  # Componentes compartidos
```

### Routas

Todas las rutas de usuario usan el prefijo `/user/*` (relativo a publicPath `/app/`):
- `/user/home`
- `/user/transactions`
- `/user/jars`
- `/user/config`

NUNCA usar `/app/*` directamente (genera duplicados `/app/app/*`).

## Problemas comunes

### Páginas vacías después de cambiar layout

**Causa**: Doble `<router-view />` en jerarquía.

**Solución**: 
- DynamicRoleLayout → NO router-view
- Layout hijo → SÍ router-view

### Layout no cambia al seleccionar

**Causa**: Store no se actualiza o computed no es reactivo.

**Solución**: Verificar `auth.settings.layout_mode` y computed reactivo.

### Componente no se encuentra

**Causa**: Import path incorrecto.

**Solución**: Import explícito en lugar de auto-import:
```vue
import LiquidHeader from 'components/liquid/LiquidHeader.vue';
```

## Referencias rápidas

- **Doc completa**: `docs/03-frontend/SISTEMA_LAYOUTS_DINAMICOS.md`
- **Stitch Design**: `docs/ui-ux/MASTER_UI_SOURCES.md`
- **Routes Testing**: `.agents/skills/owfinance-dev-routes-testing/`

## Validación antes de deploy

```bash
# Validar rutas
./validate-routes.sh

# Build
cd OWFinanceFrontend2025 && npm run build

# Deploy
./deploy-frontend.sh "descripción de cambios"
```

---

**Versión**: 1.0.0  
**Fecha**: 2026-04-06
