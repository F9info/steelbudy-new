import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:steel_buddy/services/api_service.dart';
import 'package:flutter/services.dart';

class AddProductPopup extends StatefulWidget {
  const AddProductPopup({super.key});

  @override
  State<AddProductPopup> createState() => _AddProductPopupState();
}

class _AddProductPopupState extends State<AddProductPopup> {
  Map<String, bool> _selectedProducts = {};
  Map<String, String?> _selectedBrands = {};
  Map<String, String?> _quantities = {};
  Map<String, String?> _pieces = {};
  List<String> _allBrands = [];
  Map<String, dynamic> _productIdMap = {}; // Store product name to ID mapping
  Map<String, dynamic> _brandIdMap = {}; // Store brand name to ID mapping
  Map<String, int> _productPiecesMap = {}; // Store product name to pieces field
  bool _isLoading = true;

  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, TextEditingController> _piecesControllers = {};

  static const String baseUrl = 'https://steelbuddyapi.cloudecommerce.in/api';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final productsData = await ApiService.getProductTypes();
      final products = productsData
          .where((product) =>
              product['publish'] == 1 &&
              product.containsKey('name') &&
              product.containsKey('id'))
          .toList();

      final brandsData = await ApiService.getBrands();
      final brands = (brandsData as List)
          .where((brand) => brand.name != null && brand.id != null)
          .toList();

      setState(() {
        _selectedProducts = {
          for (var product in products) product['name'] as String: false
        };
        _productIdMap = {
          for (var product in products) product['name'] as String: product['id']
        };
        _allBrands = brands.map((brand) => brand.name as String).toList();
        _brandIdMap = {
          for (var brand in brands) brand.name as String: brand.id
        };
        _productPiecesMap = {
          for (var product in products)
            product['name'] as String: product['pieces'] ?? 1
        };
        _isLoading = false;
        // Reset selected brands if not in the new _allBrands
        _selectedBrands.updateAll(
            (product, brand) => _allBrands.contains(brand) ? brand : null);
        // Initialize controllers
        for (var product in _selectedProducts.keys) {
          _quantityControllers[product] =
              TextEditingController(text: _quantities[product] ?? '');
          _piecesControllers[product] =
              TextEditingController(text: _pieces[product] ?? '');
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    for (var controller in _quantityControllers.values) {
      controller.dispose();
    }
    for (var controller in _piecesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Select Products, Brand & Enter Quantity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const {
                    0: FixedColumnWidth(40),
                    1: FixedColumnWidth(150),
                    2: FixedColumnWidth(120),
                    3: FixedColumnWidth(100),
                    4: FixedColumnWidth(100),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
                      children: [
                        SizedBox(),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Product',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Brand',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Qty (Tons)',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Pieces',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                    ..._selectedProducts.keys.map((product) {
                      final isSelected = _selectedProducts[product] ?? false;
                      final isQuantityEditable = isSelected;
                      final showPiecesInput = _productPiecesMap[product] != 0;
                      final isPiecesEditable = isSelected && showPiecesInput;

                      return TableRow(
                        children: [
                          Center(
                            child: Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  _selectedProducts[product] = value ?? false;
                                  if (!value!) {
                                    _quantities[product] = null;
                                    _pieces[product] = null;
                                    _quantityControllers[product]?.text = '';
                                    _piecesControllers[product]?.text = '';
                                  }
                                });
                              },
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(product,
                                  style: const TextStyle(fontSize: 13)),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text('Select Brand',
                                  style: TextStyle(fontSize: 13)),
                              value: _selectedBrands[product],
                              items: _allBrands.map((brand) {
                                return DropdownMenuItem(
                                  value: brand,
                                  child: Text(brand,
                                      style: const TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: isSelected
                                  ? (value) {
                                      setState(() {
                                        _selectedBrands[product] = value;
                                      });
                                    }
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              enabled: isQuantityEditable,
                              readOnly: !isQuantityEditable,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              style: const TextStyle(fontSize: 13),
                              controller: _quantityControllers[product],
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^[0-9]*\.?[0-9]*')),
                              ],
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 8.0),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4.0)),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4.0)),
                                ),
                                disabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 0.5),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4.0)),
                                ),
                                filled: !isQuantityEditable,
                                fillColor: !isQuantityEditable
                                    ? Colors.grey[200]
                                    : null,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _quantities[product] = value;
                                  if (value.isNotEmpty) {
                                    _pieces[product] = null;
                                    _piecesControllers[product]?.text = '';
                                  }
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: !showPiecesInput
                                ? const Center(
                                    child: Text('N/A',
                                        style: TextStyle(fontSize: 13)))
                                : TextFormField(
                                    enabled: isPiecesEditable,
                                    readOnly: !isPiecesEditable,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    style: const TextStyle(fontSize: 13),
                                    controller: _piecesControllers[product],
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^[0-9]*\.?[0-9]*')),
                                    ],
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 8.0),
                                      border: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4.0)),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4.0)),
                                      ),
                                      disabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 0.5),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4.0)),
                                      ),
                                      filled: !isPiecesEditable,
                                      fillColor: !isPiecesEditable
                                          ? Colors.grey[200]
                                          : null,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _pieces[product] = value;
                                        if (value.isNotEmpty) {
                                          _quantities[product] = null;
                                          _quantityControllers[product]?.text =
                                              '';
                                        }
                                      });
                                    },
                                  ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Validation
                    final selected = _selectedProducts.entries
                        .where((e) => e.value)
                        .map((e) => e.key)
                        .toList();
                    if (selected.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please select at least one product.')),
                      );
                      return;
                    }
                    for (final product in selected) {
                      final brand = _selectedBrands[product];
                      final qty = _quantities[product];
                      final pcs = _pieces[product];
                      if (brand == null || brand.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Please select a brand for $product.')),
                        );
                        return;
                      }
                      if ((qty == null || qty.isEmpty) &&
                          (pcs == null || pcs.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Please enter quantity or pieces for $product.')),
                        );
                        return;
                      }
                      if ((qty != null && qty.isNotEmpty) &&
                          (pcs != null && pcs.isNotEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Please enter either quantity or pieces for $product, not both.')),
                        );
                        return;
                      }
                    }
                    // Prepare selected products list
                    final List<Map<String, dynamic>> selectedProducts = selected
                        .map((product) => {
                              'product': product,
                              'brand': _selectedBrands[product],
                              'qty': _quantities[product],
                              'pieces': _pieces[product],
                              'productId': _productIdMap[product],
                              'brandId': _brandIdMap[_selectedBrands[product]],
                            })
                        .toList();
                    Navigator.pop(context, selectedProducts);
                  },
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
