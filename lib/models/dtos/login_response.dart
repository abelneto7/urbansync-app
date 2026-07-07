import '../entities/user.dart';

class LoginResponse {
  final String accessToken;
  final User usuario;
  final String message;

  const LoginResponse({
    required this.accessToken,
    required this.usuario,
    required this.message,
  });
}
