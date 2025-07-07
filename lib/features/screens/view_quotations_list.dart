import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:steel_buddy/services/api_service.dart';

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
          if (displayQuotations.isEmpty) {
            return Center(child: Text('No quotations found.'));
          }
          return ListView.builder(
            itemCount: displayQuotations.length,
            itemBuilder: (context, index) {
              final q = displayQuotations[index];
              double totalMaterial = 0.0;
              final products =
                  q['dealer_quotation_products'] as List<dynamic>? ?? [];
              final productRows = products.map<DataRow>((p) {
                double rowTotal = 0.0;
                final cost = (p['cost'] as num?)?.toDouble() ?? 0.0;
                if (p['pieces'] != null) {
                  rowTotal = cost;
                } else {
                  final qty = (p['quantity'] as num?)?.toDouble() ?? 0.0;
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
                elevation:
                    8, // Increased for a smoother, more noticeable shadow
                shadowColor: Colors.grey.withOpacity(0.5), // Soft grey shadow
                color: Colors.white, // Transparent background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!), // Grey outline
                ),
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
                            DataColumn(
                                label: Text(
                              'Brand',
                              style: TextStyle(color: Colors.white),
                            )),
                            DataColumn(
                                label: Text(
                              'Qty (Tons)',
                              style: TextStyle(color: Colors.white),
                            )),
                            DataColumn(
                                label: Text(
                              'Pieces',
                              style: TextStyle(color: Colors.white),
                            )),
                            DataColumn(
                                label: Text(
                              'Cost',
                              style: TextStyle(color: Colors.white),
                            )),
                            DataColumn(
                                label: Text(
                              'Total',
                              style: TextStyle(color: Colors.white),
                            )),
                          ],
                          rows: productRows,
                        ),
                      ),
                      SizedBox(height: 12),
                      // Charges and Terms
                      Table(
                        border:
                            TableBorder.all(color: Colors.grey[300]!, width: 1),
                        columnWidths: {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(3),
                        },
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Bending Charges',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('₹${q['bending_charges'] ?? '-'}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Transport Charges',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child:
                                    Text('₹${q['transport_charges'] ?? '-'}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Payment Terms',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                    '${q['payment_terms'] ?? order['payment_terms'] ?? '-'}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Delivery Terms',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                    '${q['delivery_terms'] ?? order['delivery_terms'] ?? '-'}'),
                              ),
                            ],
                          ),
                          if ((q['delivery_terms'] ??
                                  order['delivery_terms']) ==
                              'Delivered To')
                            TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Delivery Address',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                      '${q['delivery_address'] ?? order['delivery_address'] ?? '-'}'),
                                ),
                              ],
                            ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Delivery Condition',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                    '${q['delivery_conditions'] ?? order['delivery_conditions'] ?? '-'}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Delivery Date',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                    '${q['delivery_date'] ?? order['delivery_date'] ?? '-'}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Total Material Rs',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                    '₹${totalMaterial.toStringAsFixed(2)}'),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('GST 18%',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('₹${q['gst_amount'] ?? '-'}'),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                              child: Text(
                                'Call',
                                style: TextStyle(color: Colors.white),
                              ),
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
                                child: Text(
                                  'Finalize',
                                  style: TextStyle(color: Colors.white),
                                ),
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
