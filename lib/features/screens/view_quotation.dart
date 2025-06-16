import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steel_budy/services/api_service.dart';

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
          final dqProducts = myQuotation['dealer_quotation_products'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order ID: ${order['id']}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('Company: ${order['app_user']?['company_name'] ?? ''}'),
                const SizedBox(height: 16),
                Text('Products:', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                      return Colors.blue; // Blue background for header
                    }),
                    headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                                ? DataCell(Text('₹${(p['cost']).toStringAsFixed(2)}'))
                                : p['quantity'] != null
                                    ? DataCell(Text('₹${(p['quantity'] * p['cost']).toStringAsFixed(2)}'))
                                    :
                            DataCell(Text('₹${p['cost'] ?? '-'}')),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bending Charges: ₹${myQuotation['bending_charges'] ?? '-'}'),
                        Text('Transportation Charges: ₹${myQuotation['transport_charges'] ?? '-'}'),
                        Text('GST Amount: ₹${myQuotation['gst_amount'] ?? '-'}'),
                        Text('Total Quotation: ₹${myQuotation['total_amount'] ?? '-'}'),
                        Text('Status: ${myQuotation['status'] ?? '-'}'),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Details:', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Text.rich(TextSpan(children: [TextSpan(text: 'Payment Terms: ', style: const TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: '${order['payment_terms'] ?? '-'}')])),
                        Text.rich(TextSpan(children: [TextSpan(text: 'Delivery Terms: ', style: const TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: '${order['delivery_terms'] ?? '-'}')])),
                        
                        if(order['delivery_terms'] == 'Delivered To')
                          Text.rich(TextSpan(children: [TextSpan(text: 'Delivery Address: ', style: const TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: '${order['delivery_address'] ?? '-'}')])),

                        Text.rich(TextSpan(children: [TextSpan(text: 'Delivery Conditions: ', style: const TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: '${order['delivery_conditions'] ?? '-'}')])),
                        Text.rich(TextSpan(children: [TextSpan(text: 'Delivery Date: ', style: const TextStyle(fontWeight: FontWeight.bold)), TextSpan(text: '${order['delivery_date'] ?? '-'}')])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 