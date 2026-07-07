import 'package:flutter/foundation.dart';
import '../models/entities/profile.dart';
import '../models/repositories/profile_repository.dart';

class UsuarioFormViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  UsuarioFormViewModel(this._profileRepository);

  bool _isLoadingProfiles = false;
  bool get isLoadingProfiles => _isLoadingProfiles;

  String? _profilesError;
  String? get profilesError => _profilesError;

  List<Profile> _availableProfiles = [];
  List<Profile> get availableProfiles => _availableProfiles;

  final Set<int> _selectedProfileIds = {};
  Set<int> get selectedProfileIds => _selectedProfileIds;

  void initSelectedIds(List<int> ids) {
    if (ids.isNotEmpty) {
      _selectedProfileIds.addAll(ids);
      notifyListeners();
    }
  }

  Future<void> carregarPerfis(String token) async {
    _isLoadingProfiles = true;
    _profilesError = null;
    notifyListeners();

    final result = await _profileRepository.listar(token);

    result.when(
      success: (profiles) => _availableProfiles = profiles,
      failure: (error) => _profilesError = error.message,
    );

    _isLoadingProfiles = false;
    notifyListeners();
  }

  void toggleProfile(int id) {
    if (_selectedProfileIds.contains(id)) {
      _selectedProfileIds.remove(id);
    } else {
      _selectedProfileIds.add(id);
    }
    notifyListeners();
  }

  void disposeViewModel() {
    super.dispose();
  }
}
