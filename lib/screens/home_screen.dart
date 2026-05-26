import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/session_manager.dart';
import 'login_screen.dart';
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
  int _currentIndex = 0;

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              SessionManager.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = SessionManager.currentUser?.role ?? '';
    return role == 'dokter' ? _buildDokter() : _buildPasien();
  }

  // ===================== TAMPILAN DOKTER =====================
  Widget _buildDokter() {
    final nama = SessionManager.currentUser?.nama ?? 'Dokter';
    return Scaffold(
      appBar: _buildAppBar('dr. $nama', 'Dokter'),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pasien')
            .orderBy('tanggalDaftar', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyDokter();
          }
          final pasienList = snapshot.data!.docs;
          return Column(
            children: [
              // Summary card
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Total Pasien',
                        '${pasienList.length}', Icons.people),
                    _buildStatCard('Hari Ini',
                        _countHariIni(pasienList), Icons.today),
                    _buildStatCard('Menunggu',
                        '${pasienList.length}', Icons.pending),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Daftar Pasien',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: pasienList.length,
                  itemBuilder: (ctx, i) {
                    final data = pasienList[i].data() as Map<String, dynamic>;
                    final docId = pasienList[i].id;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1A73E8),
                          child: Text(
                            (data['namaLengkap'] ?? '?')[0].toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(data['namaLengkap'] ?? '-',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${data['umur'] ?? '-'} th • ${data['keluhanUtama'] ?? '-'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('No. RM',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500)),
                            Text(data['noRm'] ?? '-',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        onLongPress: () => _konfirmasiHapus(docId,
                            data['namaLengkap'] ?? 'Pasien ini'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const RegistrasiScreen())),
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
                    MaterialPageRoute(builder: (_) => const VerifikasiScreen()))
                .then((_) => setState(() => _currentIndex = 0));
          } else if (index == 2) {
            Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const JadwalScreen()))
                .then((_) => setState(() => _currentIndex = 0));
          } else if (index == 3) {
            Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DokumentasiScreen()))
                .then((_) => setState(() => _currentIndex = 0));
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_outlined),
              activeIcon: Icon(Icons.verified_user),
              label: 'Verifikasi'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Jadwal'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Dokumentasi'),
        ],
      ),
    );
  }

  // ===================== TAMPILAN PASIEN =====================
  Widget _buildPasien() {
    final nama = SessionManager.currentUser?.nama ?? 'Pasien';
    return Scaffold(
      appBar: _buildAppBar(nama, 'Pasien'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, $nama!',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const Text('Selamat datang di TELASIH',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu utama pasien
          const Text('Layanan Tersedia',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildMenuCard(
                icon: Icons.calendar_month,
                label: 'Buat Jadwal\nKonsultasi',
                color: Colors.blue,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const JadwalScreen())),
              ),
              _buildMenuCard(
                icon: Icons.sick,
                label: 'Input\nKeluhan',
                color: Colors.orange,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const KeluhanScreen())),
              ),
              _buildMenuCard(
                icon: Icons.receipt_long,
                label: 'Riwayat\nLayanan',
                color: Colors.green,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DokumentasiScreen())),
              ),
              _buildMenuCard(
                icon: Icons.person_search,
                label: 'Verifikasi\nIdentitas',
                color: Colors.purple,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const VerifikasiScreen())),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Jadwal terdekat
          const Text('Jadwal Konsultasi Terdekat',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('jadwal')
                .orderBy('createdAt', descending: true)
                .limit(3)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Belum ada jadwal konsultasi',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_month,
                          color: Color(0xFF1A73E8)),
                      title: Text(data['dokter'] ?? '-',
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13)),
                      subtitle: Text('${data['waktu']} • ${data['tanggal']?.substring(0, 10) ?? '-'}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(data['status'] ?? 'menunggu',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.shade700)),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ===================== HELPER WIDGETS =====================
  AppBar _buildAppBar(String nama, String role) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TELASIH',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white)),
          Text('Halo, $nama! ($role)',
              style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
      backgroundColor: const Color(0xFF1A73E8),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          tooltip: 'Logout',
          onPressed: _logout,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDokter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.health_and_safety, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Belum ada pasien terdaftar',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          const SizedBox(height: 8),
          Text('Tekan tombol + untuk mendaftarkan pasien baru',
              style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  String _countHariIni(List<QueryDocumentSnapshot> docs) {
    final today = DateTime.now();
    final count = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final tgl = data['tanggalDaftar'] ?? '';
      return tgl.startsWith(
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}');
    }).length;
    return '$count';
  }

  void _konfirmasiHapus(String docId, String nama) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Data Pasien?'),
        content: Text('Data $nama akan dihapus secara permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('pasien')
                  .doc(docId)
                  .delete();
              if (context.mounted) Navigator.pop(context);
            },
            child:
                const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}