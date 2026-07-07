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

    try {
      final lista = await _userRepository.listar(token);
      _usuarios = lista;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> removerUsuario(String token, User usuario) async {
    try {
      final message = await _userRepository.remover(
        token: token,
        id: usuario.id,
      );
      _usuarios.removeWhere((i) => i.id == usuario.id);
      notifyListeners();
      return message;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
  Future<String?> saveUsuario({
    required String token,
    User? usuario,
    required String nome,
    required String email,
    String? password,
    required List<int> profileIds,
  }) async {
    try {
      final result = await _userRepository.salvar(
        token: token,
        usuario: usuario,
        nome: nome,
        email: email,
        password: password,
        profileIds: profileIds,
      );

      if (usuario == null) {
        _usuarios.insert(0, result.data);
      } else {
        final index = _usuarios.indexWhere((u) => u.id == usuario.id);
        if (index != -1) _usuarios[index] = result.data;
      }

      notifyListeners();
      return result.message;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
