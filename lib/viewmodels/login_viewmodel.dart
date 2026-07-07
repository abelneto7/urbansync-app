import 'package:flutter/foundation.dart';
import '../models/repositories/auth_repository.dart';
import '../models/entities/user.dart';
import '../shared/config/auth_session.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  String? _token;
  String? get token => _token;

  User? _usuario;
  User? get usuario => _usuario;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _authRepository.login(email, password);

    final success = result.when(
      success: (response) {
        _token = response.accessToken;
        _usuario = response.usuario;
        _successMessage = response.message;
        AuthSession.instance.setUser(response.usuario);
        return true;
      },
      failure: (error) {
        _errorMessage = error.message;
        return false;
      },
    );

    _isLoading = false;
    notifyListeners();
    return success;
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
