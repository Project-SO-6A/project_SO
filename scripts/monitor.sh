#!/usr/bin/env bash
# monitor.sh - Anggota 6: monitoring layanan, log, dan laporan
set -u

BASE_DIR="${BASE_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
LOG_FILE="$BASE_DIR/logs/operasional.log"
OUT_DIR="$BASE_DIR/output"
REPORT="$OUT_DIR/laporan.txt"
BACKUP_LOG="${BACKUP_LOG:-$BASE_DIR/logs/backup.log}"
read -ra SERVICES <<< "${SERVICES_LIST:-ssh}"   # nanti ganti default jadi: smbd ssh

log() { echo "$(date '+%F %T') [$1] $2" >> "$LOG_FILE"; }

mkdir -p "$BASE_DIR/logs" "$OUT_DIR" 2>/dev/null
if [ ! -w "$OUT_DIR" ] || [ ! -w "$BASE_DIR/logs" ]; then
  echo "ERROR: direktori output/logs tidak dapat ditulis" >&2
  exit 2
fi

down=0
tmp="$(mktemp "$OUT_DIR/.laporan.XXXXXX")"

{
  echo "=== LAPORAN LAYANAN DAN BACKUP ==="
  echo "Waktu : $(date '+%F %T')"
  echo "Host  : $(hostname)"
  echo
  echo "[Layanan]"
  for s in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$s"; then
      pid="$(systemctl show -p MainPID --value "$s")"
      echo "$s : AKTIF (PID $pid)"
      log INFO "$s aktif (PID $pid)"
    else
      echo "$s : TIDAK AKTIF"
      log ERROR "$s tidak aktif"
      down=$((down + 1))
    fi
  done
  echo
  echo "[Backup terakhir]"
  if [ -r "$BACKUP_LOG" ] && [ -s "$BACKUP_LOG" ]; then
    tail -n 1 "$BACKUP_LOG"
  else
    echo "TIDAK ADA DATA BACKUP"
    log WARN "log backup tidak tersedia"
  fi
  echo
  echo "[Sumber daya]"
  echo "Load average : $(cut -d' ' -f1-3 /proc/loadavg)"
  echo "Memori (MB)  : $(free -m | awk '/Mem:/ {print $3" terpakai dari "$2}')"
} > "$tmp"

chmod 640 "$tmp"
mv "$tmp" "$REPORT"

if [ "$down" -gt 0 ]; then
  log ERROR "monitoring selesai: $down layanan bermasalah"
  exit 1
fi
log INFO "monitoring selesai: semua layanan aktif"
exit 0
