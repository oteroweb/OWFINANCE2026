# OWF-140 — API Contracts

**Base:** `POST|GET|PUT|DELETE /api/v1/admin/users/...`  
**Middleware:** `auth:sanctum` + `CheckRole:admin`

---

## GET /admin/users

Lista paginada de usuarios con campos enriquecidos.

### Query params
| Param | Tipo | Default | Descripción |
|---|---|---|---|
| `page` | int | 1 | Página |
| `per_page` | int | 20 | Items por página |
| `search` | string | — | Busca en name + email |
| `role` | string | — | Slug del rol: `admin`, `user` |
| `active` | bool | — | Filtra por activo |
| `plan` | string | — | `lite` o `pro` (del campo `layout_mode` en settings) |
| `sort_by` | string | `created_at` | Campo de orden |
| `descending` | bool | true | Orden desc |

### Response 200
```json
{
  "status": "OK",
  "code": 200,
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 42,
        "name": "Juan Pérez",
        "email": "juan@example.com",
        "phone": "+58 412 123 4567",
        "active": true,
        "role": { "id": 2, "slug": "user", "name": "User" },
        "currency": { "id": 1, "code": "USD", "name": "Dólar" },
        "layout_mode": "lite",
        "created_at": "2026-01-15T10:30:00Z",
        "last_login": "2026-06-28T08:15:00Z",
        "tokens_count": 2,
        "accounts_count": 3,
        "jars_count": 5
      }
    ],
    "total": 127,
    "per_page": 20,
    "last_page": 7
  },
  "kpis": {
    "total_users": 127,
    "active_today": 12,
    "registered_this_month": 8,
    "pro_count": 23
  }
}
```

---

## GET /admin/users/:id/detail

Perfil completo del usuario con entidades relacionadas.

### Response 200
```json
{
  "status": "OK",
  "code": 200,
  "data": {
    "user": {
      "id": 42,
      "name": "Juan Pérez",
      "email": "juan@example.com",
      "phone": "+58 412 123 4567",
      "city": "Caracas",
      "country": "VE",
      "occupation": "Ingeniero",
      "birthdate": "1990-05-15",
      "active": true,
      "role": { "id": 2, "slug": "user", "name": "User" },
      "currency": { "id": 1, "code": "USD", "name": "Dólar" },
      "created_at": "2026-01-15T10:30:00Z",
      "email_verified_at": "2026-01-15T10:31:00Z"
    },
    "settings": {
      "layout_mode": "lite",
      "notifications": true,
      "strict_budget": false,
      "monthly_income": 15000.00,
      "financial_goal": "saving"
    },
    "accounts": [
      {
        "id": 1,
        "name": "Cuenta Principal",
        "balance": 45230.00,
        "currency": { "code": "USD" },
        "account_type": { "name": "Corriente" },
        "active": true,
        "include_in_global_balance": true
      }
    ],
    "jars": [
      {
        "id": 3,
        "name": "Necesidades",
        "percent": 55.0,
        "type": "percent",
        "balance": 24876.50,
        "active": true
      }
    ],
    "recent_transactions": [
      {
        "id": 100,
        "name": "Walmart",
        "amount": -234.50,
        "date": "2026-06-27",
        "category": { "name": "Alimentos" },
        "transaction_type": { "name": "Gasto" }
      }
    ],
    "security": {
      "tokens_count": 2,
      "last_login": "2026-06-28T08:15:00Z",
      "password_changed_at": null
    },
    "currencies": [
      {
        "id": 5,
        "currency": { "code": "VES", "name": "Bolívar" },
        "current_rate": 40.50,
        "is_current": true,
        "is_official": false,
        "updated_at": "2026-06-25T12:00:00Z"
      }
    ]
  }
}
```

---

## POST /admin/users/:id/impersonate

Genera un token de impersonación para el usuario target.

### Request
```json
{}
```

### Response 200
```json
{
  "status": "OK",
  "code": 200,
  "message": "Impersonación iniciada",
  "data": {
    "token": "42|AbCdEf...",
    "user": {
      "id": 42,
      "name": "Juan Pérez",
      "email": "juan@example.com",
      "role": { "slug": "user" },
      "layout_mode": "lite"
    },
    "expires_at": "2026-06-28T10:00:00Z"
  }
}
```

### Errores
| Código | Cuándo |
|---|---|
| 403 | El target también es admin |
| 404 | Usuario no encontrado |
| 422 | Usuario inactivo o eliminado |

---

## PUT /admin/users/:id/password

Cambiar contraseña de un usuario desde el admin (sin conocer la actual).

### Request
```json
{
  "password": "NuevaContrasena123!",
  "password_confirmation": "NuevaContrasena123!"
}
```

### Validaciones
- `password`: requerido, mínimo 8 caracteres, confirmado

### Response 200
```json
{
  "status": "OK",
  "code": 200,
  "message": "Contraseña actualizada correctamente"
}
```

---

## DELETE /admin/users/:id/tokens

Revocar todos los tokens (personal_access_tokens) del usuario.

### Response 200
```json
{
  "status": "OK",
  "code": 200,
  "message": "3 tokens revocados",
  "data": { "revoked_count": 3 }
}
```

---

## POST /admin/users/:id/reset-password-email

Enviar email de restablecimiento de contraseña al usuario.

### Request
```json
{}
```

### Response 200
```json
{
  "status": "OK",
  "code": 200,
  "message": "Email de restablecimiento enviado a juan@example.com"
}
```

### Errores
| Código | Cuándo |
|---|---|
| 422 | Email no verificado |
| 503 | SMTP no configurado en prod |

---

## PUT /admin/users/:id (existente, mejorado)

Actualización de perfil desde admin — igual que el endpoint existente, añade `role_id`.

### Request body adicional vs el actual
```json
{
  "role_id": 2
}
```
