import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steel_buddy/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewQuotation extends StatefulWidget {
  final int orderId;
  const ViewQuotation({Key? key, required this.orderId}) : super(key: key);

  @override
  State<ViewQuotation> createState() => _ViewQuotationState();
}

class _ViewQuotationState extends State<ViewQuotation> {
  late Future<Map<String, dynamic>> _orderFuture;
  String? userId;

  @override
  void initState() {
    super.initState();
    _orderFuture = ApiService().fetchCustomerOrderDetails(widget.orderId);
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Quotation')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData || userId == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final order = data['customerOrder'];
          final products = data['products'] as List<dynamic>;
          final dealerQuotations = order['dealer_quotations'] as List<dynamic>;
          final myQuotation = dealerQuotations.firstWhere(
            (q) => q['app_user_id'].toString() == userId,
            orElse: () => null,
          );
          if (myQuotation == null) {
            return const Center(child: Text('No quotation found for you.'));
          }
          final dqProducts =
              myQuotation['dealer_quotation_products'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        'Company: ${order['app_user']?['company_name'] ?? ''}'),
                    Text(
                      'Order ID: ${order['id']}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Products:',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    border: TableBorder(
                      top: BorderSide(width: 1, color: Colors.grey),
                      bottom: BorderSide(width: 1, color: Colors.grey),
                      left: BorderSide(width: 1, color: Colors.grey),
                      right: BorderSide(width: 1, color: Colors.grey),
                      horizontalInside:
                          BorderSide(width: 1, color: Colors.grey),
                      verticalInside: BorderSide(width: 1, color: Colors.grey),
                    ),
                    headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return Colors.blue; // Blue background for header
                      },
                    ),
                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    columns: const [
                      DataColumn(label: Text('S.No')),
                      DataColumn(label: Text('Product Type')),
                      DataColumn(label: Text('Brand')),
                      DataColumn(label: Text('Quantity')),
                      DataColumn(label: Text('Pieces')),
                      DataColumn(label: Text('Cost')),
                      DataColumn(label: Text('Total')),
                    ],
                    rows: List<DataRow>.generate(
                      dqProducts.length,
                      (index) {
                        final p = dqProducts[index];
                        return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text('${p['product_type'] ?? '-'}')),
                            DataCell(Text('${p['brand'] ?? '-'}')),
                            DataCell(Text('${p['quantity'] ?? '-'}')),
                            DataCell(Text('${p['pieces'] ?? '-'}')),
                            DataCell(Text('₹${p['cost'] ?? '-'}')),
                            p['pieces'] != null
                                ? DataCell(
                                    Text('₹${(p['cost']).toStringAsFixed(2)}'))
                                : p['quantity'] != null
                                    ? DataCell(Text(
                                        '₹${(p['quantity'] * p['cost']).toStringAsFixed(2)}'))
                                    : DataCell(Text('₹${p['cost'] ?? '-'}')),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Table(
                      border: TableBorder.all(
                          color: const Color.fromARGB(255, 205, 205, 205),
                          width: 1.0), // Adds border to the table
                      columnWidths: const {
                        0: FlexColumnWidth(3), // Title column
                        1: FlexColumnWidth(2), // Value column
                      },
                      children: [
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Text(
                                'Bending Charges',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Text(
                                '₹${myQuotation['bending_charges'] ?? '-'}',
                                textAlign:
                                    TextAlign.right, // Right-align the value
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Text(
                                'Transportation Charges',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Text(
                                '₹${myQuotation['transport_charges'] ?? '-'}',
                                textAlign:
                                    TextAlign.right, // Right-align the value
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Text(
                                'GST Amount',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Text(
                                '₹${myQuotation['gst_amount'] ?? '-'}',
                                textAlign:
                                    TextAlign.right, // Right-align the value
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Text(
                                'Total Quotation',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Text(
                                '₹${myQuotation['total_amount'] ?? '-'}',
                                textAlign:
                                    TextAlign.right, // Right-align the value
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Text(
                                'Status',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                              child: Text(
                                '${myQuotation['status'] ?? '-'}',
                                textAlign:
                                    TextAlign.right, // Right-align the value
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                SizedBox(height: 24),
                Text(
                  'Order Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Blue color for the title
                  ),
                ),
                SizedBox(height: 4),
                Table(
                  border: TableBorder.all(
                      color: Colors.grey,
                      width: 1.0), // Adds border to the table
                  columnWidths: const {
                    0: FlexColumnWidth(3), // Title column
                    1: FlexColumnWidth(2), // Value column
                  },
                  children: [
                    // Payment Terms row
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Text(
                            'Payment Terms',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Text(
                            '${order['payment_terms'] ?? '-'}',
                            textAlign: TextAlign.right, // Right-align the value
                          ),
                        ),
                      ],
                    ),
                    // Delivery Terms row
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Text(
                            'Delivery Terms',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Text(
                            '${order['delivery_terms'] ?? '-'}',
                            textAlign: TextAlign.right, // Right-align the value
                          ),
                        ),
                      ],
                    ),
                    // Delivery Conditions row
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Text(
                            'Delivery Conditions',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Text(
                            '${order['delivery_conditions'] ?? '-'}',
                            textAlign: TextAlign.right, // Right-align the value
                          ),
                        ),
                      ],
                    ),
                    // Delivery Date row
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Text(
                            'Delivery Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Text(
                            '${order['delivery_date'] ?? '-'}',
                            textAlign: TextAlign.right, // Right-align the value
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if ((myQuotation['status'] ?? '').toString().toLowerCase() ==
                    'finalized')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _callCustomer(order['app_user']?['mobile']),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Call Customer',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _callCustomer(String? mobile) async {
    if (mobile == null || mobile.isEmpty) return;
    final uri = Uri.parse('tel:$mobile');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
