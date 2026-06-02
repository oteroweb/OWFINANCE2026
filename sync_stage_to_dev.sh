#!/usr/bin/env bash
# ============================================================
# Sincronizar DB Stage → Dev
# WARNING: Este script SOBREESCRIBE toda la DB de dev con data de stage
# Ubicacion: ~/OW_Ecosystem/apps/owfinance/central/sync_stage_to_dev.sh
# ============================================================

set -e

# CONFIG — Credenciales (verificar antes de ejecutar)
STAGE_HOST="178.156.160.70"
STAGE_SSH_USER="appfinan1"
STAGE_SSH_PASS=";,a6_1bInbleV4l4"
STAGE_DB_NAME="appfinan1_db"
STAGE_DB_USER="appfinan1_user"
STAGE_DB_PASS="d17Ca%_*UyqhqZoe"

DEV_HOST="178.156.160.70"
DEV_SSH_USER="appfinan2"
DEV_SSH_PASS="ukg5nef6EJV*cyu@hdr"
DEV_DB_NAME="appfinan2_db"
DEV_DB_USER="appfinan2"
DEV_DB_PASS="AKCH8xZB4TAY4WgS"

BACKUP_DIR="$HOME/OW_Ecosystem/_backups"
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
DEV_BACKUP_NAME="dev_backup_before_stage_sync_${TIMESTAMP}.sql.gz"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "=========================================="
echo "  SYNC STAGE DB -> DEV DB"
echo "  Fecha: $(date)"
echo "=========================================="

# Paso 1: Backup de seguridad de Dev ANTES de tocar
log_info "Paso 1: Backup de seguridad de Dev actual..."
DEV_BACKUP_PATH="${BACKUP_DIR}/${DEV_BACKUP_NAME}"
sshpass -p "$DEV_SSH_PASS" ssh -o StrictHostKeyChecking=no "$DEV_SSH_USER@$DEV_HOST" \
  "mariadb-dump -u '$DEV_DB_USER' -p'$DEV_DB_PASS' --single-transaction --routines --triggers '$DEV_DB_NAME' 2>/dev/null" \
  | gzip > "$DEV_BACKUP_PATH"

if [ -f "$DEV_BACKUP_PATH" ] && [ -s "$DEV_BACKUP_PATH" ]; then
  SIZE=$(du -h "$DEV_BACKUP_PATH" | cut -f1)
  log_info "Backup Dev guardado: $DEV_BACKUP_PATH ($SIZE)"
else
  log_error "Backup de Dev fallo. ABORTANDO."
  exit 1
fi

# Paso 2: Verificar que el backup de stage existe
STAGE_BACKUP="${BACKUP_DIR}/latest-stage-mysql/owfinance_stage_backup.sql.gz"
if [ ! -f "$STAGE_BACKUP" ]; then
  # Buscar el mas reciente
  STAGE_BACKUP=$(ls -t ${BACKUP_DIR}/*-stage-mysql/owfinance_stage_backup.sql.gz 2>/dev/null | head -1)
  log_warn "Usando backup de stage mas reciente: $STAGE_BACKUP"
fi

if [ ! -f "$STAGE_BACKUP" ]; then
  log_error "No se encontro backup de stage. ABORTANDO."
  exit 1
fi

log_info "Backup de stage a usar: $STAGE_BACKUP"

# Paso 3: Transferir backup de stage a Dev
log_info "Paso 2: Transfirendo backup de stage a servidor Dev..."
TEMP_FILE="/tmp/stage_backup_$$_$(date +%s).sql.gz"
sshpass -p "$DEV_SSH_PASS" scp -o StrictHostKeyChecking=no "$STAGE_BACKUP" "$DEV_SSH_USER@$DEV_HOST:$TEMP_FILE"

# Paso 4: Restaurar en Dev
log_info "Paso 3: Restaurando stage en Dev (DROP + CREATE)..."

sshpass -p "$DEV_SSH_PASS" ssh -o StrictHostKeyChecking=no "$DEV_SSH_USER@$DEV_HOST" << 'REMOTE_SSH'
set -e

DB_NAME="appfinan2_db"
DB_USER="appfinan2"
DB_PASS="AKCH8xZB4TAY4WgS"
BACKUP_FILE="TEMP_FILE_PLACEHOLDER"

echo "[DEV] Verificando archivo de backup..."
if [ ! -f "$BACKUP_FILE" ]; then
  echo "ERROR: Archivo de backup no encontrado en Dev"
  exit 1
fi

echo "[DEV] Desactivando Foreign Keys..."
mariadb -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SET FOREIGN_KEY_CHECKS=0;"

echo "[DEV] Dropping tablas existentes..."
TABLES=$(mariadb -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -N -e "SHOW TABLES;")
for TABLE in $TABLES; do
  echo "  DROP TABLE IF EXISTS $TABLE;"
  mariadb -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -N -e "DROP TABLE IF EXISTS $TABLE;"
done

echo "[DEV] Reactivando Foreign Keys..."
mariadb -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SET FOREIGN_KEY_CHECKS=1;"

echo "[DEV] Importando backup de stage..."
gunzip -c "$BACKUP_FILE" | mariadb -u "$DB_USER" -p"$DB_PASS" "$DB_NAME"

if [ $? -eq 0 ]; then
  echo "SUCCESS: DB Dev restaurada con data de Stage"
  TABLES_COUNT=$(mariadb -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME';")
  echo "Tablas creadas: $TABLES_COUNT"
else
  echo "ERROR: Import fallo"
  exit 1
fi

echo "[DEV] Limpiando archivo temporal..."
rm -f "$BACKUP_FILE"
REMOTE_SSH

log_info "Restore completado!"

# Paso 5: Verificar
log_info "Paso 4: Verificando integridad..."
DEV_TABLES=$(sshpass -p "$DEV_SSH_PASS" ssh -o StrictHostKeyChecking=no "$DEV_SSH_USER@$DEV_HOST" \
  "mariadb -u '$DEV_DB_USER' -p'$DEV_DB_PASS' -N -e \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DEV_DB_NAME';\" 2>/dev/null")

log_info "Tablas en Dev: $DEV_TABLES"
log_info "Backup de seguridad: $DEV_BACKUP_PATH"

echo ""
echo "=========================================="
echo -e "${GREEN}[SUCCESS] Sync Stage -> Dev completado${NC}"
echo "=========================================="