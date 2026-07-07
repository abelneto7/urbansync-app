class Permission {
  final int id;
  final String name;
  final String module;

  Permission({
    required this.id,
    required this.name,
    required this.module,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] as int,
      name: json['name'] as String,
      module: json['module'] as String,
    );
  }

  @override
  String toString() => 'Permission(id: $id, name: $name, module: $module)';
}
