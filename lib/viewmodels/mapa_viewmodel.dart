import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/interdicao.dart';
import '../services/interdicao_service.dart';

class MapaViewModel extends ChangeNotifier {
  final InterdicaoService _interdicaoService;

  MapaViewModel(this._interdicaoService);

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

    try {
      final lista = await _interdicaoService.listar(token);
      _markers = lista.map((i) => _buildMarker(i)).toSet();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Marker _buildMarker(Interdicao i) {
    final BitmapDescriptor icon;
    switch (i.tipo) {
      case 1:
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
        break;
      case 2:
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
        break;
      case 3:
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        break;
      default:
        icon = BitmapDescriptor.defaultMarker;
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
