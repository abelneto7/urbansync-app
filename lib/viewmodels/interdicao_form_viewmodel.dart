import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/entities/interdicao.dart';
import '../models/repositories/interdicao_repository.dart';

class InterdicaoFormViewModel extends ChangeNotifier {
  final InterdicaoRepository _repository;
  final Interdicao? interdicaoInicial;

  InterdicaoFormViewModel(
    this._repository, {
    this.interdicaoInicial,
  }) {
    _inicializar();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  String? _successMessage;
  String? get successMessage => _successMessage;
  late int _tipoSelecionado;
  int get tipoSelecionado => _tipoSelecionado;
  late DateTime _dataInicio;
  DateTime get dataInicio => _dataInicio;
  DateTime? _dataFim;
  DateTime? get dataFim => _dataFim;
  LatLng? _posicaoSelecionada;
  LatLng? get posicaoSelecionada => _posicaoSelecionada;
  bool get isEditing => interdicaoInicial != null;


  void _inicializar() {
    final i = interdicaoInicial;
    if (i != null) {
      _tipoSelecionado = i.tipo;
      _dataInicio = i.dataInicio;
      _dataFim = i.dataFim;
      _posicaoSelecionada = LatLng(i.latitude, i.longitude);
    } else {
      _tipoSelecionado = 1;
      _dataInicio = DateTime.now();
      _dataFim = null;
      _posicaoSelecionada = null;
    }
  }

  void setTipoSelecionado(int tipo) {
    _tipoSelecionado = tipo;
    notifyListeners();
  }

  void setDataInicio(DateTime dataInicio) {
    _dataInicio = dataInicio;
    notifyListeners();
  }

  void setDataFim(DateTime? dataFim) {
    _dataFim = dataFim;
    notifyListeners();
  }

  void setPosicaoSelecionada(LatLng? posicao) {
    _posicaoSelecionada = posicao;
    notifyListeners();
  }

  void limparErro() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<Interdicao?> salvar({
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

    final result = isEditing
        ? await _repository.atualizar(
            token: token,
            id: interdicaoInicial!.id,
            titulo: titulo,
            descricao: descricao,
            latitude: latitude,
            longitude: longitude,
            tipo: _tipoSelecionado,
            dataInicio: _dataInicio,
            dataFim: _dataFim,
          )
        : await _repository.cadastrar(
            token: token,
            titulo: titulo,
            descricao: descricao,
            latitude: latitude,
            longitude: longitude,
            tipo: _tipoSelecionado,
            dataInicio: _dataInicio,
            dataFim: _dataFim,
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
