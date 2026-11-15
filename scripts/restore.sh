#!/usr/bin/enc bash
set -Eeuo pipefail

BACKUP_DIR="/srv/backup"
RESTORE_DIR="/srv/restore_test"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$BASE_DIR/logs/backup.log"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
    printf '%s|%s|%s|%s\n' \
	"$(date '+%F %T')" "$1" "$2" "$3" >> "$LOG_FILE"
}

fail () {
    log "GAGAL" "${ARCHIVE:--}" "$1"
    echo "ERROR: $1" >&2
    exit 1
}

if [[ "$EUID" -ne 0 ]]; then
    fail "Script harus dijalankan menggunakan sudo."
fi

if [[ $# -ne 1 ]]; then
    fail "Gunakan: sudo bash restore.sh NAMA_ARSIP.tar.gz"
fi

ARCHIVE="$BACKUP_DIR/$1"
if [[ "$1" == */* || "$1" != *.tar.gz ]]; then
    fail "Nama arsip tidak valid."
fi

if [[ ! -f "$ARCHIVE" ]]; then
    fail "Arsip tidak ditemukan."
fi

if [[ ! -f "$ARCHIVE.sha256" ]]; then
    fail "File checksum tidak ditemukan."
fi

echo "Memeriksa integritas arsip..."

if ! (cd "$BACKUP_DIR" && sha256sum -c "$(basename "$ARCHIVE").sha256"); then
   fail "Checksum tidak cocok. Restore dibatalkan."
fi

if ! tar -tzf "$ARCHIVE" >/dev/null; then
   fail "Arsip tidak valid atau rusak."
fi

mkdir -p "$RESTORE_DIR"
find "$RESTORE_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +

if ! tar -xzf "$ARCHIVE" -C "$RESTORE_DIR"; then
   fail "Proses restore gagal."
fi

log "SUKSES" "$(basename "$ARCHIVE")" "Restore dan verifikasi berhasil"

echo "Restore berhasil."
echo "Lokasi hasil: $RESTORE_DIR"

exit 0

