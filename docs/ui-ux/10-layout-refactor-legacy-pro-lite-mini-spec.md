# Mini-Spec: Layout Refactor Legacy / Pro / Lite

Status: Draft formal para backlog y planificacion. No habilita implementacion por si solo.

## Contexto

`OFB-27` define la fase 1 del trabajo de layout: congela la base UX, las rutas canonicas y la traduccion funcional de los flujos core hacia una sola arquitectura de producto con variantes por densidad.

Los documentos de referencia ya dejan fijado que:

- Lite y Pro comparten una misma identidad visual y un mismo sistema de componentes.
- Las rutas canonicas se mantienen en la familia `/user/home`, `/user/transactions`, `/user/jars` y `/user/config`.
- Las diferencias entre Lite y Pro deben expresarse por shell, densidad, distribucion de regiones y exposicion de controles, no por marca ni por duplicacion arbitraria de producto.

Este nuevo workstream no redefine la UX congelada en `OFB-27`. Su funcion es preparar el refactor estructural que permita separar con claridad las responsabilidades de layout entre Legacy, Lite y Pro sin romper contratos de navegacion, componentes compartidos ni ownership funcional de pantallas.

## Problema

La base actual mezcla decisiones historicas de layout, densidad y navegacion dentro de superficies que todavia cargan comportamiento heredado. Eso genera cuatro fricciones principales:

1. El layout legacy y las variantes Lite/Pro comparten demasiado acoplamiento estructural.
2. La misma ruta o pantalla puede cargar responsabilidades de shell, distribucion y densidad en una sola capa dificil de evolucionar.
3. La migracion posterior de pantallas queda mas riesgosa porque no existe una frontera suficientemente explicita entre shell comun, layout por variante y contenido de flujo.
4. La base congelada por `OFB-27` puede quedar interpretada de forma inconsistente si no se formaliza una arquitectura objetivo para el refactor.

## Objetivo del refactor

Formalizar y ejecutar un refactor estructural de layout que:

- mantenga `OFB-27` como baseline funcional y visual de fase 1;
- separe explicitamente las responsabilidades de `Legacy`, `Lite` y `Pro`;
- preserve las rutas canonicas y los contratos de flujo ya congelados;
- permita que el shell, la navegacion y la distribucion de regiones evolucionen por variante sin duplicar logica de negocio;
- reduzca el riesgo de regresiones durante la migracion posterior de pantallas y widgets.

## Fuera de alcance

Queda fuera de este workstream:

- redefinir la identidad visual canonica ya congelada;
- cambiar las rutas canonicas del producto;
- introducir nuevos flujos funcionales fuera del scope core congelado;
- implementar modulos nuevos de IA, inversiones, soporte o admin como parte de este refactor;
- reabrir decisiones de UX ya cerradas en `OFB-27` salvo que exista un nuevo documento aprobatorio posterior.

## Dependencias

Este mini-spec depende de los siguientes artefactos:

1. `OFB-27` como fase 1 y prerequisito de baseline.
2. `docs/ui-ux/08-frozen-canonical-design-system-brief.md` como autoridad visual y de reglas de densidad.
3. `docs/ui-ux/09-freeze-stitch-flujo-core-matrix.md` como autoridad de rutas, flujos core, decomposition decisions y orden de migracion.
4. `docs/ui-ux/06-version-matrix-differences.md` como referencia historica de filosofia Lite vs Pro, util solo donde no contradiga los documentos congelados.

Sin estas dependencias, este refactor perderia el marco que distingue entre decisiones ya congeladas y decisiones aun abiertas de estructura.

## Arquitectura objetivo

La arquitectura objetivo debe separar tres niveles claros:

### 1. Legacy compatibility layer

Una capa temporal y acotada para absorber comportamiento heredado que todavia no pueda migrarse directamente al nuevo shell. Su funcion es contener deuda y evitar que siga filtrandose a la arquitectura destino.

### 2. Shared canonical shell

Una capa comun responsable de:

- marco general de navegacion;
- slots o regiones estructurales compartidas;
- contratos de page container;
- reglas de header, acciones globales y overlays compartidos.

