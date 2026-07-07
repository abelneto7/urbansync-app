import '../entities/profile.dart';

class ProfileSaveResponse {
  final Profile profile;
  final String message;

  const ProfileSaveResponse({required this.profile, required this.message});
}
