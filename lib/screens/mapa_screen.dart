import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/interdicao.dart';
import '../services/interdicao_service.dart';
import '../utils/app_colors.dart';
import '../widgets/app_text.dart';

const _lagarto = LatLng(-10.9167, -37.6500);

class MapaScreen extends StatefulWidget {
  final String token;

  const MapaScreen({super.key, required this.token});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  final _interdicaoService = InterdicaoService();

  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _carregarMarcadores();
  }

  Future<void> _carregarMarcadores() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lista = await _interdicaoService.listar(widget.token);
      final markers = lista.map((i) => _buildMarker(i)).toSet();
      setState(() => _markers = markers);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  Future<void> _irParaLocalizacaoAtual() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _mostrarSnack('GPS desativado. Ative-o nas configurações.', isErro: true);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _mostrarSnack('Permissão de localização negada.', isErro: true);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _mostrarSnack('Permissão negada permanentemente. Habilite nas configurações.', isErro: true);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final controller = await _controllerCompleter.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 15),
        ),
      );
    } catch (e) {
      _mostrarSnack('Erro ao obter localização: $e', isErro: true);
    }
  }

  void _mostrarSnack(String msg, {bool isErro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText.pequeno(msg, color: AppColors.textOnAccent),
        backgroundColor: isErro ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(target: _lagarto, zoom: 13),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) => _controllerCompleter.complete(controller),
        ),

        Positioned(
          top: 12,
          left: 12,
          child: _buildLegenda(),
        ),

        if (_isLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          ),

        if (_errorMessage != null && !_isLoading)
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Material(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.error.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: AppText.pequeno(_errorMessage!, color: Colors.white)),
                    TextButton(
                      onPressed: _carregarMarcadores,
                      child: const AppText.pequeno('Tentar', color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

        Positioned(
          bottom: 24,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'fab_recarregar_mapa',
                onPressed: _carregarMarcadores,
                backgroundColor: AppColors.surface,
                child: const Icon(Icons.refresh_rounded, color: AppColors.accent),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'fab_minha_localizacao',
                onPressed: _irParaLocalizacaoAtual,
                backgroundColor: AppColors.accent,
                child: const Icon(Icons.my_location_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegenda() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _legendaItem('Obra', AppColors.tipoObra, Icons.construction_rounded),
          const SizedBox(height: 4),
          _legendaItem('Evento', AppColors.tipoEvento, Icons.event_rounded),
          const SizedBox(height: 4),
          _legendaItem('Acidente', AppColors.tipoAcidente, Icons.car_crash_rounded),
        ],
      ),
    );
  }

  Widget _legendaItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        AppText.pequeno(label, color: AppColors.textSecondary),
      ],
    );
  }
}
