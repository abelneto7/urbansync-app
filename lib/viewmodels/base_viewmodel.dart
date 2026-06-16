import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class BaseViewModel extends ChangeNotifier {
  final AuthService _authService;

  BaseViewModel(this._authService);

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
      final message = await _authService.logout(token);
      return message;
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
  }
}
