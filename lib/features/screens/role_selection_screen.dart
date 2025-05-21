import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:steel_budy/providers/role_provider.dart';
import 'package:steel_budy/providers/auth_provider.dart';
import 'package:steel_budy/features/screens/dashboardscreen.dart';
import 'package:flutter_svg/flutter_svg.dart';


class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleOptions = ref.watch(roleOptionsProvider);
    final selectedRole = ref.watch(roleProvider);

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
          child: Column(
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
                value: selectedRole,
                items: roleOptions.map((role) {
                  return DropdownMenuItem(
                    value: role.displayName,
                    child: Text(role.displayName),
                  );
                }).toList(),
                onChanged: (String? value) {
                  ref.read(roleProvider.notifier).state = value;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedRole != null
                      ? () async {
                          // Get the phone number from auth state
                          final authState = ref.read(authProvider);
                          if (authState.phoneNumber != null) {
                            // Submit role and navigate to dashboard
                            await ref.read(authProvider.notifier).login(
                              authState.phoneNumber!,
                              selectedRole,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DashboardScreen(),
                              ),
                            );
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
