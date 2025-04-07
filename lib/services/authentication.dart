// auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Keys for SharedPreferences
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _phoneNumberKey = 'phoneNumber';

  // Set logged-in status and phone number (called during login)
  Future<void> setLoggedIn(bool value, {required String phoneNumber}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
    if (value) {
      // Only set phone number if logging in
      await prefs.setString(_phoneNumberKey, phoneNumber);
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get the current user's phone number
  Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneNumberKey);
  }

  // Logout: Clear both logged-in status and phone number
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_phoneNumberKey);
  }
}
