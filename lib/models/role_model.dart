class Role {
  final String name;
  final String value;

  Role({
    required this.name,
    required this.value,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      name: json['name'] as String,
      value: json['name'].toString().toLowerCase().replaceAll(' ', '_'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
    };
  }
}