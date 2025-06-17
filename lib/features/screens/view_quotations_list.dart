import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:steel_budy/services/api_service.dart';

class ViewQuotationsList extends StatefulWidget {
  final int orderId;
  const ViewQuotationsList({Key? key, required this.orderId}) : super(key: key);

  @override
  State<ViewQuotationsList> createState() => _ViewQuotationsListState();
}

class _ViewQuotationsListState extends State<ViewQuotationsList> {
  late Future<Map<String, dynamic>> _orderFuture;
  bool _finalizing = false;

  @override
  void initState() {
    super.initState();
    _orderFuture = ApiService().fetchCustomerOrderDetails(widget.orderId);
  }

  void _callDealer(String? mobile) async {
    if (mobile == null || mobile.isEmpty) return;
    final uri = Uri.parse('tel:$mobile');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _finalizeQuotation(int quotationId) async {
    setState(() {
      _finalizing = true;
    });
    try {
      await ApiService.finalizeQuotation(widget.orderId, quotationId);
      if (mounted) {
        Navigator.pop(context,
            true); // Pop with result to trigger parent refresh and tab switch
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to finalize quotation')),
      );
    } finally {
      if (mounted)
        setState(() {
          _finalizing = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quotations')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          final order = snapshot.data!['customerOrder'];
          final quotations = order['dealer_quotations'] as List<dynamic>;
          final isFinalized =
              (order['status'] == 'done' || order['status'] == 'finalized');
          List<dynamic> displayQuotations = quotations;
          if (isFinalized) {
            // Only show the finalized quotation
            displayQuotations = quotations
                .where(
                    (q) => q['status'] == 'finalized' || q['status'] == 'done')
                .toList();
          }
          if (displayQuotations.isEmpty)
            return Center(child: Text('No quotations found.'));
          return ListView.builder(
            itemCount: displayQuotations.length,
            itemBuilder: (context, index) {
              final q = displayQuotations[index];
              var totalMaterial = 0;
              final products =
                  q['dealer_quotation_products'] as List<dynamic>? ?? [];
              final productRows = products.map<DataRow>((p) {
                var rowTotal = 0;
                final cost = p['cost'] ?? 0;
                if (p['pieces'] != null) {
                  rowTotal = cost;
                } else {
                  final qty = p['quantity'] ?? 0;
                  rowTotal = qty * cost;
                }
                totalMaterial += rowTotal;
                return DataRow(
                  cells: [
                    DataCell(Text('${p['product_type'] ?? '-'}')),
                    DataCell(Text('${p['brand'] ?? '-'}')),
                    DataCell(Text('${p['quantity'] ?? '0'}')),
                    DataCell(Text('${p['pieces'] ?? '-'}')),
                    DataCell(Text('₹${p['cost'] ?? '-'}')),
                    DataCell(Text('₹${rowTotal.toStringAsFixed(2)}')),
                  ],
                );
              }).toList();
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dealer/Company Name
                      Text(
                        q['company_name'] ?? '-',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 4),
                      // Date/ID Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            q['created_at'] != null
                                ? q['created_at'].toString()
                                : '',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                          Text(
                            'ID: ${q['quotation_code'] ?? q['id'] ?? ''}',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Products Table
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Colors.blue),
                          columns: const [
                            DataColumn(
                                label: Text(
                              'Item',
                              style: TextStyle(color: Colors.white),
                            )),
                            DataColumn(label: Text('Brand')),
                            DataColumn(label: Text('Qty (Tons)')),
                            DataColumn(label: Text('Pieces')),
                            DataColumn(label: Text('Cost')),
                            DataColumn(label: Text('Total')),
                          ],
                          rows: productRows,
                        ),
                      ),
                      SizedBox(height: 12),
                      // Charges and Terms
                      Text('Bending Charges: ₹${q['bending_charges'] ?? '-'}'),
                      Text(
                          'Transport Charges: ₹${q['transport_charges'] ?? '-'}'),
                      Text(
                          'Payment Terms:    ${q['payment_terms'] ?? order['payment_terms'] ?? '-'}'),
                      Text(
                          'Delivery Terms: ${q['delivery_terms'] ?? order['delivery_terms'] ?? '-'}'),
                      if ((q['delivery_terms'] ?? order['delivery_terms']) ==
                          'Delivered To')
                        Text(
                            'Delivery Address: ${q['delivery_address'] ?? order['delivery_address'] ?? '-'}'),
                      Text(
                          'Delivery Condition: ${q['delivery_conditions'] ?? order['delivery_conditions'] ?? '-'}'),
                      Text(
                          'Delivery Date: ${q['delivery_date'] ?? order['delivery_date'] ?? '-'}'),
                      SizedBox(height: 8),
                      // Totals
                      Text(
                          'Total Material Rs: ₹${totalMaterial.toStringAsFixed(2)}'),
                      Text('GST 18%: ₹${q['gst_amount'] ?? '-'}'),
                      SizedBox(height: 4),
                      Text(
                        'Grand Total (GST included): ₹${q['total_amount'] ?? 0}',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 12),
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _callDealer(q['mobile']),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: Text('Call'),
                            ),
                          ),
                          if (!isFinalized) ...[
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _finalizing
                                    ? null
                                    : () => _finalizeQuotation(q['id']),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue),
                                child: Text('Finalize'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
