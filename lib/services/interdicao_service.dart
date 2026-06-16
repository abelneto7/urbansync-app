import '../models/interdicao.dart';
import '../services/api_service.dart';
import '../utils/http_client.dart';

class InterdicaoService {
  Future<List<Interdicao>> listar(String token) async {
    final body = await HttpClient.get('/interdicao', token: token);
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
        .map((e) => Interdicao.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ApiResponse<Interdicao>> cadastrar({
    required String token,
    required String titulo,
    String? descricao,
    required double latitude,
    required double longitude,
    required int tipo,
    required bool status,
  }) async {
    final payload = <String, dynamic>{
      'titulo': titulo,
      'latitude': latitude,
      'longitude': longitude,
      'tipo': tipo,
      'status': status,
    };
    if (descricao != null && descricao.isNotEmpty) {
      payload['descricao'] = descricao;
    }

    final body = await HttpClient.post('/interdicao', token: token, body: payload);

    return ApiResponse<Interdicao>(
      data: Interdicao.fromJson(body['data'] as Map<String, dynamic>),
      message: body['message'] as String? ?? 'Interdição cadastrada com sucesso.',
    );
  }

  Future<String> remover({required String token, required int id}) async {
    final body = await HttpClient.delete('/interdicao/$id', token: token);
    return body['message'] as String? ?? 'Interdição removida com sucesso.';
  }
}
