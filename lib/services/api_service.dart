import 'dart:convert';
import 'package:http/http.dart' as http;

// Product model to map API response
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

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static final http.Client _client = http.Client();

  /// Fetches a list of categories from the API.
  static Future<List<dynamic>> getCategories() async {
    return _get(endpoint: '/categories');
  }

  /// Fetches a list of products from the API.
  static Future<List<Product>> getProducts() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/products'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['products'] is List) {
          return (decoded['products'] as List)
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw HttpException('Expected a "products" list in response');
        }
      } else {
        throw HttpException(
          'Failed to load products: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw HttpException('Error fetching products: $e');
    }
  }

  /// Fetches a list of brands from the API.
  static Future<List<dynamic>> getBrands() async {
    return _get(endpoint: '/brands');
  }

  /// Fetches a list of regions from the API.
  static Future<List<dynamic>> getRegions() async {
    return _get(endpoint: '/regions');
  }

  /// Generic method to handle GET requests.
  static Future<List<T>> _get<T>({
    required String endpoint,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl$endpoint'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          if (fromJson != null) {
            return decoded
                .map((item) => fromJson(item as Map<String, dynamic>))
                .toList() as List<T>;
          }
          return decoded as List<T>;
        } else {
          throw HttpException('Expected a list response from $endpoint');
        }
      } else {
        throw HttpException(
          'Failed to load data from $endpoint: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw HttpException('Error fetching $endpoint: $e');
    }
  }

  /// Closes the HTTP client when no longer needed.
  static void dispose() {
    _client.close();
  }
}

class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() => 'HttpException: $message';
}