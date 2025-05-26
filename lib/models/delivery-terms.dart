class DeliveryTerm {
  final int id;
  final String name;
  final int publish;
  final int? sort;

  DeliveryTerm({
    required this.id,
    required this.name,
    required this.publish,
    this.sort,
  });

  factory DeliveryTerm.fromJson(Map<String, dynamic> json) {
    return DeliveryTerm(
      id: json['id'] as int,
      name: json['name'] as String,
      publish: json['publish'] as int,
      sort: json['sort'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'publish': publish,
      'sort': sort,
    };
  }
}