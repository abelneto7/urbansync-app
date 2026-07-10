import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../shared/theme/app_colors.dart';
import '../../shared_widgets/app_text_widget.dart';

class InterdicaoLocaleSeletor extends StatelessWidget {
  final LatLng? posicaoSelecionada;
  final VoidCallback onTap;

  const InterdicaoLocaleSeletor({
    super.key,
    required this.onTap,
    this.posicaoSelecionada,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng? pos = posicaoSelecionada;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: pos != null
              ? AppColors.accent.withValues(alpha: 0.08)
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: pos != null ? AppColors.accent : AppColors.divider,
            width: pos != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (pos != null ? AppColors.accent : AppColors.textMuted)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                pos != null
                    ? Icons.location_on_rounded
                    : Icons.add_location_alt_outlined,
                color: pos != null ? AppColors.accent : AppColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: pos != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppTextWidget.pequeno(
                          'Localização selecionada',
                          color: AppColors.accent,
                        ),
                        AppTextWidget.corpo(
                          'Lat: ${pos.latitude.toStringAsFixed(6)}',
                          color: AppColors.textPrimary,
                        ),
                        AppTextWidget.corpo(
                          'Lng: ${pos.longitude.toStringAsFixed(6)}',
                          color: AppColors.textPrimary,
                        ),
                      ],
                    )
                  : const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextWidget.corpo(
                          'Selecionar no mapa',
                          color: AppColors.textPrimary,
                        ),
                        AppTextWidget.pequeno(
                          'Toque para abrir o mapa e marcar a posição',
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: pos != null ? AppColors.accent : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
