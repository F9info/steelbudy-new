import 'package:flutter/material.dart';
import 'package:steel_buddy/features/dashboard/widgets/mainappbar.dart';
import 'package:steel_buddy/features/dashboard/widgets/mainbottombar.dart';
import 'package:steel_buddy/features/screens/dashboardscreen.dart';
import 'package:steel_buddy/features/screens/enquiry.dart';
import 'package:steel_buddy/features/screens/profile.dart';
import 'package:steel_buddy/features/screens/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steel_buddy/features/screens/dealer_enquiry_screen.dart';

class Layout extends StatefulWidget {
  final Widget child;
  final String appBarTitle;
  final int initialIndex;

  const Layout({
    super.key,
    required this.child,
    required this.appBarTitle,
    this.initialIndex = 0,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) async {
    if (selectedIndex == index) {
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }

    setState(() {
      selectedIndex = index;
    });

    Widget newScreen;
    String newTitle;

    switch (index) {
      case 0:
        newScreen = const DashboardScreen();
        newTitle = 'Dashboard';
        break;
      case 1:
        // Check user role from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('role') ?? '';
        if (role.toLowerCase().contains('dealer') ||
            role.toLowerCase().contains('retailer') ||
            role.toLowerCase().contains('builder')) {
          newScreen = const DealerEnquiryScreen();
        } else {
          newScreen = const EnquiryScreen();
        }
        newTitle = 'Enquiry';
        break;
      case 2:
        newScreen = ProfileScreen();
        newTitle = 'Profile';
        break;
      default:
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Layout(
          child: newScreen,
          appBarTitle: newTitle,
          initialIndex: index,
        ),
      ),
      (route) => false,
    );
  }

  void _onNotificationTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Layout(
          child: const NotificationScreen(),
          appBarTitle: 'Notifications',
          initialIndex: selectedIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MainAppBar(
        title: widget.appBarTitle,
        onNotificationTap: _onNotificationTap,
      ),
      body: widget.child,
      bottomNavigationBar: MainBottomBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
