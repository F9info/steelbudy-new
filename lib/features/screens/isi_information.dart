import 'package:flutter/material.dart';

class IsiInformation extends StatelessWidget {
  const IsiInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Title and Back Button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Expanded(
                  child: Text(
                    'ISI Information',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Spacer to balance the back button
              ],
            ),
          ),
          // Table with Horizontal and Vertical Scroll
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Expanded(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Table Header
                      Row(
                        children: [
                          Container(
                            width: 150,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.grey[200],
                            ),
                            child: const Text(
                              'Product',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: 120,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.grey[200],
                            ),
                            child: const Text(
                              'ISI No',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: 120,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.grey[200],
                            ),
                            child: const Text(
                              'License No',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: 100,
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.grey[200],
                            ),
                            child: const Text(
                              'Grade',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      // Table Data Rows
                      ...[
                        {'product': '10MM Rebar', 'isiNo': 'IS 1786', 'licenseNo': 'R/123456', 'grade': 'Fe 500'},
                        {'product': '12MM Rebar', 'isiNo': 'IS 1786', 'licenseNo': 'R/123457', 'grade': 'Fe 500'},
                        {'product': '16MM Rebar', 'isiNo': 'IS 1786', 'licenseNo': 'R/123458', 'grade': 'Fe 500'},
                        {'product': '20MM Rebar', 'isiNo': 'IS 1786', 'licenseNo': 'R/123459', 'grade': 'Fe 500'},
                        {'product': '25MM Rebar', 'isiNo': 'IS 1786', 'licenseNo': 'R/123460', 'grade': 'Fe 500'},
                        {'product': '32MM Rebar', 'isiNo': 'IS 1786', 'licenseNo': 'R/123461', 'grade': 'Fe 500'},
                        {'product': '8MM Rebar', 'isiNo': 'IS 1786', 'licenseNo': 'R/123462', 'grade': 'Fe 500'},
                        {'product': 'MS Binding Wire', 'isiNo': 'IS 280', 'licenseNo': 'R/123463', 'grade': 'N/A'},
                        {'product': 'Nails', 'isiNo': 'IS 723', 'licenseNo': 'R/123464', 'grade': 'N/A'},
                      ].map((item) {
                        return Row(
                          children: [
                            Container(
                              width: 150,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Text(item['product']!),
                            ),
                            Container(
                              width: 120,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Text(item['isiNo']!),
                            ),
                            Container(
                              width: 120,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Text(item['licenseNo']!),
                            ),
                            Container(
                              width: 100,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Text(item['grade']!),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}