import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  // Sample product data with additional fields for filtering
  final List<Map<String, dynamic>> _allProducts = [
    {
      'name': '12MM REBAR',
      'brand': 'Simhadri TMT',
      'image': 'assets/images/12mm_rebar.png',
      'category': 'Steel'
    },
    {
      'name': '19MM REBAR',
      'brand': 'Vizag Profiles',
      'image': 'assets/images/19mm_rebar.png',
      'category': 'Steel'
    },
    {
      'name': '20MM REBAR',
      'brand': 'Simhadri TMT',
      'image': 'assets/images/20mm_rebar.png',
      'category': 'Steel'
    },
    {
      'name': '32MM REBAR',
      'brand': 'Simhadri TMT',
      'image': 'assets/images/32mm_rebar.png',
      'category': 'Steel'
    },
    {
      'name': '8MM REBAR',
      'brand': 'Vizag Profiles',
      'image': 'assets/images/8mm_rebar.png',
      'category': 'Steel'
    },
    {
      'name': 'BINDING WIRE',
      'brand': 'Simhadri TMT',
      'image': 'assets/images/binding_wire.png',
      'category': 'Wire'
    },
    {
      'name': '10MM REBAR',
      'brand': 'Simhadri TMT',
      'image': 'assets/images/10mm_rebar.png',
      'category': 'Steel'
    },
    {
      'name': '16MM REBAR',
      'brand': 'Simhadri TMT',
      'image': 'assets/images/16mm_rebar.png',
      'category': 'Steel'
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> filtered = _allProducts;

    // Apply category filter
    if (_selectedCategoryIndex != 0) {
      // 0 is "All"
      if (_selectedCategoryIndex == 1) {
        // Products (e.g., filter by category "Steel")
        filtered = filtered
            .where((product) => product['category'] == 'Steel')
            .toList();
      } else if (_selectedCategoryIndex == 2) {
        // Brands (e.g., filter by brand "Simhadri TMT")
        filtered = filtered
            .where((product) => product['brand'] == 'Simhadri TMT')
            .toList();
      } else if (_selectedCategoryIndex == 3) {
        // Locations (e.g., filter by brand "Vizag Profiles")
        filtered = filtered
            .where((product) => product['brand'] == 'Vizag Profiles')
            .toList();
      }
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      print('Search Query: $_searchQuery'); // Debug log
      filtered = filtered
          .where((product) => product['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
      print(
          'Filtered Products: ${filtered.map((p) => p['name']).toList()}'); // Debug log
    }

    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text
            .trim(); // Trim to remove leading/trailing spaces
        print('Search Controller Updated: $_searchQuery'); // Debug log
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Products',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for products',
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Categories
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
          // Products List
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text('No products found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: (_filteredProducts.length / 2)
                        .ceil(), // Two products per row
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
                                    _filteredProducts[secondProductIndex]
                                        ['name'],
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Enquiry',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Me',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildCategoryChip(String label, int index) {
    bool isSelected = _selectedCategoryIndex == index;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedCategoryIndex = index;
          });
        },
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue,
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
            // Product Image
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
            const SizedBox(height: 8),
            // Product Name
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            // Brand with Radio Button
            Row(
              children: [
                Radio(
                  value: false,
                  groupValue: true,
                  onChanged: (value) {},
                  activeColor: Colors.blue,
                ),
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
            // Call Button
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
