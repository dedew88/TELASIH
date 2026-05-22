import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pasien.dart';
import '../models/user.dart';

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
    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Tabel pasien
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

    // Tabel user (akun login)
    await db.execute('''
      CREATE TABLE user (
        id TEXT PRIMARY KEY,
        nama TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        tanggal_daftar TEXT NOT NULL
      )
    ''');
  }

  // ========== PASIEN ==========
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

  // ========== USER ==========
  Future<String> insertUser(User user) async {
    final db = await instance.database;
    await db.insert('user', user.toMap());
    return user.id!;
  }

  Future<User?> loginUser(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'user',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'user',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}