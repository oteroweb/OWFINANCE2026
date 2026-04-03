# Fuentes de Maquetas y Master UI (Stitch)

Este documento define los proyectos y pantallas de Stitch que actúan como la **Fuente de Verdad** para el desarrollo visual de OW Finance 2026. Los agentes y desarrolladores deben consultar estos IDs antes de realizar cambios en la UI.

## Proyecto Principal
**Nombre:** OW Finance 2026 — Master UI [Definitivo]  
**ID:** `5968657237763273187`  
**Estilo:** Liquid Editorial / Dark Mode (Mobile Optimized)

---

## Mapeo de Pantallas (Lite Mode)

| Componente / Vista | Título en Stitch | Screen ID | Contexto |
|---|---|---|---|
| **Dashboard Home** | OW Finance Dashboard Lite | `c5c8b5d5104a426a9db806f612bce86b` | Vista principal con Saludo, Balance y Cards. |
| **Cántaros (Jars)** | Cántaros - Mobile Lite | `1a0a89c7aa9e464daf857858cf8d2750` | Gestión de ahorros y objetivos visuales. |
| **Transacciones** | Transactions - Mobile Lite | `6113b935ed1f4d92bffd83e422bdcc40` | Listado editorial de movimientos. |
| **Menú / Nav** | Expanded Navigation Menu | `50f3e07d7aa64ec9b0f18778fa97c6e4` | Menú lateral / flotante expandido. |
| **Quick Add** | Quick Add Modal - Light Mode | `9d0b06688dd842fc8e2a79e552453f38` | Modal rápido de entrada de transacciones. |

---

## Reglas de Extracción
1. **No guardar en /tmp:** No dejar archivos HTML/CSS de Stitch en `/tmp` durante más de una sesión. Si un fragmento es crucial, documentarlo aquí o en `docs/ui-ux/reference/`.
2. **Prioridad del Diseño:** Si hay una discrepancia entre el código actual y Stitch, la versión de Stitch (ID arriba) es la que manda, a menos que el usuario indique lo contrario.

---

*Última actualización: 2026-04-02*
