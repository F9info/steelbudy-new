import 'package:flutter/material.dart';

class AddProductPopup extends StatefulWidget {
  const AddProductPopup({super.key});

  @override
  State<AddProductPopup> createState() => _AddProductPopupState();
}

class _AddProductPopupState extends State<AddProductPopup> {
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

  final List<String> _brands = ['Brand A', 'Brand B', 'Brand C'];

  @override
  Widget build(BuildContext context) {
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
                      return TableRow(
                        children: [
                          Center(
                            child: Checkbox(
                              value: _selectedProducts[product],
                              onChanged: (value) {
                                setState(() {
                                  _selectedProducts[product] = value!;
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
                              onChanged: _selectedProducts[product]!
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
                              enabled: _selectedProducts[product],
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              onChanged: (value) => _quantities[product] = value,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: product == 'MS Binding Wire' || product == 'Nails'
                                ? const Center(child: Text('N/A', style: TextStyle(fontSize: 13)))
                                : TextFormField(
                                    enabled: _selectedProducts[product],
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                    ),
                                    onChanged: (value) => _pieces[product] = value,
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
