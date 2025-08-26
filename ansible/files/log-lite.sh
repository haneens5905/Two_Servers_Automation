#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="/var/log/barq"
YDAY="$(date -d 'yesterday' +%F)"

# Compress yesterday's *.log files (if any)
compressed_any=false
for f in "${LOG_DIR}"/*"${YDAY}"*.log; do
  if [ -e "$f" ]; then
    gzip -f "$f"
    compressed_any=true
  fi
done
if [ "$compressed_any" = false ]; then
  echo "No log found for ${YDAY}"
fi

# Delete compressed logs older than 7 days
find "${LOG_DIR}" -type f -name "*.log.gz" -mtime +7 -print -delete || true
