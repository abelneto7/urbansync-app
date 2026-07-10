import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../shared_widgets/app_text_widget.dart';

class DateTimeTile extends StatelessWidget {
  final String id;
  final String label;
  final IconData icon;
  final DateTime? value;
  final String? hint;
  final bool hasError;
  final String? errorText;
  final Widget? trailing;
  final VoidCallback onTap;

  const DateTimeTile({
    super.key,
    required this.id,
    required this.label,
    required this.icon,
    required this.onTap,
    this.value,
    this.hint,
    this.hasError = false,
    this.errorText,
    this.trailing,
  });

  String _formatDisplay(DateTime dt) {
    final date =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$date  $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null;

    final Color activeColor = hasError ? AppColors.error : AppColors.accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          key: Key(id),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: hasError
                  ? AppColors.error.withValues(alpha: 0.07)
                  : hasValue
                      ? AppColors.accent.withValues(alpha: 0.07)
                      : AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasError
                    ? AppColors.error
                    : hasValue
                        ? AppColors.accent
                        : AppColors.divider,
                width: (hasError || hasValue) ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasError ? Icons.error_outline_rounded : icon,
                  size: 20,
                  color: hasValue || hasError ? activeColor : AppColors.textMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextWidget.pequeno(
                        label,
                        color: hasValue || hasError
                            ? activeColor
                            : AppColors.textMuted,
                      ),
                      const SizedBox(height: 2),
                      AppTextWidget.corpo(
                        hasValue ? _formatDisplay(value!) : (hint ?? '—'),
                        color: hasError
                            ? AppColors.error
                            : hasValue
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color:
                        hasValue || hasError ? activeColor : AppColors.textMuted,
                  ),
              ],
            ),
          ),
        ),
        if (hasError && errorText != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: AppTextWidget.pequeno(
              errorText!,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
