// lib/pages/home_page.dart
// Halaman beranda: ringkasan saldo dan daftar transaksi terbaru

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/transaksi_cubit.dart';
import '../widgets/kartu_ringkasan.dart';
import '../widgets/item_transaksi.dart';
import 'form_transaksi_page.dart';
import 'statistik_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Muat data transaksi bulan ini saat aplikasi dibuka
    context.read<TransaksiCubit>().muatTransaksi();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _BerandaTab(),
          StatistikPage(),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _bukaFormTambah(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Tambah'),
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }

  void _bukaFormTambah(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FormTransaksiPage()),
    );
  }
}

// ── TAB BERANDA ──────────────────────────────────────────────────────────────

class _BerandaTab extends StatelessWidget {
  const _BerandaTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<TransaksiCubit, TransaksiState>(
        listener: (context, state) {
          if (state is TransaksiError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.pesan),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
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
    return RefreshIndicator(
      onRefresh: () => context.read<TransaksiCubit>().muatTransaksi(
            bulan: state.bulanAktif,
          ),
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            backgroundColor: const Color(0xFFF8F9FE),
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dompetku',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color(0xFF1565C0))),
                Text(
                  'Catat keuanganmu dengan mudah',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            actions: [
              // Pemilih bulan
              _PemilihBulan(bulanAktif: state.bulanAktif),
            ],
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              // Kartu ringkasan saldo
              KartuRingkasan(
                saldo: state.ringkasan['saldo'] ?? 0,
                pemasukan: state.ringkasan['pemasukan'] ?? 0,
                pengeluaran: state.ringkasan['pengeluaran'] ?? 0,
                bulan: state.bulanAktif,
              ),

              // Header daftar transaksi
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Transaksi Terbaru',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${state.transaksiList.length} data',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
              ),
            ]),
          ),

          // Daftar transaksi
          state.transaksiList.isEmpty
              ? const SliverFillRemaining(child: _KosongWidget())
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final transaksi = state.transaksiList[index];
                      return ItemTransaksi(
                        transaksi: transaksi,
                        onEdit: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FormTransaksiPage(transaksi: transaksi),
                          ),
                        ),
                        onHapus: () => context
                            .read<TransaksiCubit>()
                            .hapusTransaksi(transaksi.id!),
                      );
                    },
                    childCount: state.transaksiList.length,
                  ),
                ),

          // Padding bawah agar tidak tertutup FAB
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }
}

// Widget pemilih bulan
class _PemilihBulan extends StatelessWidget {
  final String bulanAktif;
  const _PemilihBulan({required this.bulanAktif});

  @override
  Widget build(BuildContext context) {
    final parts = bulanAktif.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    final label = DateFormat('MMM yyyy', 'id_ID').format(dt);

    return GestureDetector(
      onTap: () => _pilihBulan(context, dt),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded,
                size: 16, color: Color(0xFF1565C0)),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Future<void> _pilihBulan(BuildContext context, DateTime current) async {
    final cubit = context.read<TransaksiCubit>();
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Pilih Bulan',
    );
    if (picked != null) {
      final bulan =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
      cubit.gantibulan(bulan);
    }
  }
}

// Widget saat tidak ada transaksi
class _KosongWidget extends StatelessWidget {
  const _KosongWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Belum ada transaksi',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Tekan tombol + untuk menambahkan',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }
}
