import '../../shared/network/http_client.dart';
import '../../shared/result.dart';

class AuthService {
  Future<Result<Map<String, dynamic>>> login(String email, String password) {
    return HttpClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
  }

  Future<Result<Map<String, dynamic>>> me(String token) {
    return HttpClient.get('/auth/me', token: token);
  }

  Future<Result<Map<String, dynamic>>> logout(String token) {
    return HttpClient.post('/auth/logout', token: token);
  }
}
