import 'package:flutter/material.dart';
import 'package:steel_buddy/features/screens/create_enquiry_screen.dart';
import 'package:steel_buddy/services/api_service.dart';
import 'package:steel_buddy/features/screens/view_quotations_list.dart';

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  late Future<List<dynamic>> _enquiriesFuture;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 3, vsync: this); // Updated length to 3
    _tabController.addListener(() {
      if (_tabController.index != _selectedTabIndex) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
    _enquiriesFuture = ApiService.getCustomerOrdersForCurrentUser();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: const Color(0xFF757575),
            indicatorColor: Colors.blue,
            tabs: const [
              Tab(text: 'New'),
              Tab(text: 'Finalized'),
              Tab(text: 'Expired'),
            ],
          ),
        ),
        // Add the "Create enquiry" button below the tab bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity, // Full width button
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateEnquiryScreen(),
                  ),
                );
                if (result == true) {
                  setState(() {
                    _enquiriesFuture =
                        ApiService.getCustomerOrdersForCurrentUser();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                '+ Create enquiry',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // Tab Bar View
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // New tab: pending or inprogress
              FutureBuilder<List<dynamic>>(
                future: _enquiriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Data Found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF757575),
                        ),
                      ),
                    );
                  }
                  final orders = snapshot.data!;
                  final newOrders = orders
                      .where((order) =>
                          order['status'] == 'pending' ||
                          order['status'] == 'inprogress')
                      .toList();
                  Widget buildOrderList(List<dynamic> filteredOrders) {
                    if (filteredOrders.isEmpty) {
                      return const Center(
                        child: Text(
                          'No Data Found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF757575),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order =
                            filteredOrders[index] as Map<String, dynamic>;
                        final createdAt = order['created_at'] ?? '';
                        final products =
                            (order['custom_order_products'] ?? []) as List;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 8,
                          shadowColor: Colors.grey.withOpacity(0.5),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ID and Date/Time Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('ID: ${order['id']?.toString() ?? ''}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      createdAt,
                                      style:
                                          TextStyle(color: Color(0xFF757575)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                // Products Table
                                Table(
                                  border:
                                      TableBorder.all(color: Colors.grey[300]!),
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(1.5),
                                    3: FlexColumnWidth(1.5),
                                  },
                                  children: [
                                    TableRow(
                                      decoration:
                                          BoxDecoration(color: Colors.blue),
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text('Products',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white))),
                                        Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text('Brand',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white))),
                                        Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text('Qty (Tons)',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white))),
                                        Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text('Pieces',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white))),
                                      ],
                                    ),
                                    if (products.isEmpty)
                                      TableRow(
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text('No products',
                                                  style: TextStyle(
                                                      color: Colors.grey))),
                                          SizedBox(),
                                          SizedBox(),
                                          SizedBox(),
                                        ],
                                      )
                                    else
                                      ...products.map<TableRow>((product) {
                                        return TableRow(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(
                                                    product['product_type']
                                                            ?.toString() ??
                                                        '')),
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(product['brand']
                                                        ?.toString() ??
                                                    '')),
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(product['quantity']
                                                        ?.toString() ??
                                                    '')),
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(
                                                    product['pieces'] != null
                                                        ? product['pieces']
                                                            .toString()
                                                        : '-')),
                                          ],
                                        );
                                      }).toList(),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // Details Table
                                Table(
                                  border:
                                      TableBorder.all(color: Colors.grey[300]!),
                                  columnWidths: const {
                                    0: FlexColumnWidth(1.5),
                                    1: FlexColumnWidth(2.5),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Payment Terms',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                              order['payment_terms'] ?? ''),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Delivery Terms',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                              order['delivery_terms'] ?? ''),
                                        ),
                                      ],
                                    ),
                                    if (order['delivery_terms'] ==
                                        'Delivered To')
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              'Delivery Address',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                                order['delivery_address'] ??
                                                    ''),
                                          ),
                                        ],
                                      ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Delivery Conditions',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                              order['delivery_conditions'] ??
                                                  ''),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Delivery Date',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                              order['delivery_date'] ?? ''),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Order By',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(order['app_user']
                                                  ?['company_name'] ??
                                              ''),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Status',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            order['status'] == 'cancelled'
                                                ? 'Cancelled'
                                                : 'Expired',
                                            style: TextStyle(
                                              color:
                                                  order['status'] == 'cancelled'
                                                      ? Colors.red
                                                      : Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // View Quotations Button
                                if ((order['dealer_quotations'] ?? [])
                                    .isNotEmpty) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ViewQuotationsList(
                                                    orderId: order['id']),
                                          ),
                                        );
                                        if (result == true) {
                                          setState(() {
                                            _tabController.index =
                                                1; // Switch to Finalized tab
                                            _enquiriesFuture = ApiService
                                                .getCustomerOrdersForCurrentUser();
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green),
                                      child: Text('View Quotations',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ] else ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[300],
                                      ),
                                      child: Text('No Quotations',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                                // Cancel Button
                                if (order['status'] != 'expired' &&
                                    order['status'] != 'cancelled') ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await ApiService.cancelEnquiry(
                                              order['id']);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('Enquiry cancelled')),
                                          );
                                          if (mounted) {
                                            setState(() {
                                              _enquiriesFuture = ApiService
                                                  .getCustomerOrdersForCurrentUser();
                                              _tabController.index =
                                                  2; // Switch to Expired tab
                                            });
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed to cancel enquiry')),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text('Cancel',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return buildOrderList(newOrders);
                },
              ),
              // Finalized tab: done
              FutureBuilder<List<dynamic>>(
                future: _enquiriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Data Found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF757575),
                        ),
                      ),
                    );
                  }
                  final orders = snapshot.data!;
                  final finalizedOrders = orders
                      .where((order) => order['status'] == 'finalized')
                      .toList();
                  Widget buildOrderList(List<dynamic> filteredOrders) {
                    if (filteredOrders.isEmpty) {
                      return const Center(
                        child: Text(
                          'No Data Found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF757575),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order =
                            filteredOrders[index] as Map<String, dynamic>;
                        final createdAt = order['created_at'] ?? '';
                        final products =
                            (order['custom_order_products'] ?? []) as List;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 8,
                          shadowColor: Colors.grey.withOpacity(0.5),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ID and Date/Time Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('ID: ${order['id']?.toString() ?? ''}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      createdAt,
                                      style:
                                          TextStyle(color: Color(0xFF757575)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                // Products Table
                                Table(
                                  border:
                                      TableBorder.all(color: Colors.grey[300]!),
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(1.5),
                                    3: FlexColumnWidth(1.5),
                                  },
                                  children: [
                                    TableRow(
                                      decoration:
                                          BoxDecoration(color: Colors.blue),
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text('Products',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white))),
                                        Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text('Brand',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white))),
                                        Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text('Qty (Tons)',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white))),
                                        Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text('Pieces',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white))),
                                      ],
                                    ),
                                    if (products.isEmpty)
                                      TableRow(
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text('No products',
                                                  style: TextStyle(
                                                      color: Colors.grey))),
                                          SizedBox(),
                                          SizedBox(),
                                          SizedBox(),
                                        ],
                                      )
                                    else
                                      ...products.map<TableRow>((product) {
                                        return TableRow(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(
                                                    product['product_type']
                                                            ?.toString() ??
                                                        '')),
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(product['brand']
                                                        ?.toString() ??
                                                    '')),
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(product['quantity']
                                                        ?.toString() ??
                                                    '')),
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(
                                                    product['pieces'] != null
                                                        ? product['pieces']
                                                            .toString()
                                                        : '-')),
                                          ],
                                        );
                                      }).toList(),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // Details Table
                                Table(
                                  border:
                                      TableBorder.all(color: Colors.grey[300]!),
                                  columnWidths: const {
                                    0: FlexColumnWidth(1.5),
                                    1: FlexColumnWidth(2.5),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Payment Terms',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                              order['payment_terms'] ?? ''),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Delivery Terms',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                              order['delivery_terms'] ?? ''),
                                        ),
                                      ],
                                    ),
                                    if (order['delivery_terms'] ==
                                        'Delivered To')
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              'Delivery Address',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                                order['delivery_address'] ??
                                                    ''),
                                          ),
                                        ],
                                      ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Delivery Conditions',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                              order['delivery_conditions'] ??
                                                  ''),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Delivery Date',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                              order['delivery_date'] ?? ''),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Order By',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(order['app_user']
                                                  ?['company_name'] ??
                                              ''),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Status',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            order['status'] == 'cancelled'
                                                ? 'Cancelled'
                                                : 'Expired',
                                            style: TextStyle(
                                              color:
                                                  order['status'] == 'cancelled'
                                                      ? Colors.red
                                                      : Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // View Quotations Button
                                if ((order['dealer_quotations'] ?? [])
                                    .isNotEmpty) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ViewQuotationsList(
                                                    orderId: order['id']),
                                          ),
                                        );
                                        if (result == true) {
                                          setState(() {
                                            _tabController.index =
                                                1; // Switch to Finalized tab
                                            _enquiriesFuture = ApiService
                                                .getCustomerOrdersForCurrentUser();
                                          });
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green),
                                      child: Text('View Quotations',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ] else ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[300],
                                      ),
                                      child: Text('No Quotations',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                                // Cancel Button
                                if (order['status'] != 'expired' &&
                                    order['status'] != 'cancelled') ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await ApiService.cancelEnquiry(
                                              order['id']);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('Enquiry cancelled')),
                                          );
                                          if (mounted) {
                                            setState(() {
                                              _enquiriesFuture = ApiService
                                                  .getCustomerOrdersForCurrentUser();
                                              _tabController.index =
                                                  2; // Switch to Expired tab
                                            });
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed to cancel enquiry')),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text('Cancel',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return buildOrderList(finalizedOrders);
                },
              ),
              // Expired tab: expired
              FutureBuilder<List<dynamic>>(
                future: _enquiriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Data Found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF757575),
                        ),
                      ),
                    );
                  }
                  final orders = snapshot.data!;
                  final expiredOrders = orders
                      .where((order) =>
                          order['status'] == 'expired' ||
                          order['status'] == 'cancelled')
                      .toList();
                  Widget buildOrderList(List<dynamic> filteredOrders) {
                    if (filteredOrders.isEmpty) {
                      return const Center(
                        child: Text(
                          'No Data Found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF757575),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order =
                            filteredOrders[index] as Map<String, dynamic>;
                        final createdAt = order['created_at'] ?? '';
                        final products =
                            (order['custom_order_products'] ?? []) as List;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 8,
                          shadowColor: Colors.grey.withOpacity(0.5),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ID and Date/Time Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('ID: ${order['id']?.toString() ?? ''}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      createdAt,
                                      style:
                                          TextStyle(color: Color(0xFF757575)),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                // Products Table
                                Table(
                                  border:
                                      TableBorder.all(color: Colors.grey[300]!),
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(1.5),
                                    3: FlexColumnWidth(1.5),
                                  },
                                  children: [
                                    TableRow(
                                      decoration:
                                          BoxDecoration(color: Colors.blue),
                                      children: [
                                        Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text('Products',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white))),
                                        Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text('Brand',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white))),
                                        Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text('Qty (Tons)',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white))),
                                        Padding(
                                            padding: EdgeInsets.all(4),
                                            child: Text('Pieces',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: Colors.white))),
                                      ],
                                    ),
                                    if (products.isEmpty)
                                      TableRow(
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Text('No products',
                                                  style: TextStyle(
                                                      color: Colors.grey))),
                                          SizedBox(),
                                          SizedBox(),
                                          SizedBox(),
                                        ],
                                      )
                                    else
                                      ...products.map<TableRow>((product) {
                                        return TableRow(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(
                                                    product['product_type']
                                                            ?.toString() ??
                                                        '')),
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(product['brand']
                                                        ?.toString() ??
                                                    '')),
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(product['quantity']
                                                        ?.toString() ??
                                                    '')),
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(
                                                    product['pieces'] != null
                                                        ? product['pieces']
                                                            .toString()
                                                        : '-')),
                                          ],
                                        );
                                      }).toList(),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // Details Table
                                Table(
                                  border:
                                      TableBorder.all(color: Colors.grey[300]!),
                                  columnWidths: const {
                                    0: FlexColumnWidth(1.5),
                                    1: FlexColumnWidth(2.5),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Payment Terms',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                              order['payment_terms'] ?? ''),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Delivery Terms',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                              order['delivery_terms'] ?? ''),
                                        ),
                                      ],
                                    ),
                                    if (order['delivery_terms'] ==
                                        'Delivered To')
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              'Delivery Address',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                                order['delivery_address'] ??
                                                    ''),
                                          ),
                                        ],
                                      ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Delivery Conditions',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                              order['delivery_conditions'] ??
                                                  ''),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Delivery Date',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                              order['delivery_date'] ?? ''),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Order By',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(order['app_user']
                                                  ?['company_name'] ??
                                              ''),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            'Status',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            order['status'] == 'cancelled'
                                                ? 'Cancelled'
                                                : 'Expired',
                                            style: TextStyle(
                                              color:
                                                  order['status'] == 'cancelled'
                                                      ? Colors.red
                                                      : Colors.orange,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // View Quotations Button
                                if ((order['dealer_quotations'] ?? [])
                                    .isEmpty) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[300],
                                      ),
                                      child: Text('No Quotations',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                                // Cancel Button
                                if (order['status'] != 'expired' &&
                                    order['status'] != 'cancelled') ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await ApiService.cancelEnquiry(
                                              order['id']);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('Enquiry cancelled')),
                                          );
                                          if (mounted) {
                                            setState(() {
                                              _enquiriesFuture = ApiService
                                                  .getCustomerOrdersForCurrentUser();
                                              _tabController.index =
                                                  2; // Switch to Expired tab
                                            });
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed to cancel enquiry')),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: Text('Cancel',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return buildOrderList(expiredOrders);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
