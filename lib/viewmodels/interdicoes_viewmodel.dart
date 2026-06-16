import 'package:flutter/foundation.dart';
import '../models/interdicao.dart';
import '../services/interdicao_service.dart';

class InterdicoesViewModel extends ChangeNotifier {
  final InterdicaoService _interdicaoService;

  InterdicoesViewModel(this._interdicaoService);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Interdicao> _interdicoes = [];
  List<Interdicao> get interdicoes => _interdicoes;

  Future<void> carregarInterdicoes(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final lista = await _interdicaoService.listar(token);
      _interdicoes = lista;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> removerInterdicao(String token, Interdicao interdicao) async {
    try {
      final message = await _interdicaoService.remover(token: token, id: interdicao.id);
      _interdicoes.removeWhere((i) => i.id == interdicao.id);
      notifyListeners();
      return message;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void adicionarInterdicaoLocal(Interdicao interdicao) {
    _interdicoes.insert(0, interdicao);
    notifyListeners();
  }
}
