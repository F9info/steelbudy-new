import 'package:flutter/material.dart';

class AddProductPopup extends StatefulWidget {
  const AddProductPopup({super.key});

  @override
  State<AddProductPopup> createState() => _AddProductPopupState();
}

class _AddProductPopupState extends State<AddProductPopup> {
  // State for selected products and their details
  final Map<String, bool> _selectedProducts = {
    '10MM Rebar': false,
    '12MM Rebar': false,
    '16MM Rebar': false,
    '20MM Rebar': false,
    '25MM Rebar': false,
    '32MM Rebar': false,
    '8MM Rebar': false,
    'MS Binding Wire': false,
    'Nails': false,
  };

  final Map<String, String?> _selectedBrands = {};
  final Map<String, String?> _quantities = {};
  final Map<String, String?> _pieces = {};

  final List<String> _brands = ['Brand A', 'Brand B', 'Brand C']; // Example brands

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            children: const [
              Expanded(child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text('Brand', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text('Qty (Tons)', style: TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text('Pieces', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          const Divider(),
          // Product Rows
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: _selectedProducts.keys.map((product) {
                return Row(
                  children: [
                    Checkbox(
                      value: _selectedProducts[product],
                      onChanged: (value) {
                        setState(() {
                          _selectedProducts[product] = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(product),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Select Brand'),
                        value: _selectedBrands[product],
                        items: _brands
                            .map((brand) => DropdownMenuItem(
                                  value: brand,
                                  child: Text(brand),
                                ))
                            .toList(),
                        onChanged: _selectedProducts[product]!
                            ? (value) {
                                setState(() {
                                  _selectedBrands[product] = value;
                                });
                              }
                            : null,
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        enabled: _selectedProducts[product],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _quantities[product] = value;
                        },
                      ),
                    ),
                    Expanded(
                      child: product == 'MS Binding Wire' || product == 'Nails'
                          ? const Text('N/A', textAlign: TextAlign.center)
                          : TextFormField(
                              enabled: _selectedProducts[product],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                _pieces[product] = value;
                              },
                            ),
                    ),
                  ],
                );
              }).toList(),
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
                // Return selected products and their details
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
        ],
      ),
    );
  }
}