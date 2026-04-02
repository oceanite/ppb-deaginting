
---
## Hasil

![WhatsApp Image 2026-03-18 at 10 03 30 AM](https://github.com/user-attachments/assets/4d402083-0fc2-4383-90c0-fb456cfc3f7a)


## Widget tree

<img width="8191" height="4281" alt="MyApp MaterialApp Structure-2026-03-18-032856" src="https://github.com/user-attachments/assets/cf65642a-1fe9-4232-b7f3-42fdcdfd651d" />



## Penjelasan

### 1. Root widget
- `runApp()` digunakan untuk menjalankan aplikasi.
- `MyApp` merupakan widget utama yang mengembalikan `MaterialApp`.

### 2. MaterialApp
- Menyediakan struktur dasar aplikasi Flutter.
- Menghilangkan debug banner.
- Menentukan `HomePage` sebagai halaman utama.

### 3. Scaffold
- Kerangka utama layout aplikasi.
- Terdiri dari:
  - `AppBar` → bagian atas aplikasi
  - `Body` → isi utama aplikasi

---

## Layout Body (Column)

Widget `Column` digunakan untuk menyusun elemen secara **vertikal**:

### Bagian Gambar
- Menggunakan `Container` yang berisi `Image.network`
- Menampilkan gambar dari internet

### Bagian Pertanyaan
- `Container` dengan `Text`
- Menampilkan teks: **"What image is that?"**

### Bagian Menu
- Menggunakan `Row` untuk menyusun secara horizontal
- Terdiri dari 3 widget `MenuItem`:
  - Food
  - Scenery
  - People

### Bagian Counter
- `Row` berisi:
  - Teks counter
  - Tombol "+" menggunakan `GestureDetector`

---

## Widget Reusable: MenuItem

`MenuItem` adalah `StatelessWidget` yang digunakan untuk menghindari pengulangan kode.

Struktur:

Column

├── Icon

├── SizedBox

└── Text


---

## State Management

Aplikasi menggunakan `StatefulWidget` (`HomePage`) untuk mengelola data yang berubah.

