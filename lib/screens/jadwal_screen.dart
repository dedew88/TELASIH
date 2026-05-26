import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/jadwal.dart';
import '../models/user.dart';
import '../utils/session_manager.dart';
import 'jadwal_dokter_screen.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  @override
  void initState() {
    super.initState();
    // Kalau login sebagai dokter, langsung arahkan ke halaman dokter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (SessionManager.isDokter) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const JadwalDokterScreen()),
        );
      } else {
        _loadData();
      }
    });
  }

  DateTime _selectedDate = DateTime.now();
  User? _selectedDokter;
  String? _selectedWaktu;
  List<User> _daftarDokter = [];
  List<Jadwal> _jadwalSaya = [];
  bool _loadingDokter = true;

  final List<String> _waktuSlot = [
    '08:00', '08:30', '09:00', '09:30',
    '10:00', '10:30', '11:00', '11:30',
    '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00',
  ];

  Future<void> _loadData() async {
    final dokter = await DatabaseHelper.instance.getAllDokter();
    final userId = SessionManager.currentUser?.id ?? '';
    final jadwal =
        await DatabaseHelper.instance.getJadwalByPasien(userId);
    setState(() {
      _daftarDokter = dokter;
      _jadwalSaya = jadwal;
      _loadingDokter = false;
    });
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _konfirmasiJadwal() async {
    if (_selectedDokter == null || _selectedWaktu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Pilih dokter dan waktu konsultasi terlebih dahulu'),
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
            _buildDialogRow('Dokter', 'dr. ${_selectedDokter!.nama}'),
            _buildDialogRow('Tanggal',
                DateFormat('dd MMMM yyyy').format(_selectedDate)),
            _buildDialogRow('Waktu', _selectedWaktu!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final jadwal = Jadwal(
                id: const Uuid().v4(),
                pasienId: SessionManager.currentUser!.id!,
                pasienNama: SessionManager.currentUser!.nama,
                dokterNama: _selectedDokter!.nama,
                tanggal:
                    DateFormat('dd MMM yyyy').format(_selectedDate),
                waktu: _selectedWaktu!,
                status: 'menunggu',
              );
              await DatabaseHelper.instance.insertJadwal(jadwal);
              if (context.mounted) Navigator.pop(context);
              _loadData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('✅ Jadwal konsultasi berhasil dibuat!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
            ),
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
                style:
                    const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'selesai':
        return Colors.green;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penjadwalan Konsultasi')),
      body: _loadingDokter
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Pilih tanggal
                const Text('Pilih Tanggal',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
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
                          DateFormat('EEEE, dd MMMM yyyy')
                              .format(_selectedDate),
                          style: const TextStyle(fontSize: 15),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down,
                            color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Pilih dokter
                const Text('Pilih Dokter',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                if (_daftarDokter.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Belum ada dokter terdaftar.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._daftarDokter.map((dokter) =>
                      RadioListTile<User>(
                        value: dokter,
                        groupValue: _selectedDokter,
                        onChanged: (v) =>
                            setState(() => _selectedDokter = v),
                        title: Text(
                          'dr. ${dokter.nama}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(dokter.email),
                        activeColor: const Color(0xFF1A73E8),
                        contentPadding: EdgeInsets.zero,
                      )),
                const SizedBox(height: 20),

                // Pilih waktu
                const Text('Pilih Waktu',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _waktuSlot.map((waktu) {
                    final dipilih = _selectedWaktu == waktu;
                    return ChoiceChip(
                      label: Text(waktu),
                      selected: dipilih,
                      onSelected: (_) =>
                          setState(() => _selectedWaktu = waktu),
                      selectedColor: const Color(0xFF1A73E8),
                      labelStyle: TextStyle(
                          color: dipilih
                              ? Colors.white
                              : Colors.black),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Jadwal saya
                const Text('Jadwal Konsultasi Saya',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                if (_jadwalSaya.isEmpty)
                  const Text('Belum ada jadwal konsultasi',
                      style: TextStyle(color: Colors.grey))
                else
                  ..._jadwalSaya.map((j) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF1A73E8),
                            child: Icon(Icons.calendar_month,
                                color: Colors.white, size: 20),
                          ),
                          title: Text('dr. ${j.dokterNama}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${j.tanggal} • ${j.waktu}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(j.status)
                                  .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Text(
                              j.status,
                              style: TextStyle(
                                  color: _statusColor(j.status),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )),

                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: _konfirmasiJadwal,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Konfirmasi Jadwal'),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
    );
  }
}