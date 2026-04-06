# Flujo Operativo Unificado OWFINANCE

Estado documental: `vigente`

Este documento define el flujo unico de trabajo entre Git, repo, Drive, Notion, Stitch y release.

## 1. Jerarquia de verdad

- Drive `OWFINANCE` decide contexto compartido, estrategia, planning y decision logs.
- Notion coordina tickets, ownership, estado y handoff.
- El repo documenta solo lo necesario para ejecutar y validar trabajo tecnico.
- Stitch referencia la fuente visual de UI cuando exista un screen o proyecto canonico.
- Git gobierna actualizacion local, ramas y seguridad por repo.

## 2. Paso 0 obligatorio: Git hygiene

Antes de cualquier `pull`, cambio de rama, implementacion o release:
1. ejecutar el preflight del repo afectado;
2. confirmar si el repo esta en detached HEAD;
3. validar working tree limpio o cambios entendidos;
4. verificar upstream tracking;
5. decidir estrategia segura de actualizacion.

Referencia obligatoria:
- `docs/00-sistema/GIT_HYGIENE_AND_SAFE_UPDATE.md`

## 3. Flujo de trabajo end-to-end

1. Identificar idea, bug, hallazgo o deuda.
2. Buscar el contexto canonico en Drive si el tema toca estrategia, planning, ownership o docs compartidas.
3. Abrir o actualizar ticket en Notion.
4. Clasificar el ticket por:
   - `Work Type`
   - `Repo`
   - `Source of Truth`
   - `Role`
   - `Release Phase`
   - `Cleanup Needed`
5. Leer el contexto minimo del repo y el ticket antes de ejecutar.
6. Implementar en backend, frontend o workspace segun corresponda.
7. Validar cambios tecnicos y contratos.
8. Ejecutar deploy solo cuando el usuario lo pida explicitamente con la palabra `deploya`.
9. Despues del release o lote estable, correr el gate de cleanup documental y de contexto.

## 4. Tratamiento de Lite / Pro

- Lite y Pro no deben usarse como rutas activas del producto actual.
- Si aparecen en tickets o docs, tratarlos como:
  - contexto historico de arquitectura;
  - contexto de diseño o de densidad visual;
  - plan futuro si existe un documento vigente que lo reactive.
- Las rutas ejecutables actuales deben seguir lo documentado en `docs/03-frontend/RUTAS.md` y el router real.

## 5. Cierre correcto de un trabajo

Un trabajo queda bien cerrado cuando:
- el ticket en Notion refleja el estado real;
- el repo deja solo la documentacion operativa minima necesaria;
- Drive conserva el cambio canonico si el trabajo afecto contexto compartido;
- Stitch queda referenciado si el trabajo fue visual;
- se registran riesgos, drift encontrado y limpieza pendiente.

## 6. Gate final de cleanup

El cleanup no ocurre al inicio ni a mitad de una entrega.

Se ejecuta al final de un release o lote estable para:
- detectar drift entre codigo, docs, Notion y rutas reales;
- consolidar o archivar documentos cruzados;
- actualizar indices y estados documentales;
- levantar tickets de saneamiento si algo no puede resolverse de forma segura.
