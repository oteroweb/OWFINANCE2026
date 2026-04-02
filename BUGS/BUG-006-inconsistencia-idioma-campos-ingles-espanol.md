# BUG-006 - Inconsistencia de idioma: campos y etiquetas en ingles en lugar de espanol

## Estado
- Estado: `todo`
- Prioridad: `media`
- Fecha registro: `2026-03-14`
- Reportado por: usuario

## Modulo
- Frontend (UI/UX + i18n)
- Componentes de tabla, filtros y formularios
- Impacto: experiencia de usuario y consistencia de producto

## Descripcion
La aplicacion debe mostrarse completamente en espanol para este contexto de uso. Actualmente existen etiquetas/campos en ingles (por ejemplo, `Records per page`, `All` u otros textos de componentes base) mezclados con textos en espanol.

## Resultado actual
- Interfaz parcialmente en espanol.
- Algunos labels/acciones permanecen en ingles.
- Experiencia inconsistente en vistas clave.

## Resultado esperado
- Todos los campos, etiquetas, acciones, placeholders y mensajes visibles al usuario en espanol.
- Sin mezcla de idiomas en una misma pantalla.
- Incluye textos provenientes de componentes de libreria (tabla/paginador/dialogos), no solo textos custom.

## Pasos para reproducir
1. Navegar por vistas principales (dashboard, transacciones, importacion, formularios).
2. Revisar paginador de tablas y acciones de filtros.
3. Identificar textos en ingles junto a textos en espanol.

## Alcance minimo recomendado
1. Tabla/paginador (ej. `Records per page`, `All`).
2. Dialogos y botones de accion.
3. Mensajes de validacion y toasts.
4. Placeholders y labels de formularios.

## Checklist de futura solucion
1. Inventario de strings visibles por modulo.
2. Consolidar textos en capa i18n (locale `es`).
3. Sobrescribir labels por defecto de componentes de Quasar cuando aplique.
4. Prueba de regresion visual por pantalla clave (capturas antes/despues).
