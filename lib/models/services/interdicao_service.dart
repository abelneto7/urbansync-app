import '../../shared/network/http_client.dart';
import '../../shared/result.dart';

class InterdicaoService {
  Future<Result<Map<String, dynamic>>> listar(String token) {
    return HttpClient.get('/interdicao', token: token);
  }

  Future<Result<Map<String, dynamic>>> cadastrar({
    required String token,
    required String titulo,
    String? descricao,
    required double latitude,
    required double longitude,
    required int tipo,
    required String dataInicio,
    String? dataFim,
  }) {
    final payload = <String, dynamic>{
      'titulo': titulo,
      'latitude': latitude,
      'longitude': longitude,
      'tipo': tipo,
      'data_inicio': dataInicio,
    };
    if (descricao != null && descricao.isNotEmpty) {
      payload['descricao'] = descricao;
    }
    if (dataFim != null) {
      payload['data_fim'] = dataFim;
    }
    return HttpClient.post('/interdicao', token: token, body: payload);
  }

  Future<Result<Map<String, dynamic>>> atualizar({
    required String token,
    required int id,
    required String titulo,
    String? descricao,
    required double latitude,
    required double longitude,
    required int tipo,
    required String dataInicio,
    String? dataFim,
  }) {
    final payload = <String, dynamic>{
      'titulo': titulo,
      'latitude': latitude,
      'longitude': longitude,
      'tipo': tipo,
      'data_inicio': dataInicio,
    };
    if (descricao != null && descricao.isNotEmpty) {
      payload['descricao'] = descricao;
    }
    if (dataFim != null) {
      payload['data_fim'] = dataFim;
    }
    return HttpClient.put('/interdicao/$id', token: token, body: payload);
  }

  Future<Result<Map<String, dynamic>>> remover({
    required String token,
    required int id,
  }) {
    return HttpClient.delete('/interdicao/$id', token: token);
  }
}
