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

  @override
  void initState() {
    super.initState();
    _quotationDetailsFuture = ApiService().fetchCustomerOrderDetails(widget.orderId);
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
                    headingRowColor: MaterialStateColor.resolveWith((states) => Colors.grey.shade200),
                    columns: const [
                      DataColumn(label: Text('S.No')),
                      DataColumn(label: Text('Product Type')),
                      DataColumn(label: Text('Brand')),
                      DataColumn(label: Text('Quantity')),
                    ],
                    rows: products.asMap().entries.map((entry) {
                      int index = entry.key + 1;
                      final product = entry.value;

                      final quantity = product['quantity'];
                      final pieces = product['pieces'];
                      final displayQty = quantity != null
                          ? "$quantity (Qty)"
                          : pieces != null
                              ? "$pieces (Pieces)"
                              : "N/A";

                      return DataRow(cells: [
                        DataCell(Text('$index')),
                        DataCell(Text(product['product_type']['name'] ?? '')),
                        DataCell(Text(product['brand']['name'] ?? '')),
                        DataCell(Text(displayQty)),
                      ]);
                    }).toList(),
                  ),
                ),
                const Divider(height: 30),

                // User Details Section
                const Text(
                  "User Details:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Company: ${order['app_user']['company_name'] ?? 'Unknown'}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text("Contact Person: ${order['app_user']['contact_person'] ?? 'N/A'}"),
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
                          width: 150, // Fixed width for labels
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
              ],
            ),
          );
        },
      ),
    );
  }
}