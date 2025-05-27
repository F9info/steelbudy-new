// ignore_for_file: unnecessary_type_check

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:steel_budy/models/Payment_term.dart';
import 'package:steel_budy/models/application_settings_model.dart';
import 'package:steel_budy/models/delivery-terms.dart';
import 'dart:io';
import 'package:steel_budy/models/product_model.dart';
import 'package:steel_budy/models/role_model.dart';
import 'package:steel_budy/models/category_model.dart';
import 'package:steel_budy/models/brand_model.dart';
import 'package:steel_budy/models/region_model.dart';
import 'package:steel_budy/models/app_user_model.dart';


class ApiService {
  static const String baseUrl = 'https://steelbuddyapi.cloudecommerce.in/api';
  static final http.Client _client = http.Client();

  static Future<http.Response> _makeRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      final response = await _client.send(
        http.Request(method, Uri.parse(url))
          ..headers.addAll(headers ?? {})
          ..bodyBytes = body != null ? utf8.encode(json.encode(body)) : [],
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 302) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          return _makeRequest(
            url: redirectUrl,
            method: method,
            headers: headers,
            body: body,
          );
        }
      }

      return http.Response.fromStream(response);
    } catch (e) {
      if (e is SocketException) {
        throw HttpException('Could not connect to the server. Please check if the server is running.');
      }
      throw HttpException('Error making request: $e');
    }
  }

  static Future<List<Role>> getUserTypes() async {
    try {
      final response = await _makeRequest(
        url: '$baseUrl/user-types',
        method: 'GET',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        List<dynamic> userTypes;

        // Handle both direct list and nested userTypes field
        if (decoded is List) {
          userTypes = decoded;
        } else if (decoded is Map<String, dynamic> && decoded.containsKey('userTypes')) {
          userTypes = decoded['userTypes'];
        } else {
          throw HttpException('Invalid response format: expected a list or userTypes field\nResponse: ${response.body}');
        }

        if (userTypes.isEmpty) {
          throw HttpException('No roles found in the response');
        }

        return userTypes
            .map((item) => Role.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException(
          'Failed to load user types: ${response.statusCode} ${response.reasonPhrase}\nResponse: ${response.body}',
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

  static Future<List<Category>> getCategories() async {
    return _get(
      endpoint: '/categories',
      fromJson: Category.fromJson,
    );
  }

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

  static Future<List<Brand>> getBrands() async {
    return _get(
      endpoint: '/brands',
      fromJson: Brand.fromJson,
    );
  }

  static Future<List<Region>> getRegions() async {
    return _get(
      endpoint: '/regions',
      fromJson: Region.fromJson,
    );
  }

  static Future<List<PaymentTerm>> getPaymentTerms() async {
    return _get(
      endpoint: '/payment-terms',
      fromJson: PaymentTerm.fromJson,
    );
  }

  static Future<List<DeliveryTerm>> getDeliveryTerms() async {
    return _get(
      endpoint: '/delivery-terms',
      fromJson: DeliveryTerm.fromJson,
    );
  }

  static Future<AppUser> createAppUser(AppUser user) async {
    try {
      final response = await _makeRequest(
        url: '$baseUrl/app-users',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: user.toJson(),
      );

      if (response.statusCode == 201) {
        return AppUser.fromJson(json.decode(response.body));
      } else {
        throw HttpException(
          'Failed to create user: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw HttpException('Error creating user: $e');
    }
  }

  static Future<AppUser> updateAppUser(int id, AppUser user) async {
    try {
      final response = await _makeRequest(
        url: '$baseUrl/app-users/$id',
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: user.toJson(),
      );

      if (response.statusCode == 200) {
        return AppUser.fromJson(json.decode(response.body));
      } else {
        throw HttpException(
          'Failed to update user: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw HttpException('Error updating user: $e');
    }
  }

  static Future<AppUser> getAppUser(int id) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/app-users/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return AppUser.fromJson(json.decode(response.body)['appUser']);
      } else {
        throw HttpException(
          'Failed to get user: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw HttpException('Error getting user: $e');
    }
  }



static Future<ApplicationSettings> getApplicationSettings() async {
  final response = await _client
      .get(Uri.parse('$baseUrl/application-settings')) // Updated endpoint
      .timeout(const Duration(seconds: 10));

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
      return ApplicationSettings.fromJson(jsonResponse['data']);
    } else {
      throw HttpException('Failed to load application settings: ${jsonResponse['message']}');
    }
  } else {
    throw HttpException('Failed to load application settings: ${response.statusCode}');
  }
}


static Future<void> submitEnquiry(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/customer-orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      // Success
      return;
    } else {
      throw Exception('Failed to submit enquiry: ${response.statusCode}');
    }
  }







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
        List<dynamic> data;

        // Handle both direct list and nested structure (e.g., {"paymentTerms": [...]})
        if (decoded is List) {
          data = decoded;
        } else if (decoded is Map<String, dynamic>) {
          // Try common keys: camelCase version of endpoint, "data", or the endpoint name
          final key = endpoint.replaceFirst('/', '');
          final camelCaseKey = key.split('-').asMap().entries.map((entry) {
            if (entry.key == 0) return entry.value.toLowerCase();
            return entry.value[0].toUpperCase() + entry.value.substring(1).toLowerCase();
          }).join();
          data = decoded[camelCaseKey] ?? decoded[key] ?? decoded['data'] ?? [];
          if (data is! List) {
            throw HttpException('Expected a list in response for $endpoint\nResponse: ${response.body}');
          }
        } else {
          throw HttpException('Expected a list response from $endpoint\nResponse: ${response.body}');
        }

        if (fromJson != null) {
          return data
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList() as List<T>;
        }
        return data as List<T>;
      } else {
        throw HttpException(
          'Failed to load data from $endpoint: ${response.statusCode} ${response.reasonPhrase}\nResponse: ${response.body}',
        );
      }
    } catch (e) {
      throw HttpException('Error fetching $endpoint: $e');
    }
  }

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