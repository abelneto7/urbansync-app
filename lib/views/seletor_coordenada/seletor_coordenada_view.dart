import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../shared/utils/app_colors.dart';
import '../global_widgets/app_text.dart';
import '../../viewmodels/seletor_coordenada_viewmodel.dart';

const _lagarto = LatLng(-10.9167, -37.6500);

Future<LatLng?> selecionarCoordenadaNoMapa(
  BuildContext context, {
  LatLng? posicaoInicial,
}) {
  return Navigator.of(context).push<LatLng>(
    MaterialPageRoute(
      builder: (_) => _SeletorCoordenadaView(posicaoInicial: posicaoInicial),
    ),
  );
}

class _SeletorCoordenadaView extends StatefulWidget {
  final LatLng? posicaoInicial;

  const _SeletorCoordenadaView({this.posicaoInicial});

  @override
  State<_SeletorCoordenadaView> createState() => _SeletorCoordenadaViewState();
}

class _SeletorCoordenadaViewState extends State<_SeletorCoordenadaView> {
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  late final SeletorCoordenadaViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SeletorCoordenadaViewModel(posicaoInicial: widget.posicaoInicial);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onTap(LatLng posicao) {
    _viewModel.marcarPosicao(posicao);
  }

  void _confirmar() {
    if (_viewModel.marcado == null) return;
    Navigator.of(context).pop(_viewModel.marcado);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textOnAccent, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const AppText.subtitulo(
          'Toque para marcar a posição',
          color: AppColors.textOnAccent,
        ),
        centerTitle: false,
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final latLng = _viewModel.marcado;
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.posicaoInicial ?? _lagarto,
                  zoom: 14,
                ),
                markers: _viewModel.markers,
                onTap: _onTap,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                onMapCreated: (c) => _controllerCompleter.complete(c),
              ),

              if (latLng != null)
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppText.pequeno('Posição selecionada:', color: AppColors.textMuted),
                        const SizedBox(height: 4),
                        AppText.corpo(
                          'Lat: ${latLng.latitude.toStringAsFixed(6)}',
                          color: AppColors.textPrimary,
                        ),
                        AppText.corpo(
                          'Lng: ${latLng.longitude.toStringAsFixed(6)}',
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),

              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: ElevatedButton.icon(
                  onPressed: latLng != null ? _confirmar : null,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                  label: const AppText(
                    'Confirmar localização',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnAccent,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.textOnAccent,
                    disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.4),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
