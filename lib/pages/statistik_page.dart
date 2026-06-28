// lib/pages/statistik_page.dart
// Halaman statistik: grafik pengeluaran per kategori & ringkasan bulanan

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/transaksi_cubit.dart';

class StatistikPage extends StatelessWidget {
  const StatistikPage({super.key});

  String _formatRupiah(double angka) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(angka);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<TransaksiCubit, TransaksiState>(
        builder: (context, state) {
          if (state is TransaksiLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransaksiLoaded) {
            return _buildKonten(context, state);
          }

          return const Center(child: Text('Memuat data...'));
        },
      ),
    );
  }

  Widget _buildKonten(BuildContext context, TransaksiLoaded state) {
    final kategoriData = state.pengeluaranPerKategori;
    final totalPengeluaran = state.ringkasan['pengeluaran'] ?? 0;
    final totalPemasukan = state.ringkasan['pemasukan'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text('Statistik Keuangan',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0))),
          const SizedBox(height: 4),
          Text(
            _namaBulan(state.bulanAktif),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Kartu ringkasan angka
          Row(
            children: [
              Expanded(
                child: _KartuStat(
                  label: 'Total Pemasukan',
                  nilai: _formatRupiah(totalPemasukan),
                  ikon: Icons.arrow_downward_rounded,
                  warna: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KartuStat(
                  label: 'Total Pengeluaran',
                  nilai: _formatRupiah(totalPengeluaran),
                  ikon: Icons.arrow_upward_rounded,
                  warna: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Kartu saldo bersih
          _KartuSaldo(
            saldo: state.ringkasan['saldo'] ?? 0,
            formatRupiah: _formatRupiah,
          ),
          const SizedBox(height: 24),

          // Grafik pie pengeluaran per kategori
          if (kategoriData.isNotEmpty) ...[
            const Text('Pengeluaran per Kategori',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _GrafikPie(
              data: kategoriData,
              total: totalPengeluaran,
              formatRupiah: _formatRupiah,
            ),
            const SizedBox(height: 20),

            // Legenda
            ...kategoriData.map((item) => _LegendaItem(
                  kategori: item['kategori'] as String,
                  total: (item['total'] as num).toDouble(),
                  persentase: totalPengeluaran > 0
                      ? ((item['total'] as num).toDouble() /
                              totalPengeluaran *
                              100)
                          .toStringAsFixed(1)
                      : '0',
                  formatRupiah: _formatRupiah,
                  warna: _warnaKategori(kategoriData.indexOf(item)),
                )),
          ] else
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.pie_chart_outline_rounded,
                      size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Belum ada data pengeluaran',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _namaBulan(String bulanTahun) {
    final parts = bulanTahun.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMMM yyyy', 'id_ID').format(dt);
  }

  Color _warnaKategori(int index) {
    const warna = [
      Color(0xFF1565C0),
      Color(0xFF26A69A),
      Color(0xFFEF5350),
      Color(0xFFFF7043),
      Color(0xFFAB47BC),
      Color(0xFF66BB6A),
      Color(0xFFFFCA28),
      Color(0xFF78909C),
    ];
    return warna[index % warna.length];
  }
}

// ── KOMPONEN STATISTIK ───────────────────────────────────────────────────────

class _KartuStat extends StatelessWidget {
  final String label;
  final String nilai;
  final IconData ikon;
  final Color warna;

  const _KartuStat({
    required this.label,
    required this.nilai,
    required this.ikon,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: warna, size: 24),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 4),
          Text(nilai,
              style: TextStyle(
                  color: warna, fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _KartuSaldo extends StatelessWidget {
  final double saldo;
  final String Function(double) formatRupiah;

  const _KartuSaldo({required this.saldo, required this.formatRupiah});

  @override
  Widget build(BuildContext context) {
    final isPositif = saldo >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPositif
            ? Colors.green.shade50
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPositif ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isPositif ? Icons.trending_up : Icons.trending_down,
                color: isPositif ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text('Saldo Bersih',
                  style: TextStyle(
                    color: isPositif
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          Text(
            '${isPositif ? '+' : ''}${formatRupiah(saldo)}',
            style: TextStyle(
              color: isPositif ? Colors.green.shade800 : Colors.red.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrafikPie extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final double total;
  final String Function(double) formatRupiah;

  const _GrafikPie({
    required this.data,
    required this.total,
    required this.formatRupiah,
  });

  Color _warnaIndex(int index) {
    const warna = [
      Color(0xFF1565C0),
      Color(0xFF26A69A),
      Color(0xFFEF5350),
      Color(0xFFFF7043),
      Color(0xFFAB47BC),
      Color(0xFF66BB6A),
      Color(0xFFFFCA28),
      Color(0xFF78909C),
    ];
    return warna[index % warna.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SizedBox(
        height: 220,
        child: PieChart(
          PieChartData(
            sections: data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final nilai = (item['total'] as num).toDouble();
              final persen = total > 0 ? nilai / total * 100 : 0;

              return PieChartSectionData(
                color: _warnaIndex(index),
                value: nilai,
                title: '${persen.toStringAsFixed(0)}%',
                radius: 80,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
            centerSpaceRadius: 40,
            sectionsSpace: 2,
          ),
        ),
      ),
    );
  }
}

class _LegendaItem extends StatelessWidget {
  final String kategori;
  final double total;
  final String persentase;
  final String Function(double) formatRupiah;
  final Color warna;

  const _LegendaItem({
    required this.kategori,
    required this.total,
    required this.persentase,
    required this.formatRupiah,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: warna, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(kategori,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text('$persentase%',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          const SizedBox(width: 12),
          Text(
            formatRupiah(total),
            style: TextStyle(
                color: warna,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        ],
      ),
    );
  }
}
