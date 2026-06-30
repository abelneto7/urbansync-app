import '../models/user.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';

/// Ponte entre o ViewModel e o UserService.
/// Responsabilidades:
///   1. Chamar o UserService para obter o Map bruto da API.
///   2. Fazer o mapeamento (fromJson) para List<User> e ApiResponse<User>.
///   3. Tratar e relançar exceções de negócio com mensagens legíveis.
class UserRepository {
  final UserService _service;

  UserRepository(this._service);

  Future<List<User>> listar(String token) async {
    try {
      final body = await _service.listar(token);
      final data = body['data'];

      List<dynamic> lista;
      if (data is Map && data.containsKey('data')) {
        lista = data['data'] as List<dynamic>;
      } else if (data is List) {
        lista = data;
      } else {
        lista = [];
      }

      return lista
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<ApiResponse<User>> cadastrar({
    required String token,
    required String nome,
    required String email,
    required String password,
  }) async {
    try {
      final body = await _service.cadastrar(
        token: token,
        nome: nome,
        email: email,
        password: password,
      );
      return ApiResponse<User>(
        data: User.fromJson(body['data'] as Map<String, dynamic>),
        message: body['message'] as String? ?? 'Usuário cadastrado com sucesso.',
      );
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> remover({required String token, required int id}) async {
    try {
      final body = await _service.remover(token: token, id: id);
      return body['message'] as String? ?? 'Usuário removido com sucesso.';
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
