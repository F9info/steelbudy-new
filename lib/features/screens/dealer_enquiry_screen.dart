import 'package:flutter/material.dart';
import 'package:steel_budy/services/api_service.dart';
import 'package:steel_budy/features/screens/post_quotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steel_budy/features/screens/view_quotation.dart';

class DealerEnquiryScreen extends StatefulWidget {
  const DealerEnquiryScreen({super.key});

  @override
  State<DealerEnquiryScreen> createState() => _DealerEnquiryScreenState();
}

class _DealerEnquiryScreenState extends State<DealerEnquiryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  late Future<List<dynamic>> _enquiriesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _selectedTabIndex) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
    _enquiriesFuture = ApiService.getAllCustomerOrders(); // Replace with actual dealer API if available
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SharedPreferences.getInstance().then((prefs) => prefs.getString('userId')),
      builder: (context, userIdSnapshot) {
        if (!userIdSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final userId = userIdSnapshot.data;
        if (userId == null) {
          return const Center(child: Text('User ID not found. Please log in again.'));
        }
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
                  Tab(text: 'Responded'),
                  Tab(text: 'Finalized'),
                ],
              ),
            ),
            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // New tab: Only show enquiries with NO quotation from this dealer
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
                      final newOrders = orders.where((order) {
                        final dq = (order['dealer_quotations'] ?? []) as List;
                        final hasMyQuotation = dq.any((q) {
                          final qId = q['app_user_id'].toString();
                          final match = qId == userId;
                          return match;
                        });
                        return (order['status'] == 'pending' || order['status'] == 'inprogress') && !hasMyQuotation;
                      }).toList();
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
                            final order = filteredOrders[index] as Map<String, dynamic>;
                            final createdAt = order['created_at'] ?? '';
                            final products = (order['custom_order_products'] ?? []) as List;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 0,
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
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('ID: ${order['id']?.toString() ?? ''}', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(
                                          createdAt,
                                          style: TextStyle(color: Color(0xFF757575)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    // Products Table
                                    Table(
                                      border: TableBorder.all(color: Colors.grey[300]!),
                                      columnWidths: const {
                                        0: FlexColumnWidth(2),
                                        1: FlexColumnWidth(2),
                                        2: FlexColumnWidth(1.5),
                                        3: FlexColumnWidth(1.5),
                                      },
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(color: Colors.grey[200]),
                                          children: [
                                            Padding(padding: EdgeInsets.all(4), child: Text('Products', style: TextStyle(fontWeight: FontWeight.bold))),
                                            Padding(padding: EdgeInsets.all(4), child: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
                                            Padding(padding: EdgeInsets.all(4), child: Text('Qty (Tons)', style: TextStyle(fontWeight: FontWeight.bold))),
                                            Padding(padding: EdgeInsets.all(4), child: Text('Pieces', style: TextStyle(fontWeight: FontWeight.bold))),
                                          ],
                                        ),
                                        if (products.isEmpty)
                                          TableRow(
                                            children: [
                                              Padding(padding: EdgeInsets.all(4), child: Text('No products', style: TextStyle(color: Colors.grey))),
                                              SizedBox(),
                                              SizedBox(),
                                              SizedBox(),
                                            ],
                                          )
                                        else
                                          ...products.map<TableRow>((product) {
                                            return TableRow(
                                              children: [
                                                Padding(padding: EdgeInsets.all(4), child: Text(product['product_type']?.toString() ?? '')),
                                                Padding(padding: EdgeInsets.all(4), child: Text(product['brand']?.toString() ?? '')),
                                                Padding(padding: EdgeInsets.all(4), child: Text(product['quantity']?.toString() ?? '')),
                                                Padding(padding: EdgeInsets.all(4), child: Text(product['pieces'] != null ? product['pieces'].toString() : '-')),
                                              ],
                                            );
                                          }).toList(),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    // Other fields
                                    Text('Payment Terms: ${order['payment_terms'] ?? ''}'),
                                    SizedBox(height: 10),
                                    Text('Delivery Terms: ${order['delivery_terms'] ?? ''}'),
                                    SizedBox(height: 10),
                                    if (order['delivery_terms'] == 'Delivered To') ...[
                                      Text('Delivery Address: ${order['delivery_address'] ?? ''}'),
                                      SizedBox(height: 10),
                                    ],
                                    Text('Delivery Conditions: ${order['delivery_conditions'] ?? ''}'),
                                    SizedBox(height: 10),
                                    Text('Delivery Date: ${order['delivery_date'] ?? ''}'),
                                    SizedBox(height: 10),
                                    Text('Order By: ${order['app_user']?['company_name'] ?? ''}'),
                                    SizedBox(height: 10),
                                    // Post Quotation Button (only in New tab)
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PostQuotation(orderId: order['id']),
                                            ),
                                          );
                                          if (result == true) {
                                            setState(() {
                                              _enquiriesFuture = ApiService.getAllCustomerOrders();
                                              _tabController.index = 1; // Switch to Responded tab
                                            });
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                        ),
                                        child: Text('Post Quotation', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
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
                  // Responded tab: Only show enquiries where this dealer has a quotation with status pending/responded
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
                      final respondedOrders = orders.where((order) {
                        final dq = (order['dealer_quotations'] ?? []) as List;
                        // Only show if this dealer has a quotation with status pending or responded
                        return dq.any((q) => q['app_user_id'].toString() == userId && (q['status'] == 'pending' || q['status'] == 'responded'));
                      }).toList();
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
                            final order = filteredOrders[index] as Map<String, dynamic>;
                            final createdAt = order['created_at'] ?? '';
                            final products = (order['custom_order_products'] ?? []) as List;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[200]!),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('ID: ${order['id']?.toString() ?? ''}', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(
                                          createdAt,
                                          style: TextStyle(color: Color(0xFF757575)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Table(
                                      border: TableBorder.all(color: Colors.grey[300]!),
                                      columnWidths: const {
                                        0: FlexColumnWidth(2),
                                        1: FlexColumnWidth(2),
                                        2: FlexColumnWidth(1.5),
                                        3: FlexColumnWidth(1.5),
                                      },
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(color: Colors.grey[200]),
                                          children: [
                                            Padding(padding: EdgeInsets.all(4), child: Text('Products', style: TextStyle(fontWeight: FontWeight.bold))),
                                            Padding(padding: EdgeInsets.all(4), child: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
                                            Padding(padding: EdgeInsets.all(4), child: Text('Qty (Tons)', style: TextStyle(fontWeight: FontWeight.bold))),
                                            Padding(padding: EdgeInsets.all(4), child: Text('Pieces', style: TextStyle(fontWeight: FontWeight.bold))),
                                          ],
                                        ),
                                        if (products.isEmpty)
                                          TableRow(
                                            children: [
                                              Padding(padding: EdgeInsets.all(4), child: Text('No products', style: TextStyle(color: Colors.grey))),
                                              SizedBox(),
                                              SizedBox(),
                                              SizedBox(),
                                            ],
                                          )
                                        else
                                          ...products.map<TableRow>((product) {
                                            return TableRow(
                                              children: [
                                                Padding(padding: EdgeInsets.all(4), child: Text(product['product_type']?.toString() ?? '')),
                                                Padding(padding: EdgeInsets.all(4), child: Text(product['brand']?.toString() ?? '')),
                                                Padding(padding: EdgeInsets.all(4), child: Text(product['quantity']?.toString() ?? '')),
                                                Padding(padding: EdgeInsets.all(4), child: Text(product['pieces'] != null ? product['pieces'].toString() : '-')),
                                              ],
                                            );
                                          }).toList(),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Text('Payment Terms: ${order['payment_terms'] ?? ''}'),
                                    SizedBox(height: 10),
                                    Text('Delivery Terms: ${order['delivery_terms'] ?? ''}'),
                                    SizedBox(height: 10),
                                    if (order['delivery_terms'] == 'Delivered To') ...[
                                      Text('Delivery Address: ${order['delivery_address'] ?? ''}'),
                                      SizedBox(height: 10),
                                    ],
                                    Text('Delivery Conditions: ${order['delivery_conditions'] ?? ''}'),
                                    SizedBox(height: 10),
                                    Text('Delivery Date: ${order['delivery_date'] ?? ''}'),
                                    SizedBox(height: 10),
                                    Text('Order By: ${order['app_user']?['company_name'] ?? ''}'),
                                    SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewQuotation(orderId: order['id']),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        child: const Text('View My Quotation', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return buildOrderList(respondedOrders);
                    },
                  ),
                  // Finalized tab: Only show enquiries where this dealer has a quotation with status finalized/done
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
                      final finalizedOrders = orders.where((order) {
                        final dq = (order['dealer_quotations'] ?? []) as List;
                        // Only show if this dealer has a quotation with status finalized or done
                        return dq.any((q) => q['app_user_id'].toString() == userId && (q['status'] == 'finalized' || q['status'] == 'done'));
                      }).toList();
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
                            final order = filteredOrders[index] as Map<String, dynamic>;
                            final createdAt = order['created_at'] ?? '';
                            final products = (order['custom_order_products'] ?? []) as List;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.grey[200]!),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('ID: ${order['id']?.toString() ?? ''}', style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(
                                          createdAt,
                                          style: TextStyle(color: Color(0xFF757575)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Table(
                                      border: TableBorder.all(color: Colors.grey[300]!),
                                      columnWidths: const {
                                        0: FlexColumnWidth(2),
                                        1: FlexColumnWidth(2),
                                        2: FlexColumnWidth(1.5),
                                        3: FlexColumnWidth(1.5),
                                      },
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(color: Colors.grey[200]),
                                          children: [
                                            Padding(padding: EdgeInsets.all(4), child: Text('Products', style: TextStyle(fontWeight: FontWeight.bold))),
                                            Padding(padding: EdgeInsets.all(4), child: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
                                            Padding(padding: EdgeInsets.all(4), child: Text('Qty (Tons)', style: TextStyle(fontWeight: FontWeight.bold))),
                                            Padding(padding: EdgeInsets.all(4), child: Text('Pieces', style: TextStyle(fontWeight: FontWeight.bold))),
                                          ],
                                        ),
                                        if (products.isEmpty)
                                          TableRow(
                                            children: [
                                              Padding(padding: EdgeInsets.all(4), child: Text('No products', style: TextStyle(color: Colors.grey))),
                                              SizedBox(),
                                              SizedBox(),
                                              SizedBox(),
                                            ],
                                          )
                                        else
                                          ...products.map<TableRow>((product) {
                                            return TableRow(
                                              children: [
                                                Padding(padding: EdgeInsets.all(4), child: Text(product['product_type']?.toString() ?? '')),
                                                Padding(padding: EdgeInsets.all(4), child: Text(product['brand']?.toString() ?? '')),
                                                Padding(padding: EdgeInsets.all(4), child: Text(product['quantity']?.toString() ?? '')),
                                                Padding(padding: EdgeInsets.all(4), child: Text(product['pieces'] != null ? product['pieces'].toString() : '-')),
                                              ],
                                            );
                                          }).toList(),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Text('Payment Terms: ${order['payment_terms'] ?? ''}'),
                                    SizedBox(height: 10),
                                    Text('Delivery Terms: ${order['delivery_terms'] ?? ''}'),
                                    SizedBox(height: 10),
                                    Text('Delivery Conditions: ${order['delivery_conditions'] ?? ''}'),
                                    SizedBox(height: 10),
                                    Text('Delivery Date: ${order['delivery_date'] ?? ''}'),
                                    SizedBox(height: 10),
                                    Text('Order By: ${order['app_user']?['company_name'] ?? ''}'),
                                    SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ViewQuotation(orderId: order['id']),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                        child: const Text('View My Quotation', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
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
                ],
              ),
            ),
          ],
        );
      },
    );
  }
} 