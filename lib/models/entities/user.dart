import 'profile.dart';

class User {
  final int id;
  final String nome;
  final String email;
  final String? criadoEm;
  final String? atualizadoEm;
  final List<Profile>? perfis;
  final List<String> permissoes;

  User({
    required this.id,
    required this.nome,
    required this.email,
    this.criadoEm,
    this.atualizadoEm,
    this.perfis,
    this.permissoes = const [],
  });

  List<int> get profileIds => perfis?.map((p) => p.id).toList() ?? [];

  factory User.fromJson(Map<String, dynamic> json) {
    List<Profile>? perfisParsed;
    final perfisRaw = json['perfis'] ?? json['profiles'];
    
    if (perfisRaw != null && perfisRaw is List) {
      perfisParsed = perfisRaw
          .map((p) => Profile.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    final rawPermissoes = json['permissoes'] as List<dynamic>? ?? [];

    return User(
      id: json['id'] as int? ?? 0,
      nome: json['name'] as String? ?? json['nome'] as String? ?? '',
      email: json['email'] as String,
      criadoEm: json['criado_em'] as String?,
      atualizadoEm: json['atualizado_em'] as String?,
      perfis: perfisParsed,
      permissoes: rawPermissoes.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson({String? password}) {
    final data = <String, dynamic>{
      'name': nome,
      'email': email,
      'profile_ids': profileIds,
    };
    if (password != null && password.trim().isNotEmpty) {
      data['password'] = password.trim();
    }
    return data;
  }

  @override
  String toString() => 'User(id: $id, nome: $nome, email: $email)';
}
