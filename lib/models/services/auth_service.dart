import '../../shared/network/http_client.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    return HttpClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
  }

  Future<Map<String, dynamic>> me(String token) async {
    return HttpClient.get('/auth/me', token: token);
  }

  Future<Map<String, dynamic>> logout(String token) async {
    return HttpClient.post('/auth/logout', token: token);
  }
}
