# OWF-140 — Backend Tasks

**Contexto técnico:**
- Framework: Laravel 12 + Sanctum
- Auth middleware: `CheckRole:admin` (ya existe en `app/Http/Middleware/CheckMiddleware.php` o similar)
- Controladores admin viven en `app/Http/Controllers/Admin/`
- Rutas admin en `routes/api/admin.php`

---

## OWF-140 — POST /admin/users/:id/impersonate

**Archivo:** `app/Http/Controllers/Admin/UserAdminController.php` (nuevo)

```php
public function impersonate(Request $request, int $id): JsonResponse
{
    $target = User::findOrFail($id);

    // No impersonar admins
    if ($target->role && $target->role->slug === 'admin') {
        return response()->json(['status'=>'FAILED','code'=>403,'message'=>'No puedes impersonar un administrador'], 403);
    }

    if (!$target->active) {
        return response()->json(['status'=>'FAILED','code'=>422,'message'=>'Usuario inactivo'], 422);
    }

    // Token con scope impersonate — expira en 120 minutos
    $token = $target->createToken('impersonate', ['impersonate'], now()->addMinutes(120));

    return response()->json([
        'status' => 'OK',
        'code'   => 200,
        'message'=> 'Impersonación iniciada',
        'data'   => [
            'token'      => $token->plainTextToken,
            'user'       => $target->load('role', 'currency'),
            'expires_at' => $token->accessToken->expires_at,
        ],
    ]);
}
```

**Ruta:** `Route::post('/{id}/impersonate', [UserAdminController::class, 'impersonate']);`

---

## OWF-141 — GET /admin/users/:id/detail

```php
public function detail(Request $request, int $id): JsonResponse
{
    $user = User::with(['role', 'currency'])->findOrFail($id);

    $settings = UserSetting::where('user_id', $id)->first();

    $accounts = Account::with(['currency', 'accountType'])
        ->whereHas('users', fn($q) => $q->where('users.id', $id))
        ->get(['id','name','balance','currency_id','include_in_global_balance','active']);

    $jars = Jar::where('user_id', $id)
        ->get(['id','name','percent','type','active']);

    $recentTx = Transaction::with(['category','transactionType'])
        ->where('user_id', $id)
        ->orderByDesc('date')
        ->limit(20)
        ->get(['id','name','amount','date','category_id','transaction_type_id']);

    $tokensCount = $user->tokens()->count();

    $currencies = UserCurrency::with('currency')
        ->where('user_id', $id)
        ->get();

    return response()->json([
        'status' => 'OK',
        'code'   => 200,
        'data'   => [
            'user'                => $user,
            'settings'            => $settings,
            'accounts'            => $accounts,
            'jars'                => $jars,
            'recent_transactions' => $recentTx,
            'security'            => [
                'tokens_count' => $tokensCount,
                'last_login'   => $user->updated_at,
            ],
            'currencies'          => $currencies,
        ],
    ]);
}
```

---

## OWF-142 — PUT /admin/users/:id/password

```php
public function changePassword(Request $request, int $id): JsonResponse
{
    $user = User::findOrFail($id);

    $request->validate([
        'password' => 'required|string|min:8|confirmed',
    ]);

    $user->password = Hash::make($request->password);
    $user->save();

    return response()->json(['status'=>'OK','code'=>200,'message'=>'Contraseña actualizada correctamente']);
}
```

---

## OWF-143 — DELETE /admin/users/:id/tokens

```php
public function revokeTokens(Request $request, int $id): JsonResponse
{
    $user = User::findOrFail($id);
    $count = $user->tokens()->count();
    $user->tokens()->delete();

    return response()->json([
        'status' => 'OK',
        'code'   => 200,
        'message'=> "{$count} tokens revocados",
        'data'   => ['revoked_count' => $count],
    ]);
}
```

---

## OWF-144 — POST /admin/users/:id/reset-password-email

```php
public function sendResetEmail(Request $request, int $id): JsonResponse
{
    $user = User::findOrFail($id);
    $token = Password::createToken($user);
    $user->notify(new ResetPasswordNotification($token));

    return response()->json([
        'status'  => 'OK',
        'code'    => 200,
        'message' => "Email de restablecimiento enviado a {$user->email}",
    ]);
}
```

---

## Registro de rutas

En `routes/api/admin.php`, dentro del grupo `CheckRole:admin`:

```php
use App\Http\Controllers\Admin\UserAdminController;

Route::prefix('users')->group(function () {
    // Existing
    Route::get('/',          [UserController::class, 'all']);
    Route::get('/active',    [UserController::class, 'allActive']);
    Route::get('/{id}',      [UserController::class, 'find']);
    Route::post('/',         [UserController::class, 'save']);
    Route::put('/{id}',      [UserController::class, 'update']);
    Route::patch('/{id}/status', [UserController::class, 'change_status']);
    Route::delete('/{id}',   [UserController::class, 'delete']);

    // NEW
    Route::get('/{id}/detail',                [UserAdminController::class, 'detail']);
    Route::post('/{id}/impersonate',          [UserAdminController::class, 'impersonate']);
    Route::put('/{id}/password',              [UserAdminController::class, 'changePassword']);
    Route::delete('/{id}/tokens',             [UserAdminController::class, 'revokeTokens']);
    Route::post('/{id}/reset-password-email', [UserAdminController::class, 'sendResetEmail']);
});
```

---

## Lista de todos los modelos involucrados (ya existen)

| Modelo | Tabla | Namespace |
|---|---|---|
| `User` | `users` | `App\Models\User` |
| `Role` | `roles` | `App\Models\Role` |
| `Account` | `accounts` | `App\Models\Entities\Account` |
| `Jar` | `jars` | `App\Models\Entities\Jar` |
| `Transaction` | `transactions` | `App\Models\Entities\Transaction` |
| `UserSetting` | `user_settings` | `App\Models\Entities\UserSetting` |
| `UserCurrency` | `user_currencies` | `App\Models\Entities\UserCurrency` |

**No hay migraciones nuevas.**
