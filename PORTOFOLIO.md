# Portofolio Proyek Akhir Sistem Operasi

## Identitas
- **Nama**: Swastika Sisilia Saksono
- **Kelompok**: 6A (Anggota 2 - Samba dan Klien)
- **Tautan Repo**: https://github.com/Project-SO-6A/project_SO

---

## 1. Peran & Tanggung Jawab (Anggota 2)
Mengonfigurasi server Samba di Linux, menyelaraskan dengan permission Linux, serta memastikan otorisasi akun berwenang dan penolakan akun tak berwenang.

---

## 2. Pelaksanaan Skenario Pengujian

### Skenario Positif (Akses Berwenang)
- **Perintah**: `smbclient //127.0.0.1/DataShared -U sisiliasakono`
- **Hasil**: Berhasil autentikasi, mampu membaca dan membuat berkas.
- **Exit Status**: `0`

### Skenario Negatif (Akses Ditolak)
- **Perintah**: `smbclient //127.0.0.1/DataShared -U user_asing`
- **Hasil**: Akses ditolak (`NT_STATUS_ACCESS_DENIED`).
- **Exit Status**: `1`

---

## 3. Analisis Konsep Sistem Operasi
- **Autentikasi & Otorisasi**: Samba memvalidasi kredensial pengguna terhadap database `smbpasswd` dan memetakan hak akses berdasarkan parameter `valid users` pada `smb.conf`.
- **Proteksi Berkas & Access Control List (ACL)**: Keamanan berlapis di mana Samba mengecek izin jaringan dulu, kemudian Linux Kernel memeriksa POSIX permission (`chmod`/`chown`) direktori asli `/srv/samba/shared`.

---

## 4. Kendala dan Penyelesaian
- **Kendala**: Terjadi kegagalan resolusi domain (`Temporary failure resolving`) saat update package di Ubuntu.
- **Solusi**: Menambahkan DNS Google (`nameserver 8.8.8.8`) ke `/etc/resolv.conf`.

---

# Portofolio Individu - Anggota 3

- **Nama:** Ainnisya Rezka
- **NIM/Username:** AinnisyaRezka
- **Peran:** Anggota 3 - Pengujian & Audit Hak Akses Read-Only (Pembaca)

---

## 1. Tanggung Jawab & Kontribusi
- Mengonfigurasi dan menguji skema hak akses *Read-Only* pada Server Berkas Bersama.
- Memastikan grup pembaca hanya dapat melakukan operasi baca (*read/list*) dan dibatasi dari operasi modifikasi (*write/delete*).
- Membuat skrip pengujian otomatis `test_anggota3.sh`.

## 2. Hasil Pengujian
| Skenario Uji | Tindakan | Ekspektasi | Hasil |
| :--- | :--- | :--- | :--- |
| Uji Positif | Reading/Listing directory | Berhasil (Allowed) | PASS |
| Uji Negatif | Touch/Create new file | Permission Denied | PASS |
| Uji Negatif | Delete file | Permission Denied | PASS |

## 3. Eksekusi Pengujian
Skrip pengujian dapat dijalankan menggunakan perintah:
```bash
./test_anggota3.sh