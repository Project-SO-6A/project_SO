# Catatan Anggota 1

STUDI KASUS 6A – ANGGOTA 1

Konfigurasi User, Group, Permission, dan ACL pada Linux

Nama Anggota:Chesya Ramadhani Putri Widodo  
Peran:Anggota 1  
Studi Kasus:6A

1. Tujuan Pengerjaan

Pengerjaan Anggota 1 bertujuan untuk melakukan konfigurasi hak akses pada sistem operasi Linux menggunakan user, group, permission, dan Access Control List (ACL). Konfigurasi ini dilakukan agar setiap pengguna memiliki hak akses sesuai dengan perannya, sehingga keamanan direktori bersama dapat terjaga.

2. Pembuatan Group

Pada tahap ini dibuat dua group, yaitu:

- operator: group untuk pengguna yang memiliki hak akses membaca, menulis, dan mengeksekusi.
- reader: group untuk pengguna yang hanya memiliki hak akses membaca dan mengeksekusi.

Pemisahan group dilakukan agar hak akses pengguna dapat dibedakan berdasarkan tugasnya.

3. Pembuatan User

Terdapat tiga user yang digunakan dalam pengujian:

| User | Group/Peran | Keterangan |
|---|---|---|
| operator1 | operator | Pengguna yang dapat mengelola file |
| reader1 | reader | Pengguna yang hanya dapat membaca |
| outsider1 | Di luar kedua group | Pengguna tanpa hak akses ke direktori |

Ketiga user tersebut digunakan untuk memastikan bahwa konfigurasi hak akses berjalan sesuai dengan peran masing-masing.

4. Pembuatan Direktori Bersama

Direktori bersama dibuat pada lokasi /srv/share.

Direktori ini digunakan sebagai tempat penyimpanan file yang akan diakses dan diuji oleh masing-masing pengguna.

5. Konfigurasi Permission

Permission direktori diatur menggunakan mode 2770.

Perintah yang digunakan:

bash
sudo chmod 2770 /srv/share


Pengaturan tersebut memberikan hak akses penuh kepada pemilik dan group yang ditetapkan, sedangkan pengguna lain tidak diberikan akses. Angka 2 pada permission digunakan untuk mengaktifkan setgid sehingga file atau direktori baru dapat mewarisi group direktori induknya.

6. Konfigurasi Access Control List (ACL)

ACL digunakan untuk mengatur hak akses group secara lebih spesifik.

Hak akses yang diterapkan adalah:

| Group | Hak akses | Keterangan |
|---|---|---|
| operator | rwx | Membaca, menulis, dan mengeksekusi |
| reader | r-x | Membaca dan mengeksekusi |
| others | --- | Tidak memiliki akses |

Pemeriksaan konfigurasi ACL dilakukan menggunakan perintah:

bash
getfacl /srv/share


Hasil pemeriksaan digunakan untuk memastikan bahwa hak akses setiap group sudah sesuai dengan konfigurasi yang diterapkan.

7. Pengujian Positif

Pengujian positif dilakukan menggunakan user operator1.

Pengujian ini bertujuan memastikan bahwa pengguna yang tergabung dalam group operator dapat mengakses direktori bersama dan membuat atau menulis file sesuai dengan hak akses yang diberikan.

Hasil:Pengguna operator1 berhasil melakukan pengujian pembuatan atau penulisan file pada direktori bersama.

8. Pengujian Negatif

Pengujian negatif dilakukan menggunakan user outsider1.

Pengujian ini bertujuan memastikan bahwa pengguna yang tidak memiliki hak akses tidak dapat membuat file pada direktori bersama.

Hasil:Pengguna outsider1 mendapatkan pesan Permission denied ketika mencoba membuat file pada direktori yang dibatasi.

Hasil tersebut menunjukkan bahwa pembatasan hak akses telah berjalan sesuai dengan konfigurasi.

9. Verifikasi Permission dan ACL

Setelah pengujian dilakukan, konfigurasi diperiksa kembali untuk memastikan hak akses sudah sesuai.

Perintah pemeriksaan yang digunakan:

bash
ls -ld /srv/share


bash
getfacl /srv/share


Verifikasi dilakukan untuk melihat permission direktori, group, serta aturan ACL yang telah diterapkan.

10. Persiapan File Pengujian

File data.txt disiapkan pada direktori /srv/share.

File tersebut digunakan sebagai objek pengujian hak akses membaca dan menulis bagi pengguna yang memiliki hak akses sesuai dengan perannya.

Lokasi file:

text
/srv/share/data.txt


11. Kesimpulan

Berdasarkan konfigurasi dan pengujian yang telah dilakukan, pengaturan user, group, permission, dan ACL pada direktori /srv/share telah diterapkan untuk membedakan hak akses setiap pengguna.

Pengguna operator1 berhasil melakukan pengujian positif, sedangkan outsider1 tidak dapat mengakses direktori untuk membuat file karena mendapatkan pesan Permission denied.

Dengan demikian, konfigurasi dasar hak akses pada Studi Kasus 6A telah diterapkan sesuai dengan pembagian peran pengguna.
