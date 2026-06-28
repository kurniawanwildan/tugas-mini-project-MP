// lib/cubit/transaksi_state.dart
// Definisi semua state untuk TransaksiCubit

part of 'transaksi_cubit.dart';

abstract class TransaksiState {
  const TransaksiState();
}

/// State awal sebelum data dimuat
class TransaksiInitial extends TransaksiState {
  const TransaksiInitial();
}

/// State saat data sedang dimuat dari database
class TransaksiLoading extends TransaksiState {
  const TransaksiLoading();
}

/// State saat data berhasil dimuat
class TransaksiLoaded extends TransaksiState {
  final List<TransaksiModel> transaksiList;
  final Map<String, double> ringkasan; // pemasukan, pengeluaran, saldo
  final List<Map<String, dynamic>> pengeluaranPerKategori;
  final String bulanAktif; // format: 'yyyy-MM'

  const TransaksiLoaded({
    required this.transaksiList,
    required this.ringkasan,
    required this.pengeluaranPerKategori,
    required this.bulanAktif,
  });

  @override
  String toString() =>
      'TransaksiLoaded(jumlah: ${transaksiList.length}, bulan: $bulanAktif)';
}

/// State saat operasi berhasil (tambah/edit/hapus)
class TransaksiSuccess extends TransaksiState {
  final String pesan;
  const TransaksiSuccess(this.pesan);
}

/// State saat terjadi error
class TransaksiError extends TransaksiState {
  final String pesan;
  const TransaksiError(this.pesan);
}
