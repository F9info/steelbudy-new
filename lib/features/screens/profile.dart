import 'package:flutter/material.dart';
import '../../services/authentication.dart';
import 'isi_information.dart'; // Import the IsiInformation screen
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _authService.logout();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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

  Future<String> _fetchPhoneNumber() async {
    try {
      final phoneNumber = await _authService.getPhoneNumber();
      return phoneNumber ?? 'Phone number account available';
    } catch (e) {
      return 'Error fetching phone number';
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase().replaceAll(' ', '').replaceAll('/', '').replaceAll('_', '')) {
      case 'manufacturer':
        return 'Manufacturer';
      case 'distributor':
        return 'Distributor';
      case 'dealerretailerbuilder':
        return 'Dealer/Retailer/Builder';
      case 'enduser':
        return 'End User';
      case 'others':
        return 'Others';
      default:
        return role;
    }
  }

  Future<String> _fetchRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';
    return _getRoleDisplayName(role);
  }

  Future<Map<String, String?>> _fetchProfileHeaderInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      return {'companyName': 'Company', 'profilePic': null};
    }
    try {
      final user = await ApiService.getAppUser(userId);
      return {
        'companyName': user.companyName ?? 'Company',
        'profilePic': user.profilePic,
      };
    } catch (e) {
      return {'companyName': 'Company', 'profilePic': null};
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
            child: FutureBuilder<Map<String, String?>> (
              future: _fetchProfileHeaderInfo(),
              builder: (context, snapshot) {
                final companyName = snapshot.data?['companyName'] ?? 'Company';
                final profilePic = snapshot.data?['profilePic'];
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      backgroundImage: (profilePic != null && profilePic.isNotEmpty)
                          ? NetworkImage(profilePic)
                          : null,
                      child: (profilePic == null || profilePic.isEmpty)
                          ? const Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          companyName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<String>(
                          future: _fetchPhoneNumber(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              );
                            } else {
                              return Text(
                                snapshot.data ?? 'Phone number not available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<String>(
                          future: _fetchRole(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2));
                            } else if (snapshot.hasError) {
                              return Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              );
                            } else {
                              return Text(
                                snapshot.data?.isNotEmpty == true ? snapshot.data! : 'Role not available',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(),

          // Previous Orders/Enquiries
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Enquiries'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/enquiries');
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
              Navigator.pushNamed(context, '/edit-profile');
            },
          ),

          // Dealer Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('View Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/dealer_profile');
            },
          ),

          // ISI Information
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('ISI Information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const IsiInformation()),
              );
            },
          ),

          // Delete Profile Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Profile'),
                    content: Text('Are you sure you want to permanently delete your profile? This cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirmed == true) {
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );
                    await ApiService.deleteProfile();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete profile: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              },
              child: Text('Delete Profile'),
            ),
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
              Navigator.pushNamed(context, '/support');
            },
          ),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}