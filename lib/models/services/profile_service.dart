import '../../shared/network/http_client.dart';

class ProfileService {
  Future<Map<String, dynamic>> listar(String token) async {
    return HttpClient.get('/perfil', token: token);
  }

  Future<Map<String, dynamic>> listarPermissoes(String token) async {
    return HttpClient.get('/permissao', token: token);
  }

  Future<Map<String, dynamic>> cadastrar({
    required String token,
    required String name,
    String? description,
  }) async {
    return HttpClient.post(
      '/perfil',
      token: token,
      body: {'name': name, 'description': description},
    );
  }

  Future<Map<String, dynamic>> atualizar({
    required String token,
    required int id,
    required String name,
    String? description,
    List<int>? permissionIds,
  }) async {
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

  Future<Map<String, dynamic>> remover({
    required String token,
    required int id,
  }) async {
    return HttpClient.delete('/perfil/$id', token: token);
  }
}
