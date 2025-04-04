import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Controllers for text fields
  final TextEditingController _nameController =
      TextEditingController(text: "Harsha Valluri");
  final TextEditingController _phoneController =
      TextEditingController(text: "+91 72870 - 14530");
  final TextEditingController _addressController = TextEditingController(
      text: "SDFsdjkyB5DJVBVAKJSVAKJDBFVAJAKSFDASNVAFJVNJADFBJADFNBAJFNBJFBA");
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();

  // List of selected locations
  List<String> _selectedLocations = ["Guntur", "Nellore", "Tirupati"];

  // List of available locations (dummy data)
  final List<String> _availableLocations = [
    "Vijayawada",
    "Visakhapatnam",
    "Vizianagaram",
    "Srikakulam"
  ];

  // Function to add a location
  void _addLocation(String location) {
    setState(() {
      _selectedLocations.add(location);
      _availableLocations.remove(location);
    });
  }

  // Function to remove a location
  void _removeLocation(String location) {
    setState(() {
      _selectedLocations.remove(location);
      _availableLocations.add(location);
    });
  }

  // Function to save profile (for now, just prints the data)
  void _saveProfile() {
    print("Name: ${_nameController.text}");
    print("Phone: ${_phoneController.text}");
    print("Address: ${_addressController.text}");
    print("City: ${_cityController.text}");
    print("Pin Code: ${_pinCodeController.text}");
    print("Selected Locations: $_selectedLocations");

    // Later, this can be replaced with an API call to save the data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile saved successfully!")),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Edit profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile photo section
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                  // Later, replace with actual image from API or local storage
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      // Add functionality to edit photo (e.g., pick from gallery)
                      print("Edit photo tapped");
                    },
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

            // Name field
            _buildTextField("Name", _nameController),
            const SizedBox(height: 16),

            // Phone number field
            _buildTextField("Phone number", _phoneController),
            const SizedBox(height: 16),

            // Address field
            _buildTextField("Address", _addressController, maxLines: 3),
            const SizedBox(height: 16),

            // City and Pin Code fields (side by side)
            Row(
              children: [
                Expanded(child: _buildTextField("City", _cityController)),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildTextField("Pin Code", _pinCodeController)),
              ],
            ),
            const SizedBox(height: 16),

            // Selected locations with border
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

            // Available locations
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

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Save",
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
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
