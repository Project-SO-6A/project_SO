
#!/bin/bash

# Script Administrasi SSH - Kelompok 6A (Anggota 4)

set -u

CONFIG_FILE="/etc/ssh/sshd_config"
BACKUP_FILE="/etc/ssh/sshd_config.bak.$(date +%Y%m%d_%H%M%S)"
LOG_FILE="/var/log/ssh_admin.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

echo "=== Administrasi SSH ==="

# Pastikan script dijalankan sebagai administrator
if [ "$EUID" -ne 0 ]; then
    echo "[ERROR] Jalankan script menggunakan sudo."
    exit 1
fi

# Backup konfigurasi sebelum perubahan
if cp "$CONFIG_FILE" "$BACKUP_FILE"; then
    log "[OK] Backup konfigurasi berhasil: $BACKUP_FILE"
else
    echo "[ERROR] Gagal membuat backup."
    exit 1
fi

# Atur PermitRootLogin
if grep -qE '^[[:space:]]*PermitRootLogin[[:space:]]+' "$CONFIG_FILE"; then
    sed -i 's/^[[:space:]]*PermitRootLogin.*/PermitRootLogin no/' "$CONFIG_FILE"
else
    echo "PermitRootLogin no" >> "$CONFIG_FILE"
fi

# Atur MaxAuthTries
if grep -qE '^[[:space:]]*MaxAuthTries[[:space:]]+' "$CONFIG_FILE"; then
    sed -i 's/^[[:space:]]*MaxAuthTries.*/MaxAuthTries 3/' "$CONFIG_FILE"
else
    echo "MaxAuthTries 3" >> "$CONFIG_FILE"
fi

# Validasi konfigurasi
if sshd -t; then
    log "[OK] Konfigurasi SSH valid."
else
    cp "$BACKUP_FILE" "$CONFIG_FILE"
    log "[ERROR] Konfigurasi tidak valid. Backup dipulihkan."
    echo "[ERROR] Validasi gagal."
    exit 1
fi

# Restart layanan SSH
if systemctl restart ssh; then
    log "[OK] Layanan SSH berhasil direstart."
else
    cp "$BACKUP_FILE" "$CONFIG_FILE"
    systemctl restart ssh
    log "[ERROR] Restart gagal. Backup dipulihkan."
    exit 1
fi

# Periksa status layanan
if systemctl is-active --quiet ssh; then
    log "[OK] Layanan SSH aktif."
    echo "[OK] Layanan SSH aktif."
else
    log "[ERROR] Layanan SSH tidak aktif."
    exit 1
fi

echo "=== Administrasi SSH Selesai ==="
