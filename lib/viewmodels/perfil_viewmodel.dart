import 'package:flutter/foundation.dart';
import '../models/entities/profile.dart';
import '../models/repositories/profile_repository.dart';

class PerfilViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  PerfilViewModel(this._profileRepository);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Profile> _perfis = [];
  List<Profile> get perfis => _perfis;

  Future<void> loadProfiles(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _perfis = await _profileRepository.listar(token);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> saveProfile(
    String token, {
    Profile? profile,
    required String name,
    String? description,
  }) async {
    try {
      final result = await _profileRepository.salvar(
        token: token,
        profile: profile,
        name: name,
        description: description,
      );

      if (profile == null) {
        _perfis.insert(0, result.data);
      } else {
        final index = _perfis.indexWhere((p) => p.id == profile.id);
        if (index != -1) _perfis[index] = result.data;
      }

      notifyListeners();
      return result.message;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<String?> deleteProfile(String token, int id) async {
    try {
      final message = await _profileRepository.remover(token: token, id: id);
      _perfis.removeWhere((p) => p.id == id);
      notifyListeners();
      return message;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
