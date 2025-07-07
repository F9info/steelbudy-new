import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/dashboard_providers.dart';

class Searchfilters extends ConsumerStatefulWidget {
  final String searchQuery;
  final List<String> selectedProducts;
  final List<String> selectedBrands;
  final List<String> selectedLocations;
  final Function(String) onSearchChanged;
  final Function(List<String>, List<String>, List<String>) onFiltersApplied;

  const Searchfilters({
    super.key,
    required this.searchQuery,
    required this.selectedProducts,
    required this.selectedBrands,
    required this.selectedLocations,
    required this.onSearchChanged,
    required this.onFiltersApplied,
  });

  @override
  ConsumerState<Searchfilters> createState() => _SearchfiltersState();
}

class _SearchfiltersState extends ConsumerState<Searchfilters> {
  late TextEditingController _searchController;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _searchController.addListener(() {
      widget.onSearchChanged(_searchController.text.trim());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showMultiSelectBottomSheet({
    required String title,
    required AsyncValue<List<String>> optionsAsync,
    required List<String> selectedItems,
    required String filterType,
  }) {
    List<String> tempSelected = List.from(selectedItems);

    // Invalidate the appropriate provider before showing the bottom sheet
    if (filterType == 'Products') {
      ref.invalidate(productNamesProvider);
    } else if (filterType == 'Brands') {
      ref.invalidate(brandsProvider);
    } else if (filterType == 'Locations') {
      ref.invalidate(locationsProvider);
    }

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            // Re-watch the provider to get the latest state after invalidation
            final updatedOptionsAsync = filterType == 'Products'
                ? ref.watch(productNamesProvider)
                : filterType == 'Brands'
                    ? ref.watch(brandsProvider)
                    : ref.watch(locationsProvider);

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    Expanded(
                      child: updatedOptionsAsync.when(
                        data: (options) {
                          return ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            children: options.map((option) {
                              return CheckboxListTile(
                                title: Text(option),
                                value: tempSelected.contains(option),
                                onChanged: (bool? selected) {
                                  setModalState(() {
                                    if (selected == true) {
                                      tempSelected.add(option);
                                    } else {
                                      tempSelected.remove(option);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, stack) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Error: $error'),
                              ElevatedButton(
                                onPressed: () {
                                  if (filterType == 'Products') {
                                    ref.invalidate(productNamesProvider);
                                  } else if (filterType == 'Brands') {
                                    ref.invalidate(brandsProvider);
                                  } else if (filterType == 'Locations') {
                                    ref.invalidate(locationsProvider);
                                  }
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.blue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                List<String> updatedProducts = widget.selectedProducts;
                                List<String> updatedBrands = widget.selectedBrands;
                                List<String> updatedLocations = widget.selectedLocations;

                                if (filterType == 'Products') {
                                  updatedProducts = tempSelected;
                                } else if (filterType == 'Brands') {
                                  updatedBrands = tempSelected;
                                } else if (filterType == 'Locations') {
                                  updatedLocations = tempSelected;
                                }

                                widget.onFiltersApplied(
                                  updatedProducts,
                                  updatedBrands,
                                  updatedLocations,
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Apply',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showProductListPopup() {
    _showMultiSelectBottomSheet(
      title: "Select Categories",
      optionsAsync: ref.watch(productNamesProvider),
      selectedItems: widget.selectedProducts,
      filterType: 'Products',
    );
  }

  void _showBrandListPopup() {
    _showMultiSelectBottomSheet(
      title: "Select Brands",
      optionsAsync: ref.watch(brandsProvider),
      selectedItems: widget.selectedBrands,
      filterType: 'Brands',
    );
  }

  void _showLocationListPopup() {
    _showMultiSelectBottomSheet(
      title: "Select Locations",
      optionsAsync: ref.watch(locationsProvider),
      selectedItems: widget.selectedLocations,
      filterType: 'Locations',
    );
  }

  Widget _buildCategoryChip(String label, int index) {
    bool isSelected = false;
    if (label == 'Categories') {
      isSelected = widget.selectedProducts.isNotEmpty;
    } else if (label == 'Brands') {
      isSelected = widget.selectedBrands.isNotEmpty;
    } else if (label == 'Locations') {
      isSelected = widget.selectedLocations.isNotEmpty;
    } else if (label == 'All') {
      isSelected = widget.selectedProducts.isEmpty &&
                   widget.selectedBrands.isEmpty &&
                   widget.selectedLocations.isEmpty;
    }
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          setState(() {
            _selectedCategoryIndex = index;
            if (label == 'All') {
              widget.onFiltersApplied([], [], []);
              _searchController.clear();
            } else if (label == 'Categories') {
              if (widget.selectedProducts.isNotEmpty) {
                widget.onFiltersApplied([], widget.selectedBrands, widget.selectedLocations);
              } else {
                _showProductListPopup();
              }
            } else if (label == 'Brands') {
              if (widget.selectedBrands.isNotEmpty) {
                widget.onFiltersApplied(widget.selectedProducts, [], widget.selectedLocations);
              } else {
                _showBrandListPopup();
              }
            } else if (label == 'Locations') {
              if (widget.selectedLocations.isNotEmpty) {
                widget.onFiltersApplied(widget.selectedProducts, widget.selectedBrands, []);
              } else {
                _showLocationListPopup();
              }
            }
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for products...',
              suffixIcon: const Icon(Icons.search, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue),
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
              _buildCategoryChip('Categories', 1),
              _buildCategoryChip('Brands', 2),
              _buildCategoryChip('Locations', 3),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}