Esta capa no debe decidir por si sola si una pantalla se renderiza como Lite o Pro. Solo provee la estructura base y los contratos comunes.

### 3. Variant layout layers

Capas de layout especificas por variante:

- `Lite`: prioriza stack vertical, disclosure progresivo, navegacion touch-first y baja simultaneidad de controles.
- `Pro`: prioriza paneles densos, contexto simultaneo, distribucion desktop-first y herramientas visibles cuando mejoran productividad.

Ambas variantes deben reutilizar el mismo sistema visual, los mismos componentes base y la misma familia de rutas. Lo que cambia es la postura estructural del layout.

## Reglas de distribucion

Las siguientes reglas guian la separacion estructural:

1. Una misma ruta canonica puede tener distinta distribucion Lite o Pro, pero no debe convertirse en rutas funcionales duplicadas.
2. El shell compartido define contratos; las variantes definen postura de layout.
3. `Legacy` no debe seguir siendo la fuente implícita de comportamiento futuro; solo una capa de compatibilidad transitoria.
4. Ninguna decision de layout debe obligar a duplicar widgets, estados ni logica de dominio si estos pueden resolverse con composicion.
5. La navegacion Lite no usa sidebar persistente; la Pro puede expandirse a sidebar y top utility bar segun dispositivo y densidad.
6. Los overlays compartidos siguen siendo contratos reutilizables entre rutas, no paginas independientes disfrazadas.
7. Las diferencias de distribucion deben ser trazables a las reglas congeladas de densidad, no a preferencias visuales ad hoc.

## Estrategia de migracion

La migracion propuesta debe seguir una secuencia conservadora:

### Etapa A. Aislamiento estructural

Separar la deuda legacy del shell canonico futuro, dejando claros los puntos donde la compatibilidad sigue siendo necesaria.

### Etapa B. Extraccion del shell compartido

Definir el app shell comun, los contenedores estructurales y los contratos de navegacion/overlay que luego consumiran Lite y Pro.

### Etapa C. Separacion por variante

Crear capas explicitas de layout para Lite y Pro sobre el shell comun, sin mover todavia la logica funcional fuera de sus owners canonicos mas alla de lo necesario para la separacion estructural.

### Etapa D. Migracion gradual de pantallas

Reubicar progresivamente las pantallas core segun el orden ya sugerido por la matriz congelada, validando que cada flujo siga respetando la misma ruta y el mismo contrato funcional.

### Etapa E. Retiro de legacy residual

Eliminar o encapsular definitivamente piezas legacy una vez que el shell y las variantes queden estabilizados y las dependencias heredadas ya no sean necesarias.

## Riesgos

- Confundir este workstream con una re-definicion de UX y reabrir decisiones ya congeladas.
- Introducir duplicacion de rutas o pantallas bajo la excusa de separar variantes.
- Mover demasiada logica funcional dentro del layout y crear un nuevo acoplamiento estructural.
- Mantener dependencias legacy ocultas que luego bloqueen la salida de la fase de compatibilidad.
- Generar regresiones de navegacion o consistencia entre Lite y Pro por no respetar los contratos comunes.

## Criterios de salida

Este workstream puede considerarse correctamente preparado y/o completado cuando:

1. Existe una frontera documentada y verificable entre `Legacy`, shell compartido, layout `Lite` y layout `Pro`.
2. `OFB-27` sigue siendo explicitamente la fase 1 y baseline de decisiones funcionales/UX.
3. Las rutas canonicas permanecen intactas y la separacion ocurre por estructura, no por duplicacion de producto.
4. Los contratos de distribucion y reutilizacion quedan suficientemente claros para habilitar implementacion por etapas.
5. La estrategia de migracion permite retirar legacy de forma gradual sin reabrir el freeze funcional.
6. El backlog posterior puede descomponer trabajo tecnico por shell, variante y flujo sin ambiguedad arquitectonica.

## Nota de uso

Este documento define alcance y criterio estructural. No autoriza por si mismo cambios de implementacion fuera del marco congelado y debe leerse siempre junto con `OFB-27`, el brief canonico congelado y la matriz de flujos core.
