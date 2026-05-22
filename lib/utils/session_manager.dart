import '../models/user.dart';

class SessionManager {
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static void setUser(User user) {
    _currentUser = user;
  }

  static void logout() {
    _currentUser = null;
  }

  static bool get isLoggedIn => _currentUser != null;

  static bool get isDokter => _currentUser?.role == 'dokter';

  static bool get isPasien => _currentUser?.role == 'pasien';
}