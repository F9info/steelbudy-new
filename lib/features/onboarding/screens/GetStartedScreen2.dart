import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GetStartedScreen2 extends StatelessWidget {
  const GetStartedScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Logo at the top
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: SvgPicture.asset(
              'assets/images/logo.svg', // Use the same logo as in GetStartedScreen1
              placeholderBuilder: (BuildContext context) =>
                  const CircularProgressIndicator(),
              height: 100, // Match the height used in GetStartedScreen1
              semanticsLabel: 'SteelBuddy Logo', // Accessibility label
            ),
          ),
          // Main content (text and illustration)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Purchase products,',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'find the steel you need!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SvgPicture.asset(
                    'assets/images/welcomescreen2.svg',
                    placeholderBuilder: (BuildContext context) =>
                        const CircularProgressIndicator(),
                    height: 200, // Adjust the height as needed
                    semanticsLabel: 'Purchase Illustration',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
