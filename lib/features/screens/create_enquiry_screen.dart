import 'package:flutter/material.dart';
import 'package:steel_budy/features/layout/layout.dart';



class CreateEnquiryScreen extends StatefulWidget {
  const CreateEnquiryScreen({Key? key}) : super(key: key);

  @override
  State<CreateEnquiryScreen> createState() => _CreateEnquiryScreenState();
}

class _CreateEnquiryScreenState extends State<CreateEnquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProduct;
  String? _quantity;
  String? _selectedLocation;
  String? _notes;

  // State for bottom navigation
  int _selectedIndex = 1; // Default to Enquiry tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // Navigate to Dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (index == 1) {
      // Stay on Enquiry
    } else if (index == 2) {
      // Navigate to Profile
      Navigator.pushNamed(context, '/profile');
    }
  }

  final List<String> _products = [
    '10MM REBAR',
    '12MM REBAR',
    '16MM REBAR',
    '19MM REBAR',
    '20MM REBAR',
    '25MM REBAR',
    '32MM REBAR',
    '8MM REBAR',
    'BINDING WIRE'
  ];
  final List<String> _locations = ['Vizag', 'Hyderabad', 'Vijayawada', 'Chennai'];

  void _showBottomPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.blue,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                'Profile (Last updated: 26 Mar 2024)',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text('ISI Info', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.support, color: Colors.white),
              title: const Text('Support', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Layout(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Product',
                      border: OutlineInputBorder(),
                    ),
                    items: _products
                        .map((product) => DropdownMenuItem(
                              value: product,
                              child: Text(product),
                            ))
                        .toList(),
                    value: _selectedProduct,
                    onChanged: (value) => setState(() => _selectedProduct = value),
                    validator: (value) =>
                        value == null ? 'Please select a product' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Quantity (tons)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => _quantity = val,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter quantity' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                    items: _locations
                        .map((loc) => DropdownMenuItem(
                              value: loc,
                              child: Text(loc),
                            ))
                        .toList(),
                    value: _selectedLocation,
                    onChanged: (value) => setState(() => _selectedLocation = value),
                    validator: (value) =>
                        value == null ? 'Please select a location' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (val) => _notes = val,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enquiry submitted!')),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Submit',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
 
   
    );
  }
}