// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:steel_budy/services/api_service.dart';

class QuotationDetailsScreen extends StatefulWidget {
  final int orderId;

  const QuotationDetailsScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<QuotationDetailsScreen> createState() => _QuotationDetailsScreenState();
}

class _QuotationDetailsScreenState extends State<QuotationDetailsScreen> {
  late Future<Map<String, dynamic>> _quotationDetailsFuture;
  final TextEditingController _bendingChargesController = TextEditingController();
  final TextEditingController _transportationChargesController = TextEditingController();
  List<TextEditingController> _costControllers = [];
  double _bendingCharges = 0.0;
  double _transportationCharges = 0.0;

  @override
  void initState() {
    super.initState();
    _quotationDetailsFuture = ApiService().fetchCustomerOrderDetails(widget.orderId);
    _bendingChargesController.addListener(_updateCharges);
    _transportationChargesController.addListener(_updateCharges);
  }

  void _updateCharges() {
    setState(() {
      _bendingCharges = double.tryParse(_bendingChargesController.text) ?? 0.0;
      _transportationCharges = double.tryParse(_transportationChargesController.text) ?? 0.0;
    });
  }

  Future<void> _postQuotation(BuildContext context, List<dynamic> products) async {
    try {
      // Calculate total product price and prepare product data
      double totalProductPrice = 0.0;
      List<Map<String, dynamic>> productData = [];
      for (int i = 0; i < products.length; i++) {
        final product = products[i];
        final quantity = product['quantity'];
        final pieces = product['pieces'];
        final cost = double.tryParse(_costControllers[i].text) ?? 0.0;
        double price = 0.0;
        if (quantity != null) {
          price = quantity * cost;
          totalProductPrice += price;
        } else if (pieces != null) {
          price = cost; // Cost * 1 for pieces
          totalProductPrice += price;
        }
        productData.add({
          'product_type_id': product['product_type']['id'] ?? 0, // Use ID for backend
          'brand_id': product['brand']['id'] ?? 0, // Use ID for backend
          'quantity': quantity,
          'pieces': pieces,
          'cost': cost,
        });
      }

      // Calculate taxable amount and GST
      final double taxableAmount = totalProductPrice + _bendingCharges + _transportationCharges;
      final double gstAmount = taxableAmount * 0.18;
      final double totalAmount = taxableAmount + gstAmount;

      // Prepare payload
      final Map<String, dynamic> payload = {
        'custom_order_id': widget.orderId,
        'app_user_id': 1, // Replace with actual user ID from auth system
        'products': productData,
        'bending_charges': _bendingCharges,
        'transport_charges': _transportationCharges,
        'total_amount': totalAmount,
        'gst_amount': gstAmount,
      };

      // Call API to post quotation
      await ApiService().postQuotation(payload);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quotation posted successfully!')),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post quotation: $e')),
      );
    }
  }

  @override
  void dispose() {
    _bendingChargesController.dispose();
    _transportationChargesController.dispose();
    for (var controller in _costControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotation Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _quotationDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }

          final details = snapshot.data!;
          final order = details['customerOrder'];
          final products = details['products'] as List<dynamic>;

          // Initialize cost controllers if not already done
          if (_costControllers.length != products.length) {
            _costControllers = List.generate(
              products.length,
              (index) => TextEditingController()..addListener(() => setState(() {})),
            );
          }

          // Calculate total product price using user-entered costs
          double totalProductPrice = 0.0;
          for (int i = 0; i < products.length; i++) {
            final product = products[i];
            final quantity = product['quantity'];
            final pieces = product['pieces'];
            final cost = double.tryParse(_costControllers[i].text) ?? 0.0;
            if (quantity != null) {
              totalProductPrice += quantity * cost;
            } else if (pieces != null) {
              totalProductPrice += cost; // Cost * 1 for pieces
            }
          }

          // Calculate taxable amount and GST
          final double taxableAmount = totalProductPrice + _bendingCharges + _transportationCharges;
          final double gstAmount = taxableAmount * 0.18;
          final double totalAmount = taxableAmount + gstAmount;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Products Section
                const Text(
                  "Products:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue),
                    dataRowHeight: 60, // Increased height for better spacing
                    columnSpacing: 16, // Space between columns
                    rows: products.asMap().entries.map((entry) {
                      int index = entry.key + 1;
                      final product = entry.value;
                      final controller = _costControllers[entry.key];

                      final quantity = product['quantity'];
                      final pieces = product['pieces'];
                      final cost = double.tryParse(controller.text) ?? 0.0;
                      final displayQty = quantity != null
                          ? "$quantity (Qty)"
                          : pieces != null
                              ? "$pieces (Pieces)"
                              : "N/A";
                      final price = quantity != null ? quantity * cost : (pieces != null ? cost : 0.0);

                      return DataRow(
                        cells: [
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('$index'),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(product['product_type']['name'] ?? ''),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(product['brand']['name'] ?? ''),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(displayQty),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: SizedBox(
                                width: 100,
                                child: TextFormField(
                                  controller: controller,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter cost',
                                    border: OutlineInputBorder(),
                                    prefixText: '₹ ',
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text('₹${price.toStringAsFixed(2)}'),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    columns: const [
                      DataColumn(label: Text('S.No')),
                      DataColumn(label: Text('Product Type')),
                      DataColumn(label: Text('Brand')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Cost')),
                      DataColumn(label: Text('Price')),
                    ],
                  ),
                ),
                const Divider(height: 30),

                // Charges Section
                const Text(
                  "Additional Charges:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 150,
                      child: Text(
                        "Bending Charges:",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _bendingChargesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter bending charges',
                          border: OutlineInputBorder(),
                          prefixText: '₹ ',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 150,
                      child: Text(
                        "Transportation Charges:",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _transportationChargesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter transportation charges',
                          border: OutlineInputBorder(),
                          prefixText: '₹ ',
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),

                // Order Details Section
                const Text(
                  "Order Details:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 150,
                          child: Text(
                            "Payment Terms:",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text(order['payment_terms'] ?? 'N/A'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 150,
                          child: Text(
                            "Delivery Terms:",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text(order['delivery_terms'] ?? 'N/A'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 150,
                          child: Text(
                            "Delivery Conditions:",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text(order['delivery_conditions'] ?? 'N/A'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 150,
                          child: Text(
                            "Delivery Date:",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text("${order['delivery_date_days'] ?? 'N/A'} day(s)"),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 30),

                // Total Calculation Section
                const Text(
                  "Total Calculation:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 150,
                          child: Text(
                            "Subtotal:",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text('₹${totalProductPrice.toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(
                          width: 150,
                          child: Text(
                            "Bending Charges:",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text('₹${_bendingCharges.toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(
                          width: 150,
                          child: Text(
                            "Transportation Charges:",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text('₹${_transportationCharges.toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                   
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(
                          width: 150,
                          child: Text(
                            "GST (18%):",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text('₹${gstAmount.toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const SizedBox(
                          width: 150,
                          child: Text(
                            "Total Amount:",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '₹${totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // Fetch products from the snapshot to pass to _postQuotation
                        final snapshot = await _quotationDetailsFuture;
                        _postQuotation(context, snapshot['products'] as List<dynamic>);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Matches table header color
                        minimumSize: const Size(double.infinity, 50), // Full-width button
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Post Quotation'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}