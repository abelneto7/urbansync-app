import '../models/user.dart';
import '../services/api_service.dart';
import '../utils/http_client.dart';

class UserService {
  Future<List<User>> listar(String token) async {
    final body = await HttpClient.get('/usuario', token: token);
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

  Future<ApiResponse<User>> cadastrar({
    required String token,
    required String nome,
    required String email,
    required String password,
  }) async {
    final payload = <String, dynamic>{
      'name': nome,
      'email': email,
      'password': password,
    };

    final body = await HttpClient.post('/usuario', token: token, body: payload);

    return ApiResponse<User>(
      data: User.fromJson(body['data'] as Map<String, dynamic>),
      message: body['message'] as String? ?? 'Usuário cadastrado com sucesso.',
    );
  }

  Future<String> remover({required String token, required int id}) async {
    final body = await HttpClient.delete('/usuario/$id', token: token);
    return body['message'] as String? ?? 'Usuário removido com sucesso.';
  }
}
