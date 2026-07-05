import 'package:flutter/material.dart';
import '../../shared/utils/app_colors.dart';

class AppTextWidget extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const AppTextWidget(
    this.text, {
    super.key,
    this.fontSize = 14.0,
    this.color = AppColors.textPrimary,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  const AppTextWidget.titulo(
    this.text, {
    super.key,
    this.color = AppColors.textPrimary,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  })  : fontSize = 22.0,
        fontWeight = FontWeight.bold;

  const AppTextWidget.subtitulo(
    this.text, {
    super.key,
    this.color = AppColors.textSecondary,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  })  : fontSize = 16.0,
        fontWeight = FontWeight.w600;

  const AppTextWidget.corpo(
    this.text, {
    super.key,
    this.color = AppColors.textSecondary,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  })  : fontSize = 14.0,
        fontWeight = FontWeight.normal;

  const AppTextWidget.pequeno(
    this.text, {
    super.key,
    this.color = AppColors.textMuted,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  })  : fontSize = 12.0,
        fontWeight = FontWeight.normal;

  const AppTextWidget.destaque(
    this.text, {
    super.key,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  })  : fontSize = 14.0,
        color = AppColors.accent,
        fontWeight = FontWeight.w600;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        letterSpacing: fontWeight == FontWeight.bold ? 0.3 : 0.1,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
