class Profile {
  final int id;
  final String name;
  final String? description;

  Profile({
    required this.id,
    required this.name,
    this.description,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
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
