import 'package:flutter/material.dart';

import '../../../services/authentication.dart';
import 'edit-profile.dart';
// Make sure to import the AuthService

class ProfileScreen extends StatelessWidget {
  final AuthService _authService = AuthService(); // Initialize AuthService

  ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Clear login state
      await _authService.logout();

      // Remove loading indicator and navigate to login
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: Image.asset(
                    'assets/images/vizag_logo.png',
                    width: 60,
                    height: 60,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vizag Profiles',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+91 7287014560',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),

          // Previous Orders/Enquiries
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Enquiries'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/enquiry');
            },
          ),

          // Account Section Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),

          // Edit Profile
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfile()),
              );
            },
          ),

          // Dealer Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Dealer Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigator.pushNamed(context, '/dealer_profile');
            },
          ),

          // ISI Information
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('ISI Information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigator.pushNamed(context, '/isi_info');
            },
          ),

          // Help & Logout Section Header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Help & logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),

          // Support & Help
          ListTile(
            leading: const Icon(Icons.support),
            title: const Text('Support & help'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigator.pushNamed(context, '/support');
            },
          ),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _handleLogout(context), // Updated logout handler
          ),
        ],
      ),
    );
  }
}
