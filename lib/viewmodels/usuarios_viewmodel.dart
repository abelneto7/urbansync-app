import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UsuariosViewModel extends ChangeNotifier {
  final UserService _userService;

  UsuariosViewModel(this._userService);

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
      final lista = await _userService.listar(token);
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
      final message = await _userService.remover(token: token, id: usuario.id);
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
