#!/bin/bash
# Script Pengujian Positif & Negatif - Anggota 1

SHARE_DIR="/srv/share"
TEST_FILE="$SHARE_DIR/data.txt"

echo "=== [UJI POSITIF] Operator menulis berkas ke $SHARE_DIR ==="
sudo -u operator1 bash -c "echo 'Data pengujian operator' > $TEST_FILE"
STATUS_POS=$?
echo "Exit status uji positif: $STATUS_POS (Harus 0)"

if [[ $STATUS_POS -eq 0 ]]; then
    echo "HASIL: LULUS - operator1 berhasil menulis berkas."
else
    echo "HASIL: GAGAL - operator1 tidak dapat menulis berkas."
    exit 1
fi

echo ""
echo "=== [UJI NEGATIF] Outsider mencoba mengakses dan menulis ke $SHARE_DIR ==="
sudo -u outsider1 touch "$SHARE_DIR/ilegal.txt" 2>/dev/null
STATUS_NEG=$?
echo "Exit status uji negatif: $STATUS_NEG (Harus bukan 0)"

if [[ $STATUS_NEG -ne 0 ]]; then
    echo "HASIL: LULUS - Akses outsider1 berhasil ditolak oleh sistem."
else
    echo "HASIL: GAGAL - outsider1 berhasil menembus direktori!"
    exit 1
fi

echo ""
echo "Semua pengujian Anggota 1 selesai dan siap dilanjutkan oleh Anggota 2 (Samba)."
exit 0