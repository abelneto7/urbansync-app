import '../../models/entities/user.dart';

class AuthSession {
  static final AuthSession _instance = AuthSession._internal();
  factory AuthSession() => _instance;
  AuthSession._internal();

  static AuthSession get instance => _instance;

  User? _currentUser;

  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
  }

  void clearSession() {
    _currentUser = null;
  }

  bool hasPermission(String permission) {
    return _currentUser?.permissoes.contains(permission) ?? false;
  }
}
