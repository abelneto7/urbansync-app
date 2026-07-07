import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../models/services/api_service.dart';
import '../result.dart';

class HttpClient {
  static Future<Result<Map<String, dynamic>>> get(
    String endpoint, {
    String? token,
  }) async {
    return _execute(() => http.get(
          Uri.parse('${ApiService.baseUrl}$endpoint'),
          headers: token != null
              ? ApiService.authHeaders(token)
              : ApiService.defaultHeaders,
        ));
  }

  static Future<Result<Map<String, dynamic>>> post(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    return _execute(() => http.post(
          Uri.parse('${ApiService.baseUrl}$endpoint'),
          headers: token != null
              ? ApiService.authHeaders(token)
              : ApiService.defaultHeaders,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  static Future<Result<Map<String, dynamic>>> delete(
    String endpoint, {
    String? token,
  }) async {
    return _execute(() => http.delete(
          Uri.parse('${ApiService.baseUrl}$endpoint'),
          headers: token != null
              ? ApiService.authHeaders(token)
              : ApiService.defaultHeaders,
        ));
  }

  static Future<Result<Map<String, dynamic>>> put(
    String endpoint, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    return _execute(() => http.put(
          Uri.parse('${ApiService.baseUrl}$endpoint'),
          headers: token != null
              ? ApiService.authHeaders(token)
              : ApiService.defaultHeaders,
          body: body != null ? jsonEncode(body) : null,
        ));
  }

  static Future<Result<Map<String, dynamic>>> _execute(
    Future<http.Response> Function() call,
  ) async {
    try {
      final response = await call();
      return _processResponse(response);
    } on SocketException {
      return Result.failure(
        const NetworkFailure('Sem conexão com a internet. Verifique sua rede.'),
      );
    } on http.ClientException catch (e) {
      return Result.failure(NetworkFailure('Erro de conexão: ${e.message}'));
    } on FormatException {
      return Result.failure(
        const UnexpectedFailure('Resposta inesperada do servidor.'),
      );
    } catch (e) {
      return Result.failure(UnexpectedFailure(e.toString()));
    }
  }

  static Result<Map<String, dynamic>> _processResponse(http.Response response) {
    Map<String, dynamic> body;

    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      return Result.failure(
        const UnexpectedFailure('Erro ao processar resposta do servidor.'),
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.containsKey('status') && body['status'] != 'success') {
        return Result.failure(
          ApiFailure(body['message'] as String? ?? 'Erro desconhecido retornado pela API.'),
        );
      }
      return Result.success(body);
    } else {
      final message = body['message'] as String? ??
          'Falha na requisição (Código ${response.statusCode}).';
      return Result.failure(ApiFailure(message));
    }
  }
}
