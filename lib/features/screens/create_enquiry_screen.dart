import 'package:flutter/material.dart';
import 'package:steel_budy/features/layout/layout.dart';
import 'add_product_popup.dart'; // Import the AddProductPopup

class CreateEnquiryScreen extends StatefulWidget {
  const CreateEnquiryScreen({Key? key}) : super(key: key);

  @override
  State<CreateEnquiryScreen> createState() => _CreateEnquiryScreenState();
}

class _CreateEnquiryScreenState extends State<CreateEnquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPaymentTerm;
  String? _creditDays;
  String? _selectedDeliveryTerm;
  String? _deliveryAddress;
  String? _selectedDeliveryCondition;
  String? _selectedDeliveryDate;
  String? _withinDays;

  // State to track selected products
  List<String> _selectedProductNames = [];
  Map<String, dynamic>? _productDetails;

  // State for bottom navigation
  int _selectedIndex = 1; // Default to Enquiry tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  final List<String> _paymentTerms = ['Advance', 'Advance Against Delivery', 'Credit'];
  final List<String> _deliveryTerms = ['Delivered to', 'Self-Pickup Ex-Visakhapatnam'];
  final List<String> _deliveryConditions = ['Bend', 'Straight'];
  final List<String> _deliveryDates = ['Immediate', 'Within'];

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

  void _showAddProductPopup() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to take more height
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8, // 80% of screen height
        child: const AddProductPopup(),
      ),
    );

    if (result != null) {
      setState(() {
        _productDetails = result;
        _selectedProductNames = [];
        result['selectedProducts'].forEach((product, isSelected) {
          if (isSelected) {
            _selectedProductNames.add(product);
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Layout(
        appBarTitle: 'Your Enquiry',
        initialIndex: _selectedIndex,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedProductNames.isEmpty
                            ? 'No products selected'
                            : '${_selectedProductNames.length} product${_selectedProductNames.length > 1 ? 's' : ''} selected',
                        style: const TextStyle(fontSize: 16),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _showAddProductPopup, // Open the popup
                        child: const Text(
                          'Add Product',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Call Now',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PAYMENT TERMS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ..._paymentTerms.map((term) {
                    return RadioListTile<String>(
                      title: Text(term),
                      value: term,
                      groupValue: _selectedPaymentTerm,
                      onChanged: (value) => setState(() => _selectedPaymentTerm = value),
                      activeColor: Colors.purple,
                    );
                  }).toList(),
                  if (_selectedPaymentTerm == 'Credit')
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Days',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _creditDays = val,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter credit days' : null,
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'DELIVERY TERMS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ..._deliveryTerms.map((term) {
                    return RadioListTile<String>(
                      title: Text(term),
                      value: term,
                      groupValue: _selectedDeliveryTerm,
                      onChanged: (value) => setState(() => _selectedDeliveryTerm = value),
                      activeColor: Colors.purple,
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  const Text(
                    'DELIVERY ADDRESS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    initialValue: 'Self-Pickup Ex-Visakhapatnam',
                    maxLines: 3,
                    onChanged: (val) => _deliveryAddress = val,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'DELIVERY CONDITION',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ..._deliveryConditions.map((condition) {
                    return RadioListTile<String>(
                      title: Text(condition),
                      value: condition,
                      groupValue: _selectedDeliveryCondition,
                      onChanged: (value) =>
                          setState(() => _selectedDeliveryCondition = value),
                      activeColor: Colors.purple,
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  const Text(
                    'DELIVERY DATE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ..._deliveryDates.map((date) {
                    return RadioListTile<String>(
                      title: Text(date),
                      value: date,
                      groupValue: _selectedDeliveryDate,
                      onChanged: (value) => setState(() => _selectedDeliveryDate = value),
                      activeColor: Colors.purple,
                    );
                  }).toList(),
                  if (_selectedDeliveryDate == 'Within')
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Days',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => _withinDays = val,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Enter days' : null,
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enquiry submitted!')),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Submit Enquiry',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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