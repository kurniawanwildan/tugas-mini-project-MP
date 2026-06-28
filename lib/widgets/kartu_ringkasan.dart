// lib/widgets/kartu_ringkasan.dart
// Widget untuk menampilkan ringkasan keuangan di halaman utama

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KartuRingkasan extends StatelessWidget {
  final double saldo;
  final double pemasukan;
  final double pengeluaran;
  final String bulan;

  const KartuRingkasan({
    super.key,
    required this.saldo,
    required this.pemasukan,
    required this.pengeluaran,
    required this.bulan,
  });

  String _formatRupiah(double angka) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(angka);
  }

  String _namaBulan(String bulanTahun) {
    // bulanTahun format: 'yyyy-MM'
    final parts = bulanTahun.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMMM yyyy', 'id_ID').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label bulan
            Text(
              _namaBulan(bulan),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Total Saldo',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 4),

            // Saldo utama
            Text(
              _formatRupiah(saldo),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.white24, thickness: 1),
            const SizedBox(height: 12),

            // Baris pemasukan & pengeluaran
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    ikon: Icons.arrow_downward_rounded,
                    label: 'Pemasukan',
                    nominal: _formatRupiah(pemasukan),
                    warna: const Color(0xFF69F0AE),
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                Expanded(
                  child: _buildInfoItem(
                    ikon: Icons.arrow_upward_rounded,
                    label: 'Pengeluaran',
                    nominal: _formatRupiah(pengeluaran),
                    warna: const Color(0xFFFF8A80),
                    isRight: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData ikon,
    required String label,
    required String nominal,
    required Color warna,
    bool isRight = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: isRight ? 16 : 0, right: isRight ? 0 : 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: warna.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(ikon, color: warna, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.white60, fontSize: 11)),
                Text(nominal,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
