import 'tipo_interdicao.dart';

class Interdicao {
  final int id;
  final String titulo;
  final String? descricao;
  final double latitude;
  final double longitude;
  final int tipo;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final bool isAtiva;
  final int userId;
  final String? criadoEm;
  final String? atualizadoEm;

  const Interdicao({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.latitude,
    required this.longitude,
    required this.tipo,
    required this.dataInicio,
    this.dataFim,
    required this.isAtiva,
    required this.userId,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Interdicao.fromJson(Map<String, dynamic> json) {
    return Interdicao(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      latitude: _parseDouble(json['coordenadas']?['latitude'] ?? json['latitude']),
      longitude: _parseDouble(json['coordenadas']?['longitude'] ?? json['longitude']),
      tipo: json['tipo'] as int? ?? 0,
      dataInicio: DateTime.parse(json['data_inicio'] as String),
      dataFim: json['data_fim'] != null
          ? DateTime.parse(json['data_fim'] as String)
          : null,
      isAtiva: json['is_ativa'] as bool? ?? false,
      userId: json['user_id'] as int? ?? 0,
      criadoEm: json['criado_em'] as String?,
      atualizadoEm: json['atualizado_em'] as String?,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static String formatDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi:$s';
  }

  TipoInterdicao get tipoEnum => TipoInterdicao.fromValue(tipo);

  String get tipoLabel => tipoEnum.label;

  String get statusLabel => isAtiva ? 'Ativa' : 'Encerrada';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'latitude': latitude,
      'longitude': longitude,
      'tipo': tipo,
      'data_inicio': formatDateTime(dataInicio),
      'data_fim': dataFim != null ? formatDateTime(dataFim!) : null,
      'user_id': userId,
      'criado_em': criadoEm,
      'atualizado_em': atualizadoEm,
    };
  }

  @override
  String toString() => 'Interdicao(id: $id, titulo: $titulo, tipo: $tipoLabel)';
}
