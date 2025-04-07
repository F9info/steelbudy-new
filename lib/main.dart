import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/authentication/screens/optscreen.dart';
import 'features/dashboard/screens/dashboardscreen.dart';
import 'services/authentication.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/dashboard/screens/edit-profile.dart';
import 'splash_screen.dart';
import 'features/dashboard/screens/notifications.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SteelBuddy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => const DashboardScreen());
          case '/onboarding':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/otp':
            final phoneNumber = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => OtpScreen(phoneNumber: phoneNumber),
            );
          case '/edit-profile':
            return MaterialPageRoute(builder: (_) => const EditProfile());
          case '/notifications':
            return MaterialPageRoute(builder: (_) => const Notifications());
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
