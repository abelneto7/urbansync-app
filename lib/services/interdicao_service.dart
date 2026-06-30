import '../utils/http_client.dart';

/// Responsabilidade ÚNICA: executar chamadas HTTP brutas para endpoints de interdição.
/// Não faz nenhum mapeamento de dado para Model — isso é papel do InterdicaoRepository.
class InterdicaoService {
  Future<Map<String, dynamic>> listar(String token) async {
    return HttpClient.get('/interdicao', token: token);
  }

  Future<Map<String, dynamic>> cadastrar({
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
    return HttpClient.post('/interdicao', token: token, body: payload);
  }

  Future<Map<String, dynamic>> remover({
    required String token,
    required int id,
  }) async {
    return HttpClient.delete('/interdicao/$id', token: token);
  }
}

