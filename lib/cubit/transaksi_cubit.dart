// lib/cubit/transaksi_cubit.dart
// Cubit untuk mengelola state dan logika transaksi keuangan

import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/transaksi_model.dart';
import '../services/database_service.dart';

part 'transaksi_state.dart';

class TransaksiCubit extends Cubit<TransaksiState> {
  final DatabaseService _db;

  TransaksiCubit({DatabaseService? databaseService})
      : _db = databaseService ?? DatabaseService(),
        super(const TransaksiInitial());

  // Dapatkan bulan aktif saat ini (format: 'yyyy-MM')
  String get _bulanSekarang {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  // ── MUAT DATA ─────────────────────────────────────────────────────────

  /// Muat semua data transaksi untuk bulan tertentu
  Future<void> muatTransaksi({String? bulan}) async {
    emit(const TransaksiLoading());
    try {
      final bulanAktif = bulan ?? _bulanSekarang;

      final transaksiList = await _db.ambilTransaksiBulan(bulanAktif);
      final ringkasan = await _db.ambilRingkasanBulan(bulanAktif);
      final pengeluaranKategori =
          await _db.ambilPengeluaranPerKategori(bulanAktif);

      emit(TransaksiLoaded(
        transaksiList: transaksiList,
        ringkasan: ringkasan,
        pengeluaranPerKategori: pengeluaranKategori,
        bulanAktif: bulanAktif,
      ));
    } catch (e) {
      emit(TransaksiError('Gagal memuat data: ${e.toString()}'));
    }
  }

  // ── TAMBAH ────────────────────────────────────────────────────────────

  Future<void> tambahTransaksi(TransaksiModel transaksi) async {
    try {
      await _db.tambahTransaksi(transaksi);
      emit(const TransaksiSuccess('Transaksi berhasil ditambahkan'));

      // Reload data setelah tambah
      await muatTransaksi(bulan: _bulanSekarang);
    } catch (e) {
      emit(TransaksiError('Gagal menambahkan transaksi: ${e.toString()}'));
    }
  }

  // ── UPDATE ────────────────────────────────────────────────────────────

  Future<void> updateTransaksi(TransaksiModel transaksi) async {
    try {
      await _db.updateTransaksi(transaksi);
      emit(const TransaksiSuccess('Transaksi berhasil diperbarui'));

      // Ambil bulan aktif dari state sebelumnya
      final bulanAktif = state is TransaksiLoaded
          ? (state as TransaksiLoaded).bulanAktif
          : _bulanSekarang;

      await muatTransaksi(bulan: bulanAktif);
    } catch (e) {
      emit(TransaksiError('Gagal memperbarui transaksi: ${e.toString()}'));
    }
  }

  // ── HAPUS ─────────────────────────────────────────────────────────────

  Future<void> hapusTransaksi(int id) async {
    try {
      await _db.hapusTransaksi(id);
      emit(const TransaksiSuccess('Transaksi berhasil dihapus'));

      final bulanAktif = state is TransaksiLoaded
          ? (state as TransaksiLoaded).bulanAktif
          : _bulanSekarang;

      await muatTransaksi(bulan: bulanAktif);
    } catch (e) {
      emit(TransaksiError('Gagal menghapus transaksi: ${e.toString()}'));
    }
  }

  // ── FILTER BULAN ──────────────────────────────────────────────────────

  Future<void> gantibulan(String bulan) async {
    await muatTransaksi(bulan: bulan);
  }
}
