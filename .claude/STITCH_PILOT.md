# STITCH PILOT CONFIGURATION

## Goal
Implementar primera vista usando pipeline Stitch → Vue 3

## Target View
**Nombre:** Settings Overview (Vista de configuración simple)
**Componentes:**
- User info card
- Settings menu (links a subsecciones)
- Logout button

## Rationale
- Small scope (rápido)
- No data complexity (static layout mostly)
- Foundation para vistas más complejas

## Stitch Prompt Template (LISTO PARA USAR)

```markdown
# CONTEXTO: OWFINANCE Settings Overview

## APLICACIÓN
Proyecto: OWFINANCE2026
Stack: Vue 3 + Quasar 2
API: https://appfinanzas.blockshift.website/api/v1
Auth: Bearer Token (Sanctum)

## DISEÑO
Colores:
  - Primario: Deep Ocean (#001F3F)
  - Secundario: Gold (#FFB700)
  - Fondo: Glassmorphic (backdrop-filter: blur)
  - Texto: White (#FFFFFF)

Tipografía:
  - Font: Outfit
  - H1: 32px bold
  - Body: 14px regular

Componentes:
  - Cards: Glassmorphic, rounded 12px, shadow subtle
  - Buttons: Solid, rounded 8px, hover overlay

## VISTA: Settings Overview

Descripción:
Panel de configuración simple con datos del usuario y opciones principales.

Secciones:
1. Header: "Settings" título + user avatar
2. User Card: Avatar, nombre, email (datos estáticos - los inyecta Vue)
3. Menu de opciones:
   - Edit Profile (link)
   - Security (link)
   - Notifications (link)
   - Privacy (link)
   - Logout (button)

Estilos:
- Mobile-first responsive
- Cards con 16px padding
- Menu items con hover effect (gold tint)
- Sin lógica JavaScript (handlers en Vue)

Exportar como: HTML puro + CSS (Tailwind compatible)
```

## Implementación Checklist

- [ ] Descargar HTML de Stitch
- [ ] Crear componente: `src/components/SettingsOverview.vue`
- [ ] Convertir HTML → template Vue
- [ ] Añadir props: `user { avatar, name, email }`
- [ ] Añadir métodos: `goToEdit()`, `logout()`
- [ ] Conectar a API `/api/v1/user` si es necesario
- [ ] Validar token Sanctum
- [ ] Tests: responsive, accesibilidad
- [ ] Merge a dev branch

## Timeline
- Stitch generation: 0.2h
- Vue implementation: 1.5h
- Testing: 0.5h
- **Total: 2.2 horas**

## Next Views (después del piloto)
1. Home Dashboard
2. Transactions List
3. Jars Editor
