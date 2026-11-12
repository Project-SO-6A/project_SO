#!/bin/bash
# Script Pengujian Administrasi SSH - Anggota 4 (Positif & Negatif)

SCRIPT_ADMIN="./scripts/ssh_admin.sh"
TEST_USER="user_biasa_uji"

if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Jalankan file pengujian ini dengan sudo: sudo bash $0"
    exit 1
fi

chmod +x "$SCRIPT_ADMIN"

# Buat akun biasa dummy untuk simulasi
if ! id "$TEST_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$TEST_USER"
fi

echo "=== 1. UJI NEGATIF: Akun biasa mencoba menjalankan script admin ==="
su - "$TEST_USER" -c "bash $(pwd)/scripts/ssh_admin.sh"
EXIT_NEG=$?
echo "Exit Status Uji Negatif: $EXIT_NEG"
if [ "$EXIT_NEG" -ne 0 ]; then
    echo "[LULUS] Sistem menolak akun biasa (Exit status bukan 0)."
else
    echo "[GAGAL] Akun biasa seharusnya ditolak!"
fi

echo ""
echo "=== 2. UJI POSITIF: Admin menjalankan konfigurasi & cek layanan SSH ==="
bash "$SCRIPT_ADMIN"
EXIT_POS=$?
echo "Exit Status Uji Positif: $EXIT_POS"
if [ "$EXIT_POS" -eq 0 ]; then
    echo "[LULUS] Konfigurasi & layanan SSH berhasil (Exit status 0)."
else
    echo "[GAGAL] Script admin gagal dijalankan."
fi

echo ""
echo "=== 3. VERIFIKASI LOG & STATUS LAYANAN ==="
systemctl is-active ssh
tail -n 5 /var/log/ssh_admin.log

# Pembersihan akun dummy (pemulihan kondisi uji)
userdel -r "$TEST_USER" &>/dev/null
echo "[INFO] Kondisi uji telah dibersihkan."
