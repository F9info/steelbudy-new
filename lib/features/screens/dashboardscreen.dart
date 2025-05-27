import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:steel_budy/features/dashboard/widgets/mainappbar.dart';
import 'package:steel_budy/features/dashboard/widgets/searchfilters.dart';
import 'package:steel_budy/features/screens/enquiry.dart';
import 'package:steel_budy/features/screens/profile.dart';
import 'package:steel_budy/features/screens/notifications.dart';

import 'package:steel_budy/providers/dashboard_providers.dart';
import 'package:steel_budy/models/product_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  List<Product> _getFilteredProducts(
    WidgetRef ref,
    List<Product> allProducts,
  ) {
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
    final selectedProducts = ref.watch(selectedProductsProvider);
    final selectedBrands = ref.watch(selectedBrandsProvider);
    final selectedLocations = ref.watch(selectedLocationsProvider);

    return allProducts.where((product) {
      final productName = product.name;
      final productBrand = product.brand;
      final productLocation = product.location;

      if (selectedProducts.isNotEmpty && !selectedProducts.contains(productName)) {
        return false;
      }

      if (selectedBrands.isNotEmpty && !selectedBrands.contains(productBrand)) {
        return false;
      }

      if (selectedLocations.isNotEmpty && !selectedLocations.contains(productLocation)) {
        return false;
      }

      if (searchQuery.isNotEmpty && !productName.toLowerCase().contains(searchQuery)) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final productsAsync = ref.watch(productsProvider);

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
      return productsAsync.when(
        data: (products) {
          final filteredProducts = _getFilteredProducts(ref, products);
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
                    ? const Center(child: Text('No products found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: (filteredProducts.length / 2).ceil(),
                        itemBuilder: (context, index) {
                          final firstProductIndex = index * 2;
                          final secondProductIndex = firstProductIndex + 1;
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _buildProductCard(
                                    filteredProducts[firstProductIndex].name,
                                    filteredProducts[firstProductIndex].brand,
                                    filteredProducts[firstProductIndex].image,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: secondProductIndex < filteredProducts.length
                                      ? _buildProductCard(
                                          filteredProducts[secondProductIndex].name,
                                          filteredProducts[secondProductIndex].brand,
                                          filteredProducts[secondProductIndex].image,
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      );
    }

    PreferredSizeWidget _getAppBar() {
      return MainAppBar(
        title: 'Products sss',
        onNotificationTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationScreen(), // Navigate directly to NotificationScreen
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      body: selectedIndex == 0
          ? _buildDashboardContent()
          : selectedIndex == 1
              ? const EnquiryScreen()
              : ProfileScreen(),
    
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
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
                          ? Image.network(
                              imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image,
                                    size: 50, color: Colors.grey);
                              },
                            )
                          : const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name ?? 'Unknown Product',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Centers the children horizontally
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    brand ?? 'Unknown Brand',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center, // Centers the children horizontally
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 1),
        ),
      ),
      const SizedBox(width: 4),
      Text(
        brand ?? 'Unknown Brand',
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
    ],
  ),
),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: name != null
                  ? () {
                      print('Call button pressed for $name');
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: name != null ? Colors.blue : Colors.grey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Call', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}