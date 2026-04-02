# 🌐 Estrategia de Configuración Multi-Entorno

## 📁 Archivos de Configuración

Tu proyecto ahora tiene múltiples archivos `.env` para diferentes escenarios:

### `.env.local`
- **Backend:** `http://localhost:8000/api/v1` (tu máquina)
- **Uso:** Desarrollo web en navegador con backend local
- **Cuándo:** Estás desarrollando y probando en tu navegador

### `.env.remote`
- **Backend:** `https://appfinanzas.blockshift.website/api/v1`
- **Uso:** Desarrollo web en navegador con backend remoto
- **Cuándo:** Quieres probar contra el servidor de producción desde el navegador

### `.env.mobile`
- **Backend:** `https://appfinanzas.blockshift.website/api/v1`
- **Uso:** Desarrollo de apps móviles (Android/iOS)
- **Cuándo:** Compilas o pruebas en dispositivos móviles
- **Por qué:** Los dispositivos físicos no pueden acceder a `localhost`

### `.env.production`
- **Backend:** `https://appfinanzas.blockshift.website/api/v1`
- **Uso:** Builds finales para publicar en tiendas
- **Cuándo:** Generas APK/IPA para distribución

---

## 🔄 Cómo Cambiar Entre Configuraciones

### Opción 1: Script Rápido (Recomendado)

```bash
# Desarrollo local (navegador + backend local)
./switch-env.sh local

# Desarrollo web con backend remoto
./switch-env.sh remote

# Desarrollo móvil (siempre usa remoto)
./switch-env.sh mobile

# Producción
./switch-env.sh production
```

### Opción 2: Manual

```bash
# Copiar el archivo que necesitas
cp OWFinanceFrontend2025/.env.local OWFinanceFrontend2025/.env
# O
cp OWFinanceFrontend2025/.env.mobile OWFinanceFrontend2025/.env
```

---

## 🎯 Flujos de Trabajo

### 1️⃣ **Desarrollo Web Local (Backend + Frontend)**

```bash
# Configurar backend local
./switch-env.sh local

# Iniciar todo
./dev-start.sh
```

- **Backend:** http://localhost:8000
- **Frontend:** http://localhost:3000
- **Base de datos:** Local (SQLite o MySQL local)

---

### 2️⃣ **Desarrollo Web con Backend Remoto**

```bash
# Configurar backend remoto
./switch-env.sh remote

# Solo iniciar frontend
cd OWFinanceFrontend2025
npm run dev
```

- **Backend:** https://appfinanzas.blockshift.website
- **Frontend:** http://localhost:3000
- **Base de datos:** Servidor remoto

---

### 3️⃣ **Desarrollo Móvil Android (Hot-Reload)**

```bash
# La configuración se aplica automáticamente
./dev-mobile.sh
```

El script `dev-mobile.sh` automáticamente:
- Copia `.env.mobile` → `.env`
- Usa backend remoto
- Inicia hot-reload en tu dispositivo

**Ventaja:** Cada cambio en el código se refleja instantáneamente en tu Redmi Note 8 Pro

---

### 4️⃣ **Build APK/IPA para Testing**

```bash
# Android
./deploy-mobile.sh android dev

# iOS
./deploy-mobile.sh ios dev

# Ambos
./deploy-mobile.sh both dev
```

El script automáticamente usa `.env.mobile` (backend remoto)

---

### 5️⃣ **Build para Producción (Tiendas)**

```bash
# Primero, actualiza .env.production con tu API key real
# Luego:

./deploy-mobile.sh both prod
```

---

## 🔍 Verificar Configuración Actual

```bash
# Ver qué backend está configurado
cat OWFinanceFrontend2025/.env | grep VITE_API_BASE_URL

# O más detallado
./switch-env.sh
```

---

## 📱 Resolución de Problemas Comunes

### ❌ "La app no conecta en el móvil"

**Problema:** Estás usando `.env.local` (localhost) en el móvil

**Solución:**
```bash
./switch-env.sh mobile
./deploy-mobile.sh android dev
```

### ❌ "Quiero probar con mi backend local desde el móvil"

**Opción A:** Usar tu IP local (dentro de la misma red WiFi)

```bash
# Encontrar tu IP
ifconfig | grep "inet " | grep -v 127.0.0.1

# Crear .env.mobile-local
cat > OWFinanceFrontend2025/.env.mobile-local << EOF
VITE_API_BASE_URL=http://TU_IP_LOCAL:8000/api/v1
VITE_API_KEY=dev-key-local
VITE_ENV=mobile-local
EOF

# Aplicar
cp OWFinanceFrontend2025/.env.mobile-local OWFinanceFrontend2025/.env
./deploy-mobile.sh android dev
```

**Ejemplo:** Si tu IP es `192.168.1.100`
```
VITE_API_BASE_URL=http://192.168.1.100:8000/api/v1
```

**Opción B:** Usar ngrok para exponer localhost

```bash
# En una terminal
cd OWFINANCEBackend2025
php artisan serve

# En otra terminal
ngrok http 8000

# Usar la URL de ngrok en .env.mobile
VITE_API_BASE_URL=https://abc123.ngrok.io/api/v1
```

---

## 🗂️ Resumen de Comandos

| Quiero... | Comando |
|-----------|---------|
| Desarrollo web local | `./switch-env.sh local && ./dev-start.sh` |
| Desarrollo web remoto | `./switch-env.sh remote && cd OWFinanceFrontend2025 && npm run dev` |
| Probar en móvil (hot-reload) | `./dev-mobile.sh` |
| Generar APK de prueba | `./deploy-mobile.sh android dev` |
| Build producción | `./switch-env.sh production && ./deploy-mobile.sh both prod` |
| Ver configuración actual | `cat OWFinanceFrontend2025/.env` |

---

## 🔐 Seguridad

**⚠️ IMPORTANTE:** 

- ✅ `.env` está en `.gitignore` (no se sube a Git)
- ✅ Los archivos `.env.*` con configuraciones de ejemplo están en Git
- ⚠️ Cambia `VITE_API_KEY` en `.env.production` antes de publicar
- ⚠️ No subas archivos `.env` con credenciales reales a Git

---

## 📊 Diagrama de Flujo

```
┌─────────────────┐
│ ¿Dónde pruebo?  │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐  ┌──▼────┐
│ Web   │  │ Móvil │
└───┬───┘  └──┬────┘
    │         │
┌───▼───────┐ │
│ ¿Backend? │ │
└───┬───────┘ │
    │         │
┌───┴───┐     │
│       │     │
▼       ▼     ▼
Local  Remoto Remoto
.env.  .env.  .env.
local  remote mobile
```

---

**Desarrollado con ❤️ para OWFINANCE**
