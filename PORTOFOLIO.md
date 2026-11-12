# Portofolio Individu - Anggota 3

* **Nama:** Ainnisya Rezka
* **NIM/Username:** AinnisyaRezka
* **Peran:** Anggota 3 - Pengujian & Audit Hak Akses Read-Only (Pembaca)

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