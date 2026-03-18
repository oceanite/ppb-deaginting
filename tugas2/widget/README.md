
---

## Penjelasan

### 1. Root Widget
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

## ⚙️ State Management

Aplikasi menggunakan `StatefulWidget` (`HomePage`) untuk mengelola data yang berubah.

