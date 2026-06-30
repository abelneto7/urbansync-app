import '../entities/interdicao.dart';
import '../services/api_service.dart';
import '../services/interdicao_service.dart';

class InterdicaoRepository {
  final InterdicaoService _service;

  InterdicaoRepository(this._service);

  Future<List<Interdicao>> listar(String token) async {
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
          .map((e) => Interdicao.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
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
    try {
      final body = await _service.cadastrar(
        token: token,
        titulo: titulo,
        descricao: descricao,
        latitude: latitude,
        longitude: longitude,
        tipo: tipo,
        status: status,
      );
      return ApiResponse<Interdicao>(
        data: Interdicao.fromJson(body['data'] as Map<String, dynamic>),
        message: body['message'] as String? ?? 'Interdição cadastrada com sucesso.',
      );
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String> remover({required String token, required int id}) async {
    try {
      final body = await _service.remover(token: token, id: id);
      return body['message'] as String? ?? 'Interdição removida com sucesso.';
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
