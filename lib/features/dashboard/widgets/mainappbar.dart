import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showProfileIcon;
  final bool showNotificationIcon; // Add this parameter

  const MainAppBar({
    Key? key,
    required this.title,
    this.showProfileIcon = false,
    this.showNotificationIcon = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // Remove back arrow
      title: Align(
        alignment: Alignment.centerLeft, // Align title to the left
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        if (showNotificationIcon)
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notification icon action
            },
          ),
        if (showProfileIcon)
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Handle profile icon action
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
