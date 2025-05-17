import 'package:flutter/material.dart';
import 'package:steel_budy/features/dashboard/widgets/mainappbar.dart';
import 'package:steel_budy/features/screens/profile.dart';
import 'package:steel_budy/features/dashboard/widgets/mainbottombar.dart';

class Layout extends StatefulWidget {
  final Widget child;
  final String appBarTitle;
  final bool showProfileIcon;
  final bool showNotificationIcon;

  const Layout({
    super.key,
    required this.child,
    this.appBarTitle = 'Products',
    this.showProfileIcon = true,
    this.showNotificationIcon = false,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int selectedIndex = 0;

  // Function to handle bottom navigation tap
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    // Navigate to the corresponding screen based on index
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Layout(
              child: Center(child: Text('Home Screen')),
              appBarTitle: 'Home',
            ),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Layout(
              child: Center(child: Text('Enquiry Screen')),
              appBarTitle: 'Enquiry',
            ),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Layout(
              child: ProfileScreen(),
              appBarTitle: 'Profile',
            ),
          ),
        );
        break;
    }
  }

  // Function to show bottom popup
  void _showBottomPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.blue,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                'Profile (Last updated: 26 Mar 2024)',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text('ISI Info', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.support, color: Colors.white),
              title: const Text('Support', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Add logout logic here (e.g., clear auth state, navigate to login)
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  // Function to get the appropriate AppBar
  PreferredSizeWidget _getAppBar() {
    return MainAppBar(
      title: widget.appBarTitle,
      showProfileIcon: widget.showProfileIcon,
      showNotificationIcon: widget.showNotificationIcon,
      onProfileTap: () {
        _showBottomPopup(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _getAppBar(),
      body: widget.child,
      bottomNavigationBar: MainBottomBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}