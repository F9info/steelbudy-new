import 'package:flutter/material.dart';
import 'package:steel_budy/models/application_settings_model.dart'; // Add this import
import 'package:steel_budy/services/api_service.dart'; // Add this import
import 'package:url_launcher/url_launcher.dart';

class SupportHelp extends StatefulWidget {
  const SupportHelp({super.key});

  @override
  State<SupportHelp> createState() => _SupportHelpState();
}

class _SupportHelpState extends State<SupportHelp> {
  ApplicationSettings? _settings;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchApplicationSettings();
  }

  Future<void> _fetchApplicationSettings() async {
    try {
      final settings = await ApiService.getApplicationSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error fetching settings: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _makePhoneCall() async {
    final phoneNumber = _settings?.supportNumber ?? '6305953196'; // Fallback
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone call')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support & Help'),
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
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchApplicationSettings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Call to Action Button
                      Center(
                        child: ElevatedButton(
                          onPressed: _makePhoneCall,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Call Support',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Phone Number
                      _buildInfoCard(
                        'Support Phone Number',
                        _settings?.supportNumber ?? '6305953196',
                        textColor: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      // Address
                      const Text(
                        'Support Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: Text(
                          _settings?.supportAddress ??
                              '123 Support Lane, Steel City, Visakhapatnam, Andhra Pradesh, India, 530001',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 24),
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