import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/interdicao.dart';

class InterdicaoService {
  Future<List<Interdicao>> listar(String token) async {
    final uri = Uri.parse('${ApiService.baseUrl}/interdicao');

    final response = await http.get(
      uri,
      headers: ApiService.authHeaders(token),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 && body['status'] == 'success') {
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

    final message = body['message'] as String? ?? 'Erro ao listar interdições.';
    throw Exception(message);
  }

  Future<Interdicao> cadastrar({
    required String token,
    required String titulo,
    String? descricao,
    required double latitude,
    required double longitude,
    required int tipo,
    required bool status,
  }) async {
    final uri = Uri.parse('${ApiService.baseUrl}/interdicao');

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

    final response = await http.post(
      uri,
      headers: ApiService.authHeaders(token),
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['status'] == 'success') {
      return Interdicao.fromJson(body['data'] as Map<String, dynamic>);
    }

    final message =
        body['message'] as String? ?? 'Erro ao cadastrar interdição.';
    throw Exception(message);
  }

  Future<void> remover({required String token, required int id}) async {
    final uri = Uri.parse('${ApiService.baseUrl}/interdicao/$id');

    final response = await http.delete(
      uri,
      headers: ApiService.authHeaders(token),
    );

    if (response.statusCode == 200 || response.statusCode == 204) return;

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final message = body['message'] as String? ?? 'Erro ao remover interdição.';
    throw Exception(message);
  }
}
