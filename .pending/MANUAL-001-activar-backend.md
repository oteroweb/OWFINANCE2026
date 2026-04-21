# MANUAL-001 — Activar Backend AI (BLOQUEANTE)

**Tipo**: Acción manual — no puede hacerlo la IA
**Prioridad**: URGENTE — sin esto el backend AI no funciona
**Tiempo estimado**: 15 minutos

## Paso 1: Elegir proveedor AI y obtener API key

### Opción A — Groq (GRATIS, recomendado para arrancar)
1. Ir a https://console.groq.com
2. Crear cuenta (gratis)
3. Dashboard → API Keys → Create API Key
4. Copiar la key (empieza con `gsk_`)

### Opción B — Anthropic Claude (mejor calidad español, ~$5)
1. Ir a https://console.anthropic.com
2. Crear cuenta
3. Billing → Add $5 de crédito
4. API Keys → Create Key
5. Copiar la key (empieza con `sk-ant-`)

### Opción C — Gemini (gratis hasta límites generosos)
1. Ir a https://aistudio.google.com
2. Get API Key → Create API Key
3. Copiar la key (empieza con `AI`)

## Paso 2: Editar .env del backend

Archivo: `OWFINANCEBackend2025/.env`

Si usas Groq:
```env
AI_EXTRACTION_PROVIDER=groq
AI_ADVISOR_PROVIDER=groq
GROQ_API_KEY=gsk_TU_KEY_AQUI
```

Si usas Anthropic:
```env
AI_EXTRACTION_PROVIDER=anthropic
AI_ADVISOR_PROVIDER=anthropic
ANTHROPIC_API_KEY=sk-ant-TU_KEY_AQUI
```

Si usas Gemini:
```env
AI_EXTRACTION_PROVIDER=gemini
AI_ADVISOR_PROVIDER=gemini
GEMINI_API_KEY=AI_TU_KEY_AQUI
```

## Paso 3: Ejecutar migraciones

```bash
cd OWFINANCEBackend2025
php artisan migrate --force
```

Esperado: 5 migraciones nuevas ejecutadas
- create_ai_user_settings_table
- create_ai_extractions_table
- create_ai_conversations_table
- create_ai_conversation_messages_table
- create_ai_usage_log_table

## Paso 4: Ejecutar seeder

```bash
php artisan db:seed --class=AiUserSettingsSeeder
```

Esperado: mensaje "AiUserSettings seeded for all existing users."

## Verificación

```bash
# Probar endpoint (ajusta el token)
curl -X POST http://localhost:8000/api/v1/ai/extract-transaction \
  -H "Authorization: Bearer TU_TOKEN_SANCTUM" \
  -H "Content-Type: application/json" \
  -d '{"source":"auto","input":"gasté 50 pesos en el supermercado"}'

# Respuesta esperada:
# {"extraction_id":1,"data":{"type":"expense","amount":50,"currency":"USD","description":"Supermercado","confidence":0.95},...}
```

## Si hay error

- Error "AI provider not configured" → el .env no tiene la key
- Error 401 → no estás enviando el Bearer token de Sanctum
- Error de migración → verificar que la DB esté corriendo
