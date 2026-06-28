// lib/models/transaksi_model.dart
// Model data untuk setiap transaksi keuangan

class TransaksiModel {
  final int? id;
  final String judul;
  final double jumlah;
  final String kategori;
  final String tipe; // 'pemasukan' atau 'pengeluaran'
  final String tanggal; // format: yyyy-MM-dd
  final String? catatan;

  const TransaksiModel({
    this.id,
    required this.judul,
    required this.jumlah,
    required this.kategori,
    required this.tipe,
    required this.tanggal,
    this.catatan,
  });

  // Konversi dari Map (dari SQLite) ke TransaksiModel
  factory TransaksiModel.fromMap(Map<String, dynamic> map) {
    return TransaksiModel(
      id: map['id'] as int?,
      judul: map['judul'] as String,
      jumlah: (map['jumlah'] as num).toDouble(),
      kategori: map['kategori'] as String,
      tipe: map['tipe'] as String,
      tanggal: map['tanggal'] as String,
      catatan: map['catatan'] as String?,
    );
  }

  // Konversi dari TransaksiModel ke Map (untuk SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'judul': judul,
      'jumlah': jumlah,
      'kategori': kategori,
      'tipe': tipe,
      'tanggal': tanggal,
      'catatan': catatan,
    };
  }

  // copyWith untuk immutable update
  TransaksiModel copyWith({
    int? id,
    String? judul,
    double? jumlah,
    String? kategori,
    String? tipe,
    String? tanggal,
    String? catatan,
  }) {
    return TransaksiModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      jumlah: jumlah ?? this.jumlah,
      kategori: kategori ?? this.kategori,
      tipe: tipe ?? this.tipe,
      tanggal: tanggal ?? this.tanggal,
      catatan: catatan ?? this.catatan,
    );
  }

  @override
  String toString() {
    return 'TransaksiModel(id: $id, judul: $judul, jumlah: $jumlah, '
        'kategori: $kategori, tipe: $tipe, tanggal: $tanggal)';
  }
}

// Daftar kategori yang tersedia
class KategoriData {
  static const List<String> pemasukan = [
    'Gaji',
    'Freelance',
    'Bisnis',
    'Investasi',
    'Hadiah',
    'Lainnya',
  ];

  static const List<String> pengeluaran = [
    'Makanan',
    'Transport',
    'Belanja',
    'Tagihan',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya',
  ];

  static List<String> getByTipe(String tipe) {
    return tipe == 'pemasukan' ? pemasukan : pengeluaran;
  }
}
