import 'package:flutter/material.dart';
import '../../models/entities/tipo_interdicao.dart';
import '../../shared/theme/app_colors.dart';

extension TipoInterdicaoUi on TipoInterdicao {
  IconData get icon {
    switch (this) {
      case TipoInterdicao.obra:
        return Icons.construction_rounded;
      case TipoInterdicao.evento:
        return Icons.event_rounded;
      case TipoInterdicao.acidente:
        return Icons.car_crash_rounded;
      case TipoInterdicao.desconhecido:
        return Icons.location_on_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TipoInterdicao.obra:
        return AppColors.tipoObra;
      case TipoInterdicao.evento:
        return AppColors.tipoEvento;
      case TipoInterdicao.acidente:
        return AppColors.tipoAcidente;
      case TipoInterdicao.desconhecido:
        return AppColors.textMuted;
    }
  }
}
