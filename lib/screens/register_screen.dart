import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;
  bool _loading = false;
  String _selectedRole = 'pasien';

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // Cek email sudah terdaftar
    final existing = await DatabaseHelper.instance
        .getUserByEmail(_emailCtrl.text.trim());

    if (existing != null) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sudah terdaftar, gunakan email lain!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final user = User(
      id: const Uuid().v4(),
      nama: _namaCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      role: _selectedRole,
      tanggalDaftar:
          DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    );

    await DatabaseHelper.instance.insertUser(user);
    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Akun berhasil dibuat! Silakan login.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A73E8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white),
                  ),
                  const Text('Daftar Akun Baru',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Form card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Buat Akun',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                        const Text('Isi data diri Anda dengan benar',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 24),

                        // Pilih role
                        const Text('Daftar sebagai:',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildRoleButton('pasien', Icons.person,
                                'Pasien'),
                            const SizedBox(width: 12),
                            _buildRoleButton('dokter',
                                Icons.medical_services, 'Dokter'),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Nama
                        _buildTextField(_namaCtrl, 'Nama Lengkap',
                            Icons.badge_outlined,
                            validator: (v) =>
                                v!.isEmpty ? 'Nama wajib diisi' : null),

                        // Email
                        _buildTextField(
                            _emailCtrl, 'Email', Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                          if (v!.isEmpty) return 'Email wajib diisi';
                          if (!v.contains('@'))
                            return 'Format email tidak valid';
                          return null;
                        }),

                        // Password
                        _buildPasswordField(
                            _passwordCtrl, 'Password',
                            _obscurePassword, () {
                          setState(() =>
                              _obscurePassword = !_obscurePassword);
                        }, validator: (v) {
                          if (v!.isEmpty) return 'Password wajib diisi';
                          if (v.length < 6)
                            return 'Password minimal 6 karakter';
                          return null;
                        }),

                        // Konfirmasi password
                        _buildPasswordField(
                            _konfirmasiCtrl, 'Konfirmasi Password',
                            _obscureKonfirmasi, () {
                          setState(() => _obscureKonfirmasi =
                              !_obscureKonfirmasi);
                        }, validator: (v) {
                          if (v!.isEmpty)
                            return 'Konfirmasi password wajib diisi';
                          if (v != _passwordCtrl.text)
                            return 'Password tidak cocok';
                          return null;
                        }),

                        const SizedBox(height: 24),

                        // Tombol daftar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14),
                              backgroundColor:
                                  const Color(0xFF1A73E8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8)),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2))
                                : const Text('Buat Akun',
                                    style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController ctrl,
      String label,
      bool obscure,
      VoidCallback onToggle,
      {String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            onPressed: onToggle,
          ),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
      String role, IconData icon, String label) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1A73E8)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1A73E8)
                  : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}