import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GetStartedScreen1 extends StatelessWidget {
  const GetStartedScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                placeholderBuilder: (BuildContext context) =>
                    const CircularProgressIndicator(),
                height: 100, // Adjust the height as needed
                semanticsLabel: 'Logo', // Add semantics label for accessibility
              ),
            ),
            const SizedBox(height: 20), // Add some spacing
            Text(
              'Simplifying steel transactions with ease!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center, // Center align the text
            ),
          ],
        ),
      ),
    );
  }
}
