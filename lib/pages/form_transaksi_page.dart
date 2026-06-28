// lib/pages/form_transaksi_page.dart
// Halaman form untuk menambah dan mengedit transaksi

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/transaksi_cubit.dart';
import '../models/transaksi_model.dart';

class FormTransaksiPage extends StatefulWidget {
  final TransaksiModel? transaksi; // null = tambah baru, ada isi = edit

  const FormTransaksiPage({super.key, this.transaksi});

  @override
  State<FormTransaksiPage> createState() => _FormTransaksiPageState();
}

class _FormTransaksiPageState extends State<FormTransaksiPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();

  String _tipe = 'pengeluaran';
  String? _kategoriDipilih;
  DateTime _tanggalDipilih = DateTime.now();

  bool get _isEdit => widget.transaksi != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final t = widget.transaksi!;
      _judulController.text = t.judul;
      _jumlahController.text = t.jumlah.toStringAsFixed(0);
      _catatanController.text = t.catatan ?? '';
      _tipe = t.tipe;
      _kategoriDipilih = t.kategori;
      _tanggalDipilih = DateTime.parse(t.tanggal);
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _tanggalDipilih = picked);
    }
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    if (_kategoriDipilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    final transaksi = TransaksiModel(
      id: widget.transaksi?.id,
      judul: _judulController.text.trim(),
      jumlah: double.parse(_jumlahController.text.replaceAll('.', '')),
      kategori: _kategoriDipilih!,
      tipe: _tipe,
      tanggal: DateFormat('yyyy-MM-dd').format(_tanggalDipilih),
      catatan: _catatanController.text.trim().isEmpty
          ? null
          : _catatanController.text.trim(),
    );

    final cubit = context.read<TransaksiCubit>();
    if (_isEdit) {
      cubit.updateTransaksi(transaksi);
    } else {
      cubit.tambahTransaksi(transaksi);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit
            ? 'Transaksi berhasil diperbarui'
            : 'Transaksi berhasil ditambahkan'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kategoriList = KategoriData.getByTipe(_tipe);
    // Reset kategori jika tidak ada di list tipe baru
    if (_kategoriDipilih != null && !kategoriList.contains(_kategoriDipilih)) {
      _kategoriDipilih = null;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Transaksi' : 'Tambah Transaksi'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1565C0),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _simpan,
            child: const Text('Simpan',
                style: TextStyle(
                    color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle tipe transaksi
              _buildTipeToggle(),
              const SizedBox(height: 20),

              // Input judul
              _buildLabel('Judul Transaksi'),
              TextFormField(
                controller: _judulController,
                decoration: _inputDecoration('Contoh: Makan siang, Gaji bulan ini'),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Input jumlah
              _buildLabel('Jumlah (Rp)'),
              TextFormField(
                controller: _jumlahController,
                decoration: _inputDecoration('0'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _RupiahFormatter(),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Jumlah tidak boleh kosong';
                  final angka = double.tryParse(v.replaceAll('.', '')) ?? 0;
                  if (angka <= 0) return 'Jumlah harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Pilih kategori
              _buildLabel('Kategori'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kategoriList.map((kat) {
                  final dipilih = _kategoriDipilih == kat;
                  return GestureDetector(
                    onTap: () => setState(() => _kategoriDipilih = kat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: dipilih
                            ? const Color(0xFF1565C0)
                            : Colors.white,
                        border: Border.all(
                          color: dipilih
                              ? const Color(0xFF1565C0)
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        kat,
                        style: TextStyle(
                          color: dipilih ? Colors.white : Colors.grey.shade700,
                          fontWeight: dipilih
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Pilih tanggal
              _buildLabel('Tanggal'),
              GestureDetector(
                onTap: _pilihTanggal,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 18, color: Color(0xFF1565C0)),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                            .format(_tanggalDipilih),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input catatan (opsional)
              _buildLabel('Catatan (Opsional)'),
              TextFormField(
                controller: _catatanController,
                decoration: _inputDecoration('Tambahkan catatan...'),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),

              // Tombol simpan
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _simpan,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    _isEdit ? 'Perbarui Transaksi' : 'Simpan Transaksi',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget toggle tipe pemasukan / pengeluaran
  Widget _buildTipeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildTipeButton('pengeluaran', 'Pengeluaran',
              Icons.arrow_upward_rounded, Colors.red),
          _buildTipeButton('pemasukan', 'Pemasukan',
              Icons.arrow_downward_rounded, Colors.green),
        ],
      ),
    );
  }

  Widget _buildTipeButton(
      String value, String label, IconData ikon, Color warna) {
    final aktif = _tipe == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _tipe = value;
          _kategoriDipilih = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: aktif ? warna.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(ikon,
                  size: 18, color: aktif ? warna : Colors.grey.shade400),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: aktif ? warna : Colors.grey.shade400,
                  fontWeight:
                      aktif ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// Formatter angka jadi format Rupiah (titik ribuan)
class _RupiahFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue value) {
    if (value.text.isEmpty) return value;

    final digits = value.text.replaceAll('.', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    final result = buffer.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
