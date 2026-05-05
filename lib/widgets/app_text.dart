import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AppText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const AppText(
    this.text, {
    super.key,
    this.fontSize = 14.0,
    this.color = AppColors.textPrimary,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  });

  const AppText.titulo(
    this.text, {
    super.key,
    this.color = AppColors.textPrimary,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  })  : fontSize = 22.0,
        fontWeight = FontWeight.bold;

  const AppText.subtitulo(
    this.text, {
    super.key,
    this.color = AppColors.textSecondary,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  })  : fontSize = 16.0,
        fontWeight = FontWeight.w600;

  const AppText.corpo(
    this.text, {
    super.key,
    this.color = AppColors.textSecondary,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  })  : fontSize = 14.0,
        fontWeight = FontWeight.normal;

  const AppText.pequeno(
    this.text, {
    super.key,
    this.color = AppColors.textMuted,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
  })  : fontSize = 12.0,
        fontWeight = FontWeight.normal;

  const AppText.destaque(
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
