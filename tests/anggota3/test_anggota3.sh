#!/bin/bash
# Script Pengujian Hak Akses Read-Only - Anggota 3 (AinnisyaRezka)

SHARE_DIR="/srv/samba/shared"

echo "=== MEMULAI PENGUJIAN ANGGOTA 3 (READ-ONLY) ==="

# 1. Uji Positif: Membaca berkas/direktori
echo "[1/3] Uji Positif: Membaca daftar berkas di $SHARE_DIR..."
if ls -la "$SHARE_DIR" > /dev/null 2>&1; then
    echo " -> [BERHASIL] User dapat membaca daftar berkas."
else
    echo " -> [GAGAL] User tidak dapat membaca daftar berkas."
fi

# 2. Uji Negatif: Menulis/Membuat file baru
echo "[2/3] Uji Negatif: Mencoba membuat berkas baru..."
if touch "$SHARE_DIR/test_read_only.txt" > /dev/null 2>&1; then
    echo " -> [GAGAL] User malah bisa menulis/membuat berkas (Harusnya ditolak)!"
else
    echo " -> [BERHASIL] Akses tulis ditolak secara benar (Permission Denied)."
fi

# 3. Uji Negatif: Menghapus file
echo "[3/3] Uji Negatif: Mencoba menghapus berkas..."
if rm "$SHARE_DIR/file_contoh.txt" > /dev/null 2>&1; then
    echo " -> [GAGAL] User berhasil menghapus berkas (Harusnya ditolak)!"
else
    echo " -> [BERHASIL] Akses hapus ditolak secara benar (Permission Denied)."
fi

echo "=== PENGUJIAN SELESAI ==="
