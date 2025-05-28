import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:steel_budy/services/api_service.dart';
import '../../models/role_model.dart';
import '../../models/application_settings_model.dart';
import '../../providers/auth_provider.dart';
import 'package:steel_budy/features/layout/layout.dart';
import 'package:steel_budy/features/screens/edit-profile.dart';

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
  List<Role> _roles = [];

  ApplicationSettings? _settings;
  bool _isLogoLoading = true; // Separate loading state for logo fetch
  String? _logoError; // Separate error state for logo fetch

  @override
  void initState() {
    super.initState();
    _fetchRoles();
    _fetchApplicationSettings();
  }

  Future<void> _fetchApplicationSettings() async {
    try {
      final settings = await ApiService.getApplicationSettings();
      setState(() {
        _settings = settings;
        _isLogoLoading = false;
      });
    } catch (e) {
      setState(() {
        _logoError = 'Error fetching logo: $e';
        _isLogoLoading = false;
      });
    }
  }

  Future<void> _fetchRoles() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final roles = await ApiService.getUserTypes();

      setState(() {
        _roles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load roles: $e';
        _isLoading = false;
      });
      debugPrint('Error fetching roles: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.center,
          child: _isLogoLoading
              ? const CircularProgressIndicator()
              : _logoError != null
                  ? const Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey,
                    )
                  : _settings != null && _settings!.logo.isNotEmpty
                      ? Image.network(
                          _settings!.logo,
                          height: 40,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const CircularProgressIndicator();
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.error,
                              size: 40,
                              color: Colors.red,
                            );
                          },
                        )
                      : const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
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
                          _error!.split(':').first,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            _fetchRoles();
                          },
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
                              value: role.value,
                              child: Text(role.name),
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
                            onPressed: (_selectedRole != null &&
                                    authState.phoneNumber != null &&
                                    !_isLoading)
                                ? () async {
                                    setState(() {
                                      _isLoading = true;
                                      _error = null;
                                    });

                                    try {
                                      await ref
                                          .read(authProvider.notifier)
                                          .login(
                                            authState.phoneNumber!,
                                            _selectedRole!,
                                          );

                                      if (mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Layout(
                                              appBarTitle: 'Edit Profile',
                                              initialIndex: 2,
                                              child: const EditProfile(),
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        _error =
                                            'Failed to login: ${e.toString()}';
                                        _isLoading = false;
                                      });
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
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
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