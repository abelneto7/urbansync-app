import '../utils/http_client.dart';

/// Responsabilidade ÚNICA: executar chamadas HTTP brutas para endpoints de usuário.
/// Não faz nenhum mapeamento de dado para Model — isso é papel do UserRepository.
class UserService {
  Future<Map<String, dynamic>> listar(String token) async {
    return HttpClient.get('/usuario', token: token);
  }

  Future<Map<String, dynamic>> cadastrar({
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
    return HttpClient.post('/usuario', token: token, body: payload);
  }

  Future<Map<String, dynamic>> remover({
    required String token,
    required int id,
  }) async {
    return HttpClient.delete('/usuario/$id', token: token);
  }
}

