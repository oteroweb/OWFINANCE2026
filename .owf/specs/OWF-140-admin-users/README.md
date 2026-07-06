# OWF-140 — Admin: Gestión de Usuarios

**Hito:** Admin User Management  
**IDs:** OWF-140 … OWF-152  
**Estado:** SPEC LISTA — pendiente diseño + implementación

---

## Qué incluye este hito

| # | Módulo | Descripción |
|---|---|---|
| 1 | Lista de usuarios v2 | KPIs + filtros + tabla enriquecida + acciones inline |
| 2 | Detalle de usuario | Tabs: Perfil / Cuentas / Cántaros / Tx / Config / Tasas / Seguridad |
| 3 | Impersonación | Login-as con token temporal + banner + vuelta al admin |
| 4 | Gestión de credenciales | Cambio de contraseña, revocación de tokens, reset email |
| 5 | Sidebar Admin v2 | Secciones + íconos + badge usuarios |

---

## Archivos en esta carpeta

| Archivo | Para quién | Qué contiene |
|---|---|---|
| `SPEC.md` | Todos | Spec funcional completa, criterios de aceptación, restricciones |
| `API_CONTRACTS.md` | Backend dev | Endpoints, request/response JSON, errores |
| `BACKEND_TASKS.md` | Backend dev | Código PHP/Laravel de cada endpoint, rutas |
| `FRONTEND_TASKS.md` | Frontend dev | Estructura Vue, stores, componentes, router |
| `DESIGN_PROMPT.md` | Claude Design | Prompt completo para generar los mockups |

---

## Orden de implementación recomendado

```
1. Backend OWF-140 (impersonate)   ← P0, desbloquea OWF-147
2. Backend OWF-141 (detail)        ← necesario para OWF-146
3. Backend OWF-142+143+144         ← junto con el frontend del detalle
4. Frontend OWF-148 (sidebar v2)   ← puede hacerse independiente
5. Frontend OWF-145 (lista v2)     ← reemplaza index.vue existente
6. Frontend OWF-146 (detalle)      ← nueva vista, depende de OWF-141
7. Frontend OWF-147 (impersonation) ← depende de OWF-140
8. Tests OWF-151                   ← backend feature tests
9. Tests OWF-152                   ← e2e Playwright
```

---

## Cómo invocar al diseñador

Copiar el contenido de `DESIGN_PROMPT.md` y enviarlo a Claude Design (o al diseñador).  
El diseñador entregará mockups que el frontend dev usa como referencia para OWF-145/146/148.

---

## Notas de seguridad

- Impersonar admins está BLOQUEADO a nivel backend
- Token de impersonación expira en 2h (Sanctum `expiration`)
- Solo `role=admin` puede acceder a `/api/v1/admin/users/*`
- No hay migraciones de DB — todo usa tablas existentes
