#!/usr/bin/env bash
set -Eeuo pipefail

SOURCE_DIR="/srv/share"
BACKUP_DIR="/srv/backup"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$BASE_DIR/logs/backup.log"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
   printf '%s|%s|%s|%s\n' \
	"$(date '+%F %T')" "$1" "$2" "$3" >> "$LOG_FILE"
}

fail() {
    log "GAGAL" "-" "$1"
    echo "ERROR: $1" >&2
    exit 1
}

if [[ "$EUID" -ne 0 ]]; then
    fail "Script harus dijalankan menggunakan sudo."
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
    fail "Folder sumber $SOURCE_DIR tidak ditemukan."
fi

mkdir -p "$BACKUP_DIR"
chmod 700 "$BACKUP_DIR"

TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
ARCHIVE="$BACKUP_DIR/share_$TIMESTAMP.tar.gz"

echo "Memulai proses backup..."

if ! tar -czf "$ARCHIVE" -C "$SOURCE_DIR" .; then
   rm -f "$ARCHIVE"
   fail "Pembuatan arsip backup gagal."
fi

if ! sha256sum "$ARCHIVE" > "$ARCHIVE.sha256"; then
   rm -f "$ARCHIVE" "$ARCHIVE.sha256"
   fail "Pembuatan checksum gagal."
fi

if ! tar -tzf "$ARCHIVE" >/dev/null; then
   rm -f "$ARCHIVE" "$ARCHIVE.sha256"
   fail "Verifikasi arsip gagal."
fi

log "SUKSES" "$(basename "$ARCHIVE")" "Backup dan verifikasi arsip berhasil"

echo "Backup berhasil."
echo "Arsip: $ARCHIVE"
echo "Checksum: $ARCHIVE.sha256"

exit 0
