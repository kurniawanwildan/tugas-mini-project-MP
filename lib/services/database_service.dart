// lib/services/database_service.dart
// Service untuk mengelola database SQLite

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaksi_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  // Singleton pattern
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Getter database — inisialisasi jika belum ada
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Inisialisasi database SQLite
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dompetku.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Buat tabel saat pertama kali database dibuat
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transaksi (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        judul    TEXT    NOT NULL,
        jumlah   REAL    NOT NULL,
        kategori TEXT    NOT NULL,
        tipe     TEXT    NOT NULL CHECK(tipe IN ('pemasukan','pengeluaran')),
        tanggal  TEXT    NOT NULL,
        catatan  TEXT
      )
    ''');
  }

  // ── CREATE ───────────────────────────────────────────────────────────────

  Future<int> tambahTransaksi(TransaksiModel transaksi) async {
    final db = await database;
    return await db.insert(
      'transaksi',
      transaksi.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── READ ─────────────────────────────────────────────────────────────────

  /// Ambil semua transaksi, diurutkan dari terbaru
  Future<List<TransaksiModel>> ambilSemuaTransaksi() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaksi',
      orderBy: 'tanggal DESC, id DESC',
    );
    return maps.map(TransaksiModel.fromMap).toList();
  }

  /// Ambil transaksi berdasarkan bulan & tahun (format: 'yyyy-MM')
  Future<List<TransaksiModel>> ambilTransaksiBulan(String bulanTahun) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transaksi',
      where: "strftime('%Y-%m', tanggal) = ?",
      whereArgs: [bulanTahun],
      orderBy: 'tanggal DESC, id DESC',
    );
    return maps.map(TransaksiModel.fromMap).toList();
  }

  /// Ambil ringkasan: total pemasukan & pengeluaran bulan ini
  Future<Map<String, double>> ambilRingkasanBulan(String bulanTahun) async {
    final db = await database;

    final pemasukanResult = await db.rawQuery(
      "SELECT COALESCE(SUM(jumlah), 0) as total FROM transaksi "
      "WHERE tipe = 'pemasukan' AND strftime('%Y-%m', tanggal) = ?",
      [bulanTahun],
    );

    final pengeluaranResult = await db.rawQuery(
      "SELECT COALESCE(SUM(jumlah), 0) as total FROM transaksi "
      "WHERE tipe = 'pengeluaran' AND strftime('%Y-%m', tanggal) = ?",
      [bulanTahun],
    );

    final pemasukan = (pemasukanResult.first['total'] as num).toDouble();
    final pengeluaran = (pengeluaranResult.first['total'] as num).toDouble();

    return {
      'pemasukan': pemasukan,
      'pengeluaran': pengeluaran,
      'saldo': pemasukan - pengeluaran,
    };
  }

  /// Ambil total pengeluaran per kategori untuk grafik
  Future<List<Map<String, dynamic>>> ambilPengeluaranPerKategori(
      String bulanTahun) async {
    final db = await database;
    return await db.rawQuery(
      "SELECT kategori, SUM(jumlah) as total FROM transaksi "
      "WHERE tipe = 'pengeluaran' AND strftime('%Y-%m', tanggal) = ? "
      "GROUP BY kategori ORDER BY total DESC",
      [bulanTahun],
    );
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────

  Future<int> updateTransaksi(TransaksiModel transaksi) async {
    final db = await database;
    return await db.update(
      'transaksi',
      transaksi.toMap(),
      where: 'id = ?',
      whereArgs: [transaksi.id],
    );
  }

  // ── DELETE ───────────────────────────────────────────────────────────────

  Future<int> hapusTransaksi(int id) async {
    final db = await database;
    return await db.delete(
      'transaksi',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tutup koneksi database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
