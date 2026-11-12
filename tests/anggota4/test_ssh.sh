#!/bin/bash
# Skrip Pengujian Otomatis Administrasi SSH - Anggota 4
# Menguji validitas konfigurasi, status layanan sshd, serta skenario uji positif & negatif

echo "=========================================="
echo " PENGUJIAN ADMINISTRASI SSH (ANGGOTA 4)"
echo " Waktu Uji: $(date)"
echo "=========================================="

# Uji 1: Validasi sintaks file contoh konfigurasi
echo -e "\n[UJI 1 - POSITIF] Validasi sintaks config/sshd_config.example"
if sudo sshd -t -f config/sshd_config.example; then
    echo "HASIL: PASS - Sintaks config/sshd_config.example valid."
else
    echo "HASIL: FAIL - Sintaks config/sshd_config.example tidak valid."
    exit 1
fi

# Uji 2: Pengecekan parameter keamanan utama pada config/sshd_config.example
echo -e "\n[UJI 2 - POSITIF] Pengecekan parameter hardening SSH"
if grep -q "^PermitRootLogin no" config/sshd_config.example && \
   grep -q "^PasswordAuthentication no" config/sshd_config.example && \
   grep -q "^PubkeyAuthentication yes" config/sshd_config.example; then
    echo "HASIL: PASS - Parameter hardening utama (PermitRootLogin no, PasswordAuthentication no, PubkeyAuthentication yes) aktif."
else
    echo "HASIL: FAIL - Ada parameter hardening utama yang belum sesuai."
    exit 1
fi

# Uji 3: Pengecekan hak akses eksekusi skrip utama ssh_admin.sh
echo -e "\n[UJI 3 - POSITIF] Cek izin eksekusi scripts/ssh_admin.sh"
if [ -x "scripts/ssh_admin.sh" ]; then
    echo "HASIL: PASS - scripts/ssh_admin.sh memiliki izin eksekusi (+x)."
else
    echo "HASIL: FAIL - scripts/ssh_admin.sh belum executable."
    exit 1
fi

# Uji 4: Uji Negatif (Simulasi konfigurasi salah/tidak valid harus ditolak oleh sshd -t)
echo -e "\n[UJI 4 - NEGATIF] Simulasi konfigurasi SSH tidak valid"
TMP_BAD_CONF=$(mktemp)
echo "InvalidDirectiveSSH yes" > "$TMP_BAD_CONF"
if sudo sshd -t -f "$TMP_BAD_CONF" 2>/dev/null; then
    echo "HASIL: FAIL - Sistem gagal mendeteksi konfigurasi SSH yang salah."
    rm -f "$TMP_BAD_CONF"
    exit 1
else
    echo "HASIL: PASS - Sistem berhasil menolak konfigurasi SSH yang tidak valid (exit code != 0)."
fi
rm -f "$TMP_BAD_CONF"

# Uji 5: Cek status layanan/service SSH di sistem
echo -e "\n[UJI 5 - POSITIF] Cek status service SSH di sistem"
if systemctl is-active --quiet ssh || systemctl is-active --quiet sshd; then
    echo "HASIL: PASS - Layanan SSH aktif berjalan di sistem."
else
    echo "HASIL: INFO - Layanan SSH sedang tidak aktif (pastikan service ssh dijalankan saat demo)."
fi

echo -e "\n=========================================="
echo " SEMUA SKENARIO UJI SELESAI DIJALANKAN"
echo "=========================================="
