import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:steel_budy/features/authentication/screens/optscreen.dart';
import 'package:steel_budy/features/screens/dashboardscreen.dart';
import 'package:steel_budy/features/screens/edit-profile.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/screens/notifications.dart';
import 'features/screens/profile.dart';
import 'features/screens/create_enquiry_screen.dart'; // Add this import
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
        '/notifications': (context) => const NotificationScreen(),
        '/profile': (context) =>  ProfileScreen(),
        '/create-enquiry': (context) => const CreateEnquiryScreen(), // Add this route
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