import '../../shared/network/http_client.dart';
import '../../shared/result.dart';

class UserService {
  Future<Result<Map<String, dynamic>>> listar(String token) {
    return HttpClient.get('/usuario', token: token);
  }

  Future<Result<Map<String, dynamic>>> cadastrar({
    required String token,
    required String nome,
    required String email,
    required String password,
    required List<int> profileIds,
  }) {
    final payload = <String, dynamic>{
      'name': nome,
      'email': email,
      'password': password,
      'profile_ids': profileIds,
    };
    return HttpClient.post('/usuario', token: token, body: payload);
  }

  Future<Result<Map<String, dynamic>>> atualizar({
    required String token,
    required int id,
    required String nome,
    required String email,
    String? password,
    required List<int> profileIds,
  }) {
    final payload = <String, dynamic>{
      'name': nome,
      'email': email,
      'profile_ids': profileIds,
    };
    if (password != null && password.trim().isNotEmpty) {
      payload['password'] = password.trim();
    }
    return HttpClient.put('/usuario/$id', token: token, body: payload);
  }

  Future<Result<Map<String, dynamic>>> remover({
    required String token,
    required int id,
  }) {
    return HttpClient.delete('/usuario/$id', token: token);
  }
}
