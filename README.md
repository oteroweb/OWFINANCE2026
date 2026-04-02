# 🏦 hola OWFINANCE 2026

Sistema integral de gestión financiera con backend Laravel y frontend Quasar (Web + Móvil)

## 📁 Estructura del Proyecto

```
OWFINANCE2026/
├── OWFINANCEBackend2025/     # Backend Laravel (API REST)
├── OWFinanceFrontend2025/     # Frontend Quasar (Web/Mobile)
├── logs/                      # Logs de desarrollo
├── dev-start.sh               # 🚀 Iniciar entorno dev
├── dev-stop.sh                # 🛑 Detener entorno dev
├── env-config.sh              # 🔧 Configurar entornos
└── mobile-build.sh            # 📱 Compilar apps móviles
```

## 🚀 Inicio Rápido

### 1️⃣ Configuración Inicial

```bash
# Dar permisos de ejecución a los scripts
chmod +x *.sh

# Configurar entorno de desarrollo
./env-config.sh dev

# Instalar dependencias del backend
cd OWFINANCEBackend2025
composer install
php artisan migrate --seed
cd ..

# Instalar dependencias del frontend
cd OWFinanceFrontend2025
npm install
cd ..
```

### 2️⃣ Iniciar Desarrollo

```bash
# Inicia backend (puerto 8000) y frontend (puerto 3000)
./dev-start.sh

# Acceder a:
# - Backend API: http://localhost:8000
# - Frontend Web: http://localhost:3000
```

### 3️⃣ Detener Desarrollo

```bash
./dev-stop.sh
```

## 🌍 Gestión de Entornos

### Desarrollo Local
```bash
./env-config.sh dev
```

### Staging
```bash
./env-config.sh staging
# Editar archivos .env.staging generados
```

### Producción
```bash
./env-config.sh prod
# ⚠️ Revisar y configurar credenciales reales
```

## 📱 Compilación Móvil

### Requisitos Previos

**iOS:**
- macOS
- Xcode instalado
- CocoaPods: `sudo gem install cocoapods`

**Android:**
- Android Studio
- Java JDK 11+
- Variables de entorno configuradas (`ANDROID_HOME`, `JAVA_HOME`)

### Compilar Apps

```bash
# Android (desarrollo)
./mobile-build.sh android dev

# iOS (desarrollo)
./mobile-build.sh ios dev

# Ambas plataformas (producción)
./mobile-build.sh both prod
```

### Desarrollo con Hot-Reload

```bash
cd OWFinanceFrontend2025

# Android con hot-reload
quasar dev -m capacitor -T android

# iOS con hot-reload
quasar dev -m capacitor -T ios
```

## 🛠️ Tecnologías

### Backend
- **Framework:** Laravel 11.x
- **Base de datos:** MySQL / SQLite
- **API:** RESTful con Sanctum Auth
- **Documentación:** Scribe / Swagger

### Frontend
- **Framework:** Quasar 2.x (Vue 3 + TypeScript)
- **Estado:** Pinia
- **Routing:** Vue Router
- **HTTP:** Axios
- **UI:** Material Design

### Mobile
- **Capacitor:** Compilación nativa iOS/Android
- **PWA:** Progressive Web App support

## 📊 Flujo de Trabajo Recomendado

1. **Desarrollo Local**
   ```bash
   ./dev-start.sh
   # Editar código con hot-reload automático
   ```

2. **Pruebas en Móvil**
   ```bash
   # Compilar y probar en dispositivo/emulador
   ./mobile-build.sh android dev
   ```

3. **Deployment**
   ```bash
   # Configurar entorno
   ./env-config.sh prod
   
   # Backend: seguir guía en OWFINANCEBackend2025/deploy/
   # Frontend: quasar build
   ```

## 📝 Scripts Disponibles

| Script | Descripción |
|--------|-------------|
| `dev-start.sh` | Inicia backend + frontend en desarrollo |
| `dev-stop.sh` | Detiene todos los servicios |
| `env-config.sh [env]` | Configura variables de entorno |
| `mobile-build.sh [platform] [mode]` | Compila apps móviles |

## 🔗 URLs Importantes

- **Backend Dev:** http://localhost:8000
- **Frontend Dev:** http://localhost:3000
- **API Docs:** http://localhost:8000/docs
- **Swagger:** http://localhost:8000/swagger.json

## 📚 Documentación Adicional

- [Backend README](OWFINANCEBackend2025/README.md)
- [Frontend README](OWFinanceFrontend2025/README.md)
- [API Documentation](OWFINANCEBackend2025/docs/)
- [Frontend Guides](OWFinanceFrontend2025/docs/)

## 🐛 Troubleshooting

### Puerto ocupado
```bash
# Liberar puertos manualmente
lsof -ti:8000 | xargs kill -9  # Backend
lsof -ti:3000 | xargs kill -9  # Frontend
```

### Limpiar caché
```bash
# Backend
cd OWFINANCEBackend2025
php artisan cache:clear
php artisan config:clear

# Frontend
cd OWFinanceFrontend2025
rm -rf node_modules/.vite
npm run build
```

### Problemas con base de datos
```bash
cd OWFINANCEBackend2025
php artisan migrate:fresh --seed
```

## 🤝 Contribución

1. Crear rama feature: `git checkout -b feature/nueva-funcionalidad`
2. Commit cambios: `git commit -am 'Agrega nueva funcionalidad'`
3. Push a rama: `git push origin feature/nueva-funcionalidad`
4. Crear Pull Request

## 📄 Licencia

Propietario: OteroWeb  
Contacto: oterolopez1990@gmail.com

---

**Desarrollado con ❤️ por OteroWeb**
