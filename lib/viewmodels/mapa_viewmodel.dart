import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/entities/interdicao.dart';
import '../models/entities/tipo_interdicao.dart';
import '../models/repositories/interdicao_repository.dart';

class MapaViewModel extends ChangeNotifier {
  final InterdicaoRepository _interdicaoRepository;

  MapaViewModel(this._interdicaoRepository);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  Future<void> carregarMarcadores(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _interdicaoRepository.listar(token);

    result.when(
      success: (lista) => _markers = lista.map(_buildMarker).toSet(),
      failure: (error) => _errorMessage = error.message,
    );

    _isLoading = false;
    notifyListeners();
  }

  Marker _buildMarker(Interdicao i) {
    final BitmapDescriptor icon;
    switch (i.tipoEnum) {
      case TipoInterdicao.obra:
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
        break;
      case TipoInterdicao.evento:
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
        break;
      case TipoInterdicao.acidente:
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        break;
      case TipoInterdicao.desconhecido:
        icon = BitmapDescriptor.defaultMarker;
        break;
    }

    return Marker(
      markerId: MarkerId('interdicao_${i.id}'),
      position: LatLng(i.latitude, i.longitude),
      icon: icon,
      infoWindow: InfoWindow(
        title: i.titulo,
        snippet: '${i.tipoLabel} · ${i.statusLabel}',
      ),
    );
  }
}
