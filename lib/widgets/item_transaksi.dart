// lib/widgets/item_transaksi.dart
// Widget untuk menampilkan satu baris transaksi di daftar

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaksi_model.dart';

class ItemTransaksi extends StatelessWidget {
  final TransaksiModel transaksi;
  final VoidCallback onEdit;
  final VoidCallback onHapus;

  const ItemTransaksi({
    super.key,
    required this.transaksi,
    required this.onEdit,
    required this.onHapus,
  });

  // Ikon dan warna per kategori
  static const Map<String, IconData> _ikonKategori = {
    'Makanan': Icons.restaurant_rounded,
    'Transport': Icons.directions_car_rounded,
    'Belanja': Icons.shopping_bag_rounded,
    'Tagihan': Icons.receipt_long_rounded,
    'Hiburan': Icons.movie_rounded,
    'Kesehatan': Icons.local_hospital_rounded,
    'Pendidikan': Icons.school_rounded,
    'Gaji': Icons.account_balance_wallet_rounded,
    'Freelance': Icons.laptop_rounded,
    'Bisnis': Icons.business_center_rounded,
    'Investasi': Icons.trending_up_rounded,
    'Hadiah': Icons.card_giftcard_rounded,
    'Lainnya': Icons.category_rounded,
  };

  static const Map<String, Color> _warnaKategori = {
    'Makanan': Color(0xFFFF7043),
    'Transport': Color(0xFF42A5F5),
    'Belanja': Color(0xFFAB47BC),
    'Tagihan': Color(0xFF78909C),
    'Hiburan': Color(0xFFEF5350),
    'Kesehatan': Color(0xFF26A69A),
    'Pendidikan': Color(0xFF5C6BC0),
    'Gaji': Color(0xFF66BB6A),
    'Freelance': Color(0xFF26C6DA),
    'Bisnis': Color(0xFFFF7043),
    'Investasi': Color(0xFF29B6F6),
    'Hadiah': Color(0xFFEC407A),
    'Lainnya': Color(0xFF8D6E63),
  };

  String _formatRupiah(double angka) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(angka);
  }

  String _formatTanggal(String tanggal) {
    final dt = DateTime.parse(tanggal);
    return DateFormat('d MMM yyyy', 'id_ID').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final isPemasukan = transaksi.tipe == 'pemasukan';
    final ikon = _ikonKategori[transaksi.kategori] ?? Icons.category_rounded;
    final warna = _warnaKategori[transaksi.kategori] ?? Colors.grey;

    return Dismissible(
      key: Key('transaksi_${transaksi.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Transaksi'),
            content: Text('Hapus "${transaksi.judul}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Hapus'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onHapus(),
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: warna.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(ikon, color: warna, size: 22),
          ),
          title: Text(
            transaksi.judul,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                transaksi.kategori,
                style: TextStyle(color: warna, fontSize: 12),
              ),
              Text(
                _formatTanggal(transaksi.tanggal),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isPemasukan ? '+' : '-'} ${_formatRupiah(transaksi.jumlah)}',
                style: TextStyle(
                  color: isPemasukan
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit_rounded,
                      size: 16, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}
