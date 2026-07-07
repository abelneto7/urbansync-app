import '../../shared/network/http_client.dart';
import '../../shared/result.dart';

class ProfileService {
  Future<Result<Map<String, dynamic>>> listar(String token) {
    return HttpClient.get('/perfil', token: token);
  }

  Future<Result<Map<String, dynamic>>> listarPermissoes(String token) {
    return HttpClient.get('/permissao', token: token);
  }

  Future<Result<Map<String, dynamic>>> cadastrar({
    required String token,
    required String name,
    String? description,
  }) {
    return HttpClient.post(
      '/perfil',
      token: token,
      body: {'name': name, 'description': description},
    );
  }

  Future<Result<Map<String, dynamic>>> atualizar({
    required String token,
    required int id,
    required String name,
    String? description,
    List<int>? permissionIds,
  }) {
    return HttpClient.put(
      '/perfil/$id',
      token: token,
      body: {
        'name': name,
        'description': description,
        'permission_ids': permissionIds ?? [],
      },
    );
  }

  Future<Result<Map<String, dynamic>>> remover({
    required String token,
    required int id,
  }) {
    return HttpClient.delete('/perfil/$id', token: token);
  }
}
