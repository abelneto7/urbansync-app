class Interdicao {
  final int id;
  final String titulo;
  final String? descricao;
  final double latitude;
  final double longitude;
  final int tipo;
  final bool status;
  final int userId;
  final String? criadoEm;
  final String? atualizadoEm;

  Interdicao({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.latitude,
    required this.longitude,
    required this.tipo,
    required this.status,
    required this.userId,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory Interdicao.fromJson(Map<String, dynamic> json) {
    return Interdicao(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      tipo: json['tipo'] as int,
      status: json['status'] == true || json['status'] == 1,
      userId: json['user_id'] as int,
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

  String get tipoLabel {
    switch (tipo) {
      case 1:
        return 'Obra';
      case 2:
        return 'Evento';
      case 3:
        return 'Acidente';
      default:
        return 'Desconhecido';
    }
  }

  String get statusLabel => status ? 'Ativa' : 'Encerrada';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'latitude': latitude,
      'longitude': longitude,
      'tipo': tipo,
      'status': status,
      'user_id': userId,
      'criado_em': criadoEm,
      'atualizado_em': atualizadoEm,
    };
  }

  @override
  String toString() => 'Interdicao(id: $id, titulo: $titulo, tipo: $tipoLabel)';
}
