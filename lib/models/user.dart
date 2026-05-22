class User {
  final String? id;
  final String nama;
  final String email;
  final String password;
  final String role; // 'pasien' atau 'dokter'
  final String tanggalDaftar;

  User({
    this.id,
    required this.nama,
    required this.email,
    required this.password,
    required this.role,
    required this.tanggalDaftar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'password': password,
      'role': role,
      'tanggal_daftar': tanggalDaftar,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nama: map['nama'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      tanggalDaftar: map['tanggal_daftar'],
    );
  }
}