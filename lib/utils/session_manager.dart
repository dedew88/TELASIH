import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../models/user.dart';

class SessionManager {
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static void setUser(User user) {
    _currentUser = user;
  }

  static void setFirebaseUser(fb.User firebaseUser, Map<String, dynamic> data) {
    _currentUser = User(
      id: firebaseUser.uid,
      nama: data['nama'] ?? '',
      email: firebaseUser.email ?? '',
      password: '',
      role: data['role'] ?? 'pasien',
      tanggalDaftar: data['tanggalDaftar'] ?? '',
    );
  }

  static void logout() {
    _currentUser = null;
    fb.FirebaseAuth.instance.signOut();
  }

  static bool get isLoggedIn => _currentUser != null;

  static bool get isDokter => _currentUser?.role == 'dokter';

  static bool get isPasien => _currentUser?.role == 'pasien';
}