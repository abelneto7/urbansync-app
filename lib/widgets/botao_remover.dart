import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class BotaoRemover extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;
  final Color color;
  final String tooltip;

  const BotaoRemover({
    super.key,
    required this.onPressed,
    this.size = 20.0,
    this.color = AppColors.error,
    this.tooltip = 'Remover interdição',
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            size: size,
            color: color,
          ),
        ),
      ),
    );
  }
}
