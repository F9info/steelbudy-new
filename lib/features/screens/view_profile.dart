import 'package:flutter/material.dart';
import 'package:steel_budy/services/api_service.dart';
import 'package:steel_budy/models/app_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  AppUser? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        setState(() {
          _error = 'User not found';
          _isLoading = false;
        });
        return;
      }
      final user = await ApiService.getAppUser(userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _user == null
                  ? const Center(child: Text('No profile data'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile photo
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _user!.profilePic != null && _user!.profilePic!.isNotEmpty
                                  ? NetworkImage(_user!.profilePic!)
                                  : null,
                              backgroundColor: Colors.grey[300],
                              child: (_user!.profilePic == null || _user!.profilePic!.isEmpty)
                                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Show Role
                          _buildInfoCard('Role', _getRoleDisplayName(_user?.userType?.name ?? '')),
                          const SizedBox(height: 16),
                          
                          _buildInfoCard('Company Name', _user!.companyName ?? ''),
                          const SizedBox(height: 16),

                          _buildInfoCard('Contact Person', _user!.contactPerson ?? ''),
                          const SizedBox(height: 16),

                          _buildInfoCard('Registered Number', _user!.mobile ?? '', textColor: Colors.grey),
                          const SizedBox(height: 16),

                          _buildInfoCard('Alternate Number', _user!.alternateNumber ?? ''),
                          const SizedBox(height: 16),

                          _buildInfoCard('Email', _user!.email ?? ''),
                          const SizedBox(height: 16),

                          _buildInfoCard('Street Line', _user!.streetLine ?? '', maxLines: 3),
                          const SizedBox(height: 16),

                          _buildInfoCard('Town/City', _user!.townCity ?? ''),
                          const SizedBox(height: 16),

                          _buildInfoCard('State', _user!.state ?? ''),
                          const SizedBox(height: 16),

                          _buildInfoCard('Country', _user!.country ?? ''),
                          const SizedBox(height: 16),

                          _buildInfoCard('Pin Code', _user!.pincode ?? ''),
                          const SizedBox(height: 16),

                          _buildInfoCard('GST', _user!.gstin ?? ''),
                          const SizedBox(height: 16),

                          _buildInfoCard('PAN (Individual)', _user!.pan ?? ''),
                          const SizedBox(height: 16),

                          // Selected locations
                          if (_user!.regions != null && _user!.regions!.isNotEmpty) ...[
                            const Text(
                              'Selected Locations',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _user!.regions!.map((location) {
                                  return Chip(
                                    label: Text(location),
                                    backgroundColor: Colors.blue[100],
                                    labelStyle: const TextStyle(color: Colors.black),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
    );
  }

  Widget _buildInfoCard(String label, String value, {int maxLines = 1, Color? textColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: textColor ?? Colors.black,
              fontWeight: FontWeight.w500,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
}