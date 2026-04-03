# 📱 Módulo de Actualización de App (In-App Update Notification)

**Status**: To Do  
**Priority**: Medium  
**Role**: Engineering / Product  
**Sprint**: Por definir  

---

## User Story

> Como usuario de OWFinance en Android,  
> quiero ver una notificación cuando haya una nueva versión disponible,  
> para poder actualizar la app fácilmente sin tener que buscarla manualmente.

---

## Descripción

Implementar un sistema de detección de actualizaciones que:
1. Al abrir la app, consulte un endpoint del backend con la versión mínima/última disponible.
2. Compare con la versión actual instalada.
3. Si hay una versión más reciente, muestre un banner/modal indicando: *"Hay una nueva actualización disponible"* con un botón de descarga directo.

---

## Criterios de Aceptación

### Backend
- [ ] Crear endpoint `GET /api/v1/app/version` que devuelva:
  ```json
  {
    "latest_version": "1.1.0",
    "min_required_version": "1.0.0",
    "download_url_dev": "https://appfinanzasdev.blockshift.website/downloads/owfinance-dev.apk",
    "download_url_stage": "https://appfinanzas.blockshift.website/downloads/owfinance-stage.apk",
    "changelog": "Nuevas funciones de registro y mejoras de rendimiento",
    "force_update": false
  }
  ```
- [ ] El endpoint es público (sin auth requerida)
- [ ] Los valores son configurables vía `.env` o tabla en DB

### Frontend (Capacitor/Android)
- [ ] Al montar la app, llamar a `/api/v1/app/version`
- [ ] Comparar `latest_version` con la versión del `package.json`
- [ ] Si hay actualización disponible: mostrar `q-dialog` o `q-banner` con:
  - Mensaje de nueva versión
  - Botón "Actualizar" que abre el `download_url` correspondiente al entorno
  - Botón "Más tarde" (si `force_update = false`)
- [ ] Si `force_update = true`: modal sin opción de cerrar

### Deploy Protocol
- Los APKs se suben al servidor con nombre fijo (los enlaces nunca cambian):
  - DEV: `owfinance-dev.apk`
  - STAGE: `owfinance-stage.apk`
- Al hacer deploy, se sobreescribe el archivo existente
- El endpoint `/app/version` se actualiza manualmente con la nueva versión

---

## URLs de Descarga Actuales

| Entorno | URL |
|---------|-----|
| DEV | `https://appfinanzasdev.blockshift.website/downloads/owfinance-dev.apk` |
| Stage | `https://appfinanzas.blockshift.website/downloads/owfinance-stage.apk` |

---

## Notas Técnicas

- Versión actual del app: ver `OWFinanceFrontend2025/package.json` → campo `version`
- El check de versión corre en `App.vue` o en un composable `useAppUpdate()`
- Para MVP: solo mostrar banner, sin `force_update`
- Fase 2: integrar con Google Play si se sube a la tienda

---

*Creado: 2026-03-31 | Scope: DEV + Stage*
