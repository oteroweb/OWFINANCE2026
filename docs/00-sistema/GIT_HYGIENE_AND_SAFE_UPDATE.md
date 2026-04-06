# Git Hygiene and Safe Update

Estado documental: `vigente`

Ningun `git pull` debe ejecutarse antes de este preflight.

## 1. Problema actual del workspace

Los repos locales pueden quedar en `HEAD detached`, como ya ocurre en el estado actual detectado:
- backend: `dab5b83` contenido en `origin/dev`
- frontend: `7851856` contenido en `origin/dev`

Mientras el repo este detached o ambiguo:
- no hacer `pull`;
- no asumir rama activa;
- no mezclar actualizacion con implementacion.

## 2. Preflight obligatorio por repo

Ejecutar, por separado, en backend y frontend:
1. `git status --short --branch`
2. `git rev-parse --short HEAD`
3. `git branch -a --contains HEAD`
4. `git remote -v`
5. `git branch --show-current`
6. `git fetch --all --prune`
7. comparar `HEAD` local contra la rama remota objetivo

## 3. Reglas de decision

- Si el repo esta en detached HEAD:
  - identificar la rama remota correcta que contiene el commit actual;
  - cambiar a una rama local con tracking correcto antes de actualizar.
- Si hay cambios locales no committeados:
  - no hacer `pull` hasta entender si deben guardarse, moverlos o aislarlos.
- Si no existe upstream claro:
  - configurarlo explicitamente antes de actualizar.
- Si el repo esta varios commits por delante y por detras:
  - resolver la estrategia antes de trabajar; no improvisar con `pull`.

## 4. Flujo seguro recomendado

1. Diagnosticar estado.
2. Fijar rama correcta.
3. Validar working tree.
4. Confirmar upstream tracking.
5. Recien entonces actualizar.
6. Solo despues de actualizar, arrancar trabajo de implementacion.

## 5. Regla para agentes

Si el preflight detecta detached HEAD, working tree ambiguo o tracking roto:
- bloquear `pull`;
- documentar el hallazgo;
- abrir ticket o nota de higiene Git si hace falta;
- no ocultar el riesgo dentro de otra tarea.

## 6. Sincronizacion de punteros del repo central

El repo raiz no se actualiza solo cuando backend o frontend avanzan en sus propios remotos.

Flujo recomendado:
1. Hacer `commit` y `push` dentro de `OWFINANCEBackend2025` o `OWFinanceFrontend2025`.
2. Volver al root `OWFINANCE2026`.
3. Ejecutar `./sync-submodule-pointers.sh --report` para diagnosticar.
4. Si el root queda desfasado, ejecutar `./sync-submodule-pointers.sh --commit`.
5. Solo si hace falta compartir ese estado oficial del workspace, hacer `git push` del repo raiz.

Wrapper recomendado para evitar pasos manuales:
1. Ejecutar `./push-workspace.sh backend "mensaje"` o `./push-workspace.sh frontend "mensaje"`.
2. El wrapper:
   - normaliza el subrepo a la rama declarada en `.gitmodules`;
   - commitea el subrepo si hace falta;
   - hace `push` del subrepo;
   - sincroniza el puntero del repo central;
   - opcionalmente puede empujar tambien el root con `--push-root`.

El script:
- normaliza backend y frontend sobre sus ramas objetivo;
- bloquea el flujo si hay cambios locales ambiguos;
- detecta cuando el root sigue apuntando a commits viejos;
- puede crear el commit del repo raiz solo con los punteros de submodulo.

Nota operativa:
- la rama objetivo de cada submodulo se lee desde `.gitmodules`;
- hoy el workspace integra backend y frontend contra `dev`.
