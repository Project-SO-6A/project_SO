#!/usr/bin/env bash
set -euo pipefail

apt-get update -y && apt-get install -y samba smbclient
mkdir -p /srv/share
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

systemctl restart smbd
