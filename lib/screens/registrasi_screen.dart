import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/pasien.dart';

class RegistrasiScreen extends StatefulWidget {
  const RegistrasiScreen({super.key});

  @override
  State<RegistrasiScreen> createState() => _RegistrasiScreenState();
}

class _RegistrasiScreenState extends State<RegistrasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _umurCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();
  final _noRmCtrl = TextEditingController();
  final _keluhanCtrl = TextEditingController();
  String _jenisKelamin = 'Laki-laki';
  bool _loading = false;

  @override
  void dispose() {
    _namaCtrl.dispose(); _umurCtrl.dispose(); _alamatCtrl.dispose();
    _noHpCtrl.dispose(); _noRmCtrl.dispose(); _keluhanCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final pasien = Pasien(
      id: const Uuid().v4(),
      namaLengkap: _namaCtrl.text.trim(),
      umur: int.parse(_umurCtrl.text.trim()),
      jenisKelamin: _jenisKelamin,
      alamat: _alamatCtrl.text.trim(),
      noHp: _noHpCtrl.text.trim(),
      noRm: _noRmCtrl.text.trim(),
      keluhanUtama: _keluhanCtrl.text.trim(),
      tanggalDaftar: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    );

    await DatabaseHelper.instance.insertPasien(pasien);
    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Pasien berhasil didaftarkan!'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi Pasien Baru')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('Data Identitas', Icons.person),
            _buildTextField(_namaCtrl, 'Nama Lengkap', Icons.badge,
                validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null),
            _buildTextField(_umurCtrl, 'Umur', Icons.cake,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Umur wajib diisi';
                  if (int.tryParse(v) == null) return 'Masukkan angka';
                  return null;
                }),
            _buildDropdownKelamin(),
            _buildTextField(_alamatCtrl, 'Alamat Lengkap', Icons.home,
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Alamat wajib diisi' : null),
            _buildTextField(_noHpCtrl, 'No. Handphone', Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? 'No HP wajib diisi' : null),
            const SizedBox(height: 16),
            _buildSection('Data Medis', Icons.medical_information),
            _buildTextField(_noRmCtrl, 'No. Rekam Medis (RM)', Icons.numbers,
                validator: (v) => v!.isEmpty ? 'No RM wajib diisi' : null),
            _buildTextField(_keluhanCtrl, 'Keluhan Utama', Icons.sick,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Keluhan wajib diisi' : null),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loading ? null : _simpan,
              icon: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_loading ? 'Menyimpan...' : 'Simpan Data Pasien'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(children: [
        Icon(icon, color: const Color(0xFF1A73E8), size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 15,
            color: Color(0xFF1A73E8))),
        const Expanded(child: Divider(indent: 12)),
      ]),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label,
      IconData icon,
      {TextInputType? keyboardType, int maxLines = 1,
        String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildDropdownKelamin() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _jenisKelamin,
        decoration: const InputDecoration(
          labelText: 'Jenis Kelamin',
          prefixIcon: Icon(Icons.people),
          border: OutlineInputBorder(),
          filled: true,
        ),
        items: ['Laki-laki', 'Perempuan']
            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
            .toList(),
        onChanged: (v) => setState(() => _jenisKelamin = v!),
      ),
    );
  }
}