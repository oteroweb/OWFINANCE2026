# 📱 04 - Mobile (Capacitor + Android/iOS)

Documentación de deployment y desarrollo móvil: estrategias, guías y procesos.

## Subcategorías

### 🚀 [deployment/](./deployment/) - Deployment & Releases
Guías de deployment para ambas plataformas:
- `MOBILE_DEPLOYMENT_GUIDE.md` - Guía completa de deployment móvil
  - iOS & Android strategy
  - Requisitos previos (Android Studio, Xcode, etc.)
  - Configuración para development, staging, production
  - Comandos de deployment

---

**📱 Comando Rápido:**
```bash
# Development
./deploy-mobile.sh both dev

# Production
./deploy-mobile.sh both prod
```

**🛠️ Stack Técnico:**
- Framework: **Capacitor** (desde Quasar)
- Ubicación: `src-capacitor/`
- Build script: `deploy-mobile.sh`, `build-apk.sh`
- Backend: Uses `.env.mobile` (remote por defecto)

**📍 Última actualización:** 2026-03-01
