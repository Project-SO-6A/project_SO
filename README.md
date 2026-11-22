# Server Berkas Bersama dengan Backup dan Audit Akses

Proyek Akhir Sistem Operasi, Pilihan 6A (6 mahasiswa).
Program Studi S1 Sistem Informasi, FIK UPN "Veteran" Jakarta, 2026.
Dosen pengampu: Bobby Suryo Prakoso, S.T., M.Kom.

## Deskripsi

Sebuah unit kerja menyimpan berkas bersama di satu server. Operator boleh membaca dan mengubah berkas, pembaca hanya boleh membaca, dan pengguna di luar grup tidak boleh mengakses. Proyek ini mengonfigurasi hak akses tersebut (user, group, permission, ACL, dan Samba), administrasi server lewat SSH, backup dan restore dengan verifikasi checksum SHA-256, serta monitoring layanan yang menghasilkan log dan laporan. Satu aktivitas Docker membaca laporan dari host lewat mount read-only.

Seluruh pengujian memakai data dummy pada VM Linux. Laporan lengkap ada pada dokumen *Laporan Akhir Project Sistem Operasi*.

## Anggota

| No | Nama | NIM | Komponen |
| --- | --- | --- | --- |
| 1 | Chesya Ramadhani Putri Widodo | 2510512003 | User, group, permission, ACL |
| 2 | Swastika Sisilia Saksono | 2510512009 | Samba dan klien |
| 3 | Ainnisya Rezka Putri | 2510512017 | Hak pembaca |
| 4 | Desvia Maharani Kurniawan | 2510512023 | Administrasi SSH |
| 5 | Nazwa Aulya Asri Pratama | 2510512019 | Backup dan restore |
| 6 | Adelia Khalimatul Tausyiah | 2510512007 | Monitoring, log, laporan, Docker |

## Lingkungan

| Komponen | Versi |
| --- | --- |
| Sistem operasi | Ubuntu 26.04 LTS (Resolute Raccoon), VirtualBox |
| Kernel | 7.0.0-15-generic  |
| Spesifikasi VM | Pengukuran CPU dan memori Anggota 4 pada VM 1 vCPU, RAM 5872 MB total (swap 2414 MB)  |
| OpenSSH | 10.2p1 |
| Samba | 4.23.6 |
| Docker | 29.1.3 |
| Image Docker | `alpine:3.20`, digest `sha256:d9e853e87e55526f6b2917df91a2115c36dd7c696a35be12163d44e6e2a4b6bc` (12,2 MB) |

## Struktur repository

| Lokasi | Isi |
| --- | --- |
| `scripts/setup_user_perm.sh` | User, group, permission, dan ACL pada `/srv/share` |
| `scripts/ssh_admin.sh` | Administrasi dan hardening SSH |
| `scripts/backup.sh`, `scripts/restore.sh` | Backup dengan checksum dan pemulihan |
| `scripts/monitor.sh` | Monitoring layanan, log operasional, dan laporan |
| `config/sshd_config.example` | Contoh konfigurasi SSH |
| `config/smb.conf` | Contoh konfigurasi Samba tanpa password. Berkas aktif ada di `/etc/samba/smb.conf` |
| `tests/anggota2/test_samba.sh` | Uji akses Samba |
| `tests/anggota3/test_anggota3.sh`, `hasil_uji.txt` | Uji hak pembaca dan buktinya |
| `tests/anggota4/test_ssh.sh` | Uji administrasi SSH |
| `evidence/uji_ssh_anggota4.txt` | Bukti uji SSH |
| `tests/anggota5/` | Catatan dan bukti backup dan restore |
| `tests/anggota6/` | Bukti T6-01 sampai T6-06 dan `run_tests.sh` |

Folder `logs/` dan `output/` dibuat saat dijalankan dan tidak ikut di repo.

## Instalasi

```bash
sudo apt install -y git acl samba openssh-server docker.io
sudo systemctl enable --now docker smbd
sudo docker pull alpine:3.20

git clone https://github.com/Project-SO-6A/project_SO.git
cd project_SO
chmod +x scripts/*.sh tests/anggota*/*.sh
mkdir -p logs output
sudo groupadd -f operator
sudo groupadd -f reader
```

Catatan:
- `logs/` dan `output/` dibuat **sebagai user biasa sebelum** `backup.sh`. Skrip itu memakai `sudo`, sehingga kalau foldernya dibuat belakangan, dimiliki root dan `monitor.sh` berhenti dengan kode keluar 2.
- Skrip yang ditulis di Windows berakhiran CRLF. Jika muncul `command not found`, jalankan `sed -i 's/\r$//' NAMA_SKRIP`.

## Menjalankan

| Langkah | Perintah |
| --- | --- |
| 1. User, group, permission (Anggota 1 dan 3) | `sudo bash scripts/setup_user_perm.sh` |
| 2. Samba (Anggota 2) | Terapkan blok `[DataShared]` pada `/etc/samba/smb.conf`, daftarkan user dengan `smbpasswd`, lalu `sudo systemctl restart smbd` |
| 3. SSH (Anggota 4) | `sudo sshd -t -f config/sshd_config.example`, lalu `sudo ./scripts/ssh_admin.sh` |
| 4. Backup (Anggota 5) | `sudo bash scripts/backup.sh` |
| 5. Restore (Anggota 5) | `sudo bash scripts/restore.sh` {{tambahkan argumen jika ada}} |
| 6. Monitoring (Anggota 6) | `SERVICES_LIST="smbd ssh" ./scripts/monitor.sh` |

