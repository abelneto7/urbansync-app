import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/user.dart';

class UserService {
  Future<List<User>> listar(String token) async {
    final uri = Uri.parse('${ApiService.baseUrl}/usuario');

    final response = await http.get(
      uri,
      headers: ApiService.authHeaders(token),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
      final data = body['data'];

      List<dynamic> lista;
      if (data is Map && data.containsKey('data')) {
        lista = data['data'] as List<dynamic>;
      } else if (data is List) {
        lista = data;
      } else {
        lista = [];
      }

      return lista.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    }

    final message = body['message'] as String? ?? 'Erro ao listar usuários.';
    throw Exception(message);
  }

  Future<ApiResponse<User>> cadastrar({
    required String token,
    required String nome,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/usuario');

    final payload = <String, dynamic>{
      'name': nome,
      'email': email,
      'password': password,
    };

    final response = await http.post(
      uri,
      headers: ApiService.authHeaders(token),
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['status'] == 'success') {
      return ApiResponse<User>(
        data: User.fromJson(body['data'] as Map<String, dynamic>),
        message: body['message'] as String? ?? 'Usuário cadastrado com sucesso.',
      );
    }

    final message =
        body['message'] as String? ?? 'Erro ao cadastrar usuário.';
    throw Exception(message);
  }

  Future<String> remover({required String token, required int id}) async {
    final uri = Uri.parse('${ApiService.baseUrl}/usuario/$id');

    final response = await http.delete(
      uri,
      headers: ApiService.authHeaders(token),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if ((response.statusCode == 200 || response.statusCode == 204) && body['status'] == 'success') {
      return body['message'] as String? ?? 'Usuário removido com sucesso.';
    }

    final message = body['message'] as String? ?? 'Erro ao remover usuário.';
    throw Exception(message);
  }
}
