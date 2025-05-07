// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../widgets/mainappbar.dart';
import '../widgets/mainbottombar.dart';
import '../widgets/searchfilters.dart';
import 'enquiry.dart';
import '../../../data/productlist.dart';
import 'profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';
  final List<String> _selectedProducts = [];
  final List<String> _selectedBrands = [];
  final List<String> _selectedLocations = [];

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> filtered = allProducts;

    if (_selectedProducts.isNotEmpty) {
      filtered = filtered
          .where((product) =>
              _selectedProducts.contains(product['name'].toString()))
          .toList();
    }

    if (_selectedBrands.isNotEmpty) {
      filtered = filtered
          .where((product) =>
              _selectedBrands.contains(product['brand'].toString()))
          .toList();
    }

    if (_selectedLocations.isNotEmpty) {
      filtered = filtered
          .where((product) =>
              _selectedLocations.contains(product['location'].toString()))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((product) => product['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _updateFilters(
      List<String> products, List<String> brands, List<String> locations) {
    setState(() {
      _selectedProducts
        ..clear()
        ..addAll(products);
      _selectedBrands
        ..clear()
        ..addAll(brands);
      _selectedLocations
        ..clear()
        ..addAll(locations);
    });
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        Searchfilters(
          searchQuery: _searchQuery,
          selectedProducts: _selectedProducts,
          selectedBrands: _selectedBrands,
          selectedLocations: _selectedLocations,
          onSearchChanged: _updateSearchQuery,
          onFiltersApplied: _updateFilters,
        ),
        Expanded(
          child: _filteredProducts.isEmpty
              ? Center(child: Text('No products found'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: (_filteredProducts.length / 2).ceil(),
                  itemBuilder: (context, index) {
                    final firstProductIndex = index * 2;
                    final secondProductIndex = firstProductIndex + 1;
                    return Row(
                      children: [
                        Expanded(
                          child: _buildProductCard(
                            _filteredProducts[firstProductIndex]['name'],
                            _filteredProducts[firstProductIndex]['brand'],
                            _filteredProducts[firstProductIndex]['image'],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: secondProductIndex < _filteredProducts.length
                              ? _buildProductCard(
                                  _filteredProducts[secondProductIndex]['name'],
                                  _filteredProducts[secondProductIndex]
                                      ['brand'],
                                  _filteredProducts[secondProductIndex]
                                      ['image'],
                                )
                              : SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  final List<Widget> _screens = [
    Container(),
    const EnquiryScreen(),
    ProfileScreen(),
  ];

  PreferredSizeWidget _getAppBar() {
    return MainAppBar(
      title: 'Products',
      showProfileIcon: true,
      showNotificationIcon: false,
      onProfileTap: () {
        _showBottomPopup(context);
      },
    );
  }

  void _showBottomPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.blue,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person, color: Colors.white),
              title: Text(
                'Profile (Last updated: 26 Mar 2024)',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text('ISI Info', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.support, color: Colors.white),
              title: Text('Support', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 16),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _screens[0] = _buildDashboardContent();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _getAppBar(),
      body: _screens[_selectedIndex],
      bottomNavigationBar: MainBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildProductCard(String name, String brand, String imagePath) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image,
                        size: 50, color: Colors.grey);
                  },
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(brand,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  print('Call button pressed for $name');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Call', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
