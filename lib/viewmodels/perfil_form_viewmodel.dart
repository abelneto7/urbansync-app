import 'package:flutter/foundation.dart';
import '../models/entities/permission.dart';
import '../models/repositories/profile_repository.dart';

class PerfilFormViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  PerfilFormViewModel(this._repository);

  bool _isLoadingPermissoes = false;
  bool get isLoadingPermissoes => _isLoadingPermissoes;

  String? _permissoesError;
  String? get permissoesError => _permissoesError;

  Map<String, List<Permission>> _permissoesAgrupadas = {};
  Map<String, List<Permission>> get permissoesAgrupadas => _permissoesAgrupadas;

  final Set<int> _selectedIds = {};
  Set<int> get selectedIds => _selectedIds;

  void initSelectedIds(List<int> ids) {
    _selectedIds
      ..clear()
      ..addAll(ids);
  }

  Future<void> carregarPermissoes(String token) async {
    _isLoadingPermissoes = true;
    _permissoesError = null;
    notifyListeners();

    final result = await _repository.buscarPermissoes(token);

    result.when(
      success: (permissoes) => _permissoesAgrupadas = permissoes,
      failure: (error) => _permissoesError = error.message,
    );

    _isLoadingPermissoes = false;
    notifyListeners();
  }

  void togglePermissao(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }
}
