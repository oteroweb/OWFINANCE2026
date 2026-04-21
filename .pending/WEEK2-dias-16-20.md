# WEEK2 — Días 16-20 del Calendario MVP

## Día 16: Android build (Capacitor)

```bash
cd OWFinanceFrontend2025
npm run build
npx cap sync android
npx cap open android
```

- Verificar que Capacitor plugins funcionan: speech recognition, push notifications
- Generar APK de debug para testing interno
- Probar en dispositivo físico Android

## Día 17: Bulk Import (BUG-001 a BUG-005 — diferidos)

Ver `/Users/joseluisoterolopez/Desktop/dev/OWFINANCE2026/.pending/BUGS-diferidos.md`

## Día 18: PRO layout — páginas internas

ProLayout está cableado pero las páginas que carga son stubs.
Verificar y construir:
- Dashboard PRO con gráficas (recharts o Chart.js)
- Vista tabla de transacciones (paginated, filtrable)
- Vista de jars/cuentas

## Día 19: Analytics básico

- Integrar Plausible (self-hosted, GDPR-friendly) o Umami
- Eventos clave a trackear:
  - transaction_created (con source: manual/voice/ocr/auto_ia)
  - advisor_message_sent
  - export_downloaded

## Día 20: Review final pre-lanzamiento

- Audit de seguridad (revisar headers HTTP, CORS config)
- Revisar que APP_DEBUG=false en producción
- Verificar que no hay console.log sensibles en frontend
- Generar APK de release (firmado)
- ToS y Privacy Policy (páginas estáticas)
