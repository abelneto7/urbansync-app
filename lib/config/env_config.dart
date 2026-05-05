import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get apiUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.trim().isEmpty) {
      throw Exception('Variavel de ambiente API_BASE_URL nao configurada ou nula.');
    }
    return url;
  }
}
