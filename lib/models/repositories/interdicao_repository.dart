import '../entities/interdicao.dart';
import '../services/interdicao_service.dart';
import '../dtos/interdicao_save_response.dart';
import '../../shared/result.dart';

class InterdicaoRepository {
  final InterdicaoService _service;

  InterdicaoRepository(this._service);

  Future<Result<List<Interdicao>>> listar(String token) async {
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
          .map((e) => Interdicao.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<Result<InterdicaoSaveResponse>> cadastrar({
    required String token,
    required String titulo,
    String? descricao,
    required double latitude,
    required double longitude,
    required int tipo,
    required DateTime dataInicio,
    DateTime? dataFim,
  }) async {
    final result = await _service.cadastrar(
      token: token,
      titulo: titulo,
      descricao: descricao,
      latitude: latitude,
      longitude: longitude,
      tipo: tipo,
      dataInicio: Interdicao.formatDateTime(dataInicio),
      dataFim: dataFim != null ? Interdicao.formatDateTime(dataFim) : null,
    );

    return result.map((body) => InterdicaoSaveResponse(
          interdicao: Interdicao.fromJson(body['data'] as Map<String, dynamic>),
          message: body['message'] as String? ??
              'Interdição cadastrada com sucesso.',
        ));
  }

  Future<Result<InterdicaoSaveResponse>> atualizar({
    required String token,
    required int id,
    required String titulo,
    String? descricao,
    required double latitude,
    required double longitude,
    required int tipo,
    required DateTime dataInicio,
    DateTime? dataFim,
  }) async {
    final result = await _service.atualizar(
      token: token,
      id: id,
      titulo: titulo,
      descricao: descricao,
      latitude: latitude,
      longitude: longitude,
      tipo: tipo,
      dataInicio: Interdicao.formatDateTime(dataInicio),
      dataFim: dataFim != null ? Interdicao.formatDateTime(dataFim) : null,
    );

    return result.map((body) => InterdicaoSaveResponse(
          interdicao: Interdicao.fromJson(body['data'] as Map<String, dynamic>),
          message:
              body['message'] as String? ?? 'Interdição atualizada com sucesso.',
        ));
  }

  Future<Result<String>> remover(
      {required String token, required int id}) async {
    final result = await _service.remover(token: token, id: id);
    return result.map(
      (body) =>
          body['message'] as String? ?? 'Interdição removida com sucesso.',
    );
  }
}
