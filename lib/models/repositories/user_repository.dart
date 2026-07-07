import '../entities/user.dart';
import '../services/user_service.dart';
import '../dtos/user_save_response.dart';
import '../../shared/result.dart';

class UserRepository {
  final UserService _service;

  UserRepository(this._service);

  Future<Result<List<User>>> listar(String token) async {
    final result = await _service.listar(token);

    return result.map((body) {
      final data = body['data'];
      final List<dynamic> lista;
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
    });
  }

  Future<Result<UserSaveResponse>> salvar({
    required String token,
    User? usuario,
    required String nome,
    required String email,
    String? password,
    required List<int> profileIds,
  }) async {
    final result = usuario == null
        ? await _service.cadastrar(
            token: token,
            nome: nome,
            email: email,
            password: password ?? '',
            profileIds: profileIds,
          )
        : await _service.atualizar(
            token: token,
            id: usuario.id,
            nome: nome,
            email: email,
            password: password,
            profileIds: profileIds,
          );

    return result.map((body) => UserSaveResponse(
          user: User.fromJson(body['data'] as Map<String, dynamic>),
          message: body['message'] as String? ??
              (usuario == null
                  ? 'Usuário cadastrado com sucesso.'
                  : 'Usuário atualizado com sucesso.'),
        ));
  }

  Future<Result<String>> remover(
      {required String token, required int id}) async {
    final result = await _service.remover(token: token, id: id);
    return result.map(
      (body) => body['message'] as String? ?? 'Usuário removido com sucesso.',
    );
  }
}
