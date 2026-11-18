#!/usr/bin/env bash
set -euo pipefail

apt-get update -y && apt-get install -y samba smbclient

groupadd -f operator
id -u operator1 &>/dev/null || useradd -m -s /bin/bash operator1
id -u outsider1 &>/dev/null || useradd -m -s /bin/bash outsider1
usermod -aG operator operator1

mkdir -p /srv/share
chown -R root:operator /srv/share
chmod 2770 /srv/share

if ! grep -q "^\[DataShared\]" /etc/samba/smb.conf; then
  cat << 'SAMBA' >> /etc/samba/smb.conf

[DataShared]
   comment = Shared Directory Project SO
   path = /srv/share
   browseable = yes
   read only = no
   valid users = @operator @reader sisiliasakono
   write list = @operator sisiliasakono
   create mask = 0660
   directory mask = 2770
SAMBA
fi

printf 'Password123!\nPassword123!\n' | smbpasswd -s -a operator1 >/dev/null
printf 'Password123!\nPassword123!\n' | smbpasswd -s -a outsider1 >/dev/null
smbpasswd -e operator1 >/dev/null
smbpasswd -e outsider1 >/dev/null

systemctl restart smbd
