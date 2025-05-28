import 'package:flutter/material.dart';

class ViewProfile extends StatelessWidget {
  const ViewProfile({super.key});

  // Static profile data
  static const String _companyName = 'Vizag Profiles';
  static const String _contactPerson = 'John Doe';
  static const String _phone = '+91 98765 43210';
  static const String _alternateNumber = '+91 91234 56789';
  static const String _email = 'contact@vizagprofiles.com';
  static const String _streetLine = '123 Steel Road, Industrial Area';
  static const String _townCity = 'Visakhapatnam';
  static const String _state = 'Andhra Pradesh';
  static const String _country = 'India';
  static const String _pinCode = '530001';
  static const String _gst = '27AAECV1234F1Z5';
  static const String _pan = 'ABCDE1234F';
  static const List<String> _selectedLocations = [
    'Visakhapatnam',
    'Hyderabad',
    'Chennai'
  ];

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile photo
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: const AssetImage('assets/images/vizag_logo.png'),
                backgroundColor: Colors.grey[300],
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Profile details
            _buildInfoCard('Company Name', _companyName),
            const SizedBox(height: 16),

            _buildInfoCard('Contact Person', _contactPerson),
            const SizedBox(height: 16),

            _buildInfoCard('Registered Number', _phone, textColor: Colors.grey),
            const SizedBox(height: 16),

            _buildInfoCard('Alternate Number', _alternateNumber),
            const SizedBox(height: 16),

            _buildInfoCard('Email', _email),
            const SizedBox(height: 16),

            _buildInfoCard('Street Line', _streetLine, maxLines: 3),
            const SizedBox(height: 16),

            _buildInfoCard('Town/City', _townCity),
            const SizedBox(height: 16),

            _buildInfoCard('State', _state),
            const SizedBox(height: 16),

            _buildInfoCard('Country', _country),
            const SizedBox(height: 16),

            _buildInfoCard('Pin Code', _pinCode),
            const SizedBox(height: 16),

            _buildInfoCard('GST', _gst),
            const SizedBox(height: 16),

            _buildInfoCard('PAN (Individual)', _pan),
            const SizedBox(height: 16),

            // Selected locations
            if (_selectedLocations.isNotEmpty) ...[
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
                  children: _selectedLocations.map((location) {
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
}