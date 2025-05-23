import 'package:flutter/material.dart';
import 'add_product_popup.dart';

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

  List<String> _selectedProductNames = [];
  Map<String, dynamic>? _productDetails;

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

  void _showAddProductPopup() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
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
      // Add your own AppBar with Back button here
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Your Enquiry'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
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
                      onPressed: _showAddProductPopup,
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
    );
  }
}
