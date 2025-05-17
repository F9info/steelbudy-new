import 'package:flutter_riverpod/flutter_riverpod.dart';

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected filters providers
final selectedProductsProvider = StateProvider<List<String>>((ref) => []);
final selectedBrandsProvider = StateProvider<List<String>>((ref) => []);
final selectedLocationsProvider = StateProvider<List<String>>((ref) => []);

// Selected index for bottom navigation
final selectedIndexProvider = StateProvider<int>((ref) => 0);
