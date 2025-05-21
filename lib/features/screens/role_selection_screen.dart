import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:steel_budy/providers/auth_provider.dart';
import 'package:steel_budy/features/screens/dashboardscreen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:steel_budy/services/api_service.dart';
import 'package:flutter/foundation.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = true;
  String? _error;
  List<Map<String, String>> _roles = [];

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final response = await http
            .get(
          Uri.parse('http://127.0.0.1:8000/api/user-types'),
        )
            .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Connection timed out');
          },
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);

          if (!responseData.containsKey('userTypes')) {
            throw Exception('Invalid response format: missing userTypes field');
          }

          final List<dynamic> userTypes = responseData['userTypes'];
          if (userTypes.isEmpty) {
            throw Exception('No roles found in the response');
          }

          setState(() {
            _roles = userTypes.map((item) {
              if (item['name'] == null) {
                throw Exception('Invalid role data: missing name field');
              }
              return {
                'name': item['name'] as String,
                'value':
                    item['name'].toString().toLowerCase().replaceAll(' ', '_'),
              };
            }).toList();
            _isLoading = false;
          });
        } else {
          throw HttpException(
              'Server returned status code ${response.statusCode}');
        }
      } on FormatException {
        throw Exception('Invalid response format from server');
      } on SocketException {
        throw Exception(
            'Could not connect to the server. Please check if the server is running.');
      } on HttpException catch (e) {
        throw Exception('HTTP Error: ${e.message}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('Error fetching roles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/images/logo.svg',
            height: 40,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading roles...'),
                  ],
                )
              : _error != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading roles:\n${_error!.split(':').first}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchRoles,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        const Text(
                          'Please select your role to continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Role',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedRole,
                          items: _roles.map((role) {
                            return DropdownMenuItem(
                              value: role['value'],
                              child: Text(role['name']!),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedRole = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _selectedRole != null
                                ? () async {
                                    // Get the phone number from auth state
                                    final authState = ref.read(authProvider);
                                    if (authState.phoneNumber != null) {
                                      // Submit role and navigate to dashboard
                                      await ref
                                          .read(authProvider.notifier)
                                          .login(
                                            authState.phoneNumber!,
                                            _selectedRole,
                                          );
                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const DashboardScreen(),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
