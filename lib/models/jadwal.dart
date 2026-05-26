class Jadwal {
  final String? id;
  final String pasienId;
  final String pasienNama;
  final String dokterNama;
  final String tanggal;
  final String waktu;
  final String status; // 'menunggu', 'selesai', 'dibatalkan'

  Jadwal({
    this.id,
    required this.pasienId,
    required this.pasienNama,
    required this.dokterNama,
    required this.tanggal,
    required this.waktu,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pasien_id': pasienId,
      'pasien_nama': pasienNama,
      'dokter_nama': dokterNama,
      'tanggal': tanggal,
      'waktu': waktu,
      'status': status,
    };
  }

  factory Jadwal.fromMap(Map<String, dynamic> map) {
    return Jadwal(
      id: map['id'],
      pasienId: map['pasien_id'],
      pasienNama: map['pasien_nama'],
      dokterNama: map['dokter_nama'],
      tanggal: map['tanggal'],
      waktu: map['waktu'],
      status: map['status'],
    );
  }
}