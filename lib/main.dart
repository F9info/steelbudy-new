import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/authentication/screens/optscreen.dart';
import 'features/dashboard/screens/dashboardscreen.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/dashboard/screens/edit-profile.dart';
import 'features/dashboard/screens/notifications.dart';
import 'splash_screen.dart';

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
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/edit-profile': (context) => const EditProfile(),
        '/notifications': (context) => const Notifications(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          final phoneNumber = settings.arguments as String? ?? '';
          return MaterialPageRoute(
            builder: (_) => OtpScreen(phoneNumber: phoneNumber),
          );
        }
        return null;
      },
    );
  }
}
