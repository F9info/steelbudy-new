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
  final String? token;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.phoneNumber,
    required this.role,
    this.userId,
    this.companyName,
    this.token,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? phoneNumber,
    String? role,
    String? userId,
    String? companyName,
    String? token,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(role: '', isLoading: true)) {
    _initializeAuthState();
  }

  void update(AuthState Function(AuthState) updateFn) {
    state = updateFn(state);
  }

  Future<void> _initializeAuthState() async {
    try {
      state = state.copyWith(isLoading: true);
      final prefs = await SharedPreferences.getInstance();
      final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      final phoneNumber = prefs.getString('phoneNumber');
      final role = prefs.getString('role') ?? '';
      final userId = prefs.getString('userId');
      final companyName = prefs.getString('companyName');
      final token = prefs.getString('token');
      state = AuthState(
        isAuthenticated: isAuthenticated,
        phoneNumber: phoneNumber,
        role: role,
        userId: userId,
        companyName: companyName,
        token: token,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error initializing auth state: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> login(String phoneNumber, String? role, {String? token}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('phoneNumber', phoneNumber);
      await prefs.setString('role', role ?? '');
      if (token != null) {
        await prefs.setString('token', token);
      }

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
        userType: UserType(
          id: selectedRole.id,
          name: selectedRole.name,
          publish: 1,
        ),
      );

      final createdUser = await ApiService.createAppUser(appUser);

      // Store userId and companyName in SharedPreferences
      if (createdUser.id != null) {
        await prefs.setString('userId', createdUser.id!.toString());
      }
      await prefs.setString('companyName', createdUser.companyName ?? '');

      // Update auth state with user ID and companyName
      state = state.copyWith(
        isAuthenticated: true,
        phoneNumber: phoneNumber,
        role: role ?? '',
        userId: createdUser.id?.toString(),
        companyName: createdUser.companyName ?? '',
        token: token ?? state.token,
        isLoading: false,
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
        token: token ?? state.token,
        isLoading: false,
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
        token: null,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
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

  Future<void> setUserId(String? userId) async {
    state = state.copyWith(userId: userId);
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await prefs.setString('userId', userId);
    } else {
      await prefs.remove('userId');
    }
  }

  Future<void> clearUser() async {
    state = const AuthState(
      isAuthenticated: false,
      phoneNumber: null,
      role: '',
      userId: null,
      companyName: null,
      token: null,
      isLoading: false,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Call this on app start to restore userId from SharedPreferences
dynamic restoreUserId(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  final userIdStr = prefs.getString('userId');
  if (userIdStr != null) {
    ref.read(authProvider.notifier).setUserId(userIdStr);
  }
}