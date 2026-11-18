#!/usr/bin/env bash
# run_tests.sh - Anggota 6: uji monitoring, log, laporan, dan Docker
# Cara pakai (dari folder proyek): bash tests/anggota6/run_tests.sh
set -u
cd "$(dirname "${BASH_SOURCE[0]}")/../.." || exit 2

SERVICES="${SERVICES_LIST:-smbd ssh}"
STOP_SVC="${STOP_SVC:-smbd}"
IMAGE="${DOCKER_IMAGE:-alpine:3.20}"
EVID="tests/anggota6"

for f in scripts/monitor.sh; do
  [ -x "$f" ] || { echo "ERROR: $f tidak ditemukan atau tidak executable" >&2; exit 2; }
done
mkdir -p logs output
sudo -v || exit 2
trap 'sudo systemctl start "$STOP_SVC" >/dev/null 2>&1' EXIT

lulus() { echo "HASIL $1: LULUS"; }
gagal() { echo "HASIL $1: GAGAL"; }
cek()   { if eval "$2"; then lulus "$1"; else gagal "$1"; fi; }
cmd()   { echo; echo "\$ $*"; }

t_monitor() {
  echo "### T6-01 semua layanan aktif - $(date '+%F %T')"
  cmd "SERVICES_LIST=\"$SERVICES\" ./scripts/monitor.sh"
  SERVICES_LIST="$SERVICES" ./scripts/monitor.sh; rc=$?
  echo "exit=$rc"
  cmd "cat output/laporan.txt"; cat output/laporan.txt
  cek T6-01 '[ $rc -eq 0 ]'

  echo; echo "### T6-02 layanan $STOP_SVC dihentikan"
  cmd "sudo systemctl stop $STOP_SVC"; sudo systemctl stop "$STOP_SVC"
  cmd "SERVICES_LIST=\"$SERVICES\" ./scripts/monitor.sh"
  SERVICES_LIST="$SERVICES" ./scripts/monitor.sh; rc=$?
  echo "exit=$rc"
  cmd "grep -E \"$STOP_SVC|ssh\" output/laporan.txt"; grep -E "$STOP_SVC|ssh" output/laporan.txt
  cmd "tail -n 3 logs/operasional.log"; tail -n 3 logs/operasional.log
  cek T6-02 '[ $rc -eq 1 ] && grep -q "$STOP_SVC : TIDAK AKTIF" output/laporan.txt'

  echo; echo "### T6-03 layanan $STOP_SVC dipulihkan"
  cmd "sudo systemctl start $STOP_SVC"; sudo systemctl start "$STOP_SVC"
  cmd "SERVICES_LIST=\"$SERVICES\" ./scripts/monitor.sh"
  SERVICES_LIST="$SERVICES" ./scripts/monitor.sh; rc=$?
  echo "exit=$rc"
  cmd "grep -E \"$STOP_SVC|ssh\" output/laporan.txt"; grep -E "$STOP_SVC|ssh" output/laporan.txt
  cek T6-03 '[ $rc -eq 0 ] && grep -q "$STOP_SVC : AKTIF" output/laporan.txt'
}

t_nobackup() {
  echo "### T6-04 log backup tidak tersedia - $(date '+%F %T')"
  cmd "BACKUP_LOG=/tmp/tidak_ada.log SERVICES_LIST=\"$SERVICES\" ./scripts/monitor.sh"
  BACKUP_LOG=/tmp/tidak_ada.log SERVICES_LIST="$SERVICES" ./scripts/monitor.sh; rc=$?
  echo "exit=$rc"
  cmd "grep -A1 \"Backup terakhir\" output/laporan.txt"; grep -A1 "Backup terakhir" output/laporan.txt
  cmd "grep WARN logs/operasional.log | tail -n 1"; grep WARN logs/operasional.log | tail -n 1
  cek T6-04 '[ $rc -eq 0 ] && grep -q "TIDAK ADA DATA BACKUP" output/laporan.txt'
}

t_docker() {
  echo "### T6-05 container membaca laporan - $(date '+%F %T')"
  cmd "docker run --rm --mount type=bind,src=\"\$(pwd)/output\",dst=/data,readonly $IMAGE cat /data/laporan.txt"
  sudo docker run --rm --mount type=bind,src="$(pwd)/output",dst=/data,readonly "$IMAGE" cat /data/laporan.txt > /tmp/dari_container.txt; rc=$?
  cat /tmp/dari_container.txt
  echo "exit=$rc"
  cmd "diff /tmp/dari_container.txt output/laporan.txt"
  diff /tmp/dari_container.txt output/laporan.txt && echo "isi sama dengan host"
  cek T6-05 '[ $rc -eq 0 ] && diff -q /tmp/dari_container.txt output/laporan.txt >/dev/null'

  echo; echo "### T6-06 penulisan ke mount read-only ditolak"
  cmd "sha256sum output/laporan.txt"; sha256sum output/laporan.txt | tee /tmp/sebelum.txt
  cmd "docker run --rm --mount type=bind,src=\"\$(pwd)/output\",dst=/data,readonly $IMAGE sh -c 'echo \"uji\" >> /data/laporan.txt'"
  sudo docker run --rm --mount type=bind,src="$(pwd)/output",dst=/data,readonly "$IMAGE" sh -c 'echo "uji" >> /data/laporan.txt'; rc=$?
  echo "exit=$rc"
  cmd "sha256sum output/laporan.txt"; sha256sum output/laporan.txt
  sha256sum output/laporan.txt | diff - /tmp/sebelum.txt >/dev/null && echo "checksum sama"
  cek T6-06 '[ $rc -ne 0 ] && sha256sum output/laporan.txt | diff - /tmp/sebelum.txt >/dev/null'
}

clear
t_monitor  2>&1 | tee "$EVID/integrasi_T6-01_T6-03.txt"
echo
t_nobackup 2>&1 | tee "$EVID/integrasi_T6-04.txt"
SERVICES_LIST="$SERVICES" ./scripts/monitor.sh >/dev/null 2>&1   # laporan normal kembali
echo
t_docker   2>&1 | tee "$EVID/integrasi_T6-05_T6-06.txt"
echo; echo "Selesai. Bukti tersimpan di $EVID/integrasi_*.txt"
