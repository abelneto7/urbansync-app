enum TipoInterdicao {
  obra(1, 'Obra'),
  evento(2, 'Evento'),
  acidente(3, 'Acidente'),
  desconhecido(0, 'Desconhecido');

  final int value;
  final String label;

  const TipoInterdicao(this.value, this.label);

  static TipoInterdicao fromValue(int value) {
    return TipoInterdicao.values.firstWhere(
      (t) => t.value == value,
      orElse: () => TipoInterdicao.desconhecido,
    );
  }

  static List<TipoInterdicao> get selecaoveis => [obra, evento, acidente];
}
