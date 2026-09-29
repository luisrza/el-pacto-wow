#!/bin/bash
# backup-pacto.sh — backup diario de EL PACTO (auth + characters + pacto)
# CRÍTICO: la progresión es persistente. Retención: 14 días.
# Instalar en cron:  0 6 * * *  /Users/brumbrum/Desktop/torre/tools/backup-pacto.sh
set -euo pipefail
DIR="/Users/brumbrum/Desktop/torre/backups"
mkdir -p "$DIR"
STAMP=$(date +%Y%m%d-%H%M)
docker exec pacto-database mysqldump -uroot -ppassword \
  --databases acore_auth acore_characters pacto \
  --single-transaction --quick 2>/dev/null | gzip > "$DIR/pacto-$STAMP.sql.gz"
# retención 14 días
find "$DIR" -name "pacto-*.sql.gz" -mtime +14 -delete
echo "[backup-pacto] OK: $DIR/pacto-$STAMP.sql.gz ($(du -h "$DIR/pacto-$STAMP.sql.gz" | cut -f1))"