Ringkasan:
- Folder berkas bersama: `/srv/share`. Folder backup: `/srv/backup`. Folder hasil restore uji: `/srv/restore_test`.
- Akun uji: `operator1` (group `operator`), `reader1` (group `reader`), `outsider1` (di luar kedua group). Password akun uji adalah password dummy. Akun admin memakai hak `sudo`.
- Share Samba bernama `DataShared`, mengarah ke `/srv/share`. Parameter `valid users` dan `write list` membatasi siapa yang boleh masuk dan menulis.
- Arsip backup bernama `share_TANGGAL_JAM.tar.gz` dan disertai berkas `.sha256`.
- Log backup: `logs/backup.log`, format `WAKTU|STATUS|NAMA_ARSIP|KETERANGAN`.
- `monitor.sh` menulis `logs/operasional.log` dan `output/laporan.txt`. Kode keluar: 0 semua layanan aktif, 1 ada layanan tidak aktif, 2 folder `logs` atau `output` tidak bisa ditulis. Variabel opsional: `SERVICES_LIST` (daftar layanan, bawaan `smbd ssh`) dan `BACKUP_LOG` (lokasi log backup).

## Menguji

| Anggota | Perintah | Yang diuji |
| --- | --- | --- |
| 1 | {{isi perintah uji Anggota 1}} | `operator1` menulis, `outsider1` ditolak |
| 2 | `bash tests/anggota2/test_samba.sh` | `operator1` masuk, `outsider1` ditolak |
| 3 | `sudo -u reader1 bash /tmp/test_anggota3.sh` (salin skrip ke `/tmp` dulu) | Pembaca membaca, tidak bisa membuat atau menghapus |
| 4 | `bash tests/anggota4/test_ssh.sh` | Validasi SSH, penolakan akun biasa, login `operator1` |
| 5 | {{isi perintah uji Anggota 5}} | Restore identik (`diff -r`), arsip rusak ditolak |
| 6 | `bash tests/anggota6/run_tests.sh` | Deteksi layanan berhenti dan pulih, laporan, Docker read-only |

`run_tests.sh` menjalankan enam skenario (T6-01 sampai T6-06), mencetak `LULUS` atau `GAGAL`, dan menyimpan bukti ke `tests/anggota6/integrasi_*.txt`. Skrip ini sementara menghentikan `smbd` lalu menyalakannya lagi secara otomatis.

## Docker (read-only)

Image `alpine:3.20` diunduh lebih dulu (lihat Instalasi). Jalankan dari direktori utama proyek, setelah `monitor.sh` menghasilkan `output/laporan.txt`:

```bash
# uji positif: container membaca laporan
sudo docker run --rm --mount type=bind,src="$(pwd)/output",dst=/data,readonly alpine:3.20 cat /data/laporan.txt; echo "exit=$?"

# checksum sebelum
sha256sum output/laporan.txt | tee /tmp/sebelum.txt

# uji negatif: penulisan ditolak
sudo docker run --rm --mount type=bind,src="$(pwd)/output",dst=/data,readonly alpine:3.20 sh -c 'echo "uji" >> /data/laporan.txt'; echo "exit=$?"

# checksum sesudah
sha256sum output/laporan.txt | diff - /tmp/sebelum.txt && echo "checksum sama"
```

Hasil yang benar: laporan tampil dengan `exit=0`, penulisan ditolak dengan pesan `Read-only file system` (`exit=1`), dan `checksum sama`. Opsi `readonly` hanya melindungi folder yang di-mount.

## Pemulihan dan pembersihan

```bash
sudo systemctl start smbd                          # jika sempat dihentikan saat uji
sudo rm -f /srv/share/uji*.txt                     # berkas uji di folder share
SERVICES_LIST="smbd ssh" ./scripts/monitor.sh      # laporan kembali normal
```

- Arsip uji di `/srv/backup` dan hasil restore di `/srv/restore_test` boleh dihapus kalau tidak diperlukan.
- Untuk mengembalikan VM sepenuhnya, gunakan snapshot yang diambil sebelum pengujian.
- Jalankan skrip dan uji pada VM khusus proyek dengan data dummy, bukan pada sistem produksi.

## Matriks skenario dan hasil

