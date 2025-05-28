import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:steel_budy/features/screens/support-help.dart';
import 'splash_screen.dart';
import 'features/authentication/screens/optscreen.dart';
import 'features/screens/dashboardscreen.dart';
import 'features/screens/edit-profile.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/screens/notifications.dart';
import 'features/screens/profile.dart';
import 'features/screens/create_enquiry_screen.dart';
import 'features/screens/view_profile.dart';
import 'features/screens/view_enquiries.dart'; // Add this import for ViewEnquiries
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        '/profile': (context) => ProfileScreen(),
        '/create-enquiry': (context) => const CreateEnquiryScreen(),
        '/dealer_profile': (context) => const ViewProfile(),
        '/support': (context) => const SupportHelp(),
        '/view-enquiries': (context) => const ViewEnquiries(), // Add this route
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/otp') {
          final args = settings.arguments as Map<String, dynamic>?;
          final phoneNumber = args?['phoneNumber'] as String? ?? '';
          final verificationId = args?['verificationId'] as String? ?? '';
          final resendToken = args?['resendToken'] as int?;
          return MaterialPageRoute(
            builder: (_) => OtpScreen(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        }
        return null;
      },
    );
  }
}