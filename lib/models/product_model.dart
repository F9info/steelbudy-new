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
      name: json['product_name'] as String,
      description: json['description'] as String,
      image: json['product_photo'] as String,
      categoryId: json['category_id'] as int,
      brandId: json['brand_id'] as int,
      regionId: json['region_id'] as int,
      price: (json['price'] as num).toDouble(),
      publish: (json['publish'] as int) == 1,
      brand: json['brand']['name'] as String,
      category: json['category']['name'] as String,
      location: json['region']['name'] as String,
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