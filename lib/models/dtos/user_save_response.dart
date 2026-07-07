import '../entities/user.dart';

class UserSaveResponse {
  final User user;
  final String message;

  const UserSaveResponse({required this.user, required this.message});
}
