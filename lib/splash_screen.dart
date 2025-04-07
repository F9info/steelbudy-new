import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/dashboard/screens/dashboardscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingAndLoginStatus();
  }

  Future<void> _checkOnboardingAndLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding =
        prefs.getBool('onboarding_complete') ?? false;
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    await Future.delayed(const Duration(seconds: 2));

    if (!hasCompletedOnboarding) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
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
            child: SvgPicture.asset(
              'assets/images/logo.svg',
              height: 120,
              width: 120,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
