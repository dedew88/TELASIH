import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pasien.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('telasih.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pasien (
        id TEXT PRIMARY KEY,
        nama_lengkap TEXT NOT NULL,
        umur INTEGER NOT NULL,
        jenis_kelamin TEXT NOT NULL,
        alamat TEXT NOT NULL,
        no_hp TEXT NOT NULL,
        no_rm TEXT NOT NULL,
        keluhan_utama TEXT NOT NULL,
        tanggal_daftar TEXT NOT NULL
      )
    ''');
  }

  Future<String> insertPasien(Pasien pasien) async {
    final db = await instance.database;
    await db.insert('pasien', pasien.toMap());
    return pasien.id!;
  }

  Future<List<Pasien>> getAllPasien() async {
    final db = await instance.database;
    final result = await db.query('pasien', orderBy: 'tanggal_daftar DESC');
    return result.map((map) => Pasien.fromMap(map)).toList();
  }

  Future<Pasien?> getPasienById(String id) async {
    final db = await instance.database;
    final maps = await db.query('pasien', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Pasien.fromMap(maps.first);
    return null;
  }

  Future<int> deletePasien(String id) async {
    final db = await instance.database;
    return await db.delete('pasien', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}