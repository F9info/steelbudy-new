import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/authentication.dart';
import '../../services/api_service.dart';
import '../../models/app_user_model.dart';
import '../../models/role_model.dart';
import '../../providers/auth_provider.dart';

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  XFile? _profileImage;

  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _alternateNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _streetLineController = TextEditingController();
  final TextEditingController _townCityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _panController = TextEditingController();

  bool _isLoadingPhone = true;

  List<String> _selectedLocations = [];
  List<String> _availableLocations = [];

  @override
  void initState() {
    super.initState();
    _fetchPhoneNumber();
    _fetchAvailableLocations();
  }

  Future<void> _fetchPhoneNumber() async {
    final phone = await _authService.getPhoneNumber();
    setState(() {
      _phoneController.text = phone ?? "Phone number not available";
      _isLoadingPhone = false;
    });
  }

  Future<void> _fetchAvailableLocations() async {
    try {
      final regions = await ApiService.getRegions();
      setState(() {
        _availableLocations = regions.map((region) => region.name).toList();
        _availableLocations
            .removeWhere((location) => _selectedLocations.contains(location));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching regions: $e")),
      );
    }
  }

  void _addLocation(String location) {
    setState(() {
      _selectedLocations.add(location);
      _availableLocations.remove(location);
    });
  }

  void _removeLocation(String location) {
    setState(() {
      _selectedLocations.remove(location);
      _availableLocations.add(location);
    });
  }

  Future<bool> _saveProfile(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    // Validate required fields
    if (_companyNameController.text.isEmpty ||
        _contactPersonController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _streetLineController.text.isEmpty ||
        _townCityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _countryController.text.isEmpty ||
        _pinCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      setState(() {
        _isLoading = false;
      });
      return false;
    }

    final authState = ref.read(authProvider);
    if (authState.role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a role first")),
      );
      setState(() {
        _isLoading = false;
      });
      return false;
    }

    try {
      final userType = await ApiService.getUserTypes();
      final selectedUserType = userType.firstWhere(
        (role) => role.value == authState.role,
        orElse: () => Role.fromValues(
          id: 0,
          name: "",
          value: authState.role,
        ),
      );

      final appUser = AppUser(
        userTypeId: selectedUserType.id,
        companyName: _companyNameController.text,
        contactPerson: _contactPersonController.text,
        mobile: _phoneController.text,
        email: _emailController.text,
        streetLine: _streetLineController.text,
        townCity: _townCityController.text,
        state: _stateController.text,
        country: _countryController.text,
        pincode: _pinCodeController.text,
        regionId: null,
        userType: UserType(
          id: selectedUserType.id,
          name: selectedUserType.name,
          publish: 1,
        ),
        regions: _selectedLocations.isNotEmpty ? _selectedLocations : null,
      );

      try {
        if (authState.userId != null) {
          // Update existing user
          try {
            final userId = int.parse(authState.userId!);
            await ApiService.updateAppUser(userId, appUser);
          } catch (e) {
            throw Exception("Invalid user ID format: ${authState.userId}");
          }
        } else {
          // Create new user
          final createdUser = await ApiService.createAppUser(appUser);
          // Update auth state with new user ID
          ref.read(authProvider.notifier).update((state) => state.copyWith(
                userId: createdUser.id.toString(),
              ));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return true;
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving profile: $e")),
        );
        return false;
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user types: $e")),
      );
      return false;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _profileImage = pickedFile;
        });
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (!kIsWeb && !Platform.isMacOS && !Platform.isWindows)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _alternateNumberController.dispose();
    _emailController.dispose();
    _streetLineController.dispose();
    _townCityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pinCodeController.dispose();
    _gstController.dispose();
    _panController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profi1le'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            onPressed: _isLoading ? null : () => _saveProfile(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile photo
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(File(_profileImage!.path))
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: _profileImage == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Edit photo",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildTextField("Company Name", _companyNameController),
            const SizedBox(height: 16),

            _buildTextField("Contact Person", _contactPersonController),
            const SizedBox(height: 16),

            _isLoadingPhone
                ? const CircularProgressIndicator()
                : _buildTextField(
                    "Registered Number",
                    _phoneController,
                    readOnly: true,
                    textColor: Colors.grey,
                  ),
            const SizedBox(height: 16),

            _buildTextField("Alternate Number", _alternateNumberController),
            const SizedBox(height: 16),

            _buildTextField("Email", _emailController),
            const SizedBox(height: 16),

            _buildTextField("Street Line", _streetLineController, maxLines: 3),
            const SizedBox(height: 16),

            _buildTextField("Town/City", _townCityController),
            const SizedBox(height: 16),

            _buildTextField("State", _stateController),
            const SizedBox(height: 16),

            _buildTextField("Country", _countryController),
            const SizedBox(height: 16),

            _buildTextField("Pin Code", _pinCodeController),
            const SizedBox(height: 16),

            _buildTextField("GST", _gstController),
            const SizedBox(height: 16),

            _buildTextField("PAN (Individual)", _panController),
            const SizedBox(height: 16),

            if (_selectedLocations.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Selected locations",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeLocation(location),
                      backgroundColor: Colors.blue[100],
                      labelStyle: const TextStyle(color: Colors.black),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Available locations",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableLocations.map((location) {
                return ActionChip(
                  label: Text(location),
                  avatar: const Icon(Icons.add, size: 18),
                  onPressed: () => _addLocation(location),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Update and Cancel buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cancel action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (await _saveProfile(context)) {
                              Navigator.pop(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Update',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool readOnly = false,
    Color? textColor,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      style: TextStyle(color: textColor ?? Colors.black),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
