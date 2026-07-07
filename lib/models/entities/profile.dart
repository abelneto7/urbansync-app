class Profile {
  final int id;
  final String name;
  final String? description;
  final List<int> permissionIds;

  Profile({
    required this.id,
    required this.name,
    this.description,
    this.permissionIds = const [],
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    final rawPerms = json['permissions'] as List<dynamic>? ?? [];
    return Profile(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      permissionIds: rawPerms
          .map((p) => (p is Map ? p['id'] : p) as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }

  @override
  String toString() => 'Profile(id: $id, name: $name)';
}
