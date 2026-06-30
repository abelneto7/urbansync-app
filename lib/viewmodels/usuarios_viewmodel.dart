import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

/// Gerencia o estado da lista de usuários (carregar, remover, adicionar localmente).
/// Consome APENAS UserRepository — nunca fala diretamente com UserService.
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

  void adicionarUsuarioLocal(User usuario) {
    _usuarios.insert(0, usuario);
    notifyListeners();
  }
}
