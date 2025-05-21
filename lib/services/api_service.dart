import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:steel_budy/models/product_model.dart';
import 'package:steel_budy/models/role_model.dart';
import 'package:steel_budy/models/category_model.dart';
import 'package:steel_budy/models/brand_model.dart';
import 'package:steel_budy/models/region_model.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static final http.Client _client = http.Client();

  /// Fetches a list of user types (roles) from the API.
  static Future<List<Role>> getUserTypes() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/user-types'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (!responseData.containsKey('userTypes')) {
          throw HttpException('Invalid response format: missing userTypes field');
        }
        final List<dynamic> userTypes = responseData['userTypes'];
        if (userTypes.isEmpty) {
          throw HttpException('No roles found in the response');
        }
        return userTypes
            .map((item) => Role.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException(
          'Failed to load user types: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e is FormatException) {
        throw HttpException('Invalid response format from server');
      } else if (e is SocketException) {
        throw HttpException(
          'Could not connect to the server. Please check if the server is running.',
        );
      }
      throw HttpException('Error fetching user types: $e');
    }
  }

  /// Fetches a list of categories from the API.
  static Future<List<Category>> getCategories() async {
    return _get(
      endpoint: '/categories',
      fromJson: Category.fromJson,
    );
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
  static Future<List<Brand>> getBrands() async {
    return _get(
      endpoint: '/brands',
      fromJson: Brand.fromJson,
    );
  }

  /// Fetches a list of regions from the API.
  static Future<List<Region>> getRegions() async {
    return _get(
      endpoint: '/regions',
      fromJson: Region.fromJson,
    );
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