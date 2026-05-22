import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/pasien.dart';

class DokumentasiScreen extends StatefulWidget {
  const DokumentasiScreen({super.key});

  @override
  State<DokumentasiScreen> createState() => _DokumentasiScreenState();
}

class _DokumentasiScreenState extends State<DokumentasiScreen> {
  List<Pasien> _daftarPasien = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getAllPasien();
    setState(() => _daftarPasien = data);
  }

  void _lihatStruk(Pasien p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header struk
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Text('TELASIH',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Text('Telemedicine Layanan Sehat Indonesia',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('STRUK LAYANAN KONSULTASI',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(thickness: 2),

            // Detail struk
            _buildStrukRow('No. RM', p.noRm),
            _buildStrukRow('Nama Pasien', p.namaLengkap),
            _buildStrukRow('Umur', '${p.umur} tahun'),
            _buildStrukRow('Jenis Kelamin', p.jenisKelamin),
            _buildStrukRow('No. HP', p.noHp),
            _buildStrukRow('Keluhan', p.keluhanUtama),
            _buildStrukRow('Tanggal Daftar', p.tanggalDaftar),
            _buildStrukRow('Jenis Layanan', 'Konsultasi Telemedicine'),
            const Divider(thickness: 2),
            _buildStrukRow('Status', '✅ Selesai'),
            const SizedBox(height: 16),

            // Tombol tutup
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Tutup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrukRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          const Text(': '),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dokumentasi Layanan')),
      body: _daftarPasien.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 70, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Belum ada dokumentasi layanan',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _daftarPasien.length,
              itemBuilder: (ctx, i) {
                final p = _daftarPasien[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.receipt,
                          color: Colors.green.shade700),
                    ),
                    title: Text(p.namaLengkap,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${p.tanggalDaftar} • ${p.keluhanUtama}'),
                    trailing: TextButton(
                      onPressed: () => _lihatStruk(p),
                      child: const Text('Lihat Struk'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}