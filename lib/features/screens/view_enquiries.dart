import 'package:flutter/material.dart';

class ViewEnquiries extends StatelessWidget {
  const ViewEnquiries({super.key});

  // Dummy enquiry data
  static const List<Map<String, dynamic>> _enquiries = [
    {
      'id': 'SDpOTU',
      'dateTime': '16:48, 21 May 2025',
      'products': [
        {'name': '10MM Rebar', 'brand': 'Simhadri TMT', 'quantity': 10},
        {'name': '16MM Rebar', 'brand': 'Simhadri TMT', 'quantity': 0},
        {'name': '20MM Rebar', 'brand': 'Vizag Steel', 'quantity': 0},
      ],
      'paymentTerms': 'Advance Against Delivery',
      'deliveryTerms': 'Self-Pickup EX-Visakhapatnam',
      'deliveryConditions': 'Straight',
      'deliveryDate': 'Immediate 20 hrs',
      'orderBy': 'Deepthi',
      'status': 'Finished',
    },
    {
      'id': 'ENQ002',
      'dateTime': '09:15, 22 May 2025',
      'products': [
        {'name': '12MM Rebar', 'brand': 'Vizag Steel', 'quantity': 15},
        {'name': '18MM Rebar', 'brand': 'Simhadri TMT', 'quantity': 5},
        {'name': '25MM Rebar', 'brand': 'Vizag Steel', 'quantity': 0},
      ],
      'paymentTerms': 'Cash on Delivery',
      'deliveryTerms': 'Delivery to Hyderabad',
      'deliveryConditions': 'Bundled',
      'deliveryDate': '24 hrs',
      'orderBy': 'Ravi',
      'status': 'Finished',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Enquiries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _enquiries.map((enquiry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID and DateTime
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ID: ${enquiry['id']}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          enquiry['dateTime'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Table
                    Table(
                      border: TableBorder.all(color: Colors.grey[300]!),
                      columnWidths: const {
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(2),
                        2: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Products',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Brand',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Qty (Tons)',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        ...enquiry['products'].map<TableRow>((product) {
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(product['name']),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(product['brand']),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(product['quantity'].toString()),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Details
                    _buildDetailRow('Payment Terms:', enquiry['paymentTerms']),
                    const SizedBox(height: 8),
                    _buildDetailRow('Delivery Terms:', enquiry['deliveryTerms']),
                    const SizedBox(height: 8),
                    _buildDetailRow('Delivery Conditions:', enquiry['deliveryConditions']),
                    const SizedBox(height: 8),
                    _buildDetailRow('Delivery Date:', enquiry['deliveryDate']),
                    const SizedBox(height: 8),
                    _buildDetailRow('Order By:', enquiry['orderBy']),
                    const SizedBox(height: 16),

                    // Status Button
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          enquiry['status'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}