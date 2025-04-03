import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to next screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White theme
      body: Center(
        child: SvgPicture.asset(
          'assets/images/logo.svg',
          height: 120, // Adjust size as needed
          width: 120, // Adjust size as needed
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
