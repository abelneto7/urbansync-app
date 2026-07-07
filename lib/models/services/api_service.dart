import '../../shared/config/env_config.dart';

class ApiService {
  static String get baseUrl {
    return EnvConfig.apiUrl;
  }

  static Map<String, String> get defaultHeaders => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  static Map<String, String> authHeaders(String token) => {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };
}

