import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steel_budy/features/layout/layout.dart';
import 'package:steel_budy/models/application_settings_model.dart';
import 'package:steel_budy/services/api_service.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/screens/dashboardscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ApplicationSettings? _settings;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchApplicationSettingsAndNavigate();
  }

  Future<void> _fetchApplicationSettingsAndNavigate() async {
    try {
      final settings = await ApiService.getApplicationSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error fetching settings: $e';
        _isLoading = false;
      });
    }

    // Ensure the splash screen is displayed for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Navigate based on login state
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!mounted) return;
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Layout(appBarTitle: 'Dashboard', child: const DashboardScreen())),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: _isLoading
                ? const CircularProgressIndicator()
                : _error != null
                    ? const Icon(
                        Icons.image_not_supported,
                        size: 120,
                        color: Colors.grey,
                      )
                    : _settings != null && _settings!.logo.isNotEmpty
                        ? Image.network(
                            _settings!.logo,
                            height: 120,
                            width: 120,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const CircularProgressIndicator();
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.error,
                                size: 120,
                                color: Colors.red,
                              );
                            },
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 120,
                            color: Colors.grey,
                          ),
          ),
        ),
      ),
    );
  }
}