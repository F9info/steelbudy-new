import 'package:flutter/material.dart';

class MainBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MainBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.blue, // Color for the selected icon and label
      unselectedItemColor: Colors.grey, // Color for unselected icons and labels
      showUnselectedLabels: true, // Show labels for unselected items
      type: BottomNavigationBarType.fixed, // Ensures all items are visible
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Enquiry',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Me',
        ),
      ],
    );
  }
}
