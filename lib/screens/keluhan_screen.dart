import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/pasien.dart';

class KeluhanScreen extends StatefulWidget {
  const KeluhanScreen({super.key});

  @override
  State<KeluhanScreen> createState() => _KeluhanScreenState();
}

class _KeluhanScreenState extends State<KeluhanScreen> {
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

  // Daftar kategori keluhan umum
  final List<Map<String, dynamic>> _kategoriKeluhan = [
    {'icon': Icons.thermostat, 'label': 'Demam', 'color': Colors.orange},
    {'icon': Icons.air, 'label': 'Batuk / Pilek', 'color': Colors.blue},
    {'icon': Icons.favorite, 'label': 'Jantung', 'color': Colors.red},
    {'icon': Icons.psychology, 'label': 'Kepala', 'color': Colors.purple},
    {'icon': Icons.medication, 'label': 'Alergi', 'color': Colors.green},
    {'icon': Icons.healing, 'label': 'Luka', 'color': Colors.teal},
    {'icon': Icons.hotel, 'label': 'Insomnia', 'color': Colors.indigo},
    {'icon': Icons.more_horiz, 'label': 'Lainnya', 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Keluhan Utama')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kategori keluhan
          const Text('Kategori Keluhan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.9,
            ),
            itemCount: _kategoriKeluhan.length,
            itemBuilder: (ctx, i) {
              final item = _kategoriKeluhan[i];
              return InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: (item['color'] as Color).withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'] as IconData,
                          color: item['color'] as Color, size: 28),
                      const SizedBox(height: 4),
                      Text(item['label'] as String,
                          style: const TextStyle(fontSize: 11),
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Daftar pasien dengan keluhannya
          const Text('Keluhan Pasien Terdaftar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),

          if (_daftarPasien.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Belum ada data keluhan pasien',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ..._daftarPasien.map((p) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade100,
                  child: Icon(Icons.sick, color: Colors.orange.shade700),
                ),
                title: Text(p.namaLengkap,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(p.keluhanUtama),
                trailing: Text('${p.umur} th',
                    style: const TextStyle(color: Colors.grey)),
              ),
            )),
        ],
      ),
    );
  }
}