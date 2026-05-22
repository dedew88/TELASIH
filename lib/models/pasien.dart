class Pasien {
  final String? id;
  final String namaLengkap;
  final int umur;
  final String jenisKelamin;
  final String alamat;
  final String noHp;
  final String noRm;
  final String keluhanUtama;
  final String tanggalDaftar;

  Pasien({
    this.id,
    required this.namaLengkap,
    required this.umur,
    required this.jenisKelamin,
    required this.alamat,
    required this.noHp,
    required this.noRm,
    required this.keluhanUtama,
    required this.tanggalDaftar,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_lengkap': namaLengkap,
      'umur': umur,
      'jenis_kelamin': jenisKelamin,
      'alamat': alamat,
      'no_hp': noHp,
      'no_rm': noRm,
      'keluhan_utama': keluhanUtama,
      'tanggal_daftar': tanggalDaftar,
    };
  }

  factory Pasien.fromMap(Map<String, dynamic> map) {
    return Pasien(
      id: map['id'],
      namaLengkap: map['nama_lengkap'],
      umur: map['umur'],
      jenisKelamin: map['jenis_kelamin'],
      alamat: map['alamat'],
      noHp: map['no_hp'],
      noRm: map['no_rm'],
      keluhanUtama: map['keluhan_utama'],
      tanggalDaftar: map['tanggal_daftar'],
    );
  }
}