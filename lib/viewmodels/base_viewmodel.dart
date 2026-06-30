import 'package:flutter/foundation.dart';
import '../repositories/auth_repository.dart';

/// Gerencia o estado da tela base (drawer, índice de navegação, logout).
/// Consome APENAS AuthRepository — nunca fala diretamente com AuthService.
class BaseViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  BaseViewModel(this._authRepository);

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  Future<String> logout(String token) async {
    try {
      return await _authRepository.logout(token);
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
