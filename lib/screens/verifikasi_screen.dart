import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerifikasiScreen extends StatefulWidget {
  const VerifikasiScreen({super.key});

  @override
  State<VerifikasiScreen> createState() => _VerifikasiScreenState();
}

class _VerifikasiScreenState extends State<VerifikasiScreen> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _hasil = [];
  bool _sudahCari = false;
  bool _loading = false;

  Future<void> _cari() async {
    final keyword = _searchCtrl.text.trim().toLowerCase();
    if (keyword.isEmpty) return;

    setState(() {
      _loading = true;
      _sudahCari = true;
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('pasien')
        .get();

    final semua = snapshot.docs.map((d) => d.data()).toList();

    setState(() {
      _loading = false;
      _hasil = semua.where((p) =>
        (p['namaLengkap'] ?? '').toLowerCase().contains(keyword) ||
        (p['noRm'] ?? '').toLowerCase().contains(keyword) ||
        (p['noHp'] ?? '').contains(keyword)
      ).toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Identitas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cari pasien berdasarkan nama, No. RM, atau No. HP',
                      style: TextStyle(color: Colors.blue, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Cari Pasien',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                    onSubmitted: (_) => _cari(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _cari,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cari'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _sudahCari
                      ? _hasil.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_search,
                                      size: 60, color: Colors.grey),
                                  SizedBox(height: 12),
                                  Text('Pasien tidak ditemukan',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _hasil.length,
                              itemBuilder: (ctx, i) {
                                final p = _hasil[i];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
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
                                                (p['namaLengkap'] ?? '?')[0]
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
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      p['namaLengkap'] ?? '-',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15)),
                                                  Text(
                                                      'No. RM: ${p['noRm'] ?? '-'}',
                                                      style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text('Terverifikasi',
                                                  style: TextStyle(
                                                      color: Colors
                                                          .green.shade800,
                                                      fontSize: 11)),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 20),
                                        _buildInfoRow(Icons.cake,
                                            '${p['umur'] ?? '-'} tahun • ${p['jenisKelamin'] ?? '-'}'),
                                        _buildInfoRow(
                                            Icons.phone, p['noHp'] ?? '-'),
                                        _buildInfoRow(
                                            Icons.home, p['alamat'] ?? '-'),
                                        _buildInfoRow(
                                            Icons.sick, p['keluhanUtama'] ?? '-'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                      : const Center(
                          child: Text(
                              'Masukkan kata kunci untuk mencari pasien',
                              style: TextStyle(color: Colors.grey)),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}