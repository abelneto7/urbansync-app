import 'package:flutter/foundation.dart';
import '../models/entities/user.dart';
import '../models/repositories/user_repository.dart';

class UsuariosViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  UsuariosViewModel(this._userRepository);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<User> _usuarios = [];
  List<User> get usuarios => _usuarios;

  Future<void> carregarUsuarios(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _userRepository.listar(token);

    result.when(
      success: (lista) => _usuarios = lista,
      failure: (error) => _errorMessage = error.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> removerUsuario(String token, User usuario) async {
    final result = await _userRepository.remover(
      token: token,
      id: usuario.id,
    );

    return result.when(
      success: (message) {
        _usuarios.removeWhere((i) => i.id == usuario.id);
        notifyListeners();
        return message;
      },
      failure: (error) {
        _errorMessage = error.message;
        notifyListeners();
        return null;
      },
    );
  }

  Future<String?> saveUsuario({
    required String token,
    User? usuario,
    required String nome,
    required String email,
    String? password,
    required List<int> profileIds,
  }) async {
    final result = await _userRepository.salvar(
      token: token,
      usuario: usuario,
      nome: nome,
      email: email,
      password: password,
      profileIds: profileIds,
    );

    return result.when(
      success: (response) {
        if (usuario == null) {
          _usuarios.insert(0, response.user);
        } else {
          final index = _usuarios.indexWhere((u) => u.id == usuario.id);
          if (index != -1) _usuarios[index] = response.user;
        }
        notifyListeners();
        return response.message;
      },
      failure: (error) {
        _errorMessage = error.message;
        notifyListeners();
        return null;
      },
    );
  }
}
