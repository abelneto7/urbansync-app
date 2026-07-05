import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/services/api_service.dart';

class HttpClient {
  static Future<Map<String, dynamic>> get(String endpoint, {String? token}) async {
    final uri = Uri.parse('${ApiService.baseUrl}$endpoint');
    final response = await http.get(
      uri,
      headers: token != null ? ApiService.authHeaders(token) : ApiService.defaultHeaders,
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> post(String endpoint, {String? token, Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiService.baseUrl}$endpoint');
    final response = await http.post(
      uri,
      headers: token != null ? ApiService.authHeaders(token) : ApiService.defaultHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _processResponse(response);
  }

  static Future<Map<String, dynamic>> delete(String endpoint, {String? token}) async {
    final uri = Uri.parse('${ApiService.baseUrl}$endpoint');
    final response = await http.delete(
      uri,
      headers: token != null ? ApiService.authHeaders(token) : ApiService.defaultHeaders,
    );
    return _processResponse(response);
  }

  static Map<String, dynamic> _processResponse(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Erro ao processar resposta do servidor.');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.containsKey('status') && body['status'] != 'success') {
        throw Exception(body['message'] ?? 'Erro desconhecido retornado pela API.');
      }
      return body;
    } else {
      final message = body['message'] as String? ?? 'Falha na requisição (Código ${response.statusCode}).';
      throw Exception(message);
    }
  }
}
