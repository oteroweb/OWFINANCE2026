# ⚙️ 01 - Configuración & Entorno

Documentación de **configuración multi-entorno**, variables de entorno, y estrategia de deployments.

## Archivos

### 🌐 Estrategia Multi-Entorno
- **ENV_STRATEGY.md** - Estrategia completa de configuración
  - Archivos `.env` según escenario (local, remote, mobile, production)
  - Cómo cambiar entre configuraciones
  - Backend URLs para cada entorno
  - Cuándo usar cada env

---

**📌 Referencia rápida:**
- `.env.local` → Desarrollo web en navegador (backend local)
- `.env.remote` → Desarrollo web contra servidor remoto
- `.env.mobile` → Apps móviles (Android/iOS)
- `.env.production` → Builds finales para tiendas

**📍 Última actualización:** 2026-03-01
