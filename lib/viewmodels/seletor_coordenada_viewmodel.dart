import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SeletorCoordenadaViewModel extends ChangeNotifier {
  LatLng? _marcado;
  LatLng? get marcado => _marcado;

  SeletorCoordenadaViewModel({LatLng? posicaoInicial}) {
    _marcado = posicaoInicial;
  }

  void marcarPosicao(LatLng posicao) {
    _marcado = posicao;
    notifyListeners();
  }

  Set<Marker> get markers {
    if (_marcado == null) return {};
    return {
      Marker(
        markerId: const MarkerId('selecionado'),
        position: _marcado!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Posição selecionada',
          snippet:
              'Lat: ${_marcado!.latitude.toStringAsFixed(6)}  Lng: ${_marcado!.longitude.toStringAsFixed(6)}',
        ),
      ),
    };
  }
}
