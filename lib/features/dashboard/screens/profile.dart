import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                    'assets/images/vizag_logo.png', // Replace with your logo asset
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
              // Since MainScreen handles navigation, we can update the index there
              // For now, we'll keep the navigation as is
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
              // Navigate to Edit Profile screen
              // Navigator.pushNamed(context, '/edit_profile');
            },
          ),

          // Dealer Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Dealer Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to Dealer Profile screen
              // Navigator.pushNamed(context, '/dealer_profile');
            },
          ),

          // ISI Information
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('ISI Information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to ISI Info screen
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
              // Navigate to Support screen
              // Navigator.pushNamed(context, '/support');
            },
          ),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle logout action
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
