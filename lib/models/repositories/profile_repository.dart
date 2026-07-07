import '../entities/permission.dart';
import '../entities/profile.dart';
import '../services/profile_service.dart';
import '../dtos/profile_save_response.dart';
import '../../shared/result.dart';

class ProfileRepository {
  final ProfileService _service;

  ProfileRepository(this._service);

  Future<Result<List<Profile>>> listar(String token) async {
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
          .map((e) => Profile.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Result<Map<String, List<Permission>>>> buscarPermissoes(
      String token) async {
    final result = await _service.listarPermissoes(token);

    return result.map((body) {
      final data = body['data'] as Map<String, dynamic>;
      return data.map((module, rawList) {
        final perms = (rawList as List<dynamic>)
            .map((e) => Permission.fromJson(e as Map<String, dynamic>))
            .toList();
        return MapEntry(module, perms);
      });
    });
  }

  Future<Result<ProfileSaveResponse>> salvar({
    required String token,
    Profile? profile,
    required String name,
    String? description,
    List<int>? permissionIds,
  }) async {
    final result = profile == null
        ? await _service.cadastrar(
            token: token,
            name: name,
            description: description,
          )
        : await _service.atualizar(
            token: token,
            id: profile.id,
            name: name,
            description: description,
            permissionIds: permissionIds,
          );

    return result.map((body) => ProfileSaveResponse(
          profile: Profile.fromJson(body['data'] as Map<String, dynamic>),
          message: body['message'] as String? ??
              (profile == null
                  ? 'Perfil cadastrado com sucesso.'
                  : 'Perfil atualizado com sucesso.'),
        ));
  }

  Future<Result<String>> remover(
      {required String token, required int id}) async {
    final result = await _service.remover(token: token, id: id);
    return result.map(
      (body) => body['message'] as String? ?? 'Perfil removido com sucesso.',
    );
  }
}
