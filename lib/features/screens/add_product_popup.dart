import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  List<String> _brands = [];
  bool _isLoading = true;

  static const String baseUrl = 'https://steelbuddyapi.cloudecommerce.in/api';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Fetch products
  Future<List<dynamic>> _getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/product-types'));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List) {
          return jsonResponse;
        } else {
          throw Exception('Invalid product data format');
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  // Fetch brands
  Future<Map<String, dynamic>> _getBrands() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/brands'));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('brands')) {
          return jsonResponse;
        } else {
          throw Exception('Invalid brand data format');
        }
      } else {
        throw Exception('Failed to load brands: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load brands: $e');
    }
  }

  Future<void> _fetchData() async {
    try {
      final productsData = await _getProducts();
      final products = productsData
          .where((product) => product['publish'] == 1 && product.containsKey('name'))
          .map((product) => product['name'] as String)
          .toList();

      final brandsData = await _getBrands();
      final brands = (brandsData['brands'] as List)
          .where((brand) => brand['publish'] == 1 && brand.containsKey('name'))
          .map((brand) => brand['name'] as String)
          .toList();

      setState(() {
        _selectedProducts = {for (var product in products) product: false};
        _brands = brands;
        _isLoading = false;
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
                            child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Qty (Tons)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Pieces', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                    ..._selectedProducts.keys.map((product) {
                      final isSelected = _selectedProducts[product] ?? false;
                      final quantityValue = _quantities[product] ?? '';
                      final piecesValue = _pieces[product] ?? '';
                      final isQuantityEditable = isSelected;
                      final isPiecesEditable = isSelected && !product.contains('MS Binding Wire') && !product.contains('Nails');

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
                                  }
                                });
                              },
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Text(product, style: const TextStyle(fontSize: 13)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text('Select Brand', style: TextStyle(fontSize: 13)),
                              value: _selectedBrands[product],
                              items: _brands.map((brand) {
                                return DropdownMenuItem(
                                  value: brand,
                                  child: Text(brand, style: const TextStyle(fontSize: 13)),
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
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13),
                              controller: TextEditingController(text: quantityValue),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                ),
                                disabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey, width: 0.5),
                                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                ),
                                filled: !isQuantityEditable,
                                fillColor: !isQuantityEditable ? Colors.grey[200] : null,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _quantities[product] = value;
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: product.contains('MS Binding Wire') || product.contains('Nails')
                                ? const Center(child: Text('N/A', style: TextStyle(fontSize: 13)))
                                : TextFormField(
                                    enabled: isPiecesEditable,
                                    readOnly: !isPiecesEditable,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontSize: 13),
                                    controller: TextEditingController(text: piecesValue),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey),
                                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey),
                                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                      ),
                                      disabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.grey, width: 0.5),
                                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                                      ),
                                      filled: !isPiecesEditable,
                                      fillColor: !isPiecesEditable ? Colors.grey[200] : null,
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _pieces[product] = value;
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
                    Navigator.pop(context, {
                      'selectedProducts': _selectedProducts,
                      'brands': _selectedBrands,
                      'quantities': _quantities,
                      'pieces': _pieces,
                    });
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