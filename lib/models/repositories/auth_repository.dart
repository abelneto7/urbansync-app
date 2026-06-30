import '../entities/user.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final body = await _service.login(email, password);
      final data = body['data'] as Map<String, dynamic>;
      return {
        'access_token': data['access_token'] as String,
        'usuario': User.fromJson(data['usuario'] as Map<String, dynamic>),
        'message': body['message'] as String? ?? 'Login realizado com sucesso.',
      };
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<User> me(String token) async {
    try {
      final body = await _service.me(token);
      return User.fromJson(body['data'] as Map<String, dynamic>);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> logout(String token) async {
    try {
      final body = await _service.logout(token);
      return body['message'] as String? ?? 'Sessão encerrada.';
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
