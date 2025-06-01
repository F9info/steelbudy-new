class Product {
  final int id;
  final String name;
  final String description;
  final String image;
  final int categoryId;
  final int brandId;
  final int regionId;
  final double price;
  final bool publish;
  final String brand;
  final String category;
  final String location;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.categoryId,
    required this.brandId,
    required this.regionId,
    required this.price,
    required this.publish,
    required this.brand,
    required this.category,
    required this.location,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
   return Product(
    id: json['id'] as int,
    name: json['product_name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    image: json['product_photo'] as String? ?? '',
    categoryId: json['category_id'] is int ? json['category_id'] as int : 0,
    brandId: json['brand_id'] is int ? json['brand_id'] as int : 0,
    regionId: json['region_id'] is int ? json['region_id'] as int : 0,
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    publish: (json['publish'] as int?) == 1,
    brand: json['brand']?['name']?.toString() ?? '',
    category: json['category']?['name']?.toString() ?? '',
    location: json['region']?['name']?.toString() ?? '',
  );

  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'category_id': categoryId,
      'brand_id': brandId,
      'region_id': regionId,
      'price': price,
      'publish': publish,
      'brand': brand,
      'category': category,
      'location': location,
    };
  }
}