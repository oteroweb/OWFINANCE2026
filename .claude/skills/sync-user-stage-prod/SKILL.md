---
name: sync-user-stage-prod
description: Sincroniza recurrentemente todos los datos de un usuario especifico desde el backup diario de stage-mysql hacia produccion (owfinances.com). Usar cuando el usuario pida "sincroniza mi usuario a produccion", "actualiza production con mi data de stage", "sync otero@demo.com a prod", o equivalentes.
---

# Sync usuario stage -> produccion

Jose Luis usa **stage** como su entorno de trabajo personal (`otero@demo.com`).
Un cron ya genera un backup diario de stage en
`~/OW_Ecosystem/_backups/YYYY-MM-DD-stage-mysql/owfinance_stage_backup.sql.gz`
(script: `~/OW_Ecosystem/scripts/backup_mysql_stage.py`, retencion 7 dias).

Esta skill reconcilia y actualiza en **produccion** (owfinances.com) toda la data
de un usuario puntual tomandola de ese backup diario, de forma **idempotente**:
cada corrida borra el arbol de datos de ese usuario en prod y lo reinserta
fresco, remapeando IDs (cuentas, jars, categorias, transacciones, etc.) porque
los IDs de stage y produccion no coinciden. Los catalogos globales (roles,
currencies, account_types, transaction_types, taxes, rates) se emparejan por
clave natural (slug/code/name) y nunca se borran, para no afectar a otros
usuarios de produccion.

## Cuando usarla

- El usuario pide sincronizar/actualizar su usuario demo de stage hacia prod.
- Quiere "seguir en production" con su data personal ya cargada desde stage.
- Quiere correr esto de forma recurrente (cada vez que quiera "refrescar" prod
  con lo ultimo que hizo en stage).

## Que tablas sincroniza

Por usuario (se borran y reinsertan en cada corrida):
`account_folders`, `accounts`, `account_user`, `providers`, `categories`,
`user_currencies`, `jars`, `jar_settings`, `jar_leverage_settings`,
`jar_cycles`, `jar_category`, `jar_base_category`, `jar_adjustments`,
`jar_transfers`, `jar_withdrawals`, `jar_monthly_overrides`, `transactions`,
`payment_transactions`, `payment_transaction_taxes`, `item_transactions`,
`item_taxes`, `user_monthly_income_history`.

**Excluidas a proposito** (no son "data" del usuario, son sesion/seguridad):
`personal_access_tokens`, `sessions`. Un token de stage no debe autenticar
contra prod.

Catalogos globales (se aseguran por clave natural, nunca se borran):
`roles`, `currencies`, `account_types`, `transaction_types`, `taxes`, `rates`.

## Como ejecutarla

```bash
cd ~/OW_Ecosystem/scripts
python3 sync_user_stage_to_prod.py <email>              # ejecuta el sync real contra prod
python3 sync_user_stage_to_prod.py <email> --dry-run     # solo genera el SQL, no toca prod
python3 sync_user_stage_to_prod.py <email> --backup <ruta.sql.gz>   # usar un backup especifico
```

Ejemplo real usado hasta ahora: `python3 sync_user_stage_to_prod.py otero@demo.com`

El script:
1. Toma el backup diario mas reciente de `_backups/*-stage-mysql/` (o el que se
   pase con `--backup`).
2. Parsea el dump localmente (no necesita conexion MySQL directa a stage).
3. Ubica al usuario por **email** (no por ID — los IDs difieren entre entornos).
4. Genera un SQL completo con mapeo de IDs via tablas temporales
   (`_map_accounts`, `_map_jars`, `_map_categories`, etc.) y lo guarda en
   `_backups/sync_<email>_<fecha-backup>.sql` para auditoria.
5. Obtiene las credenciales de la DB de produccion en caliente via SSH
   (lee `~/OWFINANCEBACKEND2025/.env` en el servidor — nunca las hardcodea
   localmente).
6. Ejecuta el SQL contra produccion en una sola sesion `mysql` remota (por SSH,
   usando la key `.deploy/prod.sh` / `~/.ssh/owfinances_prod`), dentro de una
   transaccion.

## Verificacion post-sync (recomendado correr despues de cada sync)

```bash
ssh -i ~/.ssh/owfinances_prod owfinanc1@178.156.160.70 \
  "mysql -u owfinanc1_pr03 -p'<pass del .env remoto>' owfinanc1_pr03_d8 -e \"
    SELECT id,name,email FROM users WHERE email='<email>';
    SELECT COUNT(*) FROM account_user WHERE user_id=(SELECT id FROM users WHERE email='<email>');
    SELECT COUNT(*) FROM transactions WHERE user_id=(SELECT id FROM users WHERE email='<email>');
  \""
```

Compara esos conteos contra los mismos conteos en stage (mismo query, DB
`appfinan1_db` via `OWFINANCE_STAGE_USER/PASS` del `.env` de `~/OW_Ecosystem`).

## Gotchas conocidos

- Ambos entornos (stage y prod) viven en el **mismo servidor** (178.156.160.70)
  pero MySQL solo escucha por socket Unix local — **no hay TCP directo**, por
  eso el script no usa un driver Python de MySQL, sino que ejecuta el SQL
  remotamente via `ssh ... "mysql ..."` (mismo patron que
  `backup_mysql_stage.py`).
- Las contraseñas de MySQL en los `.env` remotos pueden traer comillas simples
  literales dentro del valor — el script ya usa `shlex.quote` para evitar
  romper el comando remoto; si se edita el script, no volver a construir el
  comando remoto con f-strings simples.
- `categories.parent_id` es auto-referencial: el script inserta primero con
  `parent_id=NULL` y en una segunda pasada hace `UPDATE` usando la tabla de
  mapeo — necesario para no romper el orden de insercion.
- Es **idempotente**: correrlo varias veces seguidas no duplica nada (se
  verifico corriendolo 2 veces consecutivas, mismos conteos).
