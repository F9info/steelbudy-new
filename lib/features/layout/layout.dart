import 'package:flutter/material.dart';
import 'package:steel_budy/features/dashboard/widgets/mainappbar.dart';
import 'package:steel_budy/features/dashboard/widgets/mainbottombar.dart';
import 'package:steel_budy/features/screens/dashboardscreen.dart';
import 'package:steel_budy/features/screens/enquiry.dart';
import 'package:steel_budy/features/screens/profile.dart';
import 'package:steel_budy/features/screens/notifications.dart';
import 'package:steel_budy/features/screens/quotation_screen.dart';

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

  void _onItemTapped(int index) {
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
        newScreen = const EnquiryScreen();
        newTitle = 'Enquiry';
        break;
      case 2:
        newScreen = ProfileScreen();
        newTitle = 'Profile';
        break;
      case 3:
        newScreen = const QuotationScreen(); // Add QuotationScreen case
        newTitle = 'Quotation';
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