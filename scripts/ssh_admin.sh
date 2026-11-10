#!/bin/bash
# Script Administrasi SSH - Kelompok 6A (Anggota 4)

echo "=== Mula Pengaturan Hardening SSH ==="

if [ ! -f /etc/ssh/sshd_config.bak ]; then
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    echo "[+] Backup sshd_config berhasil dibuat."
fi

# Nonaktifkan login root via SSH
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# Batasi percobaan login gagal
echo "MaxAuthTries 3" | sudo tee -a /etc/ssh/sshd_config > /dev/null

sudo systemctl restart sshd
echo "[+] Service SSHD berhasil di-restart."
echo "=== Hardening SSH Selesai ==="

