import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/mainappbar.dart';
import '../widgets/mainbottombar.dart';
import 'enquiry.dart';
import '../../../data.dart/productlist.dart';
import 'profile.dart'; // Import the product list

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
        const SizedBox(height: 8), // Adjust for app bar padding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
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
    const ProfileScreen(),
  ];

  // Fix the _getAppBar method to return a PreferredSizeWidget
  PreferredSizeWidget _getAppBar() {
    switch (_selectedIndex) {
      case 0:
        return MainAppBar(
          title: 'Dashboard',
          showProfileIcon: false,
          showNotificationIcon: true,
        );
      case 1:
        return MainAppBar(
          title: 'Enquiry',
          showProfileIcon: false,
          showNotificationIcon: true,
        );
      case 2:
        return MainAppBar(
          title: 'Profile',
          showProfileIcon: false,
          showNotificationIcon: true,
        );
      default:
        return MainAppBar(
          title: 'Dashboard',
          showProfileIcon: false,
          showNotificationIcon: true,
        );
    }
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
                Navigator.pop(context); // Close the popup
                // Handle Profile action
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title:
                  const Text('ISI Info', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Close the popup
                // Handle ISI Info action
              },
            ),
            ListTile(
              leading: const Icon(Icons.support, color: Colors.white),
              title:
                  const Text('Support', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Close the popup
                // Handle Support action
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Close the popup
                // Handle Logout action
              },
            ),
            const SizedBox(height: 16), // Padding at the bottom
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
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
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image,
                            size: 50, color: Colors.grey);
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      _showBottomPopup(context); // Show the bottom popup
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'More',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
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
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle call action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E90FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'Call',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
