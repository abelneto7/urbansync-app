import '../models/user.dart';
import '../utils/http_client.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final body = await HttpClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    final data = body['data'] as Map<String, dynamic>;
    return {
      'access_token': data['access_token'] as String,
      'usuario': User.fromJson(data['usuario'] as Map<String, dynamic>),
      'message': body['message'] as String? ?? 'Login realizado com sucesso.',
    };
  }

  Future<User> me(String token) async {
    final body = await HttpClient.get('/auth/me', token: token);
    return User.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<String> logout(String token) async {
    final body = await HttpClient.post('/auth/logout', token: token);
    return body['message'] as String? ?? 'Sessão encerrada.';
  }
}
