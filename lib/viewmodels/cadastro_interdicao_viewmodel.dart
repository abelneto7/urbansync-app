import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/entities/interdicao.dart';
import '../models/repositories/interdicao_repository.dart';

class CadastroInterdicaoViewModel extends ChangeNotifier {
  final InterdicaoRepository _interdicaoRepository;

  CadastroInterdicaoViewModel(this._interdicaoRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  int _tipoSelecionado = 1;
  int get tipoSelecionado => _tipoSelecionado;

  bool _statusAtivo = true;
  bool get statusAtivo => _statusAtivo;

  LatLng? _posicaoSelecionada;
  LatLng? get posicaoSelecionada => _posicaoSelecionada;

  void setTipoSelecionado(int tipo) {
    _tipoSelecionado = tipo;
    notifyListeners();
  }

  void setStatusAtivo(bool status) {
    _statusAtivo = status;
    notifyListeners();
  }

  void setPosicaoSelecionada(LatLng? posicao) {
    _posicaoSelecionada = posicao;
    notifyListeners();
  }

  Future<Interdicao?> cadastrar({
    required String token,
    required String titulo,
    String? descricao,
    required double latitude,
    required double longitude,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _interdicaoRepository.cadastrar(
      token: token,
      titulo: titulo,
      descricao: descricao,
      latitude: latitude,
      longitude: longitude,
      tipo: _tipoSelecionado,
      status: _statusAtivo,
    );

    final interdicao = result.when(
      success: (response) {
        _successMessage = response.message;
        return response.interdicao;
      },
      failure: (error) {
        _errorMessage = error.message;
        return null;
      },
    );

    _isLoading = false;
    notifyListeners();
    return interdicao;
  }
}
