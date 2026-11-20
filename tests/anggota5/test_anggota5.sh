#!/bin/bash
# Pengujian Backup dan Restore - Anggota 5
# T5-01: Pengujian Positif
# T5-02: Pengujian Negatif

set -u

SOURCE_DIR="/srv/share"
BACKUP_DIR="/srv/backup"
RESTORE_DIR="/srv/restore_test"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BAD_ARCHIVE="$BACKUP_DIR/backup_rusak.tar.gz"

cd "$PROJECT_DIR" || exit 1

echo "=========================================="
echo " PENGUJIAN BACKUP DAN RESTORE (ANGGOTA 5)"
echo "=========================================="

if [ ! -d "$SOURCE_DIR" ]; then
    echo "FAIL: Direktori sumber tidak ditemukan."
    exit 1
fi

sudo rm -f "$BAD_ARCHIVE" "$BAD_ARCHIVE.sha256"

# T5-01: Backup
echo
echo "[T5-01] Menjalankan backup"

if ! sudo bash scripts/backup.sh; then
    echo "FAIL: Backup gagal."
    exit 1
fi

# Mengambil arsip backup terbaru
ARCHIVE_PATH="$(sudo find "$BACKUP_DIR" -maxdepth 1 -type f -name 'share_*.tar.gz' -printf '%T@ %p\n' | sort -nr | head -n 1 | cut -d' ' -f2-)"

if [ -z "$ARCHIVE_PATH" ]; then
    echo "FAIL: Arsip backup tidak ditemukan."
    exit 1
fi

ARCHIVE_NAME="$(basename "$ARCHIVE_PATH")"

# Verifikasi checksum
echo
echo "[T5-01] Memeriksa checksum"

if ! sudo sha256sum -c "$BACKUP_DIR/$ARCHIVE_NAME.sha256"; then
    echo "FAIL: Checksum tidak sesuai."
    exit 1
fi

# Restore
echo
echo "[T5-01] Menjalankan restore"

if ! sudo bash scripts/restore.sh "$ARCHIVE_NAME"; then
    echo "FAIL: Restore gagal."
    exit 1
fi

# Membandingkan hasil restore
echo
echo "[T5-01] Membandingkan folder sumber dan hasil restore"

if sudo diff -r "$SOURCE_DIR" "$RESTORE_DIR"; then
    echo "PASS: Data sumber dan hasil restore sama."
else
    echo "FAIL: Data tidak sama."
    exit 1
fi

# T5-02: Pengujian negatif
echo
echo "[T5-02] Membuat salinan arsip rusak"

if ! sudo cp "$ARCHIVE_PATH" "$BAD_ARCHIVE"; then
    echo "FAIL: Gagal membuat salinan arsip."
    exit 1
fi

# Memotong arsip menjadi 100 byte
sudo truncate -s 100 "$BAD_ARCHIVE"

# Membuat checksum baru untuk arsip yang sudah dipotong
if ! sudo sha256sum "$BAD_ARCHIVE" | sudo tee "$BAD_ARCHIVE.sha256" > /dev/null; then
    echo "FAIL: Gagal membuat checksum salinan."
    exit 1
fi

# Restore harus ditolak
echo
echo "[T5-02] Mencoba restore arsip rusak"

if sudo bash scripts/restore.sh "backup_rusak.tar.gz"; then
    echo "FAIL: Arsip rusak berhasil dipulihkan."
    exit 1
else
    echo "PASS: Arsip rusak berhasil ditolak."
fi

# Membersihkan file pengujian
echo
echo "[CLEANUP] Menghapus file pengujian"

sudo rm -f "$BAD_ARCHIVE" "$BAD_ARCHIVE.sha256"

echo
echo "=========================================="
echo " PENGUJIAN ANGGOTA 5 SELESAI"
echo " T5-01: POSITIF"
echo " T5-02: NEGATIF"
echo "=========================================="
