import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/dashboard_providers.dart';

class Searchfilters extends StatefulWidget {
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
  State<Searchfilters> createState() => _SearchfiltersState();
}

class _SearchfiltersState extends State<Searchfilters> {
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

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            return optionsAsync.when(
              data: (options) {
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
                          child: ListView(
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
                                    List<String> updatedProducts =
                                        widget.selectedProducts;
                                    List<String> updatedBrands = widget.selectedBrands;
                                    List<String> updatedLocations =
                                        widget.selectedLocations;

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
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            );
          },
        );
      },
    );
  }

  void _showProductListPopup(WidgetRef ref) {
    _showMultiSelectBottomSheet(
      title: "Select Products",
      optionsAsync: ref.watch(productNamesProvider),
      selectedItems: widget.selectedProducts,
      filterType: 'Products',
    );
  }

  void _showBrandListPopup(WidgetRef ref) {
    _showMultiSelectBottomSheet(
      title: "Select Brands",
      optionsAsync: ref.watch(brandsProvider),
      selectedItems: widget.selectedBrands,
      filterType: 'Brands',
    );
  }

  void _showLocationListPopup(WidgetRef ref) {
    _showMultiSelectBottomSheet(
      title: "Select Locations",
      optionsAsync: ref.watch(locationsProvider),
      selectedItems: widget.selectedLocations,
      filterType: 'Locations',
    );
  }

  Widget _buildCategoryChip(String label, int index, WidgetRef ref) {
    bool isSelected = _selectedCategoryIndex == index;
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
            } else if (label == 'Products') {
              _showProductListPopup(ref);
            } else if (label == 'Brands') {
              _showBrandListPopup(ref);
            } else if (label == 'Locations') {
              _showLocationListPopup(ref);
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
    return Consumer(
      builder: (context, ref, child) {
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
                  _buildCategoryChip('All', 0, ref),
                  _buildCategoryChip('Products', 1, ref),
                  _buildCategoryChip('Brands', 2, ref),
                  _buildCategoryChip('Locations', 3, ref),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}