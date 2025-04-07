// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../widgets/mainappbar.dart';
import '../widgets/mainbottombar.dart';
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
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Use the imported product list
  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> filtered = allProducts;

    if (_selectedCategoryIndex != 0) {
      if (_selectedCategoryIndex == 1) {
        filtered = filtered
            .where((product) => product['category'] == 'Steel')
            .toList();
      } else if (_selectedCategoryIndex == 2) {
        filtered = filtered
            .where((product) => product['brand'] == 'Simhadri TMT')
            .toList();
      } else if (_selectedCategoryIndex == 3) {
        filtered = filtered
            .where((product) => product['brand'] == 'Vizag Profiles')
            .toList();
      }
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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildDashboardContent() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for products...',
              suffixIcon: const Icon(Icons.search,
                  color: Colors.blue), // Moved icon to right
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: Colors.blue), // Blue border as per screenshot
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Colors.blue, width: 2), // Focused state
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue), // Default state
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip('All', 0),
              _buildCategoryChip('Products', 1),
              _buildCategoryChip('Brands', 2),
              _buildCategoryChip('Locations', 3),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _filteredProducts.isEmpty
              ? const Center(child: Text('No products found'))
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: secondProductIndex < _filteredProducts.length
                              ? _buildProductCard(
                                  _filteredProducts[secondProductIndex]['name'],
                                  _filteredProducts[secondProductIndex]
                                      ['brand'],
                                  _filteredProducts[secondProductIndex]
                                      ['image'],
                                )
                              : const SizedBox.shrink(),
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
    Container(), // Will be replaced by _buildDashboardContent()
    const EnquiryScreen(),
    ProfileScreen(),
  ];

  // Adjusted app bar to match screenshot design
  PreferredSizeWidget _getAppBar() {
    return MainAppBar(
      title: 'Products',
      showProfileIcon: false,
      showNotificationIcon: true,
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
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text(
                'Profile (Last updated: 26 Mar 2024)',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title:
                  const Text('ISI Info', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.support, color: Colors.white),
              title:
                  const Text('Support', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _getAppBar(),
      body: _selectedIndex == 0
          ? _buildDashboardContent()
          : _screens[_selectedIndex],
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

  Widget _buildCategoryChip(String label, int index) {
    bool isSelected = _selectedCategoryIndex == index;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedCategoryIndex = index;
          });
        },
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.blue[100],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
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
                    return const Icon(Icons.broken_image,
                        size: 50, color: Colors.grey);
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.circle,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  brand,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity, // Make Call button full width
              child: ElevatedButton(
                onPressed: () {
                  // Handle call action (preserving original functionality)
                  print('Call button pressed for $name');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Call',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
