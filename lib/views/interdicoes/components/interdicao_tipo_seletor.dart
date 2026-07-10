import 'package:flutter/material.dart';
import '../../../models/entities/tipo_interdicao.dart';
import '../../../shared/theme/app_colors.dart';
import '../../shared_widgets/app_text_widget.dart';
import 'tipo_interdicao_widget.dart';

class InterdicaoTipoSeletor extends StatelessWidget {
  final int tipoSelecionado;
  final void Function(int tipo) onChanged;

  const InterdicaoTipoSeletor({
    super.key,
    required this.tipoSelecionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TipoInterdicao.selecaoveis.map((tipo) {
        final bool isSelected = tipoSelecionado == tipo.value;
        final Color color = tipo.color;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(tipo.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.18)
                    : AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : AppColors.divider,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    tipo.icon,
                    color: isSelected ? color : AppColors.textMuted,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  AppTextWidget.pequeno(
                    tipo.label,
                    color: isSelected ? color : AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
