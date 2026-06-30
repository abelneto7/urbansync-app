class User {
  final int id;
  final String nome;
  final String email;
  final String? criadoEm;
  final String? atualizadoEm;

  User({
    required this.id,
    required this.nome,
    required this.email,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      nome: json['nome'] as String,
      email: json['email'] as String,
      criadoEm: json['criado_em'] as String?,
      atualizadoEm: json['atualizado_em'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'criado_em': criadoEm,
      'atualizado_em': atualizadoEm,
    };
  }

  @override
  String toString() => 'User(id: $id, nome: $nome, email: $email)';
}
