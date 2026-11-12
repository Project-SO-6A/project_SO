#!/bin/bash
# Script Setup User, Group, dan Permission - Anggota 1 (Pilihan 6A)

LOG_FILE="/var/log/project_so_anggota1.log"
SHARE_DIR="/srv/share"
GROUPS=("operator" "reader")

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 1. Validasi hak akses root (Error handling & exit status)
if [[ $EUID -ne 0 ]]; then
    echo "ERROR: Script harus dijalankan dengan sudo atau sebagai root." >&2
    exit 1
fi

log_msg "=== Memulai konfigurasi User, Group, dan Permission ==="

# 2. Membuat Group (Perulangan & Percabangan)
for grp in "${GROUPS[@]}"; do
    if getent group "$grp" > /dev/null; then
        log_msg "INFO: Group '$grp' sudah ada."
    else
        groupadd "$grp" || { log_msg "ERROR: Gagal membuat group $grp"; exit 2; }
        log_msg "SUCCESS: Group '$grp' berhasil dibuat."
    fi
done

# 3. Membuat User dan memasukkan ke Group
create_user() {
    local username=$1
    local target_group=$2
    if id "$username" &>/dev/null; then
        log_msg "INFO: User '$username' sudah ada."
    else
        useradd -m -s /bin/bash "$username" || { log_msg "ERROR: Gagal membuat user $username"; exit 3; }
        echo "$username:Password123!" | chpasswd
        log_msg "SUCCESS: User '$username' berhasil dibuat."
    fi

    if [[ -n "$target_group" ]]; then
        usermod -aG "$target_group" "$username"
        log_msg "SUCCESS: User '$username' ditambahkan ke group '$target_group'."
    fi
}

create_user "operator1" "operator"
create_user "reader1" "reader"
create_user "outsider1" ""

# 4. Mengatur Direktori, Permission, dan ACL
mkdir -p "$SHARE_DIR"
chown root:operator "$SHARE_DIR"
chmod 2770 "$SHARE_DIR"

# Pastikan paket acl terpasang sebelum menjalankan setfacl
if ! command -v setfacl &> /dev/null; then
    log_msg "ERROR: Perintah setfacl tidak ditemukan. Install paket 'acl' terlebih dahulu."
    exit 4
fi

setfacl -m g:reader:rx "$SHARE_DIR"
setfacl -d -m g:operator:rwx "$SHARE_DIR"
setfacl -d -m g:reader:r-x "$SHARE_DIR"
setfacl -d -m o::--- "$SHARE_DIR"

log_msg "SUCCESS: Permission dan ACL pada $SHARE_DIR selesai dikonfigurasi."
exit 0