import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedDokter;
  String? _selectedWaktu;

  final List<Map<String, String>> _daftarDokter = [
    {'nama': 'dr. Andi Pratama, Sp.PD', 'spesialis': 'Penyakit Dalam'},
    {'nama': 'dr. Sari Dewi, Sp.A', 'spesialis': 'Anak'},
    {'nama': 'dr. Budi Santoso, Sp.JP', 'spesialis': 'Jantung'},
    {'nama': 'dr. Rina Kusuma, Sp.N', 'spesialis': 'Neurologi'},
    {'nama': 'dr. Hendra Wijaya, Umum', 'spesialis': 'Umum'},
  ];

  final List<String> _waktuSlot = [
    '08:00', '08:30', '09:00', '09:30',
    '10:00', '10:30', '11:00', '11:30',
    '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00',
  ];

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _konfirmasiJadwal() {
    if (_selectedDokter == null || _selectedWaktu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih dokter dan waktu konsultasi terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Jadwal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('Dokter', _selectedDokter!),
            _buildDialogRow('Tanggal',
                DateFormat('dd MMMM yyyy', 'id').format(_selectedDate)),
            _buildDialogRow('Waktu', _selectedWaktu!),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Jadwal konsultasi berhasil dibuat!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text('$label:',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penjadwalan Konsultasi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Pilih tanggal
          const Text('Pilih Tanggal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pilihTanggal,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Color(0xFF1A73E8)),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 15),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Pilih dokter
          const Text('Pilih Dokter',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          ..._daftarDokter.map((d) => RadioListTile<String>(
            value: d['nama']!,
            groupValue: _selectedDokter,
            onChanged: (v) => setState(() => _selectedDokter = v),
            title: Text(d['nama']!,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(d['spesialis']!),
            activeColor: const Color(0xFF1A73E8),
            contentPadding: EdgeInsets.zero,
          )),
          const SizedBox(height: 20),

          // Pilih waktu
          const Text('Pilih Waktu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _waktuSlot.map((waktu) {
              final dipilih = _selectedWaktu == waktu;
              return ChoiceChip(
                label: Text(waktu),
                selected: dipilih,
                onSelected: (_) => setState(() => _selectedWaktu = waktu),
                selectedColor: const Color(0xFF1A73E8),
                labelStyle: TextStyle(
                    color: dipilih ? Colors.white : Colors.black),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          ElevatedButton.icon(
            onPressed: _konfirmasiJadwal,
            icon: const Icon(Icons.check_circle),
            label: const Text('Konfirmasi Jadwal'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}