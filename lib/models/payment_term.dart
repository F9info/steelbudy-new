class PaymentTerm {
  final int id;
  final String name;
  final int publish; // Add publish field
  final int? sort;   // Add sort field (nullable since it can be null)

  PaymentTerm({
    required this.id,
    required this.name,
    required this.publish,
    this.sort,
  });

  factory PaymentTerm.fromJson(Map<String, dynamic> json) {
    return PaymentTerm(
      id: json['id'] as int,
      name: json['name'] as String,
      publish: json['publish'] as int,
      sort: json['sort'] as int?, // Nullable field
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