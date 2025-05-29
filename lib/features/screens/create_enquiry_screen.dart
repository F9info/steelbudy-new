import 'package:flutter/material.dart';
import 'package:steel_budy/models/delivery-terms.dart';
import 'package:steel_budy/models/payment_term.dart';
import 'package:steel_budy/models/application_settings_model.dart';
import 'package:steel_budy/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String? _immediateHours;

  List<String> _selectedProductNames = [];
  Map<String, dynamic>? _productDetails;

  ApplicationSettings? _settings;

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchApplicationSettings();
  }

  Future<void> _fetchApplicationSettings() async {
    try {
      final settings = await ApiService.getApplicationSettings();
      setState(() {
        _settings = settings;
      });
      print('Fetched delivery conditions: ${settings.deliveryConditions}');
      print('Fetched delivery dates: ${settings.deliveryDates}');
    } catch (e) {
      print('Error fetching application settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching settings: $e')),
      );
    }
  }

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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone call')),
      );
    }
  }

  Future<void> _submitEnquiry() async {
    if (_formKey.currentState!.validate()) {
      // Validate that at least one product is selected
      if (_selectedProductNames.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one product')),
        );
        return;
      }

      try {
        // Prepare the products array
        List<Map<String, dynamic>> products = [];
        if (_productDetails != null) {
          final selectedProducts = _productDetails!['selectedProducts'] as Map<String, bool>;
          final brands = _productDetails!['brands'] as Map<String, String?>;
          final quantities = _productDetails!['quantities'] as Map<String, String?>;
          final pieces = _productDetails!['pieces'] as Map<String, String?>;
          final productIds = _productDetails!['productIds'] as Map<String, dynamic>;
          final brandIds = _productDetails!['brandIds'] as Map<String, dynamic>;

          for (var product in selectedProducts.keys) {
            if (selectedProducts[product] == true) {
              // Get product ID
              final productId = productIds[product];
              if (productId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product ID not found for $product')),
                );
                return;
              }

              // Get brand ID
              final brandName = brands[product];
              if (brandName == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a brand for $product')),
                );
                return;
              }
              final brandId = brandIds[brandName];
              if (brandId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Brand ID not found for $brandName')),
                );
                return;
              }

              // Validate quantity
              if (quantities[product] == null || quantities[product]!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter quantity for $product')),
                );
                return;
              }

              products.add({
                'product_id': productId,
                'brand_id': brandId,
                'quantity': quantities[product],
                'pieces': pieces[product],
              });
            }
          }
        }

        // Validate required fields
        if (_selectedPaymentTerm == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a payment term')),
          );
          return;
        }
        if (_selectedDeliveryTerm == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a delivery term')),
          );
          return;
        }
        if (_selectedDeliveryCondition == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a delivery condition')),
          );
          return;
        }
        if (_selectedDeliveryDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a delivery date')),
          );
          return;
        }

        // Prepare the payload
        final payload = {
          'app_user_id': '1', // Replace with actual user ID from auth
          'payment_terms': _selectedPaymentTerm,
          'delivery_terms': _selectedDeliveryTerm,
          'delivery_address': _deliveryAddress ?? _settings?.supportAddress,
          'delivery_condition': _selectedDeliveryCondition,
          'delivery_date': _selectedDeliveryDate,
          'payment_terms_description': _selectedPaymentTerm == 'Credit' ? _creditDays : null,
          'delivery_date_hours': _selectedDeliveryDate == 'Immediate' ? _immediateHours : null,
          'delivery_date_days': _selectedDeliveryDate == 'Within' ? _withinDays : null,
          'products': products,
        };

        // Send the enquiry to the backend
        await ApiService.submitEnquiry(payload);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enquiry submitted successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting enquiry: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      _makePhoneCall(_settings?.supportNumber ?? '6305953196');
                    },
                    child: const Text(
                      'Call Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'PAYMENT TERMS',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<PaymentTerm>>(
                  future: ApiService.getPaymentTerms(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          children: [
                            Text('Error: ${snapshot.error}'),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No payment terms available'));
                    }

                    final paymentTerms = snapshot.data!;
                    return Column(
                      children: paymentTerms.map((term) {
                        return RadioListTile<String>(
                          title: Text(term.name),
                          value: term.name,
                          groupValue: _selectedPaymentTerm,
                          onChanged: (value) => setState(() => _selectedPaymentTerm = value),
                          activeColor: Colors.purple,
                        );
                      }).toList(),
                    );
                  },
                ),
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
                FutureBuilder<List<DeliveryTerm>>(
                  future: ApiService.getDeliveryTerms(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          children: [
                            Text('Error: ${snapshot.error}'),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No delivery terms available'));
                    }

                    final deliveryTerms = snapshot.data!;
                    return Column(
                      children: deliveryTerms.map((term) {
                        return RadioListTile<String>(
                          title: Text(term.name),
                          value: term.name,
                          groupValue: _selectedDeliveryTerm,
                          onChanged: (value) => setState(() => _selectedDeliveryTerm = value),
                          activeColor: Colors.purple,
                        );
                      }).toList(),
                    );
                  },
                ),
                if (_selectedDeliveryTerm == 'Delivered To') ...[
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
                    initialValue: _settings?.supportAddress ?? 'Self-Pickup Ex-Visakhapatnam',
                    maxLines: 3,
                    onChanged: (val) => _deliveryAddress = val,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter delivery address' : null,
                  ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'DELIVERY CONDITION',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (_settings == null || _settings!.deliveryConditions.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  ..._settings!.deliveryConditions.map((condition) {
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
                if (_settings == null || _settings!.deliveryDates.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  ..._settings!.deliveryDates.map((date) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioListTile<String>(
                          title: Text(date),
                          value: date,
                          groupValue: _selectedDeliveryDate,
                          onChanged: (value) => setState(() => _selectedDeliveryDate = value),
                          activeColor: Colors.purple,
                        ),
                        if (_selectedDeliveryDate == date && date == 'Within')
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Days',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => _withinDays = val,
                              validator: (val) =>
                                  val == null || val.isEmpty ? 'Enter days' : null,
                            ),
                          ),
                        if (_selectedDeliveryDate == date && date == 'Immediate')
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Hours',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => _immediateHours = val,
                              validator: (val) =>
                                  val == null || val.isEmpty ? 'Enter hours' : null,
                            ),
                          ),
                      ],
                    );
                  }).toList(),
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
                    onPressed: _submitEnquiry,
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