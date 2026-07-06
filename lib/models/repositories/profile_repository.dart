import '../entities/profile.dart';
import '../services/api_service.dart';
import '../services/profile_service.dart';

class ProfileRepository {
  final ProfileService _service;

  ProfileRepository(this._service);

  Future<List<Profile>> listar(String token) async {
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
          .map((e) => Profile.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<ApiResponse<Profile>> salvar({
    required String token,
    Profile? profile,
    required String name,
    String? description,
  }) async {
    try {
      final Map<String, dynamic> body;
      if (profile == null) {
        body = await _service.cadastrar(
          token: token,
          name: name,
          description: description,
        );
      } else {
        body = await _service.atualizar(
          token: token,
          id: profile.id,
          name: name,
          description: description,
        );
      }

      return ApiResponse<Profile>(
        data: Profile.fromJson(body['data'] as Map<String, dynamic>),
        message: body['message'] as String? ??
            (profile == null
                ? 'Perfil cadastrado com sucesso.'
                : 'Perfil atualizado com sucesso.'),
      );
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> remover({required String token, required int id}) async {
    try {
      final body = await _service.remover(token: token, id: id);
      return body['message'] as String? ?? 'Perfil removido com sucesso.';
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
