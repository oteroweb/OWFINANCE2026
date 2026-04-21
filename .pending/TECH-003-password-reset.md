# TECH-003 — Flujo de Password Reset

**Tipo**: Trabajo técnico (IA puede ejecutar)
**Prioridad**: Media (necesario antes de abrir a usuarios reales)
**Tiempo estimado IA**: 1 hora

## Contexto

No existe flujo de recuperación de contraseña. Necesario para MVP público.

## Qué construir

### Backend (Laravel 11)
Laravel tiene Password Reset built-in. Solo necesita:
1. Verificar que `password_reset_tokens` tabla existe (migración default de Laravel)
2. Configurar mail en `.env` (MAIL_MAILER, MAIL_HOST, etc.)
3. Exponer rutas (normalmente ya en `routes/auth.php` o similar)
4. Verificar que `User` model usa `CanResetPassword` trait

### Frontend
1. Página `src/pages/auth/ForgotPasswordPage.vue` — input email + submit
2. Página `src/pages/auth/ResetPasswordPage.vue` — input nueva password + token en URL
3. Rutas en `src/router/routes.ts` (públicas, sin auth guard)
4. Links desde LoginPage

## Notas
- SMTP recomendado para staging: Mailtrap (gratis) o Resend
- Para producción: Resend o SES
