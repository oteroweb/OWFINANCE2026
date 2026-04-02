# 📱 Guía de Deployment Móvil - iOS & Android

## 🎯 Estrategia de Deployment

Esta guía cubre el deployment completo de OWFINANCE en ambas plataformas móviles.

---

## 🚀 Despliegue Rápido

```bash
# Development (Debug)
./deploy-mobile.sh both dev          # iOS + Android (dev)
./deploy-mobile.sh android dev       # Solo Android (dev)
./deploy-mobile.sh ios dev           # Solo iOS (dev)

# Staging
./deploy-mobile.sh both staging

# Production (Release firmado)
./deploy-mobile.sh both prod
```

---

## 🤖 ANDROID - Configuración Completa

### Requisitos Previos

1. **Android Studio** instalado
2. **Java JDK 11+** configurado
3. Variables de entorno:
   ```bash
   export ANDROID_HOME=$HOME/Library/Android/sdk
   export PATH=$PATH:$ANDROID_HOME/platform-tools
   export PATH=$PATH:$ANDROID_HOME/tools
   ```

### Builds de Development

```bash
# Desarrollo con hot-reload (recomendado para desarrollo activo)
./dev-mobile.sh

# O build + instalación directa
./build-apk.sh debug install
```

### Builds de Producción (Firmado)

#### 1. Crear Keystore (solo primera vez)

```bash
cd OWFinanceFrontend2025/src-capacitor/android/app

keytool -genkey -v \
  -keystore owfinance-release.keystore \
  -alias owfinance \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

# Guarda las contraseñas en un lugar seguro!
```

#### 2. Configurar Signing en Gradle

Editar: `OWFinanceFrontend2025/src-capacitor/android/app/build.gradle`

```gradle
android {
    ...
    
    signingConfigs {
        release {
            storeFile file('owfinance-release.keystore')
            storePassword 'TU_STORE_PASSWORD'
            keyAlias 'owfinance'
            keyPassword 'TU_KEY_PASSWORD'
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

**⚠️ IMPORTANTE**: Usar variables de entorno para passwords en CI/CD:

```gradle
signingConfigs {
    release {
        storeFile file('owfinance-release.keystore')
        storePassword System.getenv("KEYSTORE_PASSWORD")
        keyAlias 'owfinance'
        keyPassword System.getenv("KEY_PASSWORD")
    }
}
```

#### 3. Generar APK/AAB Firmado

```bash
# APK (distribución directa)
./deploy-mobile.sh android prod

# O manualmente:
cd OWFinanceFrontend2025/src-capacitor/android
./gradlew assembleRelease

# AAB (para Google Play Store)
./gradlew bundleRelease
```

**Outputs:**
- APK: `android/app/build/outputs/apk/release/app-release.apk`
- AAB: `android/app/build/outputs/bundle/release/app-release.aab`

### Publicar en Google Play Store

1. **Primera vez**: Crear aplicación en [Google Play Console](https://play.google.com/console)
2. Subir AAB (no APK) a Play Console
3. Completar información de la tienda
4. Crear release (interno/cerrado/producción)

```bash
# Generar AAB para Play Store
./deploy-mobile.sh android prod

# El AAB estará en: releases/android/owfinance-prod-TIMESTAMP.aab
```

---

## 🍎 iOS - Configuración Completa

### Requisitos Previos

1. **macOS** (obligatorio)
2. **Xcode** instalado desde App Store
3. **CocoaPods**:
   ```bash
   sudo gem install cocoapods
   ```
4. **Apple Developer Account** ($99/año)
   - Crear en: https://developer.apple.com

### Configuración Inicial iOS

#### 1. Configurar Bundle ID

Editar: `OWFinanceFrontend2025/src-capacitor/capacitor.config.json`

```json
{
  "appId": "com.tuempresa.owfinance",
  "appName": "OwFinance",
  "webDir": "www"
}
```

#### 2. Configurar en Xcode

```bash
cd OWFinanceFrontend2025/src-capacitor
npx cap add ios
npx cap sync ios

# Abrir en Xcode
open ios/App/App.xcworkspace
```

En Xcode:
1. Seleccionar proyecto "App"
2. En "Signing & Capabilities":
   - ✅ Automatically manage signing
   - Seleccionar tu Team (Apple Developer Account)
   - Bundle Identifier: `com.tuempresa.owfinance`

### Builds de Development

#### Instalar en iPhone Físico (USB)

```bash
./deploy-mobile.sh ios dev

# O manualmente:
# 1. Conectar iPhone por USB
# 2. Confiar en la computadora
# 3. En Xcode: seleccionar tu iPhone como destino
# 4. Product > Run (⌘R)
```

**Primera vez en el iPhone:**
1. Settings > General > VPN & Device Management
2. Confiar en tu Apple Developer Certificate

#### Desarrollo con Hot-Reload

```bash
cd OWFinanceFrontend2025
quasar dev -m capacitor -T ios

# Esto abre Xcode automáticamente
# Los cambios se reflejan en tiempo real
```

### Builds de Producción

#### 1. Crear Certificados y Provisioning Profiles

**Opción A: Automático (Xcode)**
1. En Xcode: Signing & Capabilities
2. ✅ Automatically manage signing
3. Xcode maneja todo

**Opción B: Manual** (para CI/CD)
1. Ir a [Apple Developer Certificates](https://developer.apple.com/account/resources/certificates)
2. Crear:
   - Certificate: iOS Distribution
   - Provisioning Profile: App Store Distribution
3. Descargar e instalar en Xcode

#### 2. Archive para App Store

```bash
./deploy-mobile.sh ios prod

