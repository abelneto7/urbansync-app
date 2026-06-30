import 'package:flutter/foundation.dart';
import '../models/entities/user.dart';
import '../models/repositories/user_repository.dart';

class CadastroUsuarioViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  CadastroUsuarioViewModel(this._userRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<User?> cadastrar({
    required String token,
    required String nome,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (password != passwordConfirmation) {
      _errorMessage = 'As senhas não coincidem.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _userRepository.cadastrar(
        token: token,
        nome: nome,
        email: email,
        password: password,
      );

      _successMessage = response.message;
      return response.data;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
