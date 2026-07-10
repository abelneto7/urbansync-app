import 'package:flutter/foundation.dart';
import '../models/entities/interdicao.dart';
import '../models/repositories/interdicao_repository.dart';

class InterdicoesViewModel extends ChangeNotifier {
  final InterdicaoRepository _interdicaoRepository;

  InterdicoesViewModel(this._interdicaoRepository);

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

    final result = await _interdicaoRepository.listar(token);

    result.when(
      success: (lista) => _interdicoes = lista,
      failure: (error) => _errorMessage = error.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> removerInterdicao(String token, Interdicao interdicao) async {
    final result = await _interdicaoRepository.remover(
      token: token,
      id: interdicao.id,
    );

    return result.when(
      success: (message) {
        _interdicoes.removeWhere((i) => i.id == interdicao.id);
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

  void adicionarInterdicaoLocal(Interdicao interdicao) {
    _interdicoes.insert(0, interdicao);
    notifyListeners();
  }

  void atualizarInterdicaoLocal(Interdicao atualizada) {
    final index = _interdicoes.indexWhere((i) => i.id == atualizada.id);
    if (index != -1) {
      _interdicoes[index] = atualizada;
      notifyListeners();
    }
  }
}