# Esto abre Xcode, luego:
```

En Xcode:
1. Seleccionar "Any iOS Device (arm64)"
2. **Product > Archive** (⌘⇧B primero para build)
3. Esperar a que compile
4. Se abre Organizer con el Archive

#### 3. Distribuir

En Xcode Organizer:

**Para App Store:**
1. Click "Distribute App"
2. Seleccionar "App Store Connect"
3. Upload
4. Completar en [App Store Connect](https://appstoreconnect.apple.com)

**Para TestFlight (beta testing):**
1. Upload a App Store Connect (mismo proceso)
2. En App Store Connect > TestFlight
3. Agregar testers internos/externos

**Para distribución Ad Hoc (sin App Store):**
1. Click "Distribute App"
2. Seleccionar "Ad Hoc"
3. Exportar IPA
4. Distribuir IPA directamente

---

## 📊 Matriz de Deployment

| Entorno | Android | iOS | Uso |
|---------|---------|-----|-----|
| **dev** | APK Debug | USB Install | Desarrollo diario |
| **staging** | APK Signed | TestFlight | QA/Testing |
| **prod** | AAB Play Store | App Store | Usuarios finales |

---

## 🔄 Workflow Recomendado

### Desarrollo Diario

```bash
# Opción 1: Hot-reload en dispositivo físico
./dev-mobile.sh              # Android
quasar dev -m capacitor -T ios  # iOS

# Opción 2: Build e instalar
./build-apk.sh debug install     # Android
./deploy-mobile.sh ios dev       # iOS
```

### Testing Interno (Equipo)

```bash
# Android: APK firmado vía Google Drive/Email
./deploy-mobile.sh android staging
# Compartir: releases/android/owfinance-staging-*.apk

# iOS: TestFlight
./deploy-mobile.sh ios staging
# Luego upload a TestFlight desde Xcode
```

### Release Producción

```bash
# Build ambas plataformas
./deploy-mobile.sh both prod

# Android: Subir AAB a Play Console
# iOS: Archive y distribuir desde Xcode
```

---

## 🎨 Personalización de Apps

### Iconos y Splash Screen

1. Crear iconos:
   - Android: 1024x1024 PNG
   - iOS: 1024x1024 PNG

2. Usar generador:
   ```bash
   npm install -g @capacitor/assets
   
   cd OWFinanceFrontend2025
   # Colocar icon.png y splash.png en resources/
   npx capacitor-assets generate
   ```

### Nombre de App

**Android**: `src-capacitor/android/app/src/main/res/values/strings.xml`
```xml
<string name="app_name">OwFinance</string>
```

**iOS**: En Xcode > General > Display Name

### Versionado

Editar: `OWFinanceFrontend2025/package.json`
```json
{
  "version": "1.0.0"
}
```

Sincronizar:
```bash
cd src-capacitor
npx cap sync
```

---

## 🔧 Troubleshooting

### Android

**Error: ANDROID_HOME no configurado**
```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
```

**Error: No se puede firmar APK**
- Verifica que el keystore existe
- Confirma passwords correctas

**Dispositivo no detectado**
```bash
./adb-tools.sh restart
./adb-tools.sh devices
```

### iOS

**Error: No se puede instalar en dispositivo**
- Verifica que el certificado está instalado
- Confiar en el desarrollador en el iPhone

**Error: CocoaPods no instalado**
```bash
sudo gem install cocoapods
```

**Error de firma**
- Verifica Apple Developer Account activo
- Re-genera certificados en Xcode

---

## 📱 Testing en Dispositivos Físicos

### Android

```bash
# Verificar dispositivo
./adb-tools.sh devices

# Instalar y ver logs
./build-apk.sh debug install
./adb-tools.sh logs
```

### iOS

```bash
# En Xcode:
# 1. Conectar iPhone
# 2. Seleccionar iPhone como destino
# 3. Product > Run

# Ver logs en tiempo real:
# Window > Devices and Simulators
# Seleccionar dispositivo > View Device Logs
```

---

## 🌐 Configuración Backend por Entorno

Crear archivos `.env.*` en `OWFinanceFrontend2025/`:

**`.env.development`**
```env
VITE_API_BASE_URL=http://localhost:8000/api
VITE_ENV=development
```

**`.env.staging`**
```env
VITE_API_BASE_URL=https://staging.tudominio.com/api
VITE_ENV=staging
```

**`.env.production`**
```env
VITE_API_BASE_URL=https://api.tudominio.com/api
VITE_ENV=production
```

---

## 📦 Checklist Pre-Release

### Android
- [ ] Keystore creado y respaldado
- [ ] build.gradle configurado con signing
- [ ] Versionado actualizado
- [ ] Probado en dispositivo físico
- [ ] AAB generado correctamente
- [ ] Google Play Console configurado

### iOS
- [ ] Apple Developer Account activo
- [ ] Certificados y profiles válidos
- [ ] Bundle ID correcto
- [ ] Versionado actualizado
- [ ] Probado en iPhone físico
- [ ] Archive exitoso
- [ ] App Store Connect configurado

### General
- [ ] Iconos y splash screens actualizados
- [ ] Variables de entorno correctas
- [ ] API backend accesible
- [ ] Testing completo
- [ ] Documentación actualizada

---

## 🆘 Soporte

**Errores comunes**: Ver sección Troubleshooting arriba

**Logs**:
- Android: `./adb-tools.sh logs`
- iOS: Xcode > Window > Devices and Simulators > View Device Logs

**Scripts disponibles**:
```bash
./deploy-mobile.sh help
./adb-tools.sh help
```

---

**Desarrollado con ❤️ para OWFINANCE**
