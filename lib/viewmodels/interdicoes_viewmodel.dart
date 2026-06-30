import 'package:flutter/foundation.dart';
import '../models/interdicao.dart';
import '../repositories/interdicao_repository.dart';

/// Gerencia o estado da lista de interdições (carregar, remover, adicionar localmente).
/// Consome APENAS InterdicaoRepository — nunca fala diretamente com InterdicaoService.
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

    try {
      final lista = await _interdicaoRepository.listar(token);
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
      final message = await _interdicaoRepository.remover(
        token: token,
        id: interdicao.id,
      );
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
