import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:steel_budy/features/layout/layout.dart';
import 'package:steel_budy/features/screens/enquiry.dart';
import 'package:steel_budy/features/screens/role_selection_screen.dart';
import 'package:steel_budy/features/screens/support-help.dart';
import 'splash_screen.dart';
import 'features/authentication/screens/otp_screen.dart';
import 'features/screens/dashboardscreen.dart';
import 'features/screens/edit-profile.dart';
import 'features/authentication/screens/login_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/screens/notifications.dart';
import 'features/screens/profile.dart';
import 'features/screens/create_enquiry_screen.dart';
import 'features/screens/view_profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steel_budy/providers/auth_provider.dart';
import 'features/screens/dealer_enquiry_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:steel_budy/services/api_service.dart';
import 'package:steel_budy/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class RootDecider extends ConsumerStatefulWidget {
  const RootDecider({Key? key}) : super(key: key);

  @override
  ConsumerState<RootDecider> createState() => _RootDeciderState();
}

class _RootDeciderState extends ConsumerState<RootDecider> {
  @override
  void initState() {
    super.initState();
    _decideAndNavigate();
  }

  Future<void> _decideAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final authState = ref.read(authProvider);
    final isAuthenticated = authState.isAuthenticated;
    final userId = authState.userId;

    if (!isAuthenticated || userId == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SplashScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Layout(appBarTitle: 'Dashboard', child: const DashboardScreen()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // FCM SETUP: Register token and notification handlers after login
    if (authState.isAuthenticated && authState.userId != null) {
      FCMService.setupFCM(userId: authState.userId!, context: context);
    }

    if (authState.isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'SteelBuddy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RootDecider(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => Layout(appBarTitle: 'Dashboard', child: const DashboardScreen()),
        '/edit-profile': (context) => const EditProfile(),
        '/notifications': (context) => const NotificationScreen(),
        '/profile': (context) => ProfileScreen(),
        '/create-enquiry': (context) => const CreateEnquiryScreen(),
        '/dealer_profile': (context) => const ViewProfile(),
        '/support': (context) => const SupportHelp(),
        '/select-role': (context) => const RoleSelectionScreen(),
        '/enquiries': (context) => FutureBuilder<String?>(
              future: SharedPreferences.getInstance().then((prefs) => prefs.getString('role')),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                final role = snapshot.data ?? '';
                final screen = (role.toLowerCase().contains('dealer') ||
                                role.toLowerCase().contains('retailer') ||
                                role.toLowerCase().contains('builder'))
                    ? const DealerEnquiryScreen()
                    : const EnquiryScreen();
                return Layout(
                  appBarTitle: 'Enquiries',
                  child: screen,
                  initialIndex: 1,
                );
              },
            ),
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
