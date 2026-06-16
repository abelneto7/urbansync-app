import 'package:flutter/material.dart';
import '../models/interdicao.dart';
import '../utils/app_colors.dart';
import 'app_text.dart';
import 'botao_remover.dart';

class InterdicaoCard extends StatelessWidget {
  final Interdicao interdicao;
  final VoidCallback onRemover;

  const InterdicaoCard({
    super.key,
    required this.interdicao,
    required this.onRemover,
  });

  Color get _tipoColor {
    switch (interdicao.tipo) {
      case 1:
        return AppColors.tipoObra;
      case 2:
        return AppColors.tipoEvento;
      case 3:
        return AppColors.tipoAcidente;
      default:
        return AppColors.textMuted;
    }
  }

  IconData get _tipoIcon {
    switch (interdicao.tipo) {
      case 1:
        return Icons.construction_rounded;
      case 2:
        return Icons.event_rounded;
      case 3:
        return Icons.car_crash_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _tipoColor.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _tipoColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _tipoIcon,
                color: _tipoColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText.subtitulo(
                          interdicao.titulo,
                          color: AppColors.textPrimary,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _TipoBadge(
                        label: interdicao.tipoLabel,
                        color: _tipoColor,
                      ),
                    ],
                  ),

                  if (interdicao.descricao != null &&
                      interdicao.descricao!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    AppText.corpo(
                      interdicao.descricao!,
                      maxLines: 2,
                    ),
                  ],

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.location_pin,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      AppText.pequeno(
                        '${interdicao.latitude.toStringAsFixed(4)}, '
                        '${interdicao.longitude.toStringAsFixed(4)}',
                      ),
                      const Spacer(),
                      _StatusBadge(ativo: interdicao.status),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            BotaoRemover(onPressed: onRemover),
          ],
        ),
      ),
    );
  }
}

class _TipoBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TipoBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
      ),
      child: AppText.pequeno(label, color: color),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool ativo;

  const _StatusBadge({required this.ativo});

  @override
  Widget build(BuildContext context) {
    final color = ativo ? AppColors.success : AppColors.textMuted;
    final label = ativo ? 'Ativa' : 'Encerrada';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        AppText.pequeno(label, color: color),
      ],
    );
  }
}