| ID | Penanggung jawab | Positif | Negatif | Hasil aktual | Status | Bukti |
| --- | --- | --- | --- | --- | --- | --- |
| T1-01, T1-02 | Chesya Ramadhani Putri Widodo | `operator1` membuat dan menulis berkas di `/srv/share` | `outsider1` membuat berkas ditolak | Positif: exit 0, berkas terbentuk dan terbaca. Negatif: `Permission denied`, berkas tidak terbentuk | Lulus | Laporan 5.1 |
| T2-01, T2-02 | Swastika Sisilia Saksono | `operator1` mengakses share `DataShared` | `outsider1` ditolak | Positif: sesi terbentuk, isi direktori terbaca, exit 0. Negatif: `NT_STATUS_ACCESS_DENIED`, exit 1 | Lulus | `tests/anggota2/test_samba.sh` |
| T3-01, T3-02 | Ainnisya Rezka Putri | `reader1` membaca daftar berkas di `/srv/share` | `reader1` membuat dan menghapus berkas ditolak | Positif: berhasil (exit 0). Negatif: `Permission Denied` | Lulus | `tests/anggota3/hasil_uji.txt` |
| T4-01, T4-02, T4-03 | Desvia Maharani Kurniawan | `sshd -t` pada `sshd_config.example` valid, layanan SSH aktif, login `operator1@localhost` berhasil | Akun biasa menjalankan `ssh_admin.sh` tanpa sudo ditolak | Positif: exit 0. Negatif: akses ditolak, exit bukan 0 | Lulus | `evidence/uji_ssh_anggota4.txt` |
| T5-01, T5-02 | Nazwa Aulya Asri Pratama | Backup dibuat, checksum SHA-256 OK, restore ke `/srv/restore_test`, `diff -r` tanpa perbedaan | Arsip rusak (dipotong 100 byte) ditolak sebelum restore | Positif: berhasil. Negatif: pemeriksaan checksum gagal, restore dibatalkan, exit 1 | Lulus | Laporan 5.5 |
| T6-01 | Adelia Khalimatul Tausyiah | Semua layanan aktif, `monitor.sh` dijalankan | - | Kode keluar 0, laporan dan log terisi | Lulus | `tests/anggota6/` |
| T6-02, T6-03 | Adelia Khalimatul Tausyiah | `smbd` dijalankan lagi, kembali aktif | `smbd` dihentikan, terdeteksi tidak aktif | Negatif: kode keluar 1, `smbd : TIDAK AKTIF`, log ERROR. Positif: kode keluar 0, PID baru | Lulus | `tests/anggota6/integrasi_T6-01_T6-03.txt` |
| T6-04 | Adelia Khalimatul Tausyiah | - | Log backup tidak tersedia | Laporan menulis `TIDAK ADA DATA BACKUP`, log WARN | Lulus | `tests/anggota6/integrasi_T6-04.txt` |
| T6-05, T6-06 | Adelia Khalimatul Tausyiah | Container membaca `laporan.txt` | Container menulis ke mount read-only | Positif: exit 0, isi sama dengan host. Negatif: `Read-only file system`, exit 1, checksum sama | Lulus | `tests/anggota6/integrasi_T6-05_T6-06.txt` |

## Matriks kontribusi

| Nama | Komponen | Bagian laporan | ID skenario | Commit / PR |
| --- | --- | --- | --- | --- |
| Chesya Ramadhani Putri Widodo | User, group, permission | 3.1 | T1-01, T1-02 | PR #15, skrip `c762f10`, perbaikan `adb6a01`. Fork: https://github.com/chesyawidodo21/project_SO |
| Swastika Sisilia Saksono | Samba dan klien | 3.2 | T2-01, T2-02 | PR #11 (`c371f61`), `2716dd5`. Fork: {{isi}} |
| Ainnisya Rezka Putri | Hak pembaca | 3.3 | T3-01, T3-02 | [PR #20](https://github.com/Project-SO-6A/project_SO/pull/20) (commit `88eb393`, merge `96529cb`). Fork: {{isi}} |
| Desvia Maharani Kurniawan | Administrasi SSH | 3.4 | T4-01, T4-02 | [PR #17](https://github.com/Project-SO-6A/project_SO/pull/17) (merge `19a595e`), PR #10 (`e65c6e7`). Fork: {{isi}} |
| Nazwa Aulya Asri Pratama | Backup dan restore | 3.5 | T5-01, T5-02 | [PR #18](https://github.com/Project-SO-6A/project_SO/pull/18), commit `8f032c7`. Fork: {{isi}} |
| Adelia Khalimatul Tausyiah | Monitoring, log, laporan, Docker | 3.6 | T6-01 sampai T6-06 | PR #1 (`023890e`), `abfcd57`, PR {{nomor PR bukti integrasi}}. Fork: https://github.com/adeliakhl/project_SO |

## Keterbatasan

- Monitoring dan backup dijalankan manual (on-demand) dan belum dijadwalkan dengan `cron` atau systemd timer.
- Penulisan `logs/operasional.log` belum memakai penguncian berkas (`flock`), sehingga dua proses `monitor.sh` yang berjalan bersamaan berisiko membuat entri log tercampur.
- Sistem belum memakai autentikasi terpusat (LDAP atau Active Directory) maupun enkripsi data di `/srv/share`.
- Perlindungan `readonly` pada Docker hanya berlaku pada folder yang di-mount.
- `setup_user_perm.sh` memuat password dummy untuk akun uji (`operator1`, `reader1`, `outsider1`). Password itu hanya untuk VM uji dan bukan kredensial sebenarnya.
