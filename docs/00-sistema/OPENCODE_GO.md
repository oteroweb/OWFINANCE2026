# OpenCode Go — Referencia de integración

> Servicio de acceso a modelos open-source de alto rendimiento por suscripción.
> **$5 primer mes → $10/mes**. Política zero-retention. Servidores: US, EU, Singapur.

---

## Endpoints (compatibles con OpenAI y Anthropic)

| Formato | URL |
|---------|-----|
| OpenAI-compatible  | `https://opencode.ai/zen/go/v1/chat/completions` |
| Anthropic-compatible | `https://opencode.ai/zen/go/v1/messages` |
| Listar modelos | `https://opencode.ai/zen/go/v1/models` |

## Autenticación

```
# OpenAI-compatible
Authorization: Bearer {TU_API_KEY}

# Anthropic-compatible
x-api-key: {TU_API_KEY}
```

## Modelos disponibles (14 total)

| Modelo | ID | Formato |
|--------|-----|---------|
| GLM-5 | `glm-5` | OpenAI |
| GLM-5.1 | `glm-5.1` | OpenAI |
| Kimi K2.5 | `kimi-k2.5` | OpenAI |
| Kimi K2.6 | `kimi-k2.6` | OpenAI |
| DeepSeek V4 Pro | `deepseek-v4-pro` | OpenAI |
| DeepSeek V4 Flash | `deepseek-v4-flash` | OpenAI (más barato, ~158k req/mes) |
| MiMo variants | `mimo-*` | OpenAI |
| MiniMax M3 | `minimax-m3` | Anthropic |
| MiniMax M-series | `minimax-m*` | Anthropic |
| Qwen3.6 | `qwen3.6` | Anthropic |
| Qwen3.7 Max | `qwen3.7-max` | Anthropic |

**Formato de configuración en OpenCode CLI:** `opencode-go/<model-id>`
Ejemplo: `opencode-go/kimi-k2.6`

## Límites de uso

| Ventana | Límite valor |
|---------|-------------|
| 5 horas | $12 |
| Semanal | $30 |
| Mensual | $60 |

---

## Uso desde Laravel (laravel/ai o prism)

Como los endpoints son **compatibles con OpenAI**, se configuran como un proveedor OpenAI
apuntando a la URL base de OpenCode Go:

### Con `laravel/ai` (oficial Laravel 12+)

```php
// config/ai.php
'providers' => [
    'opencode-go' => [
        'driver'   => 'openai',
        'base_url' => 'https://opencode.ai/zen/go/v1',
        'api_key'  => env('OPENCODE_GO_API_KEY'),
    ],
],
'default_provider' => env('AI_PROVIDER', 'opencode-go'),
```

```php
// Uso
Ai::using('opencode-go')
  ->withModel('deepseek-v4-flash')
  ->prompt('Analiza mis gastos del mes');
```

### Con `echolabsdev/prism`

```php
use EchoLabs\Prism\Prism;
use EchoLabs\Prism\Enums\Provider;

Prism::text()
    ->using('opencode-go', 'kimi-k2.6')
    ->withSystemPrompt('Eres el asesor financiero de OWFINANCE...')
    ->withPrompt($userMessage)
    ->generate();
```

### Curl directo (prueba rápida)

```bash
curl https://opencode.ai/zen/go/v1/chat/completions \
  -H "Authorization: Bearer $OPENCODE_GO_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-v4-flash",
    "messages": [{"role":"user","content":"Hola"}]
  }'
```

---

## Variables de entorno para OWFINANCE

```env
# .env del backend
OPENCODE_GO_API_KEY=tu_clave_aqui
AI_PROVIDER=opencode-go          # openai | anthropic | opencode-go | groq | gemini
AI_EXTRACTION_PROVIDER=opencode-go
AI_ADVISOR_PROVIDER=opencode-go
```

---

## Ventaja sobre OpenAI directo

| | OpenAI GPT-4o | OpenCode Go DeepSeek Flash |
|---|---|---|
| Costo | Por token (caro) | $10/mes flat |
| Privacidad | Retención por defecto | Zero-retention |
| Vendor lock-in | Alto | No (multi-proveedor) |
| Modelos | GPT familia | DeepSeek, Kimi, Qwen, GLM |

---

## Configurar en OpenCode CLI

```bash
# En el TUI de opencode
/connect   # conectar con la API key
/models    # listar modelos disponibles
```

O en `~/.config/opencode/opencode.jsonc`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "opencode-go": {
      "api_key": "tu_clave_aqui",
      "base_url": "https://opencode.ai/zen/go/v1"
    }
  },
  "model": "opencode-go/kimi-k2.6"
}
```

> Fuente: https://opencode.ai/docs/es/go — leído 2026-06-10
