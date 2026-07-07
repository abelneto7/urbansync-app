import 'package:flutter/foundation.dart';
import '../models/repositories/auth_repository.dart';

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
    final result = await _authRepository.logout(token);
    return result.when(
      success: (message) => message,
      failure: (error) => error.message,
    );
  }
}
