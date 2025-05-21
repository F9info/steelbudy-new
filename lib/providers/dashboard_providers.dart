import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../models/product_model.dart';

// Provider for fetching products
final productsProvider = FutureProvider<List<Product>>((ref) async {
  return await ApiService.getProducts();
});

// Provider for fetching unique products (for filtering)
final productNamesProvider = FutureProvider<List<String>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  return products.map((product) => product.name).toSet().toList();
});

// Provider for fetching unique brands
final brandsProvider = FutureProvider<List<String>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  return products.map((product) => product.brand).toSet().toList();
});

// Provider for fetching unique locations
final locationsProvider = FutureProvider<List<String>>((ref) async {
  final products = await ref.watch(productsProvider.future);
  return products.map((product) => product.location).toSet().toList();
});

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for selected products (filter)
final selectedProductsProvider = StateProvider<List<String>>((ref) => []);

// Provider for selected brands (filter)
final selectedBrandsProvider = StateProvider<List<String>>((ref) => []);

// Provider for selected locations (filter)
final selectedLocationsProvider = StateProvider<List<String>>((ref) => []);

// Provider for selected bottom navigation index
final selectedIndexProvider = StateProvider<int>((ref) => 0);