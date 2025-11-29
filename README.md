# 🐦 TwitMe — Aplikasi Clone Twitter dengan Flutter

**TwitMe** adalah aplikasi clone Twitter berbasis **Flutter** dengan tampilan **minimalis** dan fitur utama yang menyerupai Twitter asli.  
Aplikasi ini menggunakan **Provider** sebagai state management utama dan **SQLite** (sqflite) untuk penyimpanan data lokal, memungkinkan aplikasi berjalan secara offline.

---

## 🚀 Fitur Utama

✅ **Autentikasi Pengguna**
- Halaman login dan registrasi
- Penyimpanan sesi pengguna secara lokal

✅ **Beranda (Home Feed)**
- Menampilkan daftar tweet dari semua pengguna
- Urutan tweet berdasarkan waktu terbaru

✅ **Buat Tweet**
- Menulis tweet baru (teks)
- Dukungan untuk melampirkan gambar (dari galeri/kamera)

✅ **Interaksi Tweet**
- **Like**: Menyukai tweet dengan animasi hati
- **Retweet**: Membagikan ulang tweet ke profil sendiri
- **Reply**: Membalas tweet pengguna lain

✅ **Profil Pengguna**
- Menampilkan data pengguna (foto, bio, join date)
- Tab navigasi: Tweet, Balasan, Media, Suka
- Edit profil (ganti nama, bio, foto profil/cover)

✅ **Pencarian**
- Mencari tweet berdasarkan kata kunci
- Menampilkan topik trending yang bisa diklik

✅ **Notifikasi**
- Menampilkan notifikasi interaksi (Like, Reply, Retweet)

✅ **Tema Gelap & Terang**
- Dukungan mode gelap (Dark Mode) dan terang (Light Mode)

---

## 🛠 Teknologi yang Digunakan

- **Flutter**: Framework UI utama
- **Dart**: Bahasa pemrograman
- **Provider**: Manajemen state aplikasi
- **sqflite**: Database lokal untuk menyimpan tweet, user, dan interaksi
- **image_picker**: Mengambil gambar dari galeri/kamera
- **intl**: Format tanggal dan waktu

---

## 🧱 Struktur Folder Proyek

Seluruh kode program utama terdapat di dalam folder `lib/`:

```bash
lib/
├── main.dart                 # Titik masuk aplikasi + MultiProvider
│
├── helpers/
│   └── database_helper.dart  # Manajemen database SQLite
│
├── models/
│   ├── user_model.dart       # Model data pengguna
│   ├── tweet_model.dart      # Model data tweet
│   ├── comment_model.dart    # Model data komentar/balasan
│   └── notification_model.dart # Model data notifikasi
│
├── providers/
│   ├── auth_provider.dart    # Logika autentikasi
│   ├── tweet_provider.dart   # Logika tweet & interaksi
│   ├── search_provider.dart  # Logika pencarian
│   ├── message_provider.dart # Logika pesan (DM)
│   └── theme_provider.dart   # Logika tema aplikasi
│
├── screens/
│   ├── auth_screen.dart      # Login & Register
│   ├── home_screen.dart      # Feed utama
│   ├── compose_tweet_screen.dart # Buat tweet baru
│   ├── profile_screen.dart   # Profil pengguna
│   ├── edit_profile_screen.dart # Edit profil
│   ├── search_screen.dart    # Pencarian & Trending
│   ├── tweet_detail_screen.dart # Detail tweet & komentar
│   └── ...
│
└── widgets/
    ├── tweet_card.dart       # Komponen tampilan tweet
    ├── custom_button.dart    # Tombol kustom
    └── ...
```

---

## 💻 Cara Instalasi & Menjalankan

Pastikan Anda sudah menginstal **Flutter SDK** dan **Android Studio/VS Code**.

1. **Clone repository ini** (atau download ZIP):
   ```bash
   git clone https://github.com/ferdinand-12/TwitMe_UAS.git
   cd TwitMe_UAS
   ```

2. **Instal dependensi**:
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi**:
   Pastikan emulator atau device fisik sudah terhubung.
   ```bash
   flutter run
   ```

---

## 📸 Screenshot

*(Tambahkan screenshot aplikasi di sini)*

---

Dibuat dengan ❤️ menggunakan Flutter.
