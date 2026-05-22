import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/pasien.dart';
import 'registrasi_screen.dart';
import 'verifikasi_screen.dart';
import 'keluhan_screen.dart';
import 'jadwal_screen.dart';
import 'dokumentasi_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pasien> _daftarPasien = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPasien();
  }

  Future<void> _loadPasien() async {
    final data = await DatabaseHelper.instance.getAllPasien();
    setState(() => _daftarPasien = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TELASIH',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white)),
            Text('Telemedicine Layanan Sehat Indonesia',
                style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF1A73E8),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _daftarPasien.isEmpty
          ? _buildEmptyState()
          : _buildListPasien(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const RegistrasiScreen()),
          );
          _loadPasien();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Daftar Pasien Baru'),
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A73E8),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const VerifikasiScreen()))
                .then((_) => setState(() => _currentIndex = 0));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const KeluhanScreen()))
                .then((_) => setState(() => _currentIndex = 0));
          } else if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const JadwalScreen()))
                .then((_) => setState(() => _currentIndex = 0));
          } else if (index == 4) {
            Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const DokumentasiScreen()))
                .then((_) => setState(() => _currentIndex = 0));
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_outlined),
            activeIcon: Icon(Icons.verified_user),
            label: 'Verifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sick_outlined),
            activeIcon: Icon(Icons.sick),
            label: 'Keluhan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Dokumentasi',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.health_and_safety,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Belum ada pasien terdaftar',
            style: TextStyle(
                color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol + untuk mendaftarkan pasien baru',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildListPasien() {
    return RefreshIndicator(
      onRefresh: _loadPasien,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _daftarPasien.length,
        itemBuilder: (ctx, i) {
          final p = _daftarPasien[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF1A73E8),
                child: Text(
                  p.namaLengkap[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                p.namaLengkap,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${p.umur} tahun • ${p.keluhanUtama}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'No. RM',
                    style: TextStyle(
                        fontSize: 10, color: Colors.grey.shade500),
                  ),
                  Text(
                    p.noRm,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              onLongPress: () => _konfirmasiHapus(p),
            ),
          );
        },
      ),
    );
  }

  void _konfirmasiHapus(Pasien pasien) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data Pasien?'),
        content: Text(
            'Data ${pasien.namaLengkap} akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.deletePasien(pasien.id!);
              if (context.mounted) Navigator.pop(context);
              _loadPasien();
            },
            child: const Text('Hapus',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}