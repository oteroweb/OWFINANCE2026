# Diseño (borrador) — Voice/Auto IA conversacional con slot-filling

**Estado:** borrador de diseño, sin implementar. Pedido por el usuario 2026-07-14 para
tener en cuenta antes de seguir tocando el flujo de IA de transacciones.

## Problema

Hoy `POST /ai/extract-transaction` es **stateless y single-shot**: manda todo el texto/audio
de una, la IA devuelve lo que pudo extraer, y si falta algo (ej. `account_id`) el usuario
tiene que corregirlo a mano en el formulario tras el preview. No hay pregunta de vuelta.

Ejemplo real:
- "Gasté 15 dólares en dulces con Banesco" → todo resuelto, no hace falta preguntar nada.
- "Gasté 15 dólares" → falta la cuenta. Si el usuario es Pro con 2+ cuentas, hoy la IA
  simplemente no llena `account_id` y el usuario tiene que elegirla manualmente en el
  formulario — no hay ida y vuelta conversacional, se pierde la fluidez de "hablar y listo".

## Objetivo

Simular una conversación corta (pocos turnos) que solo pregunte lo mínimo indispensable
antes de llegar a la tarjeta de confirmación que ya existe ("Vas a registrar... ¿confirmas?").
No es un chat abierto — es *slot-filling* dirigido: la IA sabe qué campos le faltan y
pregunta solo eso, de la forma más barata posible (preferir botones/chips sobre otra
grabación de voz).

## 1. Campos mínimos por tipo de transacción

| Tipo | Campos obligatorios | Quién los resuelve |
|---|---|---|
| Gasto / Ingreso | `amount`, `account_id` | IA (monto casi siempre está en el texto) + usuario si falta cuenta |
| Transferencia | `amount`, `account_from_id`, `account_to_id` | Igual, pero son 2 cuentas a resolver, no 1 |
| Ajuste | `account_id`, `target_balance` | Casi siempre requiere pregunta (rara vez se dice de forma natural) |

`description`/`category_suggestion`/`date` siempre son opcionales — tienen fallback
razonable (fecha = hoy, categoría = "Sin categoría", descripción = lo que se entendió).
**Nunca preguntar por estos** — solo por lo verdaderamente bloqueante para guardar.

## 2. Resolución de cuenta: Lite vs Pro

- **Lite**: en la práctica un usuario Lite normalmente tiene 1 sola cuenta activa (el
  layout Lite ya simplifica todo a una sola vista de saldo). Regla: **si el usuario tiene
  exactamente 1 cuenta, auto-asignarla sin preguntar nunca**, sin importar si es Lite o Pro.
  Si por algún motivo un Lite tiene 2+ cuentas (no debería ser el caso típico, pero no está
  bloqueado a nivel de datos), aplica la misma regla que Pro.
- **Pro**: el usuario puede tener 2+ cuentas (confirmado con datos reales: el usuario de
  prueba tiene 2 — USD y VES). Regla:
  1. Si el texto menciona algo que matchea el `name` de una cuenta (ej. "con Banesco" si la
     cuenta se llama "Banesco Ahorro") → asignar esa cuenta, sin preguntar.
  2. Si no hay match y hay 2+ cuentas → **preguntar**, mostrando las cuentas como opciones
     (chips con nombre + saldo + moneda), no como texto libre.
  3. Si no hay match pero solo hay 1 cuenta → auto-asignar (caso ya cubierto arriba).

  **Gap de datos detectado**: `Account` (backend) hoy solo tiene el campo `name` — no hay
  `bank_name`/`alias` separado. El matching "con Banesco" depende de que el usuario haya
  puesto esa palabra en el nombre de la cuenta. Si se quiere un matching más robusto
  (reconocer "Banesco" aunque la cuenta se llame "Cuenta corriente 1234"), haría falta
  agregar un campo de banco/alias al modelo — **no resuelto en este borrador, a decidir**.

## 3. Estado de la conversación (slot-filling)

Necesitamos un objeto "borrador de transacción" que persista entre turnos — hoy cada
llamada a `/ai/extract-transaction` es independiente y no sabe nada de la anterior.

Propuesta de contrato nuevo (extiende el endpoint actual, no lo reemplaza):

