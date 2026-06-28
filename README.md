# 💰 Dompetku — Aplikasi Catatan Keuangan Pribadi

Aplikasi mobile berbasis **Flutter** untuk mencatat dan memantau keuangan pribadi secara mudah dan terstruktur.

---

## 📱 Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| ➕ Tambah Transaksi | Input pemasukan dan pengeluaran dengan kategori |
| ✏️ Edit Transaksi | Perbarui data transaksi yang sudah ada |
| 🗑️ Hapus Transaksi | Hapus dengan swipe atau konfirmasi dialog |
| 📊 Ringkasan Saldo | Total saldo, pemasukan, dan pengeluaran per bulan |
| 📈 Statistik | Grafik pie chart pengeluaran per kategori |
| 📅 Filter Bulan | Tampilkan transaksi berdasarkan bulan & tahun |
| 💾 Penyimpanan Lokal | Data tersimpan di SQLite (offline-first) |

---

## 🏗️ Arsitektur Project

```
lib/
├── cubit/
│   ├── transaksi_cubit.dart   # Business logic & state management
│   └── transaksi_state.dart   # Definisi semua state
├── models/
│   └── transaksi_model.dart   # Data model + KategoriData
├── pages/
│   ├── home_page.dart         # Beranda + daftar transaksi
│   ├── form_transaksi_page.dart # Form tambah/edit transaksi
│   └── statistik_page.dart    # Grafik & statistik keuangan
├── services/
│   └── database_service.dart  # SQLite CRUD operations
├── widgets/
│   ├── kartu_ringkasan.dart   # Widget kartu saldo utama
│   └── item_transaksi.dart    # Widget baris item transaksi
└── main.dart                  # Entry point + BlocProvider
```

---

## 🧩 Teknologi yang Digunakan

| Komponen | Library / Tool |
|----------|---------------|
| Framework | Flutter (Dart) |
| State Management | `flutter_bloc` (Cubit) |
| Database Lokal | `sqflite` + `path` |
| Grafik | `fl_chart` |
| Font | `google_fonts` |
| Format Tanggal | `intl` |

---

## 🔄 Alur State (Cubit)

```
TransaksiInitial
       ↓ muatTransaksi()
TransaksiLoading
       ↓ berhasil
TransaksiLoaded ←─────── tambahTransaksi() / updateTransaksi() / hapusTransaksi()
       ↓ error               ↓
TransaksiError       TransaksiSuccess
```

---

## 🗄️ Skema Database SQLite

**Tabel: `transaksi`**

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | INTEGER | Primary key, auto increment |
| `judul` | TEXT | Nama/deskripsi transaksi |
| `jumlah` | REAL | Nominal uang |
| `kategori` | TEXT | Kategori (Makanan, Transport, dll) |
| `tipe` | TEXT | `'pemasukan'` atau `'pengeluaran'` |
| `tanggal` | TEXT | Format `yyyy-MM-dd` |
| `catatan` | TEXT | Keterangan tambahan (nullable) |

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK ≥ 3.0.0
- Android Studio / VS Code
- Emulator Android / iOS atau device fisik

### Langkah

```bash

# 1. Install dependencies
flutter pub get

# 2. Jalankan aplikasi
flutter run
```

---

## 👥 Pembagian Tugas Kelompok

| Nama | NIM | Kontribusi |
|------|-----|------------|
| Wildan Taufik Kurniawan | 231011402472 | Semuanya|

---

## 📂 Kategori Transaksi

**Pemasukan:** Gaji, Freelance, Bisnis, Investasi, Hadiah, Lainnya

**Pengeluaran:** Makanan, Transport, Belanja, Tagihan, Hiburan, Kesehatan, Pendidikan, Lainnya

