import 'package:flutter/material.dart';
import 'package:steel_budy/services/api_service.dart';
import 'package:steel_budy/features/screens/quotation_details.dart';

class QuotationScreen extends StatefulWidget {
  const QuotationScreen({super.key});

  @override
  _QuotationScreenState createState() => _QuotationScreenState();
}

class _QuotationScreenState extends State<QuotationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<dynamic>> _customerOrdersFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _customerOrdersFuture = ApiService().fetchCustomerOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(),
                _buildOrderList(),
                _buildOrderList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return FutureBuilder<List<dynamic>>(
      future: _customerOrdersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Log error for debugging
          print('Error fetching orders: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('No data received from API');
          return const Center(child: Text('No orders found'));
        }

        // Log raw data for debugging
        print('Raw API data: ${snapshot.data}');

        final customerOrders = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: customerOrders.length,
          itemBuilder: (context, index) {
            final order = customerOrders[index] as Map<String, dynamic>;
            // Safely access nested app_user data with fallback
            final appUser = order['app_user'] as Map<String, dynamic>? ?? {};
            return Card(
              elevation: 4.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company: ${appUser['company_name'] ?? 'Unknown'}',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Delivery Terms: ${order['delivery_terms'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Payment Terms: ${order['payment_terms'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16.0),
                    ),
                    const SizedBox(height: 12.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuotationDetailsScreen(orderId: order['id']),
                              ),
                            );
                          },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Post Quotation',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
