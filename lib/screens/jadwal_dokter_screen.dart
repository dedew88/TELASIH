import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/jadwal.dart';
import '../utils/session_manager.dart';

class JadwalDokterScreen extends StatefulWidget {
  const JadwalDokterScreen({super.key});

  @override
  State<JadwalDokterScreen> createState() => _JadwalDokterScreenState();
}

class _JadwalDokterScreenState extends State<JadwalDokterScreen> {
  List<Jadwal> _jadwalMasuk = [];
  bool _loading = true;
  String _filterStatus = 'semua';

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    final namaDokter = SessionManager.currentUser?.nama ?? '';
    final data =
        await DatabaseHelper.instance.getJadwalByDokter(namaDokter);
    setState(() {
      _jadwalMasuk = data;
      _loading = false;
    });
  }

  Future<void> _updateStatus(Jadwal jadwal, String status) async {
    await DatabaseHelper.instance
        .updateStatusJadwal(jadwal.id!, status);
    _loadJadwal();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Status jadwal ${jadwal.pasienNama} diubah ke "$status"'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  List<Jadwal> get _filteredJadwal {
    if (_filterStatus == 'semua') return _jadwalMasuk;
    return _jadwalMasuk
        .where((j) => j.status == _filterStatus)
        .toList();
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
    final namaDokter = SessionManager.currentUser?.nama ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jadwal Pasien Saya',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            Text('dr. $namaDokter',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11)),
          ],
        ),
        backgroundColor: const Color(0xFF1A73E8),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadJadwal,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Total',
                  _jadwalMasuk.length.toString(),
                  Icons.people,
                ),
                _buildSummaryItem(
                  'Menunggu',
                  _jadwalMasuk
                      .where((j) => j.status == 'menunggu')
                      .length
                      .toString(),
                  Icons.hourglass_empty,
                ),
                _buildSummaryItem(
                  'Selesai',
                  _jadwalMasuk
                      .where((j) => j.status == 'selesai')
                      .length
                      .toString(),
                  Icons.check_circle_outline,
                ),
              ],
            ),
          ),

          // Filter status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Filter: ',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                ...[
                  'semua',
                  'menunggu',
                  'selesai',
                  'dibatalkan'
                ].map((status) {
                  final isSelected = _filterStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _filterStatus = status),
                      selectedColor: const Color(0xFF1A73E8),
                      labelStyle: TextStyle(
                        color:
                            isSelected ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Daftar jadwal
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredJadwal.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today,
                                size: 64,
                                color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              _filterStatus == 'semua'
                                  ? 'Belum ada pasien yang mendaftar'
                                  : 'Tidak ada jadwal "$_filterStatus"',
                              style: const TextStyle(
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadJadwal,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredJadwal.length,
                          itemBuilder: (ctx, i) {
                            final j = _filteredJadwal[i];
                            return Card(
                              margin:
                                  const EdgeInsets.only(bottom: 10),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              const Color(0xFF1A73E8),
                                          child: Text(
                                            j.pasienNama[0]
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight:
                                                    FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                j.pasienNama,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                              Text(
                                                '${j.tanggal} • ${j.waktu}',
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _statusColor(j.status)
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(
                                                    12),
                                          ),
                                          child: Text(
                                            j.status,
                                            style: TextStyle(
                                                color: _statusColor(
                                                    j.status),
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Tombol aksi (hanya kalau masih menunggu)
                                    if (j.status == 'menunggu') ...[
                                      const SizedBox(height: 10),
                                      const Divider(height: 1),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () =>
                                                  _updateStatus(
                                                      j, 'dibatalkan'),
                                              icon: const Icon(
                                                  Icons.cancel_outlined,
                                                  size: 16),
                                              label: const Text(
                                                  'Batalkan'),
                                              style: OutlinedButton
                                                  .styleFrom(
                                                foregroundColor:
                                                    Colors.red,
                                                side: const BorderSide(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () =>
                                                  _updateStatus(
                                                      j, 'selesai'),
                                              icon: const Icon(
                                                  Icons.check_circle,
                                                  size: 16),
                                              label: const Text(
                                                  'Selesai'),
                                              style: ElevatedButton
                                                  .styleFrom(
                                                backgroundColor:
                                                    Colors.green,
                                                foregroundColor:
                                                    Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        Text(label,
            style:
                const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}