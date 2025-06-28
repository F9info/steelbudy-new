import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:steel_buddy/models/delivery-terms.dart';
import 'package:steel_buddy/models/payment_term.dart';
import 'package:steel_buddy/models/application_settings_model.dart';
import 'package:steel_buddy/services/api_service.dart';
import 'package:steel_buddy/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_product_popup.dart';
import 'package:flutter/services.dart';
import 'package:steel_buddy/services/fcm_service.dart';

class CreateEnquiryScreen extends ConsumerStatefulWidget {
  const CreateEnquiryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateEnquiryScreen> createState() =>
      _CreateEnquiryScreenState();
}

class _CreateEnquiryScreenState extends ConsumerState<CreateEnquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPaymentTerm;
  String? _creditDays;
  String? _selectedDeliveryTerm;
  String? _deliveryAddress;
  String? _selectedDeliveryCondition;
  String? _selectedDeliveryDate;
  String? _withinDays;
  String? _immediateHours;

  List<Map<String, dynamic>> _selectedProducts = [];

  ApplicationSettings? _settings;

  List<PaymentTerm>? _paymentTerms;
  List<DeliveryTerm>? _deliveryTerms;
  List<String>? _deliveryConditions;
  List<String>? _deliveryDates;

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      final settings = await ApiService.getApplicationSettings();
      final paymentTerms = await ApiService.getPaymentTerms();
      final deliveryTerms = await ApiService.getDeliveryTerms();
      setState(() {
        _settings = settings;
        _paymentTerms = paymentTerms;
        _deliveryTerms = deliveryTerms;
        _deliveryConditions = settings.deliveryConditions;
        _deliveryDates = settings.deliveryDates;
      });
    } catch (e) {
      print('Error fetching initial data: $e');
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

    if (result != null && result is List) {
      setState(() {
        // Avoid duplicates by product+brand
        for (final newProduct in result) {
          final exists = _selectedProducts.any((p) =>
              p['productId'] == newProduct['productId'] &&
              p['brandId'] == newProduct['brandId']);
          if (!exists) {
            _selectedProducts.add(newProduct);
          }
        }
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
      if (_selectedProducts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one product')),
        );
        return;
      }
      // Validate required fields
      if (_selectedPaymentTerm == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a payment term')),
        );
        return;
      }
      if (_selectedPaymentTerm == 'Credit' &&
          (_creditDays == null || _creditDays!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter credit days')),
        );
        return;
      }
      if (_selectedDeliveryTerm == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a delivery term')),
        );
        return;
      }
      if (_selectedDeliveryTerm == 'Delivered To' &&
          (_deliveryAddress == null || _deliveryAddress!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter delivery address')),
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
      if (_selectedDeliveryDate == 'Immediate' &&
          (_immediateHours == null || _immediateHours!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter no of hours')),
        );
        return;
      }
      if (_selectedDeliveryDate == 'Within' &&
          (_withinDays == null || _withinDays!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter no of days')),
        );
        return;
      }

      try {
        // Prepare the products array
        List<Map<String, dynamic>> products = [];
        for (var product in _selectedProducts) {
          products.add({
            'product_id': product['productId'],
            'brand_id': product['brandId'],
            'quantity': product['qty'],
            'pieces': product['pieces'],
          });
        }

        // Get user ID from auth provider
        final authState = ref.read(authProvider);
        final userId = authState.userId;

        // Prepare the payload
        final payload = {
          'app_user_id': userId,
          'payment_terms': _selectedPaymentTerm,
          'delivery_terms': _selectedDeliveryTerm,
          'delivery_condition': _selectedDeliveryCondition,
          'delivery_address':
              _selectedDeliveryTerm == 'Delivered To' ? _deliveryAddress : null,
          'delivery_date': _selectedDeliveryDate,
          'payment_terms_description':
              _selectedPaymentTerm == 'Credit' ? _creditDays : null,
          'delivery_date_hours':
              _selectedDeliveryDate == 'Immediate' ? _immediateHours : null,
          'delivery_date_days':
              _selectedDeliveryDate == 'Within' ? _withinDays : null,
          'products': products,
        };

        // Send the enquiry to the backend
        await ApiService.submitEnquiry(payload);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enquiry submitted successfully!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting enquiry: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _paymentTerms == null ||
        _deliveryTerms == null ||
        _deliveryConditions == null ||
        _deliveryDates == null;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Your Enquiry'),
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                            _selectedProducts.isEmpty
                                ? 'No products selected'
                                : '${_selectedProducts.length} product${_selectedProducts.length > 1 ? 's' : ''} selected',
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
                            child: Text(
                              'Add Product',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedProducts.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Table(
                          border: TableBorder.all(color: Colors.grey),
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(1.5),
                            3: FlexColumnWidth(1.5),
                            4: FlexColumnWidth(1),
                          },
                          children: [
                            const TableRow(
                              decoration:
                                  BoxDecoration(color: Color(0xFFE0E0E0)),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Product',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Brand',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Qty',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Pieces',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                SizedBox(),
                              ],
                            ),
                            ..._selectedProducts.asMap().entries.map((entry) {
                              final i = entry.key;
                              final p = entry.value;
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(p['product']?.toString() ?? ''),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(p['brand']?.toString() ?? ''),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(p['qty']?.toString() ?? ''),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(p['pieces']?.toString() ?? ''),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _selectedProducts.removeAt(i);
                                      });
                                    },
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ],
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
                            _makePhoneCall(
                                _settings?.supportNumber ?? '6305953196');
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          ..._paymentTerms!.map((term) {
                            return RadioListTile<String>(
                              title: Text(term.name),
                              value: term.name,
                              groupValue: _selectedPaymentTerm,
                              onChanged: (value) =>
                                  setState(() => _selectedPaymentTerm = value),
                              activeColor: Colors.purple,
                            );
                          }).toList(),
                          if (_selectedPaymentTerm == 'Credit')
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, left: 16.0, right: 16.0),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Days',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                onChanged: (val) => _creditDays = val,
                                validator: (val) {
                                  if (_selectedPaymentTerm == 'Credit') {
                                    if (val == null || val.isEmpty) {
                                      return 'Enter credit days';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'DELIVERY TERMS',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          ..._deliveryTerms!.map((term) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RadioListTile<String>(
                                  title: Text(term.name),
                                  value: term.name,
                                  groupValue: _selectedDeliveryTerm,
                                  onChanged: (value) => setState(
                                      () => _selectedDeliveryTerm = value),
                                  activeColor: Colors.purple,
                                ),
                                if (_selectedDeliveryTerm == 'Delivered To' &&
                                    term.name == 'Delivered To')
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 32.0, right: 16.0, bottom: 8.0),
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Delivery Address',
                                        border: OutlineInputBorder(),
                                      ),
                                      initialValue: _deliveryAddress ??
                                          _settings?.supportAddress ??
                                          'Self-Pickup Ex-Visakhapatnam',
                                      maxLines: 3,
                                      onChanged: (val) =>
                                          _deliveryAddress = val,
                                      validator: (val) {
                                        if (_selectedDeliveryTerm ==
                                            'Delivered To') {
                                          if (val == null || val.isEmpty) {
                                            return 'Enter delivery address';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'DELIVERY CONDITION',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: _deliveryConditions!.map((condition) {
                          final trimmedCondition = condition.trim();
                          return RadioListTile<String>(
                            title: Text(trimmedCondition),
                            value: trimmedCondition,
                            groupValue: _selectedDeliveryCondition?.trim(),
                            onChanged: (value) => setState(
                                () => _selectedDeliveryCondition = value),
                            activeColor: Colors.purple,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'DELIVERY DATE',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._deliveryDates!.map((date) {
                            final trimmedDate = date.trim();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RadioListTile<String>(
                                  title: Text(trimmedDate),
                                  value: trimmedDate,
                                  groupValue: _selectedDeliveryDate?.trim(),
                                  onChanged: (value) => setState(
                                      () => _selectedDeliveryDate = value),
                                  activeColor: Colors.purple,
                                ),
                                if (_selectedDeliveryDate?.trim() ==
                                        trimmedDate &&
                                    trimmedDate == 'Within')
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 32.0, right: 16.0, bottom: 8.0),
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'No of Days',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      onChanged: (val) => _withinDays = val,
                                      validator: (val) {
                                        if (_selectedDeliveryDate?.trim() ==
                                            'Within') {
                                          if (val == null || val.isEmpty) {
                                            return 'Enter no of days';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                if (_selectedDeliveryDate?.trim() ==
                                        trimmedDate &&
                                    trimmedDate == 'Immediate')
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 32.0, right: 16.0, bottom: 8.0),
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'No of Hours',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      onChanged: (val) => _immediateHours = val,
                                      validator: (val) {
                                        if (_selectedDeliveryDate?.trim() ==
                                            'Immediate') {
                                          if (val == null || val.isEmpty) {
                                            return 'Enter no of hours';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ],
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
