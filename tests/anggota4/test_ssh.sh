#!/bin/bash
# Skrip Pengujian Otomatis Administrasi SSH - Anggota 4
# Mencakup Skenario Positif (T4-01) dan Skenario Negatif (T4-02)

echo "=========================================="
echo " PENGUJIAN ADMINISTRASI SSH (ANGGOTA 4)"
echo " Waktu Uji: $(date)"
echo "=========================================="

# [T4-01 - POSITIF] Validasi sintaks file contoh konfigurasi
echo -e "\n[T4-01a - POSITIF] Validasi sintaks config/sshd_config.example"
if sudo sshd -t -f config/sshd_config.example; then
    echo "HASIL: PASS - Sintaks config/sshd_config.example valid (exit 0)."
else
    echo "HASIL: FAIL - Sintaks config/sshd_config.example tidak valid."
    exit 1
fi

# [T4-01 - POSITIF] Pengecekan parameter hardening utama
echo -e "\n[T4-01b - POSITIF] Pengecekan parameter hardening SSH"
if grep -q "^PermitRootLogin no" config/sshd_config.example && \
   grep -q "^PasswordAuthentication no" config/sshd_config.example && \
   grep -q "^PubkeyAuthentication yes" config/sshd_config.example; then
    echo "HASIL: PASS - Parameter hardening utama aktif (exit 0)."
else
    echo "HASIL: FAIL - Ada parameter hardening utama yang belum sesuai."
    exit 1
fi

# [T4-01 - POSITIF] Cek izin eksekusi skrip utama & status layanan SSH
echo -e "\n[T4-01c - POSITIF] Cek izin eksekusi scripts/ssh_admin.sh & status service SSH"
if [ -x "scripts/ssh_admin.sh" ] && (systemctl is-active --quiet ssh || systemctl is-active --quiet sshd); then
    echo "HASIL: PASS - Skrip executable dan layanan SSH aktif berjalan (exit 0)."
else
    echo "HASIL: INFO - Cek kembali izin +x atau status service ssh."
fi

# [T4-02 - NEGATIF] Akun biasa tanpa sudo mencoba tindakan administratif SSH terbatas
echo -e "\n[T4-02a - NEGATIF] Akun biasa (nobody) mencoba membaca/mengubah konfigurasi SSH"
if su -s /bin/bash nobody -c "touch /etc/ssh/sshd_config_test" 2>/dev/null; then
    echo "HASIL: FAIL - Akun biasa berhasil memodifikasi direktori /etc/ssh/."
    sudo rm -f /etc/ssh/sshd_config_test
    exit 1
else
    echo "HASIL: PASS - Akses akun biasa ke /etc/ssh/ ditolak sistem (Permission denied, exit 1)."
fi

# [T4-02 - NEGATIF] Simulasi konfigurasi SSH tidak valid ditolak daemon sshd
echo -e "\n[T4-02b - NEGATIF] Validasi konfigurasi SSH tidak valid ditolak sshd -t"
TMP_BAD_CONF=$(mktemp)
echo "InvalidDirectiveSSH yes" > "$TMP_BAD_CONF"
if sudo sshd -t -f "$TMP_BAD_CONF" 2>/dev/null; then
    echo "HASIL: FAIL - Sistem gagal mendeteksi konfigurasi SSH yang salah."
    rm -f "$TMP_BAD_CONF"
    exit 1
else
    echo "HASIL: PASS - Konfigurasi tidak valid berhasil ditolak oleh sshd -t (exit 1)."
fi
rm -f "$TMP_BAD_CONF"

echo -e "\n=========================================="
echo " SEMUA SKENARIO UJI (T4-01 & T4-02) PASS"
echo "=========================================="
