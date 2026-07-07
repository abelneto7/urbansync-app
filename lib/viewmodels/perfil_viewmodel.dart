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

    final result = await _profileRepository.listar(token);

    result.when(
      success: (lista) => _perfis = lista,
      failure: (error) => _errorMessage = error.message,
    );

    _isLoading = false;
    notifyListeners();
  }
  
  Future<String?> saveProfile(
    String token, {
    Profile? profile,
    required String name,
    String? description,
    List<int>? permissionIds,
  }) async {
    final result = await _profileRepository.salvar(
      token: token,
      profile: profile,
      name: name,
      description: description,
      permissionIds: permissionIds,
    );

    return result.when(
      success: (response) {
        if (profile == null) {
          _perfis.insert(0, response.profile);
        } else {
          final index = _perfis.indexWhere((p) => p.id == profile.id);
          if (index != -1) _perfis[index] = response.profile;
        }
        notifyListeners();
        return response.message;
      },
      failure: (error) {
        _errorMessage = error.message;
        notifyListeners();
        return null;
      },
    );
  }

  Future<String?> deleteProfile(String token, int id) async {
    final result = await _profileRepository.remover(token: token, id: id);

    return result.when(
      success: (message) {
        _perfis.removeWhere((p) => p.id == id);
        notifyListeners();
        return message;
      },
      failure: (error) {
        _errorMessage = error.message;
        notifyListeners();
        return null;
      },
    );
  }
}
