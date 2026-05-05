import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('${ApiService.baseUrl}/auth/login');

    final response = await http.post(
      uri,
      headers: ApiService.defaultHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      final data = body['data'] as Map<String, dynamic>;
      return {
        'access_token': data['access_token'] as String,
        'usuario': User.fromJson(data['usuario'] as Map<String, dynamic>),
      };
    }

    final message = body['message'] as String? ?? 'Falha ao fazer login.';
    throw Exception(message);
  }

  Future<User> me(String token) async {
    final uri = Uri.parse('${ApiService.baseUrl}/auth/me');

    final response = await http.get(
      uri,
      headers: ApiService.authHeaders(token),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      return User.fromJson(body['data'] as Map<String, dynamic>);
    }

    throw Exception('Não foi possível obter dados do usuário.');
  }

  Future<void> logout(String token) async {
    final uri = Uri.parse('${ApiService.baseUrl}/auth/logout');

    await http.post(
      uri,
      headers: ApiService.authHeaders(token),
    );
  }
}
