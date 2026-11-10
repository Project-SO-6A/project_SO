# Portofolio Individu - Anggota 6

## Identitas
- Nama / NIM: Adelia Khalimatul Tausyiah / 2510512007
- Kelompok: 6A
- Proyek: Server Berkas Bersama dengan Backup dan Audit Akses (Pilihan 6A)
- Tanggung jawab: Monitoring, log, laporan, dan Docker

## Asal proyek
Proyek ini dikerjakan berkelompok, bukan karya pribadi seluruhnya.
- Repository utama: https://github.com/Project-SO-6A/project_SO
- Anggota:
1. Chesya Ramadhani Putri Widodo - 2510512003
2. Adelia Khalimatul Tausyiah - 2510512007
3. Swastika Sisilia Saksono - 2510512009
4. Ainnisya Rezka Putri - 2510512017
5. Nazwa Aulya Asri Pratama - 2510512019
6. Desvia Maharani Kurniawan - 2510512023

## Kontribusi pribadi
- `scripts/monitor.sh`: memeriksa status layanan, menulis log operasional, dan membuat laporan layanan dan backup. Kode keluar: 0 semua aktif, 1 ada layanan mati, 2 direktori tidak dapat ditulis.
- `tests/anggota6/`: bukti uji T6-01 sampai T6-06.
- Aktivitas Docker: container `alpine:3.20` membaca laporan melalui mount read-only.

## Bukti kontribusi
- Commit: [[tautan commit, misalnya 023890e]](https://github.com/adeliakhl/project_SO/commit/36571a264d16921ddc92d33feabf84d0b9979cae)

## Skenario individu
| ID | Skenario | Hasil |
| --- | --- | --- |
| T6-01 | Semua layanan aktif | [exit 0, laporan terisi] |
| T6-02 | Layanan dihentikan | [exit 1, tercatat tidak aktif] |
| T6-03 | Layanan dipulihkan | [exit 0, kembali aktif] |
| T6-04 | Log backup tidak ada | [laporan menyatakan tidak ada data] |
| T6-05 | Container membaca laporan | [exit 0, isi sama] |
| T6-06 | Container menulis ke mount read-only | [ditolak, checksum sama] |

Bukti lengkap: `tests/anggota6/`.

## Analisis konsep SO
[Hubungkan dengan proses layanan, penulisan log dan laporan, proteksi mount read-only, serta CPU dan memori.]

## Kendala dan penyelesaian
- SSH pada VM belum aktif (status inactive). Diselesaikan dengan `sudo systemctl enable --now ssh`.
- Login SSH dari Windows ditolak karena memakai username yang salah. Diselesaikan dengan memakai username VM yang benar.
- Remote Git salah karena repo utama berada di organisasi Project-SO-6A, bukan akun pribadi. Diselesaikan dengan fork dan `git remote set-url`.
- Commit terlanjur masuk ke main di fork. Diselesaikan dengan memindahkannya ke branch lalu membuat pull request.
- Fork tertinggal dari repo utama. Diselesaikan dengan Sync fork.

## Refleksi
[Yang sudah dikuasai dan yang masih perlu dipelajari, ditulis dengan kata-katamu sendiri.]
