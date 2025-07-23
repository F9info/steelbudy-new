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
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

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
  String? _profileImageUrl;

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

  bool _isListenerSet = false;
  bool _hasFetchedProfile = false;

  Map<String, int> _regionNameToId = {};

  @override
  void initState() {
    super.initState();
    _fetchPhoneNumber();
    _fetchAvailableLocations();
    _fetchAndFillUserProfile();
    _countryController.text = 'India'; // Always set to India
  }

  @override
  void didChangeDependencies() {
    // didChangeDependencies removed; ref.listen will be in build
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final regions = await ApiService.getRegions();
      setState(() {
        _availableLocations = regions.map((region) => region.name).toList();
        _regionNameToId = {for (var region in regions) region.name: region.id};
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
    });
  }

  void _removeLocation(String location) {
    setState(() {
      _selectedLocations.remove(location);
    });
  }

  Future<void> _fetchAndFillUserProfile() async {
    final authState = ref.read(authProvider);
    final userId = authState.userId;
    if (userId == null) return;
    try {
      final user = await ApiService.getAppUser(userId);
      setState(() {
        _companyNameController.text = user.companyName ?? '';
        _contactPersonController.text = user.contactPerson ?? '';
        _phoneController.text = user.mobile ?? '';
        _alternateNumberController.text = user.alternateNumber ?? '';
        _emailController.text = user.email ?? '';
        _streetLineController.text = user.streetLine ?? '';
        _townCityController.text = user.townCity ?? '';
        _stateController.text = user.state ?? '';
        _countryController.text = 'India'; // Always set to India
        _pinCodeController.text = user.pincode ?? '';
        _gstController.text = user.gstin ?? '';
        _panController.text = user.pan ?? '';
        if (user.regions != null) {
          _selectedLocations = List<String>.from(user.regions!);
        }
        _profileImageUrl = user.profilePic;
      });
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
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
        _pinCodeController.text.isEmpty ||
        _alternateNumberController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      setState(() {
        _isLoading = false;
      });
      return false;
    }
    // Email validation
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      setState(() { _isLoading = false; });
      return false;
    }
    // Alternate number: must be exactly 10 digits if entered
    final altNum = _alternateNumberController.text;
    if (altNum.isNotEmpty && !RegExp(r'^[0-9]{10}$').hasMatch(altNum)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alternate number must be exactly 10 digits")),
      );
      setState(() { _isLoading = false; });
      return false;
    }
    // Pincode numeric
    if (!RegExp(r'^\d+$').hasMatch(_pinCodeController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pin Code must be numeric")),
      );
      setState(() { _isLoading = false; });
      return false;
    }
    // GST validation (only if not empty)
    final gst = _gstController.text;
    final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    if (gst.isNotEmpty && !gstRegex.hasMatch(gst)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid GSTIN")),
      );
      setState(() { _isLoading = false; });
      return false;
    }
    // PAN validation (only if not empty)
    final pan = _panController.text;
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (pan.isNotEmpty && !panRegex.hasMatch(pan)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid PAN")),
      );
      setState(() { _isLoading = false; });
      return false;
    }

    final authState = ref.read(authProvider);

    try {
      // Get userId and token from provider (update as per your provider)
      final userId = authState.userId;
      final token = await ref.read(authProvider.notifier).getToken(); // Implement getToken if needed
      final selectedRegionIds = _selectedLocations
          .map((name) => _regionNameToId[name])
          .where((id) => id != null)
          .toList();
      final formData = {
        'company_name': _companyNameController.text,
        'contact_person': _contactPersonController.text,
        'mobile': _phoneController.text,
        'alternate_number': _alternateNumberController.text,
        'email': _emailController.text,
        'street_line': _streetLineController.text,
        'town_city': _townCityController.text,
        'state': _stateController.text,
        'country': _countryController.text,
        'pincode': _pinCodeController.text,
        'gstin': _gstController.text,
        'pan': _panController.text,
        'region_id': selectedRegionIds.join(','),
        'api': 'true'
        // Add other fields as needed
      };
      final success = await ApiService.updateUserProfile(
        userId!.toString(),
        formData,
        token,
        profileImage: _profileImage,
      );
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('profile_complete', true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/dashboard');
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save profile")),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile: $e")),
      );
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<XFile?> compressImage(XFile file) async {
    final dir = await getTemporaryDirectory();
    final rand = Random().nextInt(100000);
    final targetPath = '${dir.path}/profile_compressed_$rand.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 80,
      minWidth: 800,
      minHeight: 800,
    );
    return result != null ? XFile(result.path) : null;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final compressed = await compressImage(pickedFile);
        setState(() {
          _profileImage = compressed ?? pickedFile;
        });
      }
    } catch (e) {
      throw Exception("Image picker error: $e");
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
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
                      : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!)
                          : null),
                  backgroundColor: Colors.grey[300],
                  child: _profileImage == null && (_profileImageUrl == null || _profileImageUrl!.isEmpty)
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

            // Show selected role (view only, disabled)
            if (authState.role.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: _getRoleDisplayName(authState.role),
                items: [DropdownMenuItem(value: _getRoleDisplayName(authState.role), child: Text(_getRoleDisplayName(authState.role)))],
                onChanged: null, // disables the dropdown
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 16),
            ],

            _buildTextField("Company Name *", _companyNameController),
            const SizedBox(height: 16),

            _buildTextField("Contact Person *", _contactPersonController),
            const SizedBox(height: 16),

            _isLoadingPhone
                ? const CircularProgressIndicator()
                : _buildTextField(
                    "Registered Number *",
                    _phoneController,
                    readOnly: true,
                    textColor: Colors.grey,
                  ),
            const SizedBox(height: 16),

            _buildTextField(
              "Alternate Number *",
              _alternateNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField("Email *", _emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),

            _buildTextField("Street Line *", _streetLineController),
            const SizedBox(height: 16),

            _buildTextField("Town/City *", _townCityController),
            const SizedBox(height: 16),

            _buildTextField("State *", _stateController),
            const SizedBox(height: 16),

            // Country dropdown (readonly, only India)
            DropdownButtonFormField<String>(
              value: 'India',
              items: [DropdownMenuItem(value: 'India', child: Text('India'))],
              onChanged: null, // disables the dropdown
              decoration: const InputDecoration(labelText: 'Country *'),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              "Pin Code *",
              _pinCodeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
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
              children: _availableLocations
                  .where((location) => !_selectedLocations.contains(location))
                  .map((location) {
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
                      Navigator.pushReplacementNamed(context, '/dashboard'); // Redirect to profile screen
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
                            await _saveProfile(context);
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
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      style: TextStyle(color: textColor ?? Colors.black),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
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

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'manufacturer':
        return 'Manufacturer';
      case 'distributor':
        return 'Distributor';
      case 'dealer_retailer_builder':
      case 'dealerretailerbuilder':
        return 'Dealer/Retailer/Builder';
      case 'end_user':
      case 'enduser':
        return 'End User';
      case 'others':
        return 'Others';
      default:
        return role;
    }
  }
}
