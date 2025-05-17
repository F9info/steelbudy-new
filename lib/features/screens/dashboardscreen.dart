import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/widgets/mainappbar.dart';
import '../dashboard/widgets/mainbottombar.dart';
import '../dashboard/widgets/searchfilters.dart';
import 'enquiry.dart';
import '../../data/productlist.dart';
import 'profile.dart';
import '../../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  List<Map<String, dynamic>> _getFilteredProducts(
    WidgetRef ref,
    List<Map<String, dynamic>> allProducts,
  ) {
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    final selectedProducts = ref.watch(selectedProductsProvider);
    final selectedBrands = ref.watch(selectedBrandsProvider);
    final selectedLocations = ref.watch(selectedLocationsProvider);

    // Use lazy evaluation with Iterable
    final filtered = allProducts.where((product) {
      final productName = product['name'].toString();
      final productBrand = product['brand'].toString();
      final productLocation = product['location'].toString();

      // Check selected products
      if (selectedProducts.isNotEmpty &&
          !selectedProducts.contains(productName)) {
        return false;
      }

      // Check selected brands
      if (selectedBrands.isNotEmpty && !selectedBrands.contains(productBrand)) {
        return false;
      }

      // Check selected locations
      if (selectedLocations.isNotEmpty &&
          !selectedLocations.contains(productLocation)) {
        return false;
      }

      // Check search query
      if (searchQuery.isNotEmpty &&
          !productName.toLowerCase().contains(searchQuery)) {
        return false;
      }

      return true;
    });

    // Convert to List only when needed
    return filtered.toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final filteredProducts = _getFilteredProducts(ref, allProducts);

    void _updateSearchQuery(String query) {
      ref.read(searchQueryProvider.notifier).state = query;
    }

    void _updateFilters(
        List<String> products, List<String> brands, List<String> locations) {
      ref.read(selectedProductsProvider.notifier).state = products;
      ref.read(selectedBrandsProvider.notifier).state = brands;
      ref.read(selectedLocationsProvider.notifier).state = locations;
    }

    Widget _buildDashboardContent() {
      return Column(
        children: [
          Searchfilters(
            searchQuery: ref.watch(searchQueryProvider),
            selectedProducts: ref.watch(selectedProductsProvider),
            selectedBrands: ref.watch(selectedBrandsProvider),
            selectedLocations: ref.watch(selectedLocationsProvider),
            onSearchChanged: _updateSearchQuery,
            onFiltersApplied: _updateFilters,
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(child: Text('No products found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: (filteredProducts.length / 2).ceil(),
                    itemBuilder: (context, index) {
                      final firstProductIndex = index * 2;
                      final secondProductIndex = firstProductIndex + 1;
                      return Row(
                        children: [
                          Expanded(
                            child: _buildProductCard(
                              filteredProducts[firstProductIndex]['name'],
                              filteredProducts[firstProductIndex]['brand'],
                              filteredProducts[firstProductIndex]['image'],
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: secondProductIndex < filteredProducts.length
                                ? _buildProductCard(
                                    filteredProducts[secondProductIndex]
                                        ['name'],
                                    filteredProducts[secondProductIndex]
                                        ['brand'],
                                    filteredProducts[secondProductIndex]
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _getAppBar(),
      body: selectedIndex == 0
          ? _buildDashboardContent()
          : selectedIndex == 1
              ? const EnquiryScreen()
              : ProfileScreen(),
      bottomNavigationBar: MainBottomBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
        },
      ),
    );
  }

  Widget _buildProductCard(String? name, String? brand, String? imagePath) {
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
                child: imagePath != null && imagePath.isNotEmpty
                    ? Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.broken_image,
                              size: 50, color: Colors.grey);
                        },
                      )
                    : Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
            SizedBox(height: 8),
            Text(
              name ?? 'Unknown Product',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  brand ?? 'Unknown Brand',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: name != null
                    ? () {
                        print('Call button pressed for $name');
                      }
                    : null, // Disable button if name is null
                style: ElevatedButton.styleFrom(
                  backgroundColor: name != null ? Colors.blue : Colors.grey,
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
