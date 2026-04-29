# 📚 LogAsdos — Digital Assistant Logbook

> Aplikasi mobile berbasis Flutter untuk mendigitalisasi proses pencatatan dan verifikasi aktivitas Asisten Dosen secara real-time.

---

## 🎬 Demo Video

<!-- Tempel link video demo di bawah ini -->

[![Demo LogAsdos](https://img.shields.io/badge/▶%20Tonton%20Demo-YouTube-red?style=for-the-badge&logo=youtube)](LINK_VIDEO_DI_SINI)

> **Link Video:** `https://` _(ganti dengan link YouTube / Google Drive / platform lainnya)_

---

## 📋 Daftar Isi

- [Latar Belakang](#-latar-belakang)
- [Tujuan Proyek](#-tujuan-proyek)
- [Fitur Utama](#-fitur-utama)
- [Role Pengguna](#-role-pengguna)
- [Arsitektur & Teknologi](#-arsitektur--teknologi)
- [Struktur Database](#-struktur-database)
- [Struktur Proyek](#-struktur-proyek)
- [Cara Menjalankan](#-cara-menjalankan)
- [Setup Firebase](#-setup-firebase)
- [Akun Demo](#-akun-demo)
- [Kesesuaian Kriteria Tugas](#-kesesuaian-kriteria-tugas)
- [Screenshot](#-screenshot)

---

## 🔍 Latar Belakang

Proses pencatatan aktivitas Asisten Dosen (Asdos) saat ini mayoritas masih dilakukan secara **manual** menggunakan dokumen teks (Microsoft Word). Hal ini menimbulkan beberapa kendala:

| Masalah | Dampak |
|---|---|
| Pencatatan manual di dokumen Word | Inefisiensi — asdos harus membuka laptop setiap selesai kelas |
| Tidak ada bukti kehadiran | Sulit bagi dosen memverifikasi apakah aktivitas benar dilakukan |
| Proses verifikasi lambat | Dosen memeriksa file satu per satu di akhir semester |
| Tidak ada notifikasi pengingat | Asdos sering lupa mengisi log setelah kelas selesai |

**LogAsdos** hadir sebagai solusi aplikasi mobile yang mendigitalisasi seluruh proses ini dengan validasi foto, notifikasi otomatis, dan verifikasi real-time oleh dosen.

---

## 🎯 Tujuan Proyek

1. Menggantikan pencatatan manual dengan sistem digital berbasis mobile.
2. Memvalidasi kehadiran asdos melalui fitur kamera (foto kelas/screenshot Zoom).
3. Memfasilitasi dosen dalam menyetujui atau menolak laporan aktivitas secara massal.
4. Memberikan admin kontrol penuh atas manajemen pengguna dan kelas.
5. Mendukung mode **offline-first** — data tetap bisa diakses tanpa internet.

---

## ✨ Fitur Utama

### 👤 Admin
- Dashboard statistik sistem (total pengguna, kelas, aktivitas, pending review)
- Manajemen pengguna — buat akun Dosen & Asdos (tanpa register mandiri)
- Manajemen kelas — buat, edit, hapus kelas dengan input waktu via **TimePicker**
- Assign/unassign Asdos ke kelas tertentu
- Assign Dosen pengampu ke kelas

### 🎓 Asisten Dosen
- Login menggunakan kredensial yang dibuat Admin
- Dashboard kelas hari ini + statistik log pribadi
- Input log aktivitas: kategori (Mengajar / Kuis / Praktikum), deskripsi, mode (Luring/Daring)
- Upload bukti foto via **kamera langsung** atau **galeri** (Cloudinary CDN)
- Riwayat aktivitas dengan filter status (Semua / Pending / Disetujui / Ditolak)
- Notifikasi **30 menit sebelum kelas** dimulai
- Notifikasi **2 jam setelah kelas** selesai jika log belum diisi
- Notifikasi saat log disetujui atau ditolak dosen
- Ganti password

### 👨‍🏫 Dosen
- Dashboard daftar Asdos + jumlah log pending
- Review aktivitas Asdos beserta foto bukti
- **Bulk Approval** — pilih semua / beberapa log sekaligus → setujui / tolak
- Isi alasan penolakan saat menolak log
- Konfirmasi dialog sebelum aksi bulk dieksekusi
- Ganti password

---

## 👥 Role Pengguna

```
Admin
  └── Membuat akun Dosen & Asdos
  └── Membuat & mengelola kelas
  └── Assign Dosen dan Asdos ke kelas

Dosen
  └── Melihat aktivitas Asdos di kelasnya
  └── Approve / Reject log (satuan atau bulk)

Asdos
  └── Input log aktivitas harian
  └── Upload foto bukti
  └── Melihat status approval
```

> **Catatan:** Asdos dan Dosen **tidak bisa mendaftar sendiri**. Akun hanya bisa dibuat oleh Admin melalui panel manajemen pengguna.

---

## 🏗 Arsitektur & Teknologi

### Framework & Language
| Komponen | Teknologi |
|---|---|
| Framework | Flutter 3.x (Dart) |
| State Management | Provider (`ChangeNotifier`) |
| Navigasi | Navigator 2.0 (MaterialPageRoute) |

### Backend & Cloud
| Komponen | Teknologi | Fungsi |
|---|---|---|
| Authentication | Firebase Auth | Login email/password, ganti password, reset password |
| Database Cloud | Cloud Firestore | Sumber data utama (source of truth) |
| Storage Foto | Cloudinary Free Tier | Upload & host foto bukti aktivitas (25 GB/bulan gratis) |
| Cache Lokal | SQLite (sqflite) | Offline-first cache untuk Asdos |

### Library Utama
| Library | Versi | Fungsi |
|---|---|---|
| `firebase_core` | ^2.27.1 | Inisialisasi Firebase |
| `firebase_auth` | ^4.17.8 | Autentikasi pengguna |
| `cloud_firestore` | ^4.15.8 | Database cloud real-time |
| `sqflite` | ^2.3.0 | SQLite lokal (cache offline) |
| `image_picker` | ^1.0.7 | Akses kamera & galeri |
| `flutter_local_notifications` | ^16.x | Notifikasi lokal terjadwal |
| `timezone` | ^0.9.x | Zona waktu untuk penjadwalan notifikasi |
| `provider` | ^6.1.2 | State management |
| `connectivity_plus` | ^5.0.2 | Deteksi status koneksi internet |
| `http` | ^1.2.0 | Upload foto ke Cloudinary |

### Alur Data (Offline-First)

```
Login → Firebase Auth
         ↓
    Profil user ← Firestore /users/{uid}
         ↓
  AppProvider.loadData()
  ┌──────────────────────────────────────┐
  │ Online  → Firestore → SQLite (cache) │
  │ Offline → SQLite cache               │
  └──────────────────────────────────────┘
         ↓
    UI dirender dari state AppProvider

Input Aktivitas (Asdos):
  Pilih foto (kamera/galeri)
       ↓
  Upload → Cloudinary CDN → dapat URL
       ↓
  Simpan aktivitas + URL ke Firestore
       ↓
  Cache ke SQLite + update state lokal

Approval (Dosen):
  Tap Setujui/Tolak
       ↓
  Update Firestore /activities/{id}.status
       ↓
  Patch state lokal (tanpa re-fetch)
       ↓
  Update cache SQLite
```

---

## 🗄 Struktur Database

### Firestore Collections

```
users/
  {uid}/
    name        : String
    email       : String
    role        : "admin" | "dosen" | "asdos"
    createdAt   : Timestamp
    lastSeen    : Timestamp
    createdBy   : String (UID admin yang membuat)

classes/
  {classId}/
    name        : String
    dosenId     : String (UID dosen)
    dosenName   : String
    startTime   : String ("HH:mm")
    endTime     : String ("HH:mm")
    room        : String
    isOnline    : Boolean
    dayOfWeek   : Integer (1=Senin … 6=Sabtu)
    asdosIds    : List<String> (UID asdos yang ditugaskan)

activities/
  {actId}/
    classId     : String
    className   : String
    asdosId     : String
    asdosName   : String
    category    : "mengajar" | "kuis" | "praktikum"
    description : String
    photoUrl    : String? (URL Cloudinary)
    photoPath   : String? (path lokal fallback)
    status      : "pending" | "approved" | "rejected"
    isOnline    : Boolean
    date        : Timestamp
    timeRange   : String ("HH:mm – HH:mm")
    rejectReason: String?
    reviewedAt  : Timestamp?
    createdAt   : Timestamp
```

### SQLite (Cache Lokal)

```sql
TABLE classes    -- cache kelas untuk offline mode
TABLE activities -- cache aktivitas asdos untuk offline mode
```

---

## 📁 Struktur Proyek

```
lib/
├── main.dart                          ← Entry point + Firebase init + AuthGate
├── firebase_options.dart              ← Konfigurasi Firebase (auto-generated)
│
├── models/
│   └── models.dart                    ← UserModel, ClassModel, ActivityModel, enums
│
├── provider/
│   └── app_provider.dart              ← State management terpusat (semua role)
│
├── services/
│   ├── auth_service.dart              ← Firebase Authentication
│   ├── firestore_service.dart         ← Firestore CRUD + admin queries
│   ├── storage_service.dart           ← Upload foto ke Cloudinary
│   ├── notification_service.dart      ← Notifikasi lokal terjadwal
│   └── sync_service.dart              ← Sinkronisasi offline ↔ online
│
├── database/
│   ├── database_helper.dart           ← Setup SQLite
│   ├── local_cache.dart               ← Cache kelas & aktivitas
│   ├── class_dao.dart                 ← CRUD kelas lokal
│   └── activity_dao.dart              ← CRUD aktivitas lokal
│
├── theme/
│   └── app_theme.dart                 ← Warna & tema Material 3
│
├── widgets/
│   └── shared_widgets.dart            ← Komponen reusable
│
└── ui/
    ├── auth/
    │   └── login_screen.dart          ← Login (semua role)
    │
    ├── admin/
    │   ├── admin_shell.dart           ← Bottom nav Admin
    │   ├── admin_dashboard_screen.dart← Statistik & ringkasan sistem
    │   ├── admin_user_screen.dart     ← CRUD pengguna (dosen & asdos)
    │   └── admin_class_screen.dart    ← CRUD kelas + assign asdos/dosen
    │
    ├── asdos/
    │   ├── asdos_home_screen.dart     ← Beranda + bottom nav Asdos
    │   ├── input_activity_screen.dart ← Form input log + upload foto
    │   ├── activity_history_screen.dart← Riwayat log + filter status
    │   ├── activity_detail_asdos_screen.dart
    │   └── asdos_profile_screen.dart  ← Profil + ganti password
    │
    └── dosen/
        ├── dosen_shell.dart           ← Bottom nav Dosen
        ├── dosen_home_screen.dart     ← Dashboard + daftar asdos
        ├── approval_screen.dart       ← Review log + bulk approve/reject
        ├── activity_detail_dosen_screen.dart
        └── dosen_profile.dart         ← Profil + ganti password
```

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK 3.x
- Android Studio / VS Code
- Akun Firebase (gratis)
- Akun Cloudinary (gratis)

### Langkah

```bash
# 1. Clone repository
git clone https://github.com/username/logasdos.git
cd logasdos

# 2. Install dependencies
flutter pub get

# 3. Pastikan google-services.json sudah ada di android/app/
#    (download dari Firebase Console)

# 4. Jalankan aplikasi
flutter run
```

---

## 🔥 Setup Firebase

### 1. Buat Firebase Project
1. Buka [console.firebase.google.com](https://console.firebase.google.com)
2. Buat project baru → nama: `logasdos`

### 2. Aktifkan Services
| Service | Cara |
|---|---|
| **Authentication** | Build → Authentication → Get started → Email/Password → Enable |
| **Firestore** | Build → Firestore Database → Create database → Production mode |

### 3. Daftarkan App Android
1. Firebase Console → Add app → Android
2. Package name: `com.example.logasdos`
3. Download `google-services.json` → taruh di `android/app/`

### 4. Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read:   if request.auth != null;
      allow write:  if request.auth != null && request.auth.uid == uid;
      allow create: if request.auth != null;
    }
    match /classes/{classId} {
      allow read:  if request.auth != null;
      allow write: if request.auth != null;
    }
    match /activities/{actId} {
      allow read:  if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### 5. Buat Akun Admin Pertama
Karena tidak ada halaman register, akun admin pertama harus dibuat **manual** di Firebase Console:

1. Firebase Console → Authentication → Users → Add user
   - Email: `admin@logasdos.id`
   - Password: `admin123`
2. Firebase Console → Firestore → Collection `users` → Add document
   - Document ID: _(UID dari step 1)_
   - Fields:
     ```
     name     : "Admin LogAsdos"
     email    : "admin@logasdos.id"
     role     : "admin"
     createdAt: (timestamp sekarang)
     ```
3. Login sebagai admin → buat akun dosen & asdos dari dalam aplikasi.

### 6. Setup Cloudinary (Foto)
1. Daftar gratis di [cloudinary.com](https://cloudinary.com/users/register_free)
2. Dashboard → Settings → Upload → Upload Presets → Add upload preset
   - Signing mode: **Unsigned**
   - Catat nama preset
3. Isi di `lib/services/storage_service.dart`:
   ```dart
   const _cloudName    = 'CLOUD_NAME_KAMU';
   const _uploadPreset = 'PRESET_KAMU';
   ```

### 7. Setup Notifikasi Android
Tambahkan di `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- Dalam <manifest> -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

### 8. Firestore Indexes (Composite)
Saat pertama run, Flutter akan print link error untuk membuat index otomatis. Klik link tersebut atau buat manual di Firebase Console → Firestore → Indexes:

| Collection | Field 1 | Field 2 | Field 3 |
|---|---|---|---|
| `activities` | `asdosId` ASC | `createdAt` DESC | — |
| `activities` | `classId` ASC | `createdAt` DESC | — |
| `activities` | `classId` ASC | `asdosId` ASC | `createdAt` DESC |
| `classes` | `dosenId` ASC | `dayOfWeek` ASC | `startTime` ASC |
| `classes` | `asdosIds` (array) | `dayOfWeek` ASC | `startTime` ASC |

---

## 🔑 Akun Demo

| Role | Email | Password |
|---|---|---|
| **Admin** | admin@logasdos.id | admin123 |
| **Dosen** | tom@univ.ac.id | tom123 |
| **Asdos** | 123456@student.univ.ac.id | grace123 |

> Akun-akun ini harus dibuat terlebih dahulu oleh admin melalui panel atau script seed.

---

## ✅ Kesesuaian Kriteria Tugas

| Kriteria | Implementasi | Bobot |
|---|---|---|
| **CRUD & Relational DB** | Tabel `classes` (master) dan `activities` (transaksi) di Firestore + SQLite. Relasi classId → activities sebagai foreign key. Semua operasi CRUD tersedia (admin: kelas & user; dosen: status aktivitas; asdos: input log). | 10% |
| **Firebase Auth** | Login email/password untuk 3 role (Admin, Dosen, Asdos). Admin membuat akun via Firebase Auth API. Ganti password dengan re-authentication. Reset password via email. | 5% |
| **Storing in Firebase** | Sinkronisasi data teks ke **Firestore**. Foto bukti aktivitas diunggah ke **Cloudinary** (pengganti Firebase Storage yang butuh Blaze plan) dan URL disimpan di Firestore. Cache lokal di SQLite untuk mode offline. | 5% |
| **Notifications** | Notifikasi pengingat **30 menit sebelum kelas** dimulai + **2 jam setelah kelas selesai** jika log belum diisi. Notifikasi status saat dosen approve/reject. Menggunakan `flutter_local_notifications`. | 5% |
| **Smartphone Resource** | Akses **kamera** untuk foto bukti kelas luring. Akses **galeri** untuk screenshot Zoom/kelas daring. Menggunakan `image_picker`. | 5% |

---

## 📸 Screenshot

<!-- Tambahkan screenshot aplikasi di sini -->

| Login | Beranda Asdos | Input Log |
|:---:|:---:|:---:|
| _<img width="738" height="1600" alt="WhatsApp Image 2026-04-29 at 8 42 15 AM" src="https://github.com/user-attachments/assets/9a1b3040-0621-4e3e-b900-9cfb972ca652" />
_ | _(screenshot)_ | _(screenshot)_ |

| Riwayat Aktivitas | Beranda Dosen | Bulk Approval |
|:---:|:---:|:---:|
| _(screenshot)_ | _(screenshot)_ | _(screenshot)_ |

| Dashboard Admin | Manajemen User | Manajemen Kelas |
|:---:|:---:|:---:|
| _(screenshot)_ | _(screenshot)_ | _(screenshot)_ |

---

## Data Diri

| Nama | NIM |
|---|---|
| _Dea Kristin Ginting_ | _5025231040_ |


---

<div align="center">
  <sub>Built with ❤️ using Flutter & Firebase</sub>
</div>
