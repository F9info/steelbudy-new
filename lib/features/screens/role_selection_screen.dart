import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:steel_budy/providers/auth_provider.dart';
import 'package:steel_budy/features/screens/dashboardscreen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:steel_budy/services/api_service.dart';
import '../../models/role_model.dart';
import 'package:steel_budy/features/layout/layout.dart';

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

      final roles = await ApiService.getUserTypes();

      setState(() {
        _roles = roles;
        _isLoading = false;
      });
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
    final authState = ref.watch(authProvider);

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
                                              appBarTitle: 'Products',
                                              initialIndex: 0,
                                              child: const DashboardScreen(),
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