```
POST /ai/extract-transaction
{ source: "voice"|"auto", audio?, input?, draft_id?: number }

Respuesta:
{
  draft_id: number,          // nuevo — identifica el borrador en curso
  data: { type, amount, currency, description, category_suggestion, date, confidence, account_id },
  missing_fields: string[],  // nuevo — ej. ["account_id"], vacío si ya se puede confirmar
  missing_field_options?: {  // nuevo — solo si falta account_id/account_from_id/account_to_id
    field: "account_id",
    options: [{ id: 42, label: "Billetera USD", balance: "$346.80" }, ...]
  },
  transcript?: string,       // ya existe (OWF-311)
}
```

Segunda llamada (el usuario tocó una cuenta, no volvió a grabar):

```
POST /ai/extract-transaction/answer
{ draft_id: 123, field: "account_id", value: 42 }
```

Esta ruta **NO llama a la IA** — solo mergea la respuesta en el draft guardado (ej. tabla
nueva `ai_extraction_drafts` o reusar `ai_extractions` con una columna `missing_fields`/
`resolved`) y recalcula `missing_fields` en PHP puro. Si ya no falta nada, devuelve
`missing_fields: []` y el frontend pasa directo a la tarjeta de confirmación existente.
**Esto es clave para no gastar una llamada de IA por cada tap de botón** — la única llamada
cara es la primera (transcripción + extracción inicial).

Si lo que falta es algo que sí necesita texto libre (raro, pero posible — ej. el usuario
dice algo ambiguo tipo "gasté en el súper" sin monto), ahí sí se permite otra grabación
corta o un input de texto, y ESA sí vuelve a pasar por la IA con el draft existente como
contexto (el system prompt incluye lo ya resuelto + lo que falta, para no reprocesar todo).

## 4. System prompt — cambios necesarios

Hoy el prompt no sabe nada de las cuentas del usuario. Habría que:
1. Pasarle al modelo la lista de cuentas del usuario (id, nombre, moneda) en el system
   prompt cuando el tipo no es `ajuste` transferencia (para que intente el match de nombre
   él mismo, ej. "con Banesco" → id correcto, sin lógica de fuzzy-matching aparte en PHP).
2. Pedirle explícitamente que devuelva `"account_id": null` (no inventar) si no está seguro,
   en vez de adivinar — el `missing_fields` en el backend se deriva de qué vino `null`.
3. Mantener el schema de salida simple (seguimos con JSON plano, no tool-calling) para no
   tocar el parser (`AiProviderChain::parseJsonContent`) ni el fallback entre proveedores.

## 5. UI (SmartTransactionModal.vue / panel Voz y Auto IA)

Estado nuevo por manejar: `missingField: 'account_id' | 'account_from_id' | null`.

- Si `missing_fields` viene vacío → comportamiento actual, sin cambios (va directo a la
  tarjeta "Vas a registrar").
- Si falta `account_id` → en vez de la tarjeta de confirmación, mostrar una fila de chips
  con las cuentas del usuario (ya existe `filteredAccountOptions` en el modal, reusable) +
  el texto "¿Con qué cuenta fue?". Tap → `POST .../answer` → re-render.
- Sin necesidad de reabrir el micrófono para esto — es la parte que hace que se sienta
  "conversación liviana" sin ser un chat real ni pedirle al usuario que hable de nuevo por
  algo tan simple como elegir una cuenta.

## 6. Costo/latencia

- Cada extracción inicial ya es 1-2 llamadas a Groq (Whisper si es voz + Llama para
  extraer) — ínfimo en costo (ver OWF-312, Groq $0.59-0.79/M tokens).
- Las respuestas a preguntas de cuenta (chips) **no llaman a la IA** — son instantáneas y
  gratis, resueltas en PHP. Solo un follow-up de texto/voz libre generaría otra llamada,
  y eso debería ser el caso raro, no el común.

## 7. Alcance y siguiente paso

Esto es un cambio de arquitectura mediano: nueva tabla o columnas para el draft, nuevo
endpoint `/answer`, cambios de UI con estado conversacional, ajuste del system prompt.
No es un fix de una línea. Cuando se decida encarar, correspondería `/sdd-new
voice-conversational-extraction` para spec/diseño formal antes de tocar código, siguiendo
el protocolo del proyecto — este documento es el insumo de partida para esa spec, no la
spec en sí.

**No implementado. Sin cambios de código en esta tarea.**
