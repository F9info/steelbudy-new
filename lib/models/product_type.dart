class ProductType {
  final int id;
  final String name;

  ProductType({
    required this.id,
    required this.name,
  });

  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}