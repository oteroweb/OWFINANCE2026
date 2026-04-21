# TECH-001 — Frontend: Página de Configuración del Asesor IA

**Tipo**: Trabajo técnico (IA puede ejecutar)
**Prioridad**: Media
**Tiempo estimado IA**: 1-2 horas

## Contexto

El backend ya tiene `AiUserSetting` model y migración con estos campos:
- advisor_name (string) — nombre del asesor
- advisor_personality (enum: formal/friendly/coach)
- voice_enabled, ocr_enabled, auto_ia_enabled, advisor_enabled (booleans)
- monthly_budget_alert (decimal, nullable)
- preferred_currency (string)
- context_window_months (tinyint)

NO existe endpoint CRUD para estos settings ni página frontend.

## Qué construir

### Backend
1. Endpoint `GET /api/v1/ai/settings` → devuelve ai_user_settings del usuario auth
2. Endpoint `PUT /api/v1/ai/settings` → actualiza ai_user_settings
3. Crear `AiSettingsController` en `app/Http/Controllers/AI/`
4. Registrar rutas en `routes/api/ai.php`
5. Invalidar cache `ai_user_context_{user_id}` en Redis al actualizar

### Frontend
1. Página `src/pages/AiSettingsPage.vue`
   - Toggle switches para voice/ocr/auto_ia/advisor
   - Input para advisor_name
   - Select para advisor_personality (Formal/Amigable/Coach)
   - Input numérico para monthly_budget_alert
   - Select para preferred_currency
2. Ruta `/user/ai-settings`
3. Link desde AsesorPage.vue (ícono engranaje en toolbar)
4. Composable `src/composables/useAiSettings.ts`

## Convenciones del proyecto

- Backend models: `App\Models\Entities\` namespace
- Controllers: `App\Http\Controllers\AI\`
- Routes: `routes/api/ai.php` (ya existe, agregar rutas ahí)
- Frontend: Vue 3 + Quasar 2.16 + TypeScript + Pinia
- API client: importar `api` desde `src/boot/axios`
