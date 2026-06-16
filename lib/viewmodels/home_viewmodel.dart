import 'package:flutter/foundation.dart';
import '../services/interdicao_service.dart';

class HomeViewModel extends ChangeNotifier {
  final InterdicaoService _interdicaoService;

  HomeViewModel(this._interdicaoService);

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
      final lista = await _interdicaoService.listar(token);
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
