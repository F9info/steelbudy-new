import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth State class to hold authentication state
class AuthState {
  final bool isAuthenticated;
  final String? phoneNumber;
  final String? role;

  AuthState({
    this.isAuthenticated = false, 
    this.phoneNumber,
    this.role,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? phoneNumber,
    String? role,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
    );
  }
}

// Auth Notifier to manage authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    // Initialize by checking stored auth state
    _initializeAuthState();
  }

  Future<void> _initializeAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    final phoneNumber = prefs.getString('phoneNumber');
    state =
        AuthState(isAuthenticated: isAuthenticated, phoneNumber: phoneNumber);
  }

  Future<void> login(String phoneNumber, String? role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('phoneNumber', phoneNumber);
    await prefs.setString('role', role ?? '');
    state = AuthState(
      isAuthenticated: true, 
      phoneNumber: phoneNumber,
      role: role,
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = AuthState(isAuthenticated: false, phoneNumber: null);
  }
}

// Provider definition
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
