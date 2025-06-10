import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/app_user_model.dart';
import '../models/role_model.dart';

class AuthState {
  final bool isAuthenticated;
  final String? phoneNumber;
  final String role;
  final String? userId;
  final String? companyName;

  const AuthState({
    this.isAuthenticated = false,
    this.phoneNumber,
    required this.role,
    this.userId,
    this.companyName,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? phoneNumber,
    String? role,
    String? userId,
    String? companyName,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(role: '')) {
    _initializeAuthState();
  }

  void update(AuthState Function(AuthState) updateFn) {
    state = updateFn(state);
  }

  Future<void> _initializeAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      final phoneNumber = prefs.getString('phoneNumber');
      final role = prefs.getString('role') ?? '';
      final userId = prefs.getString('userId');
      final companyName = prefs.getString('companyName');
      state = AuthState(
        isAuthenticated: isAuthenticated,
        phoneNumber: phoneNumber,
        role: role,
        userId: userId,
        companyName: companyName,
      );
    } catch (e) {
      debugPrint('Error initializing auth state: $e');
    }
  }

  Future<void> login(String phoneNumber, String? role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('phoneNumber', phoneNumber);
      await prefs.setString('role', role ?? '');

      // Get the user type ID from the API
      final roles = await ApiService.getUserTypes();
      final selectedRole = roles.firstWhere(
        (r) => r.value == role,
        orElse: () => Role(id: 0, name: ''),
      );

      if (selectedRole.id == 0) {
        throw Exception('Selected role not found');
      }

      // Create new user in API
      final appUser = AppUser(
        userTypeId: selectedRole.id,
        companyName: '',
        contactPerson: '',
        mobile: phoneNumber,
        email: '',
        streetLine: '',
        townCity: '',
        state: '',
        country: '',
        pincode: '',
        regionId: null,
        userType: UserType(
          id: selectedRole.id,
          name: selectedRole.name,
          publish: 1,
        ),
      );

      final createdUser = await ApiService.createAppUser(appUser);

      // Store userId and companyName in SharedPreferences
      await prefs.setString('userId', createdUser.id.toString());
      await prefs.setString('companyName', createdUser.companyName ?? '');

      // Update auth state with user ID and companyName
      state = state.copyWith(
        isAuthenticated: true,
        phoneNumber: phoneNumber,
        role: role ?? '',
        userId: createdUser.id.toString(),
        companyName: createdUser.companyName ?? '',
      );
    } catch (e) {
      debugPrint('Error creating user: $e');
      // Fallback state to preserve login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('phoneNumber', phoneNumber);
      await prefs.setString('role', role ?? '');
      state = state.copyWith(
        isAuthenticated: true,
        phoneNumber: phoneNumber,
        role: role ?? '',
        userId: null,
        companyName: null,
      );
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      state = const AuthState(
        isAuthenticated: false,
        phoneNumber: null,
        role: '',
        userId: null,
        companyName: null,
      );
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userId');
    if (token != null && token.isNotEmpty) {
      return token;
    }
    throw Exception('No token found');
  }

  Future<void> setUserDetails({required String userId, required String companyName}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('companyName', companyName);
    state = state.copyWith(userId: userId, companyName: companyName);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});