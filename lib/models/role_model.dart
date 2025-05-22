class Role {
  final int id;
  final String name;
  final int? publish;
  final int? sort;

  Role({
    required this.id,
    required this.name,
    this.publish,
    this.sort,
  });

  // Compute the 'value' field dynamically from 'name'
  String get value => name.toLowerCase().replaceAll(' ', '_').replaceAll('/', '_');

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int,
      name: json['name'] as String,
      publish: json['publish'] as int?,
      sort: json['sort'] as int?,
    );
  }

  factory Role.fromValues({
    required int id,
    required String name,
    required String value, // Ignored since 'value' is a getter
  }) {
    return Role(id: id, name: name);
  }
}