// ignore_for_file: unnecessary_type_check

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:steel_budy/models/payment_term.dart';
import 'package:steel_budy/models/application_settings_model.dart';
import 'package:steel_budy/models/delivery-terms.dart';
import 'dart:io';
import 'package:steel_budy/models/product_model.dart';
import 'package:steel_budy/models/role_model.dart';
import 'package:steel_budy/models/category_model.dart';
import 'package:steel_budy/models/brand_model.dart';
import 'package:steel_budy/models/region_model.dart';
import 'package:steel_budy/models/app_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';


class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  // static const String baseUrl = 'https://steelbuddyapi.cloudecommerce.in/api';
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await _makeRequest(
        url: '$baseUrl/user-types',
        method: 'GET',
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
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
          throw HttpException('Invalid response format: expected a list or userTypes field\nResponse: \\${response.body}');
        }

        if (userTypes.isEmpty) {
          throw HttpException('No roles found in the response');
        }

        return userTypes
            .map((item) => Role.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException(
          'Failed to load user types: \\${response.statusCode} \\${response.reasonPhrase}\nResponse: \\${response.body}',
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return _get(
      endpoint: '/categories',
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      fromJson: Category.fromJson,
    );
  }

  static Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await _client.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
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
  }

  static Future<List<Brand>> getBrands() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await _client.get(
      Uri.parse('$baseUrl/brands'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<dynamic> brandsList;
      if (decoded is List) {
        brandsList = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['brands'] is List) {
        brandsList = decoded['brands'];
      } else {
        throw HttpException('Unexpected brands response: \\${response.body}');
      }
      return brandsList.map((item) => Brand.fromJson(item)).toList();
    } else {
      throw HttpException(
        'Failed to load brands: \\${response.statusCode} \\${response.reasonPhrase}',
      );
    }
  }

  static Future<List<Region>> getRegions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await _client.get(
      Uri.parse('$baseUrl/regions'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<dynamic> regionList;
      if (decoded is List) {
        regionList = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['regions'] is List) {
        regionList = decoded['regions'];
      } else {
        throw HttpException('Unexpected regions response: $decoded');
      }
      return regionList.map((item) => Region.fromJson(item)).toList();
    } else {
      throw HttpException(
        'Failed to load regions: \\${response.statusCode} \\${response.reasonPhrase}',
      );
    }
  }

  static Future<List<PaymentTerm>> getPaymentTerms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await _client.get(
      Uri.parse('$baseUrl/payment-terms'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    if (response.body.trim().startsWith('<')) {
      throw Exception('Received HTML instead of JSON: \\${response.body}');
    }
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<dynamic> paymentTermsList;
      if (decoded is List) {
        paymentTermsList = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['paymentTerms'] is List) {
        paymentTermsList = decoded['paymentTerms'];
      } else {
        throw HttpException('Unexpected payment terms response: \\${response.body}');
      }
      return paymentTermsList.map((item) => PaymentTerm.fromJson(item)).toList();
    } else {
      throw HttpException(
        'Failed to load payment terms: \\${response.statusCode} \\${response.reasonPhrase}',
      );
    }
  }

  Future<void> postQuotation(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/dealer-quotations'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['message'] == 'Quotation created successfully') {
          return;
        } else {
          throw Exception('Unexpected response: ${response.body}');
        }
      } else {
        throw Exception('Failed to post quotation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error posting quotation: $e');
    }
  }

  static Future<List<DeliveryTerm>> getDeliveryTerms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await _client.get(
      Uri.parse('$baseUrl/delivery-terms'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    if (response.body.trim().startsWith('<')) {
      throw Exception('Received HTML instead of JSON: \\${response.body}');
    }
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      List<dynamic> deliveryTermsList;
      if (decoded is List) {
        deliveryTermsList = decoded;
      } else if (decoded is Map<String, dynamic> && decoded['deliveryTerms'] is List) {
        deliveryTermsList = decoded['deliveryTerms'];
      } else {
        throw HttpException('Unexpected delivery terms response: \\${response.body}');
      }
      return deliveryTermsList.map((item) => DeliveryTerm.fromJson(item)).toList();
    } else {
      throw HttpException(
        'Failed to load delivery terms: \\${response.statusCode} \\${response.reasonPhrase}',
      );
    }
  }

  static Future<AppUser> createAppUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await _makeRequest(
        url: '$baseUrl/app-users',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await _makeRequest(
      url: '$baseUrl/app-users/$id',
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
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
  }

  static Future<AppUser> getAppUser(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await _client.get(
      Uri.parse('$baseUrl/app-users/$id'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return AppUser.fromJson(json.decode(response.body)['appUser']);
    } else {
      throw HttpException(
        'Failed to get user: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
  }



static Future<ApplicationSettings> getApplicationSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final response = await _client
      .get(
        Uri.parse('$baseUrl/application-settings'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      )
      .timeout(const Duration(seconds: 10));
  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
      return ApplicationSettings.fromJson(jsonResponse['data']);
    } else {
      throw HttpException('Failed to load application settings: \\${jsonResponse['message']}');
    }
  } else {
    throw HttpException('Failed to load application settings: \\${response.statusCode}');
  }
}


static Future<void> submitEnquiry(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('$baseUrl/customer-orders'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );
    if (response.statusCode == 201) {
      // Success
      return;
    } else {
      throw Exception('Failed to submit enquiry: \\${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchCustomerOrderDetails(int orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$baseUrl/customer-orders/$orderId'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load customer order details');
    }
  }

  Future<List<dynamic>> fetchCustomerOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$baseUrl/customer-orders'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['customerOrders'] != null) {
        return data['customerOrders'] as List<dynamic>;
      } else {
        throw Exception('No customer orders found in response');
      }
    } else {
      throw Exception('Failed to load customer orders: ${response.statusCode}');
    }
  }

  static Future<List<T>> _get<T>({
    required String endpoint,
    T Function(Map<String, dynamic>)? fromJson,
    required Map<String, String> headers,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
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
            throw HttpException('Expected a list in response for $endpoint\nResponse: \\${response.body}');
          }
        } else {
          throw HttpException('Expected a list response from $endpoint\nResponse: \\${response.body}');
        }

        if (fromJson != null) {
          return data
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList() as List<T>;
        }
        return data as List<T>;
      } else {
        throw HttpException(
          'Failed to load data from $endpoint: \\${response.statusCode} \\${response.reasonPhrase}\nResponse: \\${response.body}',
        );
      }
    } catch (e) {
      throw HttpException('Error fetching $endpoint: $e');
    }
  }

  static void dispose() {
    _client.close();
  }

  // Check or register user
  static Future<Map<String, dynamic>> checkOrRegisterAppUser(String mobile) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/app-users/check-or-register'),
      headers: {'Accept': 'application/json'},
      body: {'mobile': mobile},
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['error'] ?? 'Server error');
    }
  }

  // Update user role
  static Future<bool> updateUserRole(String userId, int userTypeId, String token) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/app-users/$userId/update-role'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: {'user_type_id': userTypeId.toString()},
    );
    return response.statusCode == 200;
  }

  // Get user profile by mobile
  static Future<Map<String, dynamic>?> getUserByMobile(String mobile, String token) async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token') ?? token;
    final response = await _client.get(
      Uri.parse('$baseUrl/app-user-by-mobile?mobile=$mobile'),
      headers: {
        'Authorization': 'Bearer $storedToken',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user'];
    }
    return null;
  }

  // Update user profile
  static Future<bool> updateUserProfile(String userId, Map<String, dynamic> data, String token, {XFile? profileImage}) async {
    var uri = Uri.parse('$baseUrl/app-users/$userId');
    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields.addAll(data.map((k, v) => MapEntry(k, v.toString())));
    request.fields['_method'] = 'PUT'; // Laravel expects this for multipart updates
    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath('profile_pic', profileImage.path));
    }
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response.statusCode == 200;
  }

  static Future<List<dynamic>> getCustomerOrdersForCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');
    if (userId == null) {
      throw Exception('User ID not found in shared preferences');
    }
    final response = await _client.get(
      Uri.parse('$baseUrl/enquiries?user_id=$userId'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) {
        return data as List<dynamic>;
      } else {
        throw Exception('No customer orders found in response');
      }
    } else {
      throw Exception('Failed to load customer orders: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getAllCustomerOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await _client.get(
      Uri.parse('$baseUrl/enquiries'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null) {
        return data as List<dynamic>;
      } else {
        throw Exception('No customer orders found in response');
      }
    } else {
      throw Exception('Failed to load customer orders: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getProductTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await _client.get(
      Uri.parse('$baseUrl/product-types'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data;
      } else if (data is Map && data['productTypes'] is List) {
        return data['productTypes'];
      } else {
        throw Exception('Invalid product types response');
      }
    } else {
      throw Exception('Failed to load product types: \\${response.statusCode}');
    }
  }

  static Future<void> cancelEnquiry(int enquiryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('$baseUrl/enquiries/$enquiryId/cancel'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to cancel enquiry');
    }
  }

  static Future<void> finalizeQuotation(int orderId, int quotationId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    // Update enquiry status
    final enquiryResponse = await http.post(
      Uri.parse('$baseUrl/enquiries/$orderId/finalize'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (enquiryResponse.statusCode != 200) {
      throw Exception('Failed to finalize enquiry');
    }
    // Update quotation status
    final quotationResponse = await http.post(
      Uri.parse('$baseUrl/dealer-quotations/$quotationId/finalize'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (quotationResponse.statusCode != 200) {
      throw Exception('Failed to finalize quotation');
    }
  }

  static Future<void> deleteProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    final response = await http.delete(
      Uri.parse('$baseUrl/user/delete?id=$userId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete profile');
    }
  }
}


class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() => 'HttpException: $message';
}