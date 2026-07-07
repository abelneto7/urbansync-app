import '../entities/user.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';

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

  Future<ApiResponse<User>> salvar({
    required String token,
    User? usuario,
    required String nome,
    required String email,
    String? password,
    required List<int> profileIds,
  }) async {
    try {
      final Map<String, dynamic> body;
      if (usuario == null) {
        body = await _service.cadastrar(
          token: token,
          nome: nome,
          email: email,
          password: password ?? '',
          profileIds: profileIds,
        );
      } else {
        body = await _service.atualizar(
          token: token,
          id: usuario.id,
          nome: nome,
          email: email,
          password: password,
          profileIds: profileIds,
        );
      }

      return ApiResponse<User>(
        data: User.fromJson(body['data'] as Map<String, dynamic>),
        message: body['message'] as String? ??
            (usuario == null
                ? 'Usuário cadastrado com sucesso.'
                : 'Usuário atualizado com sucesso.'),
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
