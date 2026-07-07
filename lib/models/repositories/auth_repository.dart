import '../entities/user.dart';
import '../services/auth_service.dart';
import '../dtos/login_response.dart';
import '../../shared/result.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  Future<Result<LoginResponse>> login(String email, String password) async {
    final result = await _service.login(email, password);

    return result.map((body) {
      final data = body['data'] as Map<String, dynamic>;
      return LoginResponse(
        accessToken: data['access_token'] as String,
        usuario: User.fromJson(data['usuario'] as Map<String, dynamic>),
        message:
            body['message'] as String? ?? 'Login realizado com sucesso.',
      );
    });
  }

  Future<Result<User>> me(String token) async {
    final result = await _service.me(token);
    return result.map(
      (body) => User.fromJson(body['data'] as Map<String, dynamic>),
    );
  }

  Future<Result<String>> logout(String token) async {
    final result = await _service.logout(token);
    return result.map(
      (body) => body['message'] as String? ?? 'Sessão encerrada.',
    );
  }
}
