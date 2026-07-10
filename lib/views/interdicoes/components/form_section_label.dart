import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../shared_widgets/app_text_widget.dart';

class FormSectionLabel extends StatelessWidget {
  final String label;

  const FormSectionLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        AppTextWidget.subtitulo(label, color: AppColors.textSecondary),
      ],
    );
  }
}
