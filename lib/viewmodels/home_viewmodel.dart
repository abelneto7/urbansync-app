import 'package:flutter/foundation.dart';
import '../repositories/interdicao_repository.dart';

/// Gerencia o estado do Dashboard (estatísticas por tipo).
/// Consome APENAS InterdicaoRepository — nunca fala diretamente com InterdicaoService.
class HomeViewModel extends ChangeNotifier {
  final InterdicaoRepository _interdicaoRepository;

  HomeViewModel(this._interdicaoRepository);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _obras = 0;
  int get obras => _obras;

  int _eventos = 0;
  int get eventos => _eventos;

  int _acidentes = 0;
  int get acidentes => _acidentes;

  Future<void> carregarEstatisticas(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final lista = await _interdicaoRepository.listar(token);
      _obras = lista.where((i) => i.tipo == 1).length;
      _eventos = lista.where((i) => i.tipo == 2).length;
      _acidentes = lista.where((i) => i.tipo == 3).length;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
