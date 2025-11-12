# 🐦 TwitMe — Aplikasi Clone Twitter dengan Flutter

**TwitMe** adalah aplikasi clone Twitter berbasis **Flutter** dengan tampilan **minimalis** dan fitur utama yang menyerupai Twitter asli.  
Aplikasi ini menggunakan **Provider** sebagai state management utama, serta memiliki fitur autentikasi pengguna, posting tweet, like, notifikasi, dan tema gelap/terang.

---

## 🚀 Fitur Utama

✅ **Autentikasi Pengguna**
- Halaman login dan registrasi
- Penyimpanan sesi pengguna (lokal atau terhubung backend)

✅ **Beranda (Home Feed)**
- Menampilkan daftar tweet secara real-time (mock data atau dari API)
- Mendukung fitur pull-to-refresh

✅ **Buat Tweet**
- Menulis tweet baru (teks dan gambar opsional)
- Otomatis memperbarui daftar tweet

✅ **Interaksi Tweet**
- Fitur Like, Reply, dan Retweet dengan counter

✅ **Profil Pengguna**
- Menampilkan data pengguna (foto, bio, jumlah followers/following, tweet)
- Edit profil dan foto pengguna

✅ **Notifikasi**
- Menampilkan notifikasi untuk Like, Reply, dan Mention

✅ **Pencarian**
- Fitur search untuk mencari tweet atau pengguna

✅ **Tema Gelap & Terang**
- Pengguna bisa mengganti tema aplikasi dengan mudah

---

## 🧱 Struktur Folder Proyek

Seluruh kode program utama terdapat di dalam folder `lib/`:

lib/
├── main.dart
│ └── Titik masuk aplikasi + MultiProvider
│
├── models/
│ ├── user_model.dart
│ ├── tweet_model.dart
│ └── notification_model.dart
│
├── providers/
│ ├── auth_provider.dart
│ ├── tweet_provider.dart
│ └── theme_provider.dart
│
├── screens/
│ ├── auth_screen.dart
│ ├── home_screen.dart
│ ├── compose_tweet_screen.dart
│ ├── profile_screen.dart
│ ├── search_screen.dart
│ ├── messages_screen.dart
│ ├── notifications_screen.dart
│ └── tweet_detail_screen.dart
│
└── widgets/
├── custom_button.dart
├── custom_tab_bar.dart
├── tweet_card.dart
├── user_avatar.dart
└── input_field.dart

yaml
Salin kode

---

## 🖥️ Tampilan UI (Konsep)

Tampilan TwitMe dibuat semirip mungkin dengan Twitter, namun tetap sederhana:
- **Home Screen:** daftar tweet + tombol floating “+”
- **Bottom Navigation Bar:** Home, Search, Notifications, Messages, Profile
- **Compose Tweet:** halaman untuk menulis tweet baru
- **Profile Screen:** menampilkan info dan tweet pengguna

---

## 🧩 Teknologi yang Digunakan

| Bagian | Teknologi |
|--------|------------|
| **Framework** | Flutter (Material 3) |
| **State Management** | Provider |
| **Backend (opsional)** | Firebase / Supabase / Mock Data |
| **Penyimpanan Data** | SharedPreferences / Firestore |
| **Tema Aplikasi** | Light & Dark Mode |

---

🧩 Rencana Pengembangan Selanjutnya
Integrasi dengan backend nyata (Firebase atau Supabase)

Upload gambar di tweet

Real-time update tweet (WebSocket)

Fitur Direct Message (DM)

Dukungan hashtag & mention

🤝 Kontribusi
Kontribusi sangat diterima!
Silakan fork repo ini dan buat pull request jika ingin menambahkan fitur baru